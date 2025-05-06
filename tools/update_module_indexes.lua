-- VUI Module Index Updater
-- This script updates all module XML files to use the standardized format
local addonName, VUI = ...
-- Fallback for test environmentsif not VUI then VUI = _G.VUI end

-- Create the Module Index Updater namespace
VUI.ModuleIndexUpdater = {}

-- List of modules to update
local MODULES_TO_UPDATE = {
    "bags",
    "paperdoll",
    "actionbars",
    "unitframes",
    "castbar",
    "tooltip",
    "buffoverlay",
    "trufigcd",
    "moveany",
    "auctionator",
    "angrykeystone",
    "omnicc",
    "omnicd",
    "idtip",
    "premadegroupfinder",
    "infoframe",
    "automation",
    "visualconfig",
    "profiles",
    "skins",
    "spellnotifications",
    "detailsskin",
    "msbt",
    "tools",
    "nameplates",
    "epf"
}

-- XML template for module index file
local INDEX_XML_TEMPLATE = [[<Ui xmlns="http://www.blizzard.com/wow/ui/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://www.blizzard.com/wow/ui/
..\FrameXML\UI.xsd">
    <Script file="init.lua"/>
    <Script file="config.lua"/>
    %s
    <Script file="core.lua"/>
</Ui>]]

-- Function to generate the index.xml content with additional files
function VUI.ModuleIndexUpdater:GenerateIndexXML(moduleName, additionalFiles)
    local filesXML = ""
    
    if additionalFiles and #additionalFiles > 0 then
        for _, file in ipairs(additionalFiles) do
            -- Skip files that are already included
            if file ~= "init.lua" and file ~= "config.lua" and file ~= "core.lua" then
                filesXML = filesXML .. string.format('    <Script file="%s"/>\n', file)
            end
        end
    end
    
    return string.format(INDEX_XML_TEMPLATE, filesXML)
end

-- Function to check if a file exists
function VUI.ModuleIndexUpdater:FileExists(path)
    local file = io.open(path, "r")
    if file then file:close() return true end
    return false
end

-- Function to update a module's index.xml
function VUI.ModuleIndexUpdater:UpdateModuleIndex(moduleName)
    -- Get module directory
    local moduleDir = "modules/" .. moduleName .. "/"
    local indexPath = moduleDir .. "index.xml"
    local loadPath = moduleDir .. "load.xml"
    
    -- Check if we need to rename load.xml to index.xml
    local needsRename = self:FileExists(loadPath) and not self:FileExists(indexPath)
    
    -- Get list of lua files in the module directory
    local luaFiles = {}
    local dir = io.popen("ls -1 " .. moduleDir .. "*.lua 2>/dev/null")
    if dir then
        for file in dir:lines() do
            -- Extract just the filename without path
            local filename = file:match("([^/]+)$")
            if filename then
                table.insert(luaFiles, filename)
            end
        end
        dir:close()
    end
    
    -- Filter out the standard files
    local additionalFiles = {}
    for _, file in ipairs(luaFiles) do
        if file ~= "init.lua" and file ~= "config.lua" and file ~= "core.lua" then
            table.insert(additionalFiles, file)
        end
    end
    
    -- Generate the index.xml content
    local indexContent = self:GenerateIndexXML(moduleName, additionalFiles)
    
    -- Create or update the index.xml file
    local file = io.open(indexPath, "w")
    if file then
        file:write(indexContent)
        file:close()
        VUI:Print("Updated index.xml for module: " .. moduleName)
        
        -- Remove the old load.xml if it exists
        if needsRename and self:FileExists(loadPath) then
            os.remove(loadPath)
            VUI:Print("Removed load.xml for module: " .. moduleName)
        end
        
        return true
    else
        VUI:Print("Error: Could not write to " .. indexPath)
        return false
    end
end

-- Function to update all module index files
function VUI.ModuleIndexUpdater:UpdateAllModules()
    local success = 0
    local failed = 0
    
    for _, moduleName in ipairs(MODULES_TO_UPDATE) do
        if self:UpdateModuleIndex(moduleName) then
            success = success + 1
        else
            failed = failed + 1
        end
    end
    
    VUI:Print("Updated " .. success .. " module index files. Failed: " .. failed)
    return success, failed
end

-- Add slash command
SLASH_VUIUPDATEINDEXES1 = "/vuiupdateindexes"
SlashCmdList["VUIUPDATEINDEXES"] = function(input)
    VUI.ModuleIndexUpdater:UpdateAllModules()
end

-- Register with main VUI slash command handler
if VUI.RegisterSlashCommand then
    VUI:RegisterSlashCommand("updateindexes", function()
        VUI.ModuleIndexUpdater:UpdateAllModules()
    end, "Update all module index.xml files to the standardized format")
end

-- Print help
VUI:Print("Module Index Updater loaded. Use /vuiupdateindexes to update all module index files.")