local addonName, VUI = ...

-- Define colors used for notifications
function VUI.Notifications.Colors()
    return {
        ["BLUE"] = {
            ["R"] = 0,
            ["G"] = .75,
            ["B"] = 1
        },
        ["GREEN"] = {
            ["R"] = .5,
            ["G"] = 1,
            ["B"] = 0
        },
        ["YELLOW"] = {
            ["R"] = 1,
            ["G"] = 1,
            ["B"] = 0
        },
        ["ORANGE"] = {
            ["R"] = 1,
            ["G"] = .65,
            ["B"] = 0
        },
        ["RED"] = {
            ["R"] = 1,
            ["G"] = 0,
            ["B"] = 0
        },
        ["PURPLE"] = {
            ["R"] = .93,
            ["G"] = .51,
            ["B"] = .93
        },
        ["BLACK"] = {
            ["R"] = 0,
            ["G"] = 0,
            ["B"] = 0
        },
        ["WHITE"] = {
            ["R"] = 1,
            ["G"] = 1,
            ["B"] = 1
        }
    }
end