-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- Create Logger namespace
VUIGfinder.Logger = {}
local Logger = VUIGfinder.Logger

-- Log levels
Logger.LOG_LEVEL_NONE = 0
Logger.LOG_LEVEL_ERROR = 1
Logger.LOG_LEVEL_WARNING = 2
Logger.LOG_LEVEL_INFO = 3
Logger.LOG_LEVEL_DEBUG = 4
Logger.LOG_LEVEL_TRACE = 5

-- Current log level (default: errors only)
Logger.logLevel = Logger.LOG_LEVEL_ERROR

-- Prefix for all log messages
Logger.prefix = "|cff33AA33[VUIGfinder]|r "

-- Set log level
function Logger:SetLogLevel(level)
    self.logLevel = level
end

-- Get current log level
function Logger:GetLogLevel()
    return self.logLevel
end

-- Internal log function
function Logger:Log(level, message, ...)
    if level <= self.logLevel then
        if select("#", ...) > 0 then
            message = message:format(...)
        end
        
        local levelPrefix = ""
        if level == self.LOG_LEVEL_ERROR then
            levelPrefix = "|cffFF0000ERROR:|r "
        elseif level == self.LOG_LEVEL_WARNING then
            levelPrefix = "|cffFFAA00WARNING:|r "
        elseif level == self.LOG_LEVEL_INFO then
            levelPrefix = "|cff00AAAINFO:|r "
        elseif level == self.LOG_LEVEL_DEBUG then
            levelPrefix = "|cff888888DEBUG:|r "
        elseif level == self.LOG_LEVEL_TRACE then
            levelPrefix = "|cff888888TRACE:|r "
        end
        
        print(self.prefix .. levelPrefix .. message)
    end
end

-- Log error message
function Logger:Error(message, ...)
    self:Log(self.LOG_LEVEL_ERROR, message, ...)
end

-- Log warning message
function Logger:Warning(message, ...)
    self:Log(self.LOG_LEVEL_WARNING, message, ...)
end

-- Log info message
function Logger:Info(message, ...)
    self:Log(self.LOG_LEVEL_INFO, message, ...)
end

-- Log debug message
function Logger:Debug(message, ...)
    self:Log(self.LOG_LEVEL_DEBUG, message, ...)
end

-- Log trace message
function Logger:Trace(message, ...)
    self:Log(self.LOG_LEVEL_TRACE, message, ...)
end

-- Convenience function to dump a table to the log at debug level
function Logger:DumpTable(tbl, indent)
    if not tbl or type(tbl) ~= "table" then
        self:Debug("DumpTable: Not a table")
        return
    end
    
    if self.logLevel < self.LOG_LEVEL_DEBUG then return end
    
    indent = indent or 0
    local spaces = string.rep("  ", indent)
    
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            self:Debug(spaces .. tostring(k) .. " = {")
            self:DumpTable(v, indent + 1)
            self:Debug(spaces .. "}")
        else
            self:Debug(spaces .. tostring(k) .. " = " .. tostring(v))
        end
    end
end

-- Initialize logger
function Logger:Initialize()
    -- Check if debug mode is enabled in saved variables
    if VUIGfinder.db and VUIGfinder.db.profile and VUIGfinder.db.profile.debugMode then
        self:SetLogLevel(self.LOG_LEVEL_DEBUG)
    end
    
    self:Debug("Logger initialized")
end