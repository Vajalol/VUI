local _, VUI = ...
local SN = VUI.SpellNotifications

function SN:Sizes()
    return {
        ["SMALL"] = "small",
        ["BIG"] = "big",
        ["LARGE"] = "large"
    }
end