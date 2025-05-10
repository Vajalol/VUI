local VUI = select(2, ...)
if not VUI.Config then return end

local Module = VUI:GetModule("VUICD")
if not Module then return end

-- Create the options table
VUI.Config.Layout["VUICD"] = {
    name = "VUI CD",
    desc = "Party Cooldown Tracker",
    type = "group",
    order = 50,
    args = {
        header = {
            name = "Party Cooldown Tracker",
            type = "header",
            order = 1,
        },
        desc = {
            name = "Tracks and displays party member cooldowns in various formats.",
            type = "description",
            order = 2,
        },
        enabled = {
            name = "Enable",
            desc = "Enable the party cooldown tracker",
            type = "toggle",
            width = "full",
            order = 3,
            get = function() 
                if not Module.DB then return false end
                return Module.DB.profile.enable 
            end,
            set = function(info, val)
                if not Module.DB then return end
                Module.DB.profile.enable = val
                Module:ToggleModule()
            end,
        },
        configButton = {
            name = "Open Settings",
            desc = "Open detailed configuration panel",
            type = "execute",
            order = 4,
            func = function()
                if Module.RegisterOptions then
                    Module:RegisterOptions()
                    if LibStub("AceConfigDialog-3.0") then
                        LibStub("AceConfigDialog-3.0"):Open("VUICD")
                    end
                end
            end,
            disabled = function() 
                if not Module.DB then return true end
                return not Module.DB.profile.enable 
            end
        },
        themeSettings = {
            name = "Theme Integration",
            type = "group",
            inline = true,
            order = 5,
            args = {
                useTheme = {
                    name = "Use VUI Theme Colors",
                    desc = "Apply the current theme colors to borders and highlights",
                    type = "toggle",
                    width = "full",
                    order = 1,
                    get = function() 
                        if not Module.DB then return false end
                        return Module.DB.profile.border.themeBorder 
                    end,
                    set = function(info, val)
                        if not Module.DB then return end
                        Module.DB.profile.border.themeBorder = val
                        if Module.ApplyTheme then
                            Module:ApplyTheme()
                        end
                    end,
                    disabled = function() 
                        if not Module.DB then return true end
                        return not Module.DB.profile.enable 
                    end
                },
                themeColor = {
                    name = "Preview",
                    type = "description",
                    order = 2,
                    fontSize = "medium",
                    func = function()
                        local color = VUI:GetThemeColor()
                        local useTheme = Module.DB and Module.DB.profile.border.themeBorder
                        
                        if useTheme then
                            return string.format("Borders and highlights will use the current theme color: |cff%.2x%.2x%.2x■|r", 
                                color.r * 255, 
                                color.g * 255, 
                                color.b * 255)
                        else
                            return "Theme integration is disabled. Borders and highlights will use their default colors."
                        end
                    end,
                }
            }
        },
        testButton = {
            name = "Test Mode",
            desc = "Toggle test mode to view how the tracker would appear in a group",
            type = "execute",
            order = 6,
            func = function()
                if Module.Party and Module.Party.TestMode then
                    Module.Party:TestMode()
                end
            end,
            disabled = function() 
                if not Module.DB then return true end
                return not Module.DB.profile.enable 
            end
        },
    },
}

-- Register with VUI Config
VUI.Config:Register("VUICD", VUI.Config.Layout["VUICD"])