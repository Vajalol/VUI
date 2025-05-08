local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()
local P = VUICD.Party
local T = {}
P.Test = T

-- Local variables
local testMembers = {
    { name = "TestWarrior", class = "WARRIOR", unit = "player", guid = "TestWarrior-GUID" },
    { name = "TestPaladin", class = "PALADIN", unit = "player", guid = "TestPaladin-GUID" },
    { name = "TestHunter", class = "HUNTER", unit = "player", guid = "TestHunter-GUID" },
    { name = "TestRogue", class = "ROGUE", unit = "player", guid = "TestRogue-GUID" },
    { name = "TestPriest", class = "PRIEST", unit = "player", guid = "TestPriest-GUID" }
}

local testSpells = {}
local testMode = false
local updateInterval = 0.5
local updateFrame = nil
local lastUpdate = 0

-- Initialize test module
function T:Initialize()
    -- Create update frame
    updateFrame = CreateFrame("Frame")
    updateFrame:SetScript("OnUpdate", function(_, elapsed)
        if not testMode then return end
        
        lastUpdate = lastUpdate + elapsed
        if lastUpdate > updateInterval then
            self:UpdateTestCooldowns()
            lastUpdate = 0
        end
    end)
    
    -- Initialize test spells
    self:InitializeTestSpells()
end

-- Initialize test spells for all classes
function T:InitializeTestSpells()
    wipe(testSpells)
    
    -- Create test spells for each class
    for className, spells in pairs(VUICD.SpellData) do
        if not testSpells[className] then
            testSpells[className] = {}
        end
        
        -- Add spells
        for _, spell in ipairs(spells) do
            local spellID = spell.id
            if spellID then
                testSpells[className][spellID] = {
                    id = spellID,
                    name = spell.name,
                    icon = spell.icon,
                    class = className,
                    duration = spell.duration or 30,
                    onCooldown = false,
                    remaining = 0,
                    start = 0
                }
            end
        end
    end
end

-- Enable test mode
function T:Enable()
    testMode = true
    P.testMode = true
    
    -- Add test members
    wipe(P.activeMembers)
    for _, member in ipairs(testMembers) do
        table.insert(P.activeMembers, member)
    end
    
    -- Reset test cooldowns
    self:ResetTestCooldowns()
    
    -- Update UI
    P:CreateMemberFrames()
    
    -- Start updating
    updateFrame:Show()
    
    print("|cff33ff99VUICD|r: Test mode |cff00ff00enabled|r")
end

-- Disable test mode
function T:Disable()
    testMode = false
    P.testMode = false
    
    -- Clear test members
    wipe(P.activeMembers)
    
    -- Update UI
    P:UpdateRoster()
    
    -- Stop updating
    updateFrame:Hide()
    
    print("|cff33ff99VUICD|r: Test mode |cffff0000disabled|r")
end

-- Toggle test mode
function T:Toggle()
    if testMode then
        self:Disable()
    else
        self:Enable()
    end
end

-- Reset test cooldowns
function T:ResetTestCooldowns()
    -- Clear all test cooldowns
    for className, spells in pairs(testSpells) do
        for spellID, spell in pairs(spells) do
            spell.onCooldown = false
            spell.remaining = 0
            spell.start = 0
        end
    end
end

-- Update test cooldowns
function T:UpdateTestCooldowns()
    local now = GetTime()
    
    -- Update existing cooldowns
    for className, spells in pairs(testSpells) do
        for spellID, spell in pairs(spells) do
            if spell.onCooldown then
                spell.remaining = (spell.start + spell.duration) - now
                if spell.remaining <= 0 then
                    spell.onCooldown = false
                    spell.remaining = 0
                end
            end
        end
    end
    
    -- Start random cooldowns
    for i, member in ipairs(testMembers) do
        if math.random(1, 100) <= 10 then -- 10% chance to start a cooldown
            local className = member.class
            local spells = testSpells[className]
            
            if spells then
                -- Get all spells that aren't on cooldown
                local availableSpells = {}
                for spellID, spell in pairs(spells) do
                    if not spell.onCooldown then
                        table.insert(availableSpells, spellID)
                    end
                end
                
                -- Start a random spell cooldown
                if #availableSpells > 0 then
                    local randomIndex = math.random(1, #availableSpells)
                    local randomSpellID = availableSpells[randomIndex]
                    
                    testSpells[className][randomSpellID].onCooldown = true
                    testSpells[className][randomSpellID].start = now
                    testSpells[className][randomSpellID].remaining = testSpells[className][randomSpellID].duration
                end
            end
        end
    end
    
    -- Update UI
    P:UpdateCooldowns()
end

-- Is a test spell on cooldown
function T:IsTestSpellOnCooldown(className, spellID)
    if not testMode or not className or not spellID or not testSpells[className] or not testSpells[className][spellID] then
        return false, 0, 0
    end
    
    local spell = testSpells[className][spellID]
    return spell.onCooldown, spell.start, spell.duration
end