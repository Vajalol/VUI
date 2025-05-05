--[[
    VUI - Module Performance Optimizer
    Author: VortexQ8
    
    This tool analyzes and optimizes module performance by ensuring proper API caching,
    consistent formatting, and following VUI development standards.
]]

local _, VUI = ...
local Optimizer = {}
VUI.ModulePerformanceOptimizer = Optimizer

-- Module version
Optimizer.version = "1.0.0"

-- Frequently used WoW API functions that should be cached
local frequentlyUsedAPI = {
    "GetTime",
    "CreateFrame",
    "UnitExists",
    "UnitName",
    "UnitClass",
    "UnitHealth",
    "UnitHealthMax",
    "UnitPower",
    "UnitPowerMax",
    "GetSpellInfo",
    "GetItemInfo",
    "GetInventoryItemID",
    "CombatLogGetCurrentEventInfo",
    "UnitBuff",
    "UnitDebuff",
    "GetSpecialization",
    "GetSpecializationInfo",
    "GetItemCount",
    "IsSpellKnown",
    "GetNumGroupMembers",
    "GetActiveSpecGroup",
    "UnitIsUnit",
    "InCombatLockdown",
    "GetInstanceInfo",
    "UnitGUID",
    "GetSpellCooldown",
    "IsInInstance",
    "GetFramerate",
    "UnitInRaid",
    "UnitInParty",
    "GetRaidRosterInfo",
}

-- Frequently used Lua functions that should be cached
local frequentlyUsedLua = {
    "pairs",
    "ipairs",
    "select",
    "type",
    "tonumber",
    "tostring",
    "string.format",
    "string.match",
    "string.find",
    "string.gsub",
    "string.sub",
    "table.insert",
    "table.remove",
    "table.wipe",
    "table.sort",
    "math.floor",
    "math.ceil",
    "math.min",
    "math.max",
    "math.abs",
    "math.random",
}

-- Performance patterns to check
local performancePatterns = {
    apiCachingPattern = {
        description = "API functions should be cached locally at the top of the file",
        pattern = "local %w+ = %w+",
        matches = {
            "local GetTime = GetTime",
            "local CreateFrame = CreateFrame",
            "local pairs = pairs",
            "local floor = math.floor"
        }
    },
    stringConcatPattern = {
        description = "Use string.format instead of ..",
        pattern = "[\"'].+[\"'] %.%. .+",
        matches = {
            "message = \"Player \" .. name .. \" used \" .. spell",
        },
        suggestion = "Use string.format(\"Player %s used %s\", name, spell)"
    },
    tableReusePattern = {
        description = "Reuse tables instead of creating new ones frequently",
        pattern = "{.-}",
        matches = {
            "local t = {}", 
            "wipe(t)",
            "t[1] = value"
        }
    },
    frameCreationPattern = {
        description = "Use frame pools for frequently created/destroyed frames",
        pattern = "CreateFrame",
        matches = {
            "local frame = CreateFrame(\"Frame\")",
            "frame:Hide()"
        },
        suggestion = "Use VUI.FramePool:Acquire() and VUI.FramePool:Release()"
    }
}

-- Module optimization report
local optimizationReports = {}

-- Analyze a module file for performance optimizations
function Optimizer:AnalyzeFile(filePath)
    local f = io.open(filePath, "r")
    if not f then
        return false, "Could not open file: " .. filePath
    end
    
    local content = f:read("*all")
    f:close()
    
    -- Create new report
    local report = {
        file = filePath,
        apiCaching = {
            found = {},
            missing = {}
        },
        improvements = {}
    }
    
    -- Check API caching
    self:CheckAPICaching(content, report)
    
    -- Check string concatenation
    self:CheckStringConcatenation(content, report)
    
    -- Check table reuse
    self:CheckTableReuse(content, report)
    
    -- Check frame creation
    self:CheckFrameCreation(content, report)
    
    -- Store report
    optimizationReports[filePath] = report
    
    return true, report
end

-- Check API function caching
function Optimizer:CheckAPICaching(content, report)
    -- Look for local caching of API functions
    for _, api in ipairs(frequentlyUsedAPI) do
        -- Check if API is used in the file
        if content:find(api .. "%(") then
            -- Check if it's locally cached
            if content:find("local%s+" .. api .. "%s+=%s+" .. api) then
                table.insert(report.apiCaching.found, api)
            else
                -- Not cached but used
                table.insert(report.apiCaching.missing, api)
            end
        end
    end
    
    -- Look for local caching of Lua functions
    for _, func in ipairs(frequentlyUsedLua) do
        -- Handle functions like string.format specially
        local pattern
        if func:find("%.") then
            local namespace, method = func:match("([^%.]+)%.([^%.]+)")
            -- Check if the full function is used (string.format)
            if content:find(func .. "%(") then
                -- Check for local caching like "local format = string.format"
                if content:find("local%s+[%w_]+%s+=%s+" .. func) then
                    table.insert(report.apiCaching.found, func)
                else
                    table.insert(report.apiCaching.missing, func)
                end
            end
        else
            -- Simple function like pairs
            if content:find(func .. "%(") then
                if content:find("local%s+" .. func .. "%s+=%s+" .. func) then
                    table.insert(report.apiCaching.found, func)
                else
                    table.insert(report.apiCaching.missing, func)
                end
            end
        end
    end
end

-- Check string concatenation
function Optimizer:CheckStringConcatenation(content, report)
    -- Look for string concatenation with ".."
    local line_num = 1
    for line in content:gmatch("([^\n]+)") do
        -- Skip comments
        if not line:match("^%s*%-%-") then
            -- Look for multiple ".." operations
            if line:find("%.%.[^%.]") then
                local count = 0
                for _ in line:gmatch("%.%.") do
                    count = count + 1
                end
                
                if count >= 2 then
                    table.insert(report.improvements, {
                        line = line_num,
                        code = line:match("[^-][^-](.+)"),
                        issue = "Multiple string concatenations",
                        suggestion = "Use string.format() for better performance"
                    })
                end
            end
        end
        line_num = line_num + 1
    end
end

-- Check table reuse
function Optimizer:CheckTableReuse(content, report)
    -- Look for frequent table creation
    local tableCreations = {}
    local line_num = 1
    
    for line in content:gmatch("([^\n]+)") do
        -- Skip comments
        if not line:match("^%s*%-%-") then
            -- Count table creations
            if line:find("{%s*}") or line:find("{}") then
                table.insert(tableCreations, {
                    line = line_num,
                    code = line
                })
            end
        end
        line_num = line_num + 1
    end
    
    -- Check if there are many table creations without wipe() calls
    if #tableCreations > 5 then
        local wipeCount = 0
        for _ in content:gmatch("wipe%s*%(") do
            wipeCount = wipeCount + 1
        end
        
        if wipeCount < #tableCreations / 3 then
            table.insert(report.improvements, {
                issue = "Frequent table creation without reuse",
                count = #tableCreations,
                suggestion = "Create a local table once and use table.wipe() to reset it"
            })
        end
    end
end

-- Check frame creation
function Optimizer:CheckFrameCreation(content, report)
    -- Look for frequent frame creation
    local frameCreations = {}
    local line_num = 1
    
    for line in content:gmatch("([^\n]+)") do
        -- Skip comments
        if not line:match("^%s*%-%-") then
            -- Count CreateFrame calls
            if line:find("CreateFrame%s*%(") then
                table.insert(frameCreations, {
                    line = line_num,
                    code = line
                })
            end
        end
        line_num = line_num + 1
    end
    
    -- Check if there are many frame creations in loops or functions
    if #frameCreations > 3 then
        -- Check for potential frame creation in loops
        local inLoopCreation = false
        
        for _, creation in ipairs(frameCreations) do
            -- Check if frame creation might be in a loop by looking at surrounding context
            local contextStart = math.max(1, creation.line - 5)
            local contextEnd = math.min(creation.line + 5, line_num)
            
            local context = ""
            local current = 1
            for line in content:gmatch("([^\n]+)") do
                if current >= contextStart and current <= contextEnd then
                    context = context .. line .. "\n"
                end
                if current > contextEnd then
                    break
                end
                current = current + 1
            end
            
            -- Check if context contains loop keywords
            if context:find("for%s+") or context:find("while%s+") or 
               context:find("repeat%s+") or context:find("do%s+") then
                inLoopCreation = true
                break
            end
        end
        
        if inLoopCreation or #frameCreations > 10 then
            table.insert(report.improvements, {
                issue = "Frequent frame creation",
                count = #frameCreations,
                inLoop = inLoopCreation,
                suggestion = "Use VUI.FramePool for better performance"
            })
        end
    end
end

-- Implement optimizations in a file
function Optimizer:OptimizeFile(filePath)
    local report = optimizationReports[filePath]
    if not report then
        local success, result = self:AnalyzeFile(filePath)
        if not success then
            return false, "Failed to analyze file: " .. result
        end
        report = result
    end
    
    local f = io.open(filePath, "r")
    if not f then
        return false, "Could not open file: " .. filePath
    end
    
    local content = f:read("*all")
    f:close()
    
    local updatedContent = content
    
    -- Add missing API local caching if needed
    if #report.apiCaching.missing > 0 then
        -- Find where locals are normally declared
        local localSection, localsEnd = updatedContent:find("local%s+[%w_]+%s*=[^=]-\n%s*\n")
        
        if not localSection then
            -- Just find start of file after initial comments
            localSection = updatedContent:find("[^%-]")
            if localSection then
                -- Move past any initial module comment block
                local commentEnd = updatedContent:find("%]%]", localSection)
                if commentEnd then
                    localSection = commentEnd + 2
                end
            else
                localSection = 1
            end
        else
            localSection = localsEnd
        end
        
        -- Prepare caching statements
        local cachingCode = "\n-- Cache frequently used functions for better performance\n"
        for _, api in ipairs(report.apiCaching.missing) do
            if api:find("%.") then
                -- Handle namespaced functions like string.format
                local namespace, method = api:match("([^%.]+)%.([^%.]+)")
                cachingCode = cachingCode .. "local " .. method .. " = " .. api .. "\n"
            else
                cachingCode = cachingCode .. "local " .. api .. " = " .. api .. "\n"
            end
        end
        cachingCode = cachingCode .. "\n"
        
        -- Insert caching code
        updatedContent = updatedContent:sub(1, localSection) .. cachingCode .. updatedContent:sub(localSection + 1)
    end
    
    -- Write updated content if changed
    if updatedContent ~= content then
        local f = io.open(filePath, "w")
        if not f then
            return false, "Could not write to file: " .. filePath
        end
        f:write(updatedContent)
        f:close()
        
        return true, "File optimized: " .. filePath
    end
    
    return true, "No changes needed for: " .. filePath
end

-- Generate optimization report
function Optimizer:GenerateReport()
    local report = {
        totalFiles = 0,
        optimizedFiles = 0,
        apiCachingIssues = 0,
        stringConcatIssues = 0,
        tableReuseIssues = 0,
        frameCreationIssues = 0,
        details = {}
    }
    
    for path, fileReport in pairs(optimizationReports) do
        report.totalFiles = report.totalFiles + 1
        
        local fileIssues = #fileReport.apiCaching.missing + #fileReport.improvements
        
        if fileIssues > 0 then
            report.apiCachingIssues = report.apiCachingIssues + #fileReport.apiCaching.missing
            
            -- Count specific improvement types
            for _, improvement in ipairs(fileReport.improvements) do
                if improvement.issue:find("string concatenation") then
                    report.stringConcatIssues = report.stringConcatIssues + 1
                elseif improvement.issue:find("table") then
                    report.tableReuseIssues = report.tableReuseIssues + 1
                elseif improvement.issue:find("frame") then
                    report.frameCreationIssues = report.frameCreationIssues + 1
                end
            end
            
            table.insert(report.details, {
                file = path,
                apiCachingMissing = #fileReport.apiCaching.missing,
                improvements = #fileReport.improvements
            })
        else
            report.optimizedFiles = report.optimizedFiles + 1
        end
    end
    
    return report
end

-- Analyze all module files
function Optimizer:AnalyzeAllModules()
    -- Get all module directories
    local modules = {}
    local moduleDir = "modules"
    
    -- PLACEHOLDER: In a real implementation, would use io.popen or equivalent to list directories
    -- For this example, we hardcode some module names
    modules = {
        "buffoverlay",
        "angrykeystone", 
        "multinotification",
        "trufigcd",
        "detailsskin"
    }
    
    local fileCount = 0
    for _, module in ipairs(modules) do
        local moduleFiles = self:GetModuleFiles(moduleDir .. "/" .. module)
        
        for _, file in ipairs(moduleFiles) do
            if file:match("%.lua$") then
                local success, _ = self:AnalyzeFile(moduleDir .. "/" .. module .. "/" .. file)
                if success then
                    fileCount = fileCount + 1
                end
            end
        end
    end
    
    return fileCount
end

-- Get list of files in a module directory (placeholder)
function Optimizer:GetModuleFiles(moduleDir)
    -- PLACEHOLDER: In a real implementation, would use io.popen or equivalent to list files
    -- For this example, we return a hardcoded list
    if moduleDir:find("buffoverlay") then
        return {"init.lua", "core.lua", "ThemeIntegration.lua"}
    elseif moduleDir:find("angrykeystone") then
        return {"init.lua", "ThemeIntegration.lua"}
    elseif moduleDir:find("multinotification") then
        return {"init.lua"}
    elseif moduleDir:find("trufigcd") then
        return {"init.lua"}
    elseif moduleDir:find("detailsskin") then
        return {"init.lua"}
    end
    
    return {}
end

-- Initialize the optimizer
function Optimizer:Initialize()
    -- Register with VUI modules system if available
    if VUI.RegisterModule then
        VUI:RegisterModule("ModulePerformanceOptimizer", self)
    end
    
    return true
end

-- Register with VUI core if available
if VUI.RegisterScript then
    VUI:RegisterScript("tools/module_performance_optimizer.lua")
end