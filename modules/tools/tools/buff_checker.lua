local _, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Access the Tools module
local Tools = VUI.tools

-- Register the tool in the available tools list
Tools.availableTools.buffChecker = {
    name = "Buff Checker",
    description = "Monitor food, buffs, flask and combat status",
    icon = "Interface\\Icons\\INV_Misc_Food_15",
    shortcut = "ALT-B",
    order = 2,
    enabled = true
}

-- Constants
local PLAYER_ENTERING_WORLD = "PLAYER_ENTERING_WORLD"
local UNIT_AURA = "UNIT_AURA"
local PLAYER_REGEN_DISABLED = "PLAYER_REGEN_DISABLED"
local PLAYER_REGEN_ENABLED = "PLAYER_REGEN_ENABLED"
local PLAYER_DEAD = "PLAYER_DEAD"
local PLAYER_ALIVE = "PLAYER_ALIVE"

-- Locals
local buffFrame
local isFrameMovable = false
local inCombat = false
local isDead = false

-- Buff types and their icons
local buffTypes = {
    food = {
        name = "Food",
        icon = "Interface\\Icons\\INV_Misc_Food_15",
        active = false,
        spellIds = {}  -- Will be populated at runtime with all Well Fed buffs
    },
    flask = {
        name = "Flask",
        icon = "Interface\\Icons\\INV_Alchemy_EndlessFlask_06",
        active = false,
        spellIds = {}  -- Will be populated at runtime with all flask buffs
    },
    battleShout = {
        name = "Battle Shout",
        icon = "Interface\\Icons\\Ability_Warrior_BattleShout",
        active = false,
        spellIds = {6673}
    },
    arcaneIntellect = {
        name = "Arcane Intellect",
        icon = "Interface\\Icons\\Spell_Holy_MagicalSentry",
        active = false,
        spellIds = {1459}
    },
    fortitude = {
        name = "Power Word: Fortitude",
        icon = "Interface\\Icons\\Spell_Holy_WordFortitude",
        active = false,
        spellIds = {21562}
    },
    bloodlust = {
        name = "Bloodlust/Heroism",
        icon = "Interface\\Icons\\Spell_Nature_BloodLust",
        active = false,
        spellIds = {2825, 32182, 80353, 264667}  -- Bloodlust, Heroism, Time Warp, Primal Rage
    }
}

-- Initialize frame
local function CreateBuffCheckerFrame()
    -- Main frame
    local frame = CreateFrame("Frame", "VUIBuffCheckerFrame", UIParent)
    frame:SetSize(200, 60)
    frame:SetPoint("TOP", UIParent, "TOP", 0, -200)
    frame:SetFrameStrata("MEDIUM")
    frame:SetMovable(true)
    frame:EnableMouse(false)
    frame:SetClampedToScreen(true)
    frame:SetUserPlaced(true)
    
    -- Apply themed backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    
    -- Apply theme colors
    local theme = VUI.db.profile.appearance.theme or "thunderstorm"
    local backdropColor = {r = 0.04, g = 0.04, b = 0.1, a = 0.7} -- Default Thunder Storm
    local borderColor = {r = 0.05, g = 0.62, b = 0.9, a = 1} -- Electric blue
    
    if theme == "phoenixflame" then
        backdropColor = {r = 0.1, g = 0.04, b = 0.02, a = 0.7} -- Dark red/brown
        borderColor = {r = 0.9, g = 0.3, b = 0.05, a = 1} -- Fiery orange
    elseif theme == "arcanemystic" then
        backdropColor = {r = 0.1, g = 0.04, b = 0.18, a = 0.7} -- Deep purple
        borderColor = {r = 0.61, g = 0.05, b = 0.9, a = 1} -- Violet
    elseif theme == "felenergy" then
        backdropColor = {r = 0.04, g = 0.1, b = 0.04, a = 0.7} -- Dark green
        borderColor = {r = 0.1, g = 0.9, b = 0.1, a = 1} -- Fel green
    end
    
    frame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
    frame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    
    -- Status Text
    frame.statusText = frame:CreateFontString(nil, "OVERLAY")
    frame.statusText:SetFont("Fonts\\ARIALN.TTF", 12, "OUTLINE")
    frame.statusText:SetPoint("TOP", frame, "TOP", 0, -10)
    frame.statusText:SetText("Ready")
    frame.statusText:SetTextColor(0, 1, 0)
    
    -- Buff Icons Container
    frame.buffsContainer = CreateFrame("Frame", nil, frame)
    frame.buffsContainer:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -25)
    frame.buffsContainer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    
    -- Create icon frames for each buff type
    local iconSize = 24
    local spacing = 6
    local totalWidth = 0
    
    frame.buffIcons = {}
    local i = 0
    for buffId, buffInfo in pairs(buffTypes) do
        local icon = CreateFrame("Frame", nil, frame.buffsContainer)
        icon:SetSize(iconSize, iconSize)
        
        -- Position the icon
        local xPos = i * (iconSize + spacing)
        icon:SetPoint("LEFT", frame.buffsContainer, "LEFT", xPos, 0)
        totalWidth = xPos + iconSize
        
        -- Icon texture
        icon.texture = icon:CreateTexture(nil, "ARTWORK")
        icon.texture:SetAllPoints()
        icon.texture:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Trim icon borders
        icon.texture:SetTexture(buffInfo.icon)
        
        -- Status overlay (red X for inactive, green check for active)
        icon.status = icon:CreateTexture(nil, "OVERLAY")
        icon.status:SetPoint("CENTER", icon, "CENTER", 0, 0)
        icon.status:SetSize(iconSize * 0.8, iconSize * 0.8)
        icon.status:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up") -- Red X
        icon.status:SetVertexColor(1, 0, 0, 0.8)
        
        -- Store icon in frame
        frame.buffIcons[buffId] = icon
        
        i = i + 1
    end
    
    -- Resize frame based on icons
    frame:SetWidth(math.max(totalWidth + 20, 150))
    
    -- Mouse handling for movement
    frame:SetScript("OnMouseDown", function(self, button)
        if isFrameMovable and button == "LeftButton" then
            self:StartMoving()
        end
    end)
    
    frame:SetScript("OnMouseUp", function(self, button)
        if isFrameMovable and button == "LeftButton" then
            self:StopMovingOrSizing()
            -- Save position
            local point, _, relativePoint, xOfs, yOfs = self:GetPoint()
            if VUI.db.profile.modules.tools.toolSettings.buffChecker then
                VUI.db.profile.modules.tools.toolSettings.buffChecker.position = {
                    point = point,
                    relativePoint = relativePoint,
                    xOfs = xOfs,
                    yOfs = yOfs
                }
            end
        end
    end)
    
    return frame
end

-- Check if a unit has a buff by ID
local function HasBuffById(unit, spellIds)
    if type(spellIds) ~= "table" then
        spellIds = {spellIds}
    end
    
    local i = 1
    local buffName, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i)
    
    while buffName do
        for _, id in ipairs(spellIds) do
            if spellId == id then
                return true
            end
        end
        
        i = i + 1
        buffName, _, _, _, _, _, _, _, _, spellId = UnitBuff(unit, i)
    end
    
    return false
end

-- Check if a buff name contains any of the specified terms
local function HasBuffByNameContaining(unit, terms)
    if type(terms) ~= "table" then
        terms = {terms}
    end
    
    local i = 1
    local buffName = UnitBuff(unit, i)
    
    while buffName do
        for _, term in ipairs(terms) do
            if buffName:lower():find(term:lower()) then
                return true
            end
        end
        
        i = i + 1
        buffName = UnitBuff(unit, i)
    end
    
    return false
end

-- Update buff statuses
local function UpdateBuffStatuses()
    if not buffFrame or not buffFrame.buffIcons then return end
    
    -- Check food buff
    buffTypes.food.active = HasBuffByNameContaining("player", {"Well Fed", "Food"})
    
    -- Check flask buff
    buffTypes.flask.active = HasBuffByNameContaining("player", {"Flask", "Elixir"})
    
    -- Check battle shout
    buffTypes.battleShout.active = HasBuffById("player", buffTypes.battleShout.spellIds)
    
    -- Check arcane intellect
    buffTypes.arcaneIntellect.active = HasBuffById("player", buffTypes.arcaneIntellect.spellIds)
    
    -- Check fortitude
    buffTypes.fortitude.active = HasBuffById("player", buffTypes.fortitude.spellIds)
    
    -- Check bloodlust/heroism
    buffTypes.bloodlust.active = HasBuffById("player", buffTypes.bloodlust.spellIds)
    
    -- Update UI
    for buffId, buffInfo in pairs(buffTypes) do
        local icon = buffFrame.buffIcons[buffId]
        if icon then
            if buffInfo.active then
                icon.status:SetTexture("Interface\\Buttons\\UI-CheckBox-Check") -- Green check
                icon.status:SetVertexColor(0, 1, 0, 0.8)
            else
                icon.status:SetTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up") -- Red X
                icon.status:SetVertexColor(1, 0, 0, 0.8)
            end
        end
    end
    
    -- Update status text
    if isDead then
        buffFrame.statusText:SetText("Dead")
        buffFrame.statusText:SetTextColor(1, 0, 0)
    elseif inCombat then
        buffFrame.statusText:SetText("In Combat")
        buffFrame.statusText:SetTextColor(1, 0.5, 0)
    else
        local allActive = true
        for _, buffInfo in pairs(buffTypes) do
            if not buffInfo.active and (buffInfo.name == "Food" or buffInfo.name == "Flask") then
                allActive = false
                break
            end
        end
        
        if allActive then
            buffFrame.statusText:SetText("Ready")
            buffFrame.statusText:SetTextColor(0, 1, 0)
        else
            buffFrame.statusText:SetText("Missing Buffs")
            buffFrame.statusText:SetTextColor(1, 1, 0)
        end
    end
end

-- Event handler
local function OnEvent(self, event, ...)
    if event == UNIT_AURA then
        local unit = ...
        if unit == "player" then
            UpdateBuffStatuses()
        end
    elseif event == PLAYER_ENTERING_WORLD then
        -- Check current status
        inCombat = UnitAffectingCombat("player")
        isDead = UnitIsDeadOrGhost("player")
        UpdateBuffStatuses()
    elseif event == PLAYER_REGEN_DISABLED then
        inCombat = true
        UpdateBuffStatuses()
    elseif event == PLAYER_REGEN_ENABLED then
        inCombat = false
        UpdateBuffStatuses()
    elseif event == PLAYER_DEAD then
        isDead = true
        UpdateBuffStatuses()
    elseif event == PLAYER_ALIVE then
        isDead = UnitIsDeadOrGhost("player")
        UpdateBuffStatuses()
    end
end

-- Apply saved position
local function ApplySavedPosition()
    if not buffFrame then return end
    
    local settings = VUI.db.profile.modules.tools.toolSettings.buffChecker
    if settings and settings.position then
        buffFrame:ClearAllPoints()
        buffFrame:SetPoint(
            settings.position.point or "TOP",
            UIParent,
            settings.position.relativePoint or "TOP",
            settings.position.xOfs or 0,
            settings.position.yOfs or -200
        )
    end
end

-- Tool initialization
function Tools:buffCheckerInitialize()
    -- Create the main frame if it doesn't exist
    if not buffFrame then
        buffFrame = CreateBuffCheckerFrame()
    end
    
    -- Setup defaults
    self:buffCheckerSetupDefaults()
    
    -- Apply saved position
    ApplySavedPosition()
    
    -- Toggle movable status based on settings
    isFrameMovable = VUI.db.profile.modules.tools.toolSettings.buffChecker.movable
    buffFrame:EnableMouse(isFrameMovable)
    
    -- Set visibility based on settings
    if VUI.db.profile.modules.tools.toolSettings.buffChecker.enabled then
        -- Create event frame if it doesn't exist
        if not self.buffCheckerEventFrame then
            self.buffCheckerEventFrame = CreateFrame("Frame")
            self.buffCheckerEventFrame:SetScript("OnEvent", OnEvent)
        end
        
        -- Register events
        self.buffCheckerEventFrame:RegisterEvent(UNIT_AURA)
        self.buffCheckerEventFrame:RegisterEvent(PLAYER_ENTERING_WORLD)
        self.buffCheckerEventFrame:RegisterEvent(PLAYER_REGEN_DISABLED)
        self.buffCheckerEventFrame:RegisterEvent(PLAYER_REGEN_ENABLED)
        self.buffCheckerEventFrame:RegisterEvent(PLAYER_DEAD)
        self.buffCheckerEventFrame:RegisterEvent(PLAYER_ALIVE)
        
        -- Check current status
        inCombat = UnitAffectingCombat("player")
        isDead = UnitIsDeadOrGhost("player")
        UpdateBuffStatuses()
        
        -- Show frame
        buffFrame:Show()
    else
        -- Unregister events if the tool is disabled
        if self.buffCheckerEventFrame then
            self.buffCheckerEventFrame:UnregisterAllEvents()
        end
        
        -- Hide frame
        buffFrame:Hide()
    end
    
    -- Register for theme changes
    if not Tools.themeCallbacks then
        Tools.themeCallbacks = {}
    end
    table.insert(Tools.themeCallbacks, function()
        if buffFrame then
            -- Apply theme colors
            local theme = VUI.db.profile.appearance.theme or "thunderstorm"
            local backdropColor = {r = 0.04, g = 0.04, b = 0.1, a = 0.7} -- Default Thunder Storm
            local borderColor = {r = 0.05, g = 0.62, b = 0.9, a = 1} -- Electric blue
            
            if theme == "phoenixflame" then
                backdropColor = {r = 0.1, g = 0.04, b = 0.02, a = 0.7} -- Dark red/brown
                borderColor = {r = 0.9, g = 0.3, b = 0.05, a = 1} -- Fiery orange
            elseif theme == "arcanemystic" then
                backdropColor = {r = 0.1, g = 0.04, b = 0.18, a = 0.7} -- Deep purple
                borderColor = {r = 0.61, g = 0.05, b = 0.9, a = 1} -- Violet
            elseif theme == "felenergy" then
                backdropColor = {r = 0.04, g = 0.1, b = 0.04, a = 0.7} -- Dark green
                borderColor = {r = 0.1, g = 0.9, b = 0.1, a = 1} -- Fel green
            end
            
            buffFrame:SetBackdropColor(backdropColor.r, backdropColor.g, backdropColor.b, backdropColor.a)
            buffFrame:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
        end
    end)
end

-- Tool disable
function Tools:buffCheckerDisable()
    -- Unregister events
    if self.buffCheckerEventFrame then
        self.buffCheckerEventFrame:UnregisterAllEvents()
    end
    
    -- Hide frame
    if buffFrame then
        buffFrame:Hide()
    end
end

-- Setup defaults
function Tools:buffCheckerSetupDefaults()
    -- Ensure the tool has default settings in the VUI database
    if not VUI.defaults.profile.modules.tools.toolSettings.buffChecker then
        VUI.defaults.profile.modules.tools.toolSettings.buffChecker = {
            enabled = true,
            movable = true,
            position = {
                point = "TOP",
                relativePoint = "TOP",
                xOfs = 0,
                yOfs = -200
            }
        }
    end
    
    -- Initialize settings if they don't exist
    if not VUI.db.profile.modules.tools.toolSettings.buffChecker then
        VUI.db.profile.modules.tools.toolSettings.buffChecker = VUI.defaults.profile.modules.tools.toolSettings.buffChecker
    end
end

-- Tool specific config
function Tools:buffCheckerConfig()
    return {
        movable = {
            type = "toggle",
            name = "Make Movable",
            desc = "Allow the Buff Checker to be moved by dragging",
            order = 10,
            width = "full",
            get = function() 
                return VUI.db.profile.modules.tools.toolSettings.buffChecker.movable 
            end,
            set = function(_, val) 
                VUI.db.profile.modules.tools.toolSettings.buffChecker.movable = val
                isFrameMovable = val
                if buffFrame then
                    buffFrame:EnableMouse(val)
                end
            end
        },
        resetPosition = {
            type = "execute",
            name = "Reset Position",
            desc = "Reset the Buff Checker to its default position",
            order = 20,
            width = "full",
            func = function()
                if buffFrame then
                    buffFrame:ClearAllPoints()
                    buffFrame:SetPoint("TOP", UIParent, "TOP", 0, -200)
                    
                    -- Save the new position
                    VUI.db.profile.modules.tools.toolSettings.buffChecker.position = {
                        point = "TOP",
                        relativePoint = "TOP",
                        xOfs = 0,
                        yOfs = -200
                    }
                end
            end
        },
        testMode = {
            type = "execute",
            name = "Toggle Test Mode",
            desc = "Show a test view of the Buff Checker with random buff states",
            order = 30,
            width = "full",
            func = function()
                if buffFrame then
                    -- Toggle test mode
                    local isInTestMode = buffFrame:GetScript("OnUpdate") ~= nil
                    
                    if isInTestMode then
                        -- Disable test mode
                        buffFrame:SetScript("OnUpdate", nil)
                        
                        -- Restore real buff states
                        inCombat = UnitAffectingCombat("player")
                        isDead = UnitIsDeadOrGhost("player")
                        UpdateBuffStatuses()
                    else
                        -- Enable test mode
                        buffFrame:SetScript("OnUpdate", function(self, elapsed)
                            -- Randomly change buff states every 2 seconds
                            self.testTimer = (self.testTimer or 0) + elapsed
                            if self.testTimer >= 2 then
                                self.testTimer = 0
                                
                                -- Randomly set buff states
                                for buffId, buffInfo in pairs(buffTypes) do
                                    buffInfo.active = (math.random(1, 100) > 50)
                                end
                                
                                -- Randomly set combat state
                                inCombat = (math.random(1, 100) > 70)
                                isDead = (math.random(1, 100) > 90)
                                
                                -- Update UI
                                UpdateBuffStatuses()
                            end
                        end)
                        
                        -- Show frame
                        buffFrame:Show()
                    end
                end
            end
        }
    }
end