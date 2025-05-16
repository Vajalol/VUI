local Module = VUI:NewModule("General.Commands");

function Module:OnEnable()
    SlashCmdList["RELOAD"] = function()
        ReloadUI()
    end
    SLASH_RELOAD1 = "/rl"
    SLASH_FSTACK1 = "/fs"
    SlashCmdList["VUI"] = function()
        -- Check if Config method is available
        if VUI.Config then
            VUI:Config()
        else
            -- If Config isn't loaded yet, inform the user and queue a delayed call
            print("VUI configuration is initializing. Please try again in a moment.")
            C_Timer.After(1, function()
                if VUI.Config then
                    VUI:Config()
                else
                    print("VUI configuration is still loading. Please use '/vui' again later.")
                end
            end)
        end
    end
    SlashCmdList["FSTACK"] = function()
        UIParentLoadAddOn("Blizzard_DebugTools");
        local showHiddenArg, showRegionsArg, showAnchorsArg;
        local pattern = "^%s*(%S+)(.*)$";
        showHiddenArg, msg = string.match(msg or "", pattern);
        showRegionsArg, msg = string.match(msg or "", pattern);
        showAnchorsArg, msg = string.match(msg or "", pattern);
        -- If no parameters are passed the defaults specified by these cvars are used instead.
        local showHiddenDefault = FrameStackTooltip_IsShowHiddenEnabled();
        local showRegionsDefault = FrameStackTooltip_IsShowRegionsEnabled();
        local showAnchorsDefault = FrameStackTooltip_IsShowAnchorsEnabled();
        local showHidden = StringToBoolean(showHiddenArg or "", showHiddenDefault);
        local showRegions = StringToBoolean(showRegionsArg or "", showRegionsDefault);
        local showAnchors = StringToBoolean(showAnchorsArg or "", showAnchorsDefault);
        FrameStackTooltip_Toggle(showHidden, showRegions, showAnchors);
    end
    SLASH_VUI1 = "/vui"
end
