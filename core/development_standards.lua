--[[
    VUI - Development Standards
    Author: VortexQ8
    
    This file implements core standards for VUI development, providing
    guidance and utilities to ensure consistent code organization.
]]

local _, VUI = ...
local DevStandards = {}
VUI.DevStandards = DevStandards

-- Module version
DevStandards.version = "1.0.0"

-- Cache frequently used globals for performance
local pairs = pairs
local type = type
local select = select
local table_insert = table.insert
local table_sort = table.sort

-- Standards enforcement settings
local settings = {
    validateModuleStructure = true,
    validateFileNaming = true,
    validatePerformanceOptimizations = true,
    validateMediaFormats = true,
    validateModuleNaming = true,
    autoCorrectIssues = false,  -- Set to true to auto-correct issues (development only)
    trackStandardsCompliance = true
}

-- Track module standards compliance
local complianceData = {
    modules = {},
    files = {},
    media = {}
}

-- Module structure validation template
local moduleStructureTemplate = {
    required = {
        "init.lua",        -- Main module entry point
        "index.xml",       -- Module file listing
    },
    recommended = {
        "ThemeIntegration.lua", -- Theme support
        "config.lua",      -- Configuration options
        "core.lua",        -- Core functionality
    }
}

-- Module structure validation
function DevStandards:ValidateModuleStructure(moduleName)
    if not moduleName or not settings.validateModuleStructure then return true end
    
    local moduleData = complianceData.modules[moduleName] or {
        name = moduleName,
        missingRequired = {},
        missingRecommended = {},
        extraFiles = {}
    }
    
    -- Check for required files
    for _, fileName in ipairs(moduleStructureTemplate.required) do
        local filePath = "modules/" .. moduleName .. "/" .. fileName
        local exists = self:FileExists(filePath)
        if not exists then
            table_insert(moduleData.missingRequired, fileName)
        end
    end
    
    -- Check for recommended files
    for _, fileName in ipairs(moduleStructureTemplate.recommended) do
        local filePath = "modules/" .. moduleName .. "/" .. fileName
        local exists = self:FileExists(filePath)
        if not exists then
            table_insert(moduleData.missingRecommended, fileName)
        end
    end
    
    -- Store compliance data
    complianceData.modules[moduleName] = moduleData
    
    -- Return compliance status
    return #moduleData.missingRequired == 0
end

-- File naming validation
function DevStandards:ValidateFileNaming(filePath)
    if not filePath or not settings.validateFileNaming then return true end
    
    local fileName = self:GetFileName(filePath)
    local fileNameLC = fileName:lower()
    
    -- Naming convention rules:
    -- 1. Use lowercase for all filenames except special cases like ThemeIntegration.lua
    -- 2. Separate words with underscores (snake_case)
    -- 3. Avoid abbreviations except for widely recognized ones (e.g., UI, API)
    
    local acceptableUpperCaseFiles = {
        "ThemeIntegration.lua",
        "MediaRegistration.lua",
        "README.md",
        "CHANGES.md",
        "ROADMAP.md"
    }
    
    local fileData = complianceData.files[filePath] or {
        path = filePath,
        name = fileName,
        issues = {}
    }
    
    -- Check for lowercase naming
    if fileName ~= fileNameLC and not self:IsInTable(acceptableUpperCaseFiles, fileName) then
        table_insert(fileData.issues, "File should use lowercase naming: " .. fileNameLC)
    end
    
    -- Check for snake_case
    if fileName:find(" ") then
        local correctedName = fileName:gsub(" ", "_")
        table_insert(fileData.issues, "File should use snake_case: " .. correctedName)
    end
    
    -- Store compliance data
    complianceData.files[filePath] = fileData
    
    -- Return compliance status
    return #fileData.issues == 0
end

-- Media format validation
function DevStandards:ValidateMediaFormat(filePath)
    if not filePath or not settings.validateMediaFormats then return true end
    
    local extension = self:GetFileExtension(filePath)
    local fileName = self:GetFileName(filePath)
    
    local mediaData = complianceData.media[filePath] or {
        path = filePath,
        name = fileName,
        issues = {}
    }
    
    -- WoW-compatible formats
    local compatibleImageFormats = {
        "tga", "blp", "png", "jpg", "jpeg"
    }
    
    local compatibleSoundFormats = {
        "ogg", "mp3", "wav"
    }
    
    local compatibleFontFormats = {
        "ttf"
    }
    
    -- Check SVG files - should be converted to TGA
    if extension == "svg" then
        local hasTGAVersion = self:FileExists(filePath:gsub("%.svg$", ".tga"))
        if not hasTGAVersion then
            table_insert(mediaData.issues, "SVG should have TGA version for WoW compatibility")
        end
    end
    
    -- For textures used in-game, ensure they're in compatible format
    if filePath:find("media/textures/") and not self:IsInTable(compatibleImageFormats, extension) then
        table_insert(mediaData.issues, "Texture should use WoW-compatible format (TGA preferred)")
    end
    
    -- For sounds used in-game, ensure they're in compatible format
    if filePath:find("media/sounds/") and not self:IsInTable(compatibleSoundFormats, extension) then
        table_insert(mediaData.issues, "Sound should use WoW-compatible format (OGG preferred)")
    end
    
    -- Store compliance data
    complianceData.media[filePath] = mediaData
    
    -- Return compliance status
    return #mediaData.issues == 0
end

-- Utility: Check if file exists
function DevStandards:FileExists(filePath)
    local f = io.open(filePath, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Utility: Get file extension
function DevStandards:GetFileExtension(filePath)
    return filePath:match("%.([^%.]+)$") or ""
end

-- Utility: Get file name
function DevStandards:GetFileName(filePath)
    return filePath:match("([^/\\]+)$") or filePath
end

-- Utility: Check if value exists in table
function DevStandards:IsInTable(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
    return false
end

-- Generate compliance report
function DevStandards:GenerateComplianceReport()
    local report = {
        modules = {
            total = 0,
            compliant = 0,
            nonCompliant = {}
        },
        files = {
            total = 0,
            compliant = 0,
            nonCompliant = {}
        },
        media = {
            total = 0,
            compliant = 0,
            nonCompliant = {}
        }
    }
    
    -- Process module compliance
    for name, data in pairs(complianceData.modules) do
        report.modules.total = report.modules.total + 1
        if #data.missingRequired == 0 then
            report.modules.compliant = report.modules.compliant + 1
        else
            table_insert(report.modules.nonCompliant, name)
        end
    end
    
    -- Process file compliance
    for path, data in pairs(complianceData.files) do
        report.files.total = report.files.total + 1
        if #data.issues == 0 then
            report.files.compliant = report.files.compliant + 1
        else
            table_insert(report.files.nonCompliant, path)
        end
    end
    
    -- Process media compliance
    for path, data in pairs(complianceData.media) do
        report.media.total = report.media.total + 1
        if #data.issues == 0 then
            report.media.compliant = report.media.compliant + 1
        else
            table_insert(report.media.nonCompliant, path)
        end
    end
    
    return report
end

-- Initialize the development standards system
function DevStandards:Initialize()
    -- Load settings from database if available
    if VUI.db and VUI.db.profile.devStandards then
        for k, v in pairs(VUI.db.profile.devStandards) do
            if settings[k] ~= nil then
                settings[k] = v
            end
        end
    end
    
    -- Register with VUI modules system
    if VUI.RegisterModule then
        VUI:RegisterModule("DevStandards", self)
    end
    
    -- This module is initialized successfully
    return true
end

-- Module API: Convert SVG to TGA
function DevStandards:ConvertSVGToTGA(svgPath, tgaPath, size)
    -- This would use external tools in a development environment
    -- In WoW runtime, this just logs that conversion is needed
    VUI:DebugLog("SVG to TGA conversion needed: " .. svgPath)
    return false
end

-- Module API: Get development standards for a component type
function DevStandards:GetStandardsFor(componentType)
    local standards = {
        files = {
            oneFilePurpose = "Each file should have a single, clear purpose",
            consistentNaming = "Files should use consistent naming conventions (lowercase snake_case)",
            properOrganization = "Files should be properly organized in the correct module directory",
        },
        modules = {
            standardStructure = "Modules should follow standard structure with required files",
            consistentRegistration = "Modules should use consistent registration pattern",
            properVersioning = "Modules should include explicit version information",
        },
        media = {
            compatibleFormats = "Media files should use WoW-compatible formats",
            svgConversion = "SVG assets must be converted to TGA for WoW",
            properQuality = "Textures and sounds must maintain high quality",
        },
        code = {
            clearCommenting = "Code should have clear comments for each function and section",
            performanceOptimization = "Performance-critical code should use local caching",
            consistentFormatting = "Code should follow consistent formatting and style",
        }
    }
    
    if componentType and standards[componentType] then
        return standards[componentType]
    end
    
    return standards
end

-- Initialize standards if VUI system is available
if VUI.OnInitialize then
    DevStandards:Initialize()
end

-- Register with VUI core if available
if VUI.RegisterScript then
    VUI:RegisterScript("core/development_standards.lua")
end