local UIScale = VUI:NewModule('Misc.UIScale')

-- Local functions
local min, max = math.min, math.max
local format = string.format

-- Constants
local MIN_SCALE = 0.5
local MAX_SCALE = 1.5
local SCALE_STEP = 0.05

function UIScale:OnEnable()
    -- Create our db defaults if they don't exist
    if not VUI.db.profile.misc then
        VUI.db.profile.misc = {}
    end
    
    -- Create uiscale structure if it doesn't exist
    if not VUI.db.profile.misc.uiscale then
        VUI.db.profile.misc.uiscale = {
            enabled = true,
            scale = 1.0
        }
    end
    
    -- Register for settings changes
    VUI:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        -- Small delay to ensure UI is fully loaded
        C_Timer.After(1, function()
            if VUI.db.profile.misc.uiscale.enabled then
                self:ApplyScale(VUI.db.profile.misc.uiscale.scale or 1.0)
            end
        end)
    end)
    
    -- Add slash command for scaling
    SlashCmdList["VUISCALE"] = function(msg)
        local cmd, arg = self:GetArgs(msg, 2)
        if not cmd or cmd == "" or cmd == "help" then
            self:PrintHelp()
        elseif cmd == "set" then
            local scale = tonumber(arg)
            if scale then
                scale = min(max(scale, MIN_SCALE), MAX_SCALE)
                self:SetScale(scale)
                print(format("|cff00FF00VUI:|r UI scale set to %.2f", scale))
            else
                print("|cffFF0000VUI:|r Invalid scale value. Please use a number between 0.5 and 1.5.")
            end
        elseif cmd == "increase" or cmd == "+" then
            local scale = VUI.db.profile.misc.uiscale.scale or 1.0
            scale = min(scale + SCALE_STEP, MAX_SCALE)
            self:SetScale(scale)
            print(format("|cff00FF00VUI:|r UI scale increased to %.2f", scale))
        elseif cmd == "decrease" or cmd == "-" then
            local scale = VUI.db.profile.misc.uiscale.scale or 1.0
            scale = max(scale - SCALE_STEP, MIN_SCALE)
            self:SetScale(scale)
            print(format("|cff00FF00VUI:|r UI scale decreased to %.2f", scale))
        elseif cmd == "reset" then
            self:ResetScale()
        elseif cmd == "auto" then
            self:AutoScale()
        elseif cmd == "toggle" then
            VUI.db.profile.misc.uiscale.enabled = not VUI.db.profile.misc.uiscale.enabled
            if VUI.db.profile.misc.uiscale.enabled then
                self:ApplyScale(VUI.db.profile.misc.uiscale.scale or 1.0)
                print("|cff00FF00VUI:|r UI scaling enabled")
            else
                self:ApplyScale(1.0) -- Reset to default when disabled
                print("|cff00FF00VUI:|r UI scaling disabled")
            end
        else
            self:PrintHelp()
        end
    end
    SLASH_VUISCALE1 = "/vuiscale"
    SLASH_VUISCALE2 = "/vs"
end

function UIScale:GetArgs(message, numArgs)
    if not message or message:trim() == "" then
        return
    end
    
    local args = {}
    for arg in string.gmatch(message, "%S+") do
        table.insert(args, arg)
    end
    
    if numArgs == 1 then
        return args[1]
    else
        return args[1], args[2], args[3], args[4], args[5]
    end
end

function UIScale:PrintHelp()
    print("|cff3EBEFFVUI Scale Commands:|r")
    print("  |cffBBBBBB/vuiscale|r or |cffBBBBBB/vs|r - Show this help")
    print("  |cffBBBBBB/vs set X|r - Set scale to X (0.5-1.5)")
    print("  |cffBBBBBB/vs +|r - Increase scale by 0.05")
    print("  |cffBBBBBB/vs -|r - Decrease scale by 0.05")
    print("  |cffBBBBBB/vs reset|r - Reset scale to 1.0")
    print("  |cffBBBBBB/vs auto|r - Auto scale based on screen resolution")
    print("  |cffBBBBBB/vs toggle|r - Toggle UI scaling on/off")
end

function UIScale:SetScale(scale)
    -- Ensure uiscale table exists
    if not VUI.db.profile.misc.uiscale then
        VUI.db.profile.misc.uiscale = {
            enabled = true,
            scale = 1.0
        }
    end
    
    -- Save the scale
    VUI.db.profile.misc.uiscale.scale = scale
    
    -- Apply the scale
    self:ApplyScale(scale)
end

function UIScale:ApplyScale(scale)
    -- Safety check
    if type(scale) ~= "number" then scale = 1.0 end
    scale = min(max(scale, MIN_SCALE), MAX_SCALE)
    
    -- Apply the scale to the UI
    SetCVar("uiScale", scale)
    
    -- Notify other addons
    if VUI.SendCallback then
        VUI:SendCallback("UI_Scale_Changed", scale)
    end
end

function UIScale:CalculateAutoScale()
    -- Get screen resolution
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    
    -- Calculate appropriate scale based on resolution
    local scale = 1.0
    
    if screenWidth >= 3840 then -- 4K
        scale = 1.2
    elseif screenWidth >= 2560 then -- 1440p
        scale = 1.1
    elseif screenWidth >= 1920 then -- 1080p
        scale = 1.0
    elseif screenWidth >= 1600 then -- 900p
        scale = 0.9
    elseif screenWidth >= 1366 then -- 768p
        scale = 0.8
    else -- Lower resolutions
        scale = 0.7
    end
    
    return scale
end

function UIScale:AutoScale()
    -- Calculate the optimal scale
    local scale = self:CalculateAutoScale()
    local screenWidth = GetScreenWidth()
    local screenHeight = GetScreenHeight()
    
    -- Apply the automatic scale
    self:SetScale(scale)
    print(format("|cff00FF00VUI:|r Auto-scale applied: %.2f (Resolution: %dx%d)", scale, screenWidth, screenHeight))
end

function UIScale:ResetScale()
    -- Reset to default scale 1.0
    self:SetScale(1.0)
    print("|cff00FF00VUI:|r UI scale reset to 1.0")
end

-- Export the module
VUI.UIScale = UIScale