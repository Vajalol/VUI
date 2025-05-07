-- Database Optimization Configuration and Validation
local addonName, VUI = ...
-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create Database Validation namespace if it doesn't exist
VUI.DatabaseValidation = VUI.DatabaseValidation or {}

-- Schema definitions for module settings validation
VUI.DatabaseValidation.schemas = {
    -- Base types for validation
    types = {
        boolean = { type = "boolean" },
        number = { type = "number" },
        string = { type = "string" },
        table = { type = "table" },
        func = { type = "function" },
        color = { type = "table", validator = function(val) 
            return type(val) == "table" and #val >= 3 and #val <= 4 and
                   type(val[1]) == "number" and type(val[2]) == "number" and type(val[3]) == "number"
        end }
    },
    
    -- Module schemas for validation
    modules = {
        unitframes = {
            enabled = { type = "boolean", default = true },
            style = { type = "string", default = "modern", 
                      allowed = {"modern", "classic", "minimal"} },
            scale = { type = "number", default = 1.0, min = 0.5, max = 2.0 },
            classColoredBars = { type = "boolean", default = true },
            showPortraits = { type = "boolean", default = true },
            frames = { type = "table" }
        },
        buffoverlay = {
            enabled = { type = "boolean", default = true },
            size = { type = "number", default = 32, min = 16, max = 64 },
            spacing = { type = "number", default = 2, min = 0, max = 10 },
            growthDirection = { type = "string", default = "UP", 
                              allowed = {"UP", "DOWN", "LEFT", "RIGHT"} }
        },
        trufigcd = {
            enabled = { type = "boolean", default = true },
            iconSize = { type = "number", default = 30, min = 16, max = 64 },
            maxIcons = { type = "number", default = 8, min = 3, max = 20 }
        },
        nameplates = {
            enabled = { type = "boolean", default = true },
            scale = { type = "number", default = 1.0, min = 0.5, max = 2.0 },
            showClassColors = { type = "boolean", default = true }
        }
    },
    
    -- Core systems schemas
    core = {
        appearance = {
            theme = { type = "string", default = "thunderstorm", 
                    allowed = {"thunderstorm", "arcanemystic", "phoenixflame", "felenergy"} },
            fonts = { type = "table" },
            colors = { type = "table" }
        },
        performance = {
            frameLimiter = { type = "boolean", default = false },
            reducedEffects = { type = "boolean", default = false }
        }
    }
}

-- Configuration options for Database Optimization module
function VUI.DatabaseOptimization:GetConfig()
    local options = {
        type = "group",
        name = "Database Optimization",
        order = 900,
        args = {
            header = {
                type = "header",
                name = "Database Access Optimization",
                order = 1
            },
            description = {
                type = "description",
                name = "Configure database access optimization settings to improve performance.",
                order = 2
            },
            enabled = {
                type = "toggle",
                name = "Enable Database Optimization",
                desc = "Enable or disable the database optimization system.",
                width = "full",
                order = 10,
                get = function() return self.config.enableCaching end,
                set = function(_, value) 
                    self.config.enableCaching = value 
                    self.state.cacheEnabled = value
                end
            },
            enableBatching = {
                type = "toggle",
                name = "Enable Write Batching",
                desc = "Group database write operations together for better performance.",
                width = "full",
                order = 11,
                get = function() return self.config.enableBatching end,
                set = function(_, value) 
                    self.config.enableBatching = value 
                    self.state.batchingEnabled = value
                end
            },
            cacheLifetime = {
                type = "range",
                name = "Cache Lifetime (seconds)",
                desc = "How long items remain in the cache before being purged.",
                min = 30,
                max = 1800,
                step = 30,
                order = 20,
                get = function() return self.config.cacheLifetime end,
                set = function(_, value) self.config.cacheLifetime = value end
            },
            maxCacheEntries = {
                type = "range",
                name = "Maximum Cache Entries",
                desc = "Maximum number of items to keep in the cache.",
                min = 100,
                max = 10000,
                step = 100,
                order = 21,
                get = function() return self.config.maxCacheEntries end,
                set = function(_, value) self.config.maxCacheEntries = value end
            },
            batchDelay = {
                type = "range",
                name = "Batch Processing Delay (seconds)",
                desc = "How long to wait before processing batched operations.",
                min = 0.1,
                max = 2.0,
                step = 0.1,
                order = 22,
                get = function() return self.config.batchDelay end,
                set = function(_, value) self.config.batchDelay = value end
            },
            debugHeader = {
                type = "header",
                name = "Debug Options",
                order = 30
            },
            debugMode = {
                type = "toggle",
                name = "Debug Mode",
                desc = "Enable database optimization debug logging.",
                width = "full",
                order = 31,
                get = function() return self.config.debugMode end,
                set = function(_, value) self.config.debugMode = value end
            },
            statsHeader = {
                type = "header",
                name = "Current Statistics",
                order = 40
            },
            statsText = {
                type = "description",
                name = function()
                    local stats = self:GetStats()
                    if not stats then
                        return "No statistics available."
                    end
                    
                    return string.format(
                        "Cache Hit Rate: %.1f%%\n" ..
                        "Cache Size: %d entries\n" ..
                        "Batched Writes: %d\n" ..
                        "Direct Writes: %d\n",
                        stats.hitRate * 100,
                        stats.cacheSize,
                        stats.batchedWrites,
                        stats.directWrites
                    )
                end,
                order = 41,
                fontSize = "medium"
            },
            cleanupCache = {
                type = "execute",
                name = "Clean Cache Now",
                desc = "Immediately clean the database cache.",
                order = 50,
                func = function() self:CleanupCache(true) end
            },
            resetStats = {
                type = "execute",
                name = "Reset Statistics",
                desc = "Reset all database optimization statistics.",
                order = 51,
                func = function() 
                    self.state.stats.cacheHits = 0
                    self.state.stats.cacheMisses = 0
                    self.state.stats.batchedWrites = 0 
                    self.state.stats.directWrites = 0
                    self.state.stats.cacheCleaned = 0
                    
                    -- Reset module stats
                    for module, _ in pairs(self.state.stats.moduleAccess) do
                        self.state.stats.moduleAccess[module] = {
                            reads = 0,
                            writes = 0,
                            cached = 0
                        }
                    end
                end
            },
            moduleHeader = {
                type = "header",
                name = "Module Cache Settings",
                order = 60
            },
            -- New section for database validation
            validationHeader = {
                type = "header",
                name = "Configuration Validation",
                order = 200
            },
            validationDesc = {
                type = "description",
                name = "Validate configuration settings to prevent corruption and ensure addon stability.",
                order = 201
            },
            autoValidate = {
                type = "toggle",
                name = "Enable Automatic Validation",
                desc = "Automatically validate settings on login and after configuration changes.",
                width = "full",
                order = 202,
                get = function() return VUI.db.profile.validation and VUI.db.profile.validation.autoValidate end,
                set = function(_, value)
                    VUI.db.profile.validation = VUI.db.profile.validation or {}
                    VUI.db.profile.validation.autoValidate = value
                end
            },
            backupBeforeChanges = {
                type = "toggle",
                name = "Backup Before Major Changes",
                desc = "Create automatic backups before major configuration changes.",
                width = "full",
                order = 203,
                get = function() return VUI.db.profile.validation and VUI.db.profile.validation.backupBeforeChanges end,
                set = function(_, value) 
                    VUI.db.profile.validation = VUI.db.profile.validation or {}
                    VUI.db.profile.validation.backupBeforeChanges = value
                end
            },
            validateNow = {
                type = "execute",
                name = "Validate Configuration Now",
                desc = "Run a complete validation of all configuration settings.",
                order = 204,
                func = function() 
                    local results = VUI.DatabaseValidation:ValidateAllSettings()
                    if results.valid then
                        VUI:Print("Configuration validated successfully.")
                    else
                        VUI:Print("Configuration validation found issues. See the validation log for details.")
                    end
                end
            },
            createBackup = {
                type = "execute",
                name = "Create Configuration Backup",
                desc = "Create a backup of the current configuration settings.",
                order = 205,
                func = function() VUI.DatabaseValidation:CreateConfigBackup() end
            },
            validateResults = {
                type = "description",
                name = function()
                    local results = VUI.DatabaseValidation.lastValidationResults
                    if not results then
                        return "No validation has been performed yet."
                    end
                    
                    if results.valid then
                        return "|cff00ff00Configuration is valid.|r"
                    else
                        local msg = "|cffff0000Configuration validation errors:|r\n"
                        for i, err in ipairs(results.errors) do
                            msg = msg .. "- " .. err .. "\n"
                            if i > 5 then
                                msg = msg .. "- ... and " .. (#results.errors - 5) .. " more errors\n"
                                break
                            end
                        end
                        return msg
                    end
                end,
                order = 206,
                fontSize = "medium"
            },
            restoreHeader = {
                type = "header",
                name = "Restore Configuration",
                order = 210
            },
            restoreDesc = {
                type = "description",
                name = "Restore configuration from a previous backup.",
                order = 211
            },
            restoreSelector = {
                type = "select",
                name = "Select Backup",
                desc = "Choose a configuration backup to restore.",
                order = 212,
                values = function()
                    return VUI.DatabaseValidation:GetBackupList() or {["none"] = "No backups available"}
                end,
                get = function() return VUI.DatabaseValidation.selectedBackup or "none" end,
                set = function(_, value) VUI.DatabaseValidation.selectedBackup = value end
            },
            restoreBackup = {
                type = "execute",
                name = "Restore Selected Backup",
                desc = "Restore configuration from selected backup.",
                order = 213,
                disabled = function() return not VUI.DatabaseValidation.selectedBackup or VUI.DatabaseValidation.selectedBackup == "none" end,
                confirm = true,
                confirmText = "This will replace your current configuration. Continue?",
                func = function() 
                    if VUI.DatabaseValidation.selectedBackup and VUI.DatabaseValidation.selectedBackup ~= "none" then
                        VUI.DatabaseValidation:RestoreConfigBackup(VUI.DatabaseValidation.selectedBackup)
                    end
                end
            },
            backupInfo = {
                type = "description",
                name = function()
                    local backup = VUI.DatabaseValidation.selectedBackup
                    if not backup or backup == "none" then
                        return "No backup selected."
                    end
                    
                    local backups = VUI.db.global.configBackups
                    if not backups or not backups[backup] then
                        return "Selected backup information not available."
                    end
                    
                    local info = backups[backup]
                    return string.format(
                        "Backup: %s\nCreated: %s\nVersion: %s\nSize: %d bytes",
                        backup,
                        date("%Y-%m-%d %H:%M:%S", info.timestamp),
                        info.version or "Unknown",
                        info.size or 0
                    )
                end,
                order = 214,
                fontSize = "medium"
            }
        }
    }
    
    -- Add module-specific cache settings
    local moduleOrder = 61
    for module, limit in pairs(self.config.cacheByModule) do
        options.args["module_" .. module] = {
            type = "range",
            name = module .. " Cache Limit",
            desc = "Maximum cache entries for " .. module .. " module.",
            min = 10,
            max = 1000,
            step = 10,
            order = moduleOrder,
            get = function() return self.config.cacheByModule[module] or 100 end,
            set = function(_, value) 
                self.config.cacheByModule[module] = value 
                self.state.moduleCacheLimits[module] = value
            end
        }
        moduleOrder = moduleOrder + 1
    end
    
    return options
end

-- Register with config system
if VUI.options and VUI.options.args.performance then
    VUI.options.args.performance.args.databaseOptimization = VUI.DatabaseOptimization:GetConfig()
end

-- ============================================================
-- Database Validation Implementation
-- ============================================================

-- Validate a setting against its schema
function VUI.DatabaseValidation:ValidateSetting(value, schema)
    -- Check type
    if schema.type and type(value) ~= schema.type then
        return false, string.format("Expected type %s, got %s", schema.type, type(value))
    end
    
    -- Check custom validator if provided
    if schema.validator and type(schema.validator) == "function" then
        local valid, errorMsg = schema.validator(value)
        if not valid then
            return false, errorMsg or "Failed custom validation"
        end
    end
    
    -- Check numeric constraints
    if type(value) == "number" then
        if schema.min and value < schema.min then
            return false, string.format("Value %s is below minimum %s", tostring(value), tostring(schema.min))
        end
        if schema.max and value > schema.max then
            return false, string.format("Value %s is above maximum %s", tostring(value), tostring(schema.max))
        end
    end
    
    -- Check string allowed values
    if type(value) == "string" and schema.allowed then
        local found = false
        for _, allowedVal in ipairs(schema.allowed) do
            if value == allowedVal then
                found = true
                break
            end
        end
        if not found then
            return false, string.format("Value '%s' not in allowed list: %s", 
                value, table.concat(schema.allowed, ", "))
        end
    end
    
    -- Check table properties if schema has properties
    if type(value) == "table" and schema.properties then
        for propName, propSchema in pairs(schema.properties) do
            if value[propName] ~= nil then
                local propValid, propError = self:ValidateSetting(value[propName], propSchema)
                if not propValid then
                    return false, string.format("Property '%s': %s", propName, propError)
                end
            elseif propSchema.required then
                return false, string.format("Required property '%s' is missing", propName)
            end
        end
    end
    
    return true
end

-- Validate all settings in the VUI.db
function VUI.DatabaseValidation:ValidateAllSettings()
    local results = {
        valid = true,
        errors = {},
        warnings = {},
        fixes = {}
    }
    
    -- Store the results for later reference
    self.lastValidationResults = results
    
    -- Ensure we have a database to validate
    if not VUI.db or not VUI.db.profile then
        table.insert(results.errors, "Database is not initialized properly")
        results.valid = false
        return results
    end
    
    -- Validate module settings
    if VUI.db.profile.modules then
        for moduleName, settings in pairs(VUI.db.profile.modules) do
            local schema = self.schemas.modules[moduleName]
            if schema then
                for settingName, settingValue in pairs(settings) do
                    local settingSchema = schema[settingName]
                    if settingSchema then
                        local valid, error = self:ValidateSetting(settingValue, settingSchema)
                        if not valid then
                            table.insert(results.errors, string.format("Module '%s', setting '%s': %s", 
                                moduleName, settingName, error))
                            results.valid = false
                            
                            -- Auto-fix by applying default if available
                            if settingSchema.default ~= nil then
                                VUI.db.profile.modules[moduleName][settingName] = settingSchema.default
                                table.insert(results.fixes, string.format("Fixed '%s.%s' by applying default value: %s", 
                                    moduleName, settingName, tostring(settingSchema.default)))
                            end
                        end
                    else
                        -- Unknown setting, not necessarily an error but worth noting
                        table.insert(results.warnings, string.format("Module '%s' has unknown setting '%s'", 
                            moduleName, settingName))
                    end
                end
                
                -- Check for missing required settings
                for settingName, settingSchema in pairs(schema) do
                    if settingSchema.required and settings[settingName] == nil then
                        table.insert(results.errors, string.format("Module '%s' is missing required setting '%s'", 
                            moduleName, settingName))
                        results.valid = false
                        
                        -- Auto-fix by applying default if available
                        if settingSchema.default ~= nil then
                            VUI.db.profile.modules[moduleName][settingName] = settingSchema.default
                            table.insert(results.fixes, string.format("Fixed '%s.%s' by applying default value: %s", 
                                moduleName, settingName, tostring(settingSchema.default)))
                        end
                    end
                end
            else
                -- Unknown module, not necessarily an error
                table.insert(results.warnings, string.format("Unknown module in settings: '%s'", moduleName))
            end
        end
    else
        -- Missing modules section
        table.insert(results.errors, "Database is missing modules section")
        results.valid = false
        
        -- Auto-fix by creating modules section
        VUI.db.profile.modules = {}
        table.insert(results.fixes, "Created missing modules section in database")
    end
    
    -- Validate core settings
    for sectionName, schema in pairs(self.schemas.core) do
        if VUI.db.profile[sectionName] then
            local settings = VUI.db.profile[sectionName]
            for settingName, settingSchema in pairs(schema) do
                if settings[settingName] ~= nil then
                    local valid, error = self:ValidateSetting(settings[settingName], settingSchema)
                    if not valid then
                        table.insert(results.errors, string.format("Core section '%s', setting '%s': %s", 
                            sectionName, settingName, error))
                        results.valid = false
                        
                        -- Auto-fix by applying default if available
                        if settingSchema.default ~= nil then
                            VUI.db.profile[sectionName][settingName] = settingSchema.default
                            table.insert(results.fixes, string.format("Fixed '%s.%s' by applying default value: %s", 
                                sectionName, settingName, tostring(settingSchema.default)))
                        end
                    end
                elseif settingSchema.required then
                    table.insert(results.errors, string.format("Core section '%s' is missing required setting '%s'", 
                        sectionName, settingName))
                    results.valid = false
                    
                    -- Auto-fix by applying default if available
                    if settingSchema.default ~= nil then
                        VUI.db.profile[sectionName][settingName] = settingSchema.default
                        table.insert(results.fixes, string.format("Fixed '%s.%s' by applying default value: %s", 
                            sectionName, settingName, tostring(settingSchema.default)))
                    end
                end
            end
        elseif self:SectionHasRequiredFields(schema) then
            -- Missing required section
            table.insert(results.errors, string.format("Database is missing required section '%s'", sectionName))
            results.valid = false
            
            -- Auto-fix by creating the section with defaults
            VUI.db.profile[sectionName] = self:CreateDefaultSection(schema)
            table.insert(results.fixes, string.format("Created missing section '%s' with default values", sectionName))
        end
    end
    
    -- If we made any fixes, record that we've modified the settings
    if #results.fixes > 0 then
        VUI.db.profile.lastValidationFix = time()
        VUI.db.profile.lastValidationFixCount = #results.fixes
    end
    
    return results
end

-- Check if a schema section has any required fields
function VUI.DatabaseValidation:SectionHasRequiredFields(schema)
    for _, fieldSchema in pairs(schema) do
        if fieldSchema.required then
            return true
        end
    end
    return false
end

-- Create a default section based on schema
function VUI.DatabaseValidation:CreateDefaultSection(schema)
    local defaults = {}
    for settingName, settingSchema in pairs(schema) do
        if settingSchema.default ~= nil then
            defaults[settingName] = settingSchema.default
        end
    end
    return defaults
end

-- Create a backup of the current configuration
function VUI.DatabaseValidation:CreateConfigBackup(note)
    -- Initialize global backups table if it doesn't exist
    VUI.db.global.configBackups = VUI.db.global.configBackups or {}
    
    -- Create a deep copy of the profile
    local profileCopy = self:DeepCopy(VUI.db.profile)
    
    -- Generate backup ID
    local backupId = "backup_" .. date("%Y%m%d_%H%M%S")
    
    -- Create backup info
    local backupInfo = {
        timestamp = time(),
        note = note or "Manual backup",
        version = VUI.version,
        profileName = VUI.db:GetCurrentProfile(),
        size = 0, -- Will be updated after serialization
        data = profileCopy
    }
    
    -- Serialize data to estimate size
    local serialized = self:SerializeTable(profileCopy)
    backupInfo.size = #serialized
    
    -- Add to backups table
    VUI.db.global.configBackups[backupId] = backupInfo
    
    -- Limit the number of backups stored
    self:PruneOldBackups(10) -- Keep the 10 most recent backups
    
    VUI:Print(string.format("Configuration backup created: %s", backupId))
    return backupId
end

-- Restore configuration from a backup
function VUI.DatabaseValidation:RestoreConfigBackup(backupId)
    -- Check if backup exists
    if not VUI.db.global.configBackups or not VUI.db.global.configBackups[backupId] then
        VUI:Print("Backup not found: " .. backupId)
        return false
    end
    
    -- Create backup of current config before restoring
    local currentBackupId = self:CreateConfigBackup("Auto-backup before restore")
    
    -- Get the backup data
    local backupInfo = VUI.db.global.configBackups[backupId]
    
    -- Restore the profile data
    VUI.db.profile = self:DeepCopy(backupInfo.data)
    
    -- Validate the restored data
    local results = self:ValidateAllSettings()
    if not results.valid then
        VUI:Print("Warning: Restored configuration had validation issues. See the validation log for details.")
    end
    
    -- Record the restore
    VUI.db.profile.lastRestore = {
        timestamp = time(),
        backupId = backupId,
        previousBackupId = currentBackupId
    }
    
    VUI:Print(string.format("Configuration restored from backup: %s", backupId))
    
    -- Reload the UI settings
    VUI:RefreshConfig()
    
    return true
end

-- Get list of available backups
function VUI.DatabaseValidation:GetBackupList()
    if not VUI.db.global.configBackups then
        return nil
    end
    
    local list = {}
    for backupId, info in pairs(VUI.db.global.configBackups) do
        list[backupId] = string.format("%s - %s", 
            date("%Y-%m-%d %H:%M", info.timestamp),
            info.note or "Backup"
        )
    end
    
    return list
end

-- Limit the number of backups by removing oldest
function VUI.DatabaseValidation:PruneOldBackups(maxBackups)
    if not VUI.db.global.configBackups then return end
    
    -- Create an array of backup IDs with timestamps for sorting
    local backups = {}
    for backupId, info in pairs(VUI.db.global.configBackups) do
        table.insert(backups, {id = backupId, timestamp = info.timestamp})
    end
    
    -- Sort by timestamp (newest first)
    table.sort(backups, function(a, b) return a.timestamp > b.timestamp end)
    
    -- Remove oldest backups beyond the limit
    if #backups > maxBackups then
        for i = maxBackups + 1, #backups do
            VUI.db.global.configBackups[backups[i].id] = nil
        end
    end
end

-- Deep copy a table
function VUI.DatabaseValidation:DeepCopy(src)
    if type(src) ~= "table" then return src end
    local copy = {}
    for k, v in pairs(src) do
        if type(v) == "table" then
            copy[k] = self:DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

-- Helper function to serialize a table for storage or transmission
function VUI.DatabaseValidation:SerializeTable(tbl)
    -- In a real implementation, this would use proper serialization like AceSerializer
    -- For now, use built-in serialization
    
    local tmp = {}
    
    local function _serialize(t, indent)
        indent = indent or ""
        for k, v in pairs(t) do
            local key = type(k) == "string" and string.format("[%q]", k) or string.format("[%s]", tostring(k))
            if type(v) == "table" then
                table.insert(tmp, indent .. key .. " = {")
                _serialize(v, indent .. "  ")
                table.insert(tmp, indent .. "},")
            elseif type(v) == "string" then
                table.insert(tmp, indent .. key .. " = " .. string.format("%q", v) .. ",")
            else
                table.insert(tmp, indent .. key .. " = " .. tostring(v) .. ",")
            end
        end
    end
    
    table.insert(tmp, "{")
    _serialize(tbl, "  ")
    table.insert(tmp, "}")
    
    return table.concat(tmp, "\n")
end

-- Initialize database validation on addon load
function VUI.DatabaseValidation:Initialize()
    -- Ensure the validation config section exists
    if VUI.db and VUI.db.profile then
        VUI.db.profile.validation = VUI.db.profile.validation or {
            autoValidate = true,
            backupBeforeChanges = true,
            lastValidation = 0,
            lastBackup = 0
        }
        
        -- Run auto-validation if enabled
        if VUI.db.profile.validation.autoValidate then
            C_Timer.After(2, function()
                self:ValidateAllSettings()
                VUI.db.profile.validation.lastValidation = time()
            end)
        end
    end
    
    -- Register for settings changed event
    VUI:RegisterCallback("SETTINGS_CHANGED", function()
        if VUI.db.profile.validation and VUI.db.profile.validation.autoValidate then
            C_Timer.After(0.5, function()
                self:ValidateAllSettings()
                VUI.db.profile.validation.lastValidation = time()
            end)
        end
    end)
    
    -- Register for profile changed events
    if VUI.db and VUI.db.RegisterCallback then
        VUI.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChange")
        VUI.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChange")
        VUI.db.RegisterCallback(self, "OnProfileReset", "OnProfileChange")
    end
end

-- Handle profile changes
function VUI.DatabaseValidation:OnProfileChange()
    -- Create backup before validation if enabled
    if VUI.db.profile.validation and VUI.db.profile.validation.backupBeforeChanges then
        self:CreateConfigBackup("Auto-backup on profile change")
    end
    
    -- Run validation
    if VUI.db.profile.validation and VUI.db.profile.validation.autoValidate then
        C_Timer.After(0.5, function()
            self:ValidateAllSettings()
            VUI.db.profile.validation.lastValidation = time()
        end)
    end
end

-- Initialize validation system when VUI loads
if VUI.RegisterCallback then
    VUI:RegisterCallback("ADDON_LOADED", function()
        VUI.DatabaseValidation:Initialize()
    end)
end