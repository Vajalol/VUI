local AddOnName, NS = ...

local Module = VUI:NewModule("VUICD", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("VUICD")

-- Default settings
Module.defaults = {
    profile = {
        modules = { ["Party"] = true },
        party = {
            enabled = true,
            visibility = {
                arena = true,
                raid = true,
                party = true,
                scenario = true,
                none = false,
                outside = false,
                inTest = true
            },
            icons = {
                desaturate = true,
                showTooltip = true,
                tooltipScale = 1,
                showCounter = true,
                counterScale = 0.85,
                scale = 0.85,
                anchor = "TOPLEFT",
                relativePoint = "BOTTOMLEFT",
                padding = 1,
                columns = 10,
                statusBar = {
                    enabled = true,
                    position = "TOP",
                    width = 2,
                    height = 12,
                    showSpark = true,
                    statusBarTexture = "OmniCD-texture_flat",
                    useClassColor = true
                }
            },
            spells = {
                defensive = true,
                offensive = true,
                covenant = true,
                interrupt = true,
                utility = true,
                custom = false
            },
            highlight = {
                glow = {
                    enabled = true,
                    type = "pixel",
                    color = { r = 0.95, g = 0.95, b = 0.32, a = 1}
                }
            },
            extraBars = {
                -- Extra bars configuration
            },
            priority = {
                -- Priority settings
            }
        }
    }
}

-- Initialize NS (module namespace)
NS[1] = Module         -- Main module
NS[2] = L              -- Localization
NS[3] = Module.defaults.profile  -- Default profile
NS[4] = {}             -- Global settings

function NS:unpack()
    return self[1], self[2], self[3], self[4]
end

-- Initialize library references
Module.Libs = {}
Module.Libs.LSM = LibStub("LibSharedMedia-3.0")

-- Initialize module frames
Module.Party = CreateFrame("Frame")
Module.Comm = CreateFrame("Frame")
Module.Cooldowns = CreateFrame("Frame")

-- Version info
Module.Version = "1.0"
Module.Author = "VUI Team"
Module.Notes = "Party cooldown tracker for VUI"

-- Export for other modules to use
_G["VUICD"] = Module