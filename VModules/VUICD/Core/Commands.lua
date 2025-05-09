local AddOnName, NS = ...
local VUICD, L, db = NS:unpack()

-- Slash commands
VUICD.Commands = {}

-- Initialize slash commands
function VUICD.Commands:Initialize()
    -- Register slash commands
    SLASH_VUICD1 = "/vuicd"
    SLASH_VUICD2 = "/vcd"
    
    SlashCmdList["VUICD"] = function(msg)
        self:ProcessCommand(msg)
    end
end

-- Process slash command
function VUICD.Commands:ProcessCommand(msg)
    -- Split message into command and arguments
    msg = msg or ""
    local command, args = self:GetArgs(msg)
    
    -- Convert command to lowercase
    command = command and command:lower() or ""
    
    -- Process command
    if command == "" or command == "help" then
        self:ShowHelp()
    elseif command == "test" then
        self:TestCommand(args)
    elseif command == "show" then
        self:ShowCommand(args)
    elseif command == "hide" then
        self:HideCommand(args)
    elseif command == "reset" then
        self:ResetCommand(args)
    elseif command == "config" or command == "options" then
        self:ConfigCommand(args)
    elseif command == "unlock" then
        self:UnlockCommand(args)
    elseif command == "lock" then
        self:LockCommand(args)
    elseif command == "debug" then
        self:DebugCommand(args)
    else
        self:ShowHelp()
    end
end

-- Get command and arguments
function VUICD.Commands:GetArgs(msg)
    if not msg or msg == "" then
        return "", ""
    end
    
    -- Split message into command and arguments
    local command, args = msg:match("^(%S+)%s*(.*)$")
    
    return command or "", args or ""
end

-- Show help
function VUICD.Commands:ShowHelp()
    print("|cff33ff99VUICD - VUI Party Cooldown Tracker|r")
    print("Usage: /vuicd or /vcd [command] [arguments]")
    print("Commands:")
    print("  |cffff7d0ahelp|r - Show this help message")
    print("  |cffff7d0atest|r - Toggle test mode")
    print("  |cffff7d0ashow|r - Show the cooldown tracker")
    print("  |cffff7d0ahide|r - Hide the cooldown tracker")
    print("  |cffff7d0areset|r - Reset position and settings")
    print("  |cffff7d0aconfig|r or |cffff7d0aoptions|r - Open configuration panel")
    print("  |cffff7d0aunlock|r - Unlock frames for movement")
    print("  |cffff7d0alock|r - Lock frames")
    print("  |cffff7d0adebug|r - Toggle debug mode")
    print("Examples:")
    print("  /vcd test - Toggle test mode")
    print("  /vcd unlock - Unlock frames for movement")
    print("  /vcd reset position - Reset frame positions")
end

-- Test command
function VUICD.Commands:TestCommand(args)
    if VUICD.Party and VUICD.Party.Test then
        VUICD.Party.Test:Toggle()
    else
        print("|cff33ff99VUICD:|r Test module not available")
    end
end

-- Show command
function VUICD.Commands:ShowCommand(args)
    if VUICD.Party then
        VUICD.Party:Enable()
        print("|cff33ff99VUICD:|r Party cooldown tracker |cff00ff00shown|r")
    end
end

-- Hide command
function VUICD.Commands:HideCommand(args)
    if VUICD.Party then
        VUICD.Party:Disable()
        print("|cff33ff99VUICD:|r Party cooldown tracker |cffff0000hidden|r")
    end
end

-- Reset command
function VUICD.Commands:ResetCommand(args)
    args = args and args:lower() or ""
    
    if args == "position" then
        -- Reset position only
        if VUICD.Party and VUICD.Party.Position then
            VUICD.Party.Position:ResetPosition()
            print("|cff33ff99VUICD:|r Position reset")
        end
    elseif args == "settings" then
        -- Reset settings only
        if VUICD.db then
            -- Reset to defaults
            for k, v in pairs(db) do
                VUICD.db[k] = v
            end
            
            -- Reload UI components
            if VUICD.Party then
                VUICD.Party:UpdateRoster()
            end
            
            print("|cff33ff99VUICD:|r Settings reset")
        end
    else
        -- Reset everything
        if VUICD.Party and VUICD.Party.Position then
            VUICD.Party.Position:ResetPosition()
        end
        
        if VUICD.db then
            -- Reset to defaults
            for k, v in pairs(db) do
                VUICD.db[k] = v
            end
            
            -- Reload UI components
            if VUICD.Party then
                VUICD.Party:UpdateRoster()
            end
        end
        
        print("|cff33ff99VUICD:|r All settings reset")
    end
end

-- Config command
function VUICD.Commands:ConfigCommand(args)
    -- Open VUI config panel and navigate to VUICD settings
    VUI.Config:Toggle()
    VUI.Config:SelectTab("VUICD")
end

-- Unlock command
function VUICD.Commands:UnlockCommand(args)
    if VUICD.Party and VUICD.Party.Position then
        VUICD.Party.Position:SetLocked(false)
        print("|cff33ff99VUICD:|r Frames |cff00ff00unlocked|r for movement")
    end
end

-- Lock command
function VUICD.Commands:LockCommand(args)
    if VUICD.Party and VUICD.Party.Position then
        VUICD.Party.Position:SetLocked(true)
        print("|cff33ff99VUICD:|r Frames |cffff0000locked|r")
    end
end

-- Debug command
function VUICD.Commands:DebugCommand(args)
    VUICD.debug = not VUICD.debug
    print("|cff33ff99VUICD:|r Debug mode " .. (VUICD.debug and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
end