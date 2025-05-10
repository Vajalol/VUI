-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

-- Create logger namespace
VUIGfinder.Logger = {}
local Logger = VUIGfinder.Logger

-- Log levels
Logger.LOG_LEVEL_TRACE = 1
Logger.LOG_LEVEL_DEBUG = 2
Logger.LOG_LEVEL_INFO = 3
Logger.LOG_LEVEL_WARN = 4
Logger.LOG_LEVEL_ERROR = 5
Logger.LOG_LEVEL_FATAL = 6
Logger.LOG_LEVEL_NONE = 99

-- Color codes for log levels
Logger.LEVEL_COLORS = {
    [Logger.LOG_LEVEL_TRACE] = "|cff999999", -- Gray
    [Logger.LOG_LEVEL_DEBUG] = "|cff5555ff", -- Blue
    [Logger.LOG_LEVEL_INFO]  = "|cff00ff00", -- Green
    [Logger.LOG_LEVEL_WARN]  = "|cffffff00", -- Yellow
    [Logger.LOG_LEVEL_ERROR] = "|cffff5555", -- Red
    [Logger.LOG_LEVEL_FATAL] = "|cffff00ff", -- Purple
}

-- Level names
Logger.LEVEL_NAMES = {
    [Logger.LOG_LEVEL_TRACE] = "TRACE",
    [Logger.LOG_LEVEL_DEBUG] = "DEBUG",
    [Logger.LOG_LEVEL_INFO]  = "INFO",
    [Logger.LOG_LEVEL_WARN]  = "WARN",
    [Logger.LOG_LEVEL_ERROR] = "ERROR",
    [Logger.LOG_LEVEL_FATAL] = "FATAL",
}

-- Default log level
Logger.currentLogLevel = Logger.LOG_LEVEL_INFO

-- Initialize the logger
function Logger:Initialize()
    self.currentLogLevel = Module.db.profile.debug and self.LOG_LEVEL_DEBUG or self.LOG_LEVEL_INFO
end

-- Set the log level
function Logger:SetLogLevel(level)
    self.currentLogLevel = level
end

-- Get the current log level
function Logger:GetLogLevel()
    return self.currentLogLevel
end

-- Format a log message
function Logger:FormatMessage(level, message, ...)
    local prefix = string.format(
        "|cff33BBFF[VUI Gfinder]|r %s[%s]|r ",
        self.LEVEL_COLORS[level] or "|cffffffff",
        self.LEVEL_NAMES[level] or "UNKNOWN"
    )
    
    -- Format the message with the provided arguments
    local formattedMessage
    if select("#", ...) > 0 then
        formattedMessage = string.format(message, ...)
    else
        formattedMessage = message
    end
    
    return prefix .. formattedMessage
end

-- Log a message at the specified level
function Logger:Log(level, message, ...)
    -- Skip if the log level is too low
    if level < self.currentLogLevel then
        return
    end
    
    -- Format and output the message
    local formattedMessage = self:FormatMessage(level, message, ...)
    print(formattedMessage)
end

-- Convenience methods for different log levels
function Logger:Trace(message, ...)
    self:Log(self.LOG_LEVEL_TRACE, message, ...)
end

function Logger:Debug(message, ...)
    self:Log(self.LOG_LEVEL_DEBUG, message, ...)
end

function Logger:Info(message, ...)
    self:Log(self.LOG_LEVEL_INFO, message, ...)
end

function Logger:Warn(message, ...)
    self:Log(self.LOG_LEVEL_WARN, message, ...)
end

function Logger:Error(message, ...)
    self:Log(self.LOG_LEVEL_ERROR, message, ...)
end

function Logger:Fatal(message, ...)
    self:Log(self.LOG_LEVEL_FATAL, message, ...)
end