-- VUI Compatibility Tester
-- Tests compatibility with various WoW versions and other addons
local addonName, VUI = ...

-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create the Compatibility Tester namespace
VUI.CompatibilityTester = {
    version = "1.0.0",
    author = "VUI Team",
    results = {},
    tests = {},
    options = {
        verboseOutput = true,
        outputToChat = true,
        generateReport = true,
        categories = {
            "api",
            "addons",
            "libraries",
            "ui"
        }
    }
}

-- Compatibility Tester reference
local CT = VUI.CompatibilityTester

-- Log a message with color
function CT:Log(level, category, message)
    if not self.options.verboseOutput and level == "info" then
        return
    end
    
    local colors = {
        info = "ffffff",
        success = "00ff00",
        warning = "ffff00",
        error = "ff0000"
    }
    
    local prefix = "[CT:" .. category .. "] "
    local coloredMessage = "|cff" .. (colors[level] or "ffffff") .. prefix .. message .. "|r"
    
    if self.options.outputToChat then
        if VUI.Print then
            VUI:Print(coloredMessage)
        else
            print(coloredMessage)
        end
    end
    
    return coloredMessage
end

-- Initialize the results table
function CT:InitResults()
    self.results = {
        total = 0,
        passed = 0,
        failed = 0,
        warnings = 0,
        tests = {},
        startTime = time(),
        endTime = nil,
        totalTime = nil,
        buildInfo = {
            version = select(1, GetBuildInfo()),
            build = select(2, GetBuildInfo()),
            date = select(3, GetBuildInfo()),
            interface = select(4, GetBuildInfo()),
            locale = GetLocale(),
        }
    }
    
    -- Initialize categories
    for _, category in ipairs(self.options.categories) do
        self.results[category] = {
            total = 0,
            passed = 0,
            failed = 0,
            warnings = 0
        }
    end
end

-- Register a test
function CT:RegisterTest(category, name, func)
    if not self.tests[category] then
        self.tests[category] = {}
    end
    
    self.tests[category][name] = {
        func = func,
        executed = false,
        result = nil
    }
    
    self:Log("info", "Registration", "Registered compatibility test: " .. category .. " - " .. name)
end

-- Run a specific test
function CT:RunTest(category, name)
    if not self.tests[category] or not self.tests[category][name] then
        self:Log("error", "Execution", "Test not found: " .. category .. " - " .. name)
        return false
    end
    
    local test = self.tests[category][name]
    
    -- Skip if already executed
    if test.executed then
        return test.result
    end
    
    -- Execute the test
    self:Log("info", "Execution", "Running compatibility test: " .. category .. " - " .. name)
    
    local success, result = pcall(test.func)
    
    -- Record the result
    test.executed = true
    
    -- Update counters
    self.results.total = self.results.total + 1
    self.results[category].total = self.results[category].total + 1
    
    if not success then
        self:Log("error", "Execution", "Test failed with error: " .. tostring(result))
        test.result = {
            success = false,
            warning = false,
            error = tostring(result),
            message = "Test error"
        }
        
        self.results.failed = self.results.failed + 1
        self.results[category].failed = self.results[category].failed + 1
    else
        if type(result) ~= "table" then
            result = {
                success = result and true or false,
                warning = false,
                message = "Test " .. (result and "passed" or "failed")
            }
        end
        
        test.result = result
        
        if result.success then
            if result.warning then
                self:Log("warning", "Execution", "Test passed with warning: " .. category .. " - " .. name .. " - " .. (result.message or ""))
                self.results.warnings = self.results.warnings + 1
                self.results[category].warnings = self.results[category].warnings + 1
            else
                self:Log("success", "Execution", "Test passed: " .. category .. " - " .. name)
            end
            
            self.results.passed = self.results.passed + 1
            self.results[category].passed = self.results[category].passed + 1
        else
            self:Log("error", "Execution", "Test failed: " .. category .. " - " .. name .. " - " .. (result.message or "No error message"))
            self.results.failed = self.results.failed + 1
            self.results[category].failed = self.results[category].failed + 1
        end
    end
    
    -- Store test result
    self.results.tests[category .. ":" .. name] = test.result
    
    return test.result.success
end

-- Run all tests in a category
function CT:RunCategory(category)
    if not self.tests[category] then
        self:Log("error", "Execution", "Category not found: " .. category)
        return false
    end
    
    self:Log("info", "Execution", "Running all compatibility tests in category: " .. category)
    
    local allPassed = true
    for name, _ in pairs(self.tests[category]) do
        local result = self:RunTest(category, name)
        if not result then
            allPassed = false
        end
    end
    
    return allPassed
end

-- Run all tests
function CT:RunAll()
    self:InitResults()
    
    self:Log("info", "Execution", "Running all compatibility tests")
    
    local allPassed = true
    for category, _ in pairs(self.tests) do
        local categoryResult = self:RunCategory(category)
        if not categoryResult then
            allPassed = false
        end
    end
    
    -- Record end time
    self.results.endTime = time()
    self.results.totalTime = self.results.endTime - self.results.startTime
    
    -- Generate report
    if self.options.generateReport then
        self:GenerateReport()
    end
    
    return allPassed
end

-- Generate a test report
function CT:GenerateReport()
    local report = {
        "=== VUI Compatibility Test Report ===",
        "Run Date: " .. date("%Y-%m-%d %H:%M:%S", self.results.startTime),
        "Total Time: " .. self.results.totalTime .. " seconds",
        "",
        "--- WoW Build Info ---",
        "Version: " .. self.results.buildInfo.version,
        "Build: " .. self.results.buildInfo.build,
        "Date: " .. self.results.buildInfo.date,
        "Interface: " .. self.results.buildInfo.interface,
        "Locale: " .. self.results.buildInfo.locale,
        "",
        "--- Test Summary ---",
        "Total Tests: " .. self.results.total,
        "Passed: " .. self.results.passed .. " (" .. math.floor(self.results.passed / self.results.total * 100) .. "%)",
        "Failed: " .. self.results.failed .. " (" .. math.floor(self.results.failed / self.results.total * 100) .. "%)",
        "Warnings: " .. self.results.warnings .. " (" .. math.floor(self.results.warnings / self.results.total * 100) .. "%)",
        "",
        "--- Category Details ---"
    }
    
    -- Add category details
    for _, category in ipairs(self.options.categories) do
        if self.results[category].total > 0 then
            table.insert(report, category .. ": " .. self.results[category].passed .. "/" .. self.results[category].total .. 
                " passed (" .. math.floor(self.results[category].passed / self.results[category].total * 100) .. "%), " ..
                self.results[category].warnings .. " warnings")
        end
    end
    
    table.insert(report, "")
    table.insert(report, "--- Test Details ---")
    
    -- Add details of failed tests
    local failedCount = 0
    for testName, result in pairs(self.results.tests) do
        if not result.success then
            failedCount = failedCount + 1
            table.insert(report, testName .. ": FAILED - " .. (result.message or result.error or "No error message"))
        elseif result.warning then
            table.insert(report, testName .. ": PASSED WITH WARNING - " .. (result.message or "No warning message"))
        end
    end
    
    if failedCount == 0 and self.results.warnings == 0 then
        table.insert(report, "All tests passed without warnings!")
    end
    
    -- Save report to variable
    self.report = table.concat(report, "\n")
    
    -- Print summary
    self:Log("info", "Report", "Compatibility Test Summary: " .. self.results.passed .. "/" .. self.results.total .. " tests passed")
    
    -- Save report to file
    if VUI_CompatibilityReport then
        VUI_CompatibilityReport = self.report
    end
    
    return self.report
end

-- Register standard compatibility tests
function CT:RegisterStandardTests()
    -- API Compatibility Tests
    self:RegisterAPITests()
    
    -- Addon Compatibility Tests
    self:RegisterAddonTests()
    
    -- Library Compatibility Tests
    self:RegisterLibraryTests()
    
    -- UI Compatibility Tests
    self:RegisterUITests()
end

-- Register WoW API tests
function CT:RegisterAPITests()
    -- Test critical API functions
    self:RegisterTest("api", "critical_api_functions", function()
        local result = {
            success = true,
            warning = false,
            message = "All critical API functions available",
            missingAPIs = {}
        }
        
        -- List of critical Blizzard APIs used by VUI
        local criticalAPIs = {
            "CreateFrame",
            "GetAddOnMetadata",
            "IsAddOnLoaded",
            "GetCVar",
            "GetSpellInfo",
            "UnitClass",
            "UnitName",
            "GetRealmName",
            "GetFramerate",
            "InCombatLockdown",
            "UnitInRaid",
            "UnitInParty",
            "UnitExists",
            "UnitIsDead",
            "GetInventoryItemLink",
            "GetItemInfo",
            "GetContainerNumSlots"
        }
        
        -- Test each API
        for _, api in ipairs(criticalAPIs) do
            if not _G[api] then
                table.insert(result.missingAPIs, api)
                result.success = false
            end
        end
        
        if not result.success then
            result.message = "Missing critical API functions: " .. table.concat(result.missingAPIs, ", ")
        end
        
        return result
    end)
    
    -- Test API feature detection
    self:RegisterTest("api", "feature_detection", function()
        local result = {
            success = true,
            warning = false,
            message = "All required features detected",
            missingFeatures = {},
            warnings = {}
        }
        
        -- Optional API checks (warnings only)
        local optionalAPIs = {
            "C_Calendar",
            "C_Garrison",
            "C_AzeriteItem",
            "C_AzeriteEmpoweredItem",
            "C_Soulbinds",
            "C_Covenants"
        }
        
        for _, api in ipairs(optionalAPIs) do
            if not _G[api] then
                table.insert(result.warnings, api)
                result.warning = true
            end
        end
        
        -- Check for required features
        local buildVersion = select(4, GetBuildInfo())
        
        -- Interface version checks (30000 = 3.0.0, 90000 = 9.0.0, etc.)
        if buildVersion < 80000 then
            table.insert(result.missingFeatures, "World of Warcraft 8.0 or later is required")
            result.success = false
        end
        
        if buildVersion >= 100000 then
            table.insert(result.warnings, "World of Warcraft 10.0+ detected - some features might require updates")
            result.warning = true
        end
        
        if result.warning and #result.warnings > 0 then
            result.message = "Feature detection warnings: " .. table.concat(result.warnings, ", ")
        end
        
        if not result.success then
            result.message = "Missing required features: " .. table.concat(result.missingFeatures, ", ")
        end
        
        return result
    end)
end

-- Register addon compatibility tests
function CT:RegisterAddonTests()
    -- Test compatibility with popular addons
    self:RegisterTest("addons", "common_addons", function()
        local result = {
            success = true,
            warning = false,
            message = "No addon conflicts detected",
            conflicts = {},
            compatibleAddons = {}
        }
        
        -- List of addons known to be compatible
        local compatibleAddons = {
            "Details",
            "WeakAuras",
            "DBM-Core",
            "Plater",
            "BigWigs",
            "Auctionator",
            "Bagnon",
            "ElvUI"
        }
        
        -- List of addons known to have issues
        local problematicAddons = {
            -- Example: ["AddonName"] = "Specific issue description"
            ["TitanPanel"] = "Minor frame positioning conflicts",
            ["Bartender4"] = "Action bar skin conflicts if both enabled",
            ["MoveAnything"] = "Frame positioning conflicts possible"
        }
        
        -- Check for loaded problematic addons
        for addon, issue in pairs(problematicAddons) do
            if IsAddOnLoaded(addon) then
                table.insert(result.conflicts, addon .. ": " .. issue)
                result.warning = true
            end
        end
        
        -- Check for loaded compatible addons
        for _, addon in ipairs(compatibleAddons) do
            if IsAddOnLoaded(addon) then
                table.insert(result.compatibleAddons, addon)
            end
        end
        
        if result.warning and #result.conflicts > 0 then
            result.message = "Potential addon conflicts detected: " .. #result.conflicts
        end
        
        return result
    end)
    
    -- Test for hook conflicts
    self:RegisterTest("addons", "hook_conflicts", function()
        local result = {
            success = true,
            warning = false,
            message = "No hook conflicts detected",
            conflicts = {}
        }
        
        -- List of functions that might have hook conflicts
        local potentialConflicts = {
            "ContainerFrame_Update",
            "ChatFrame_OnEvent",
            "QuestLogTitleButton_OnClick",
            "GameTooltip_OnShow"
        }
        
        -- Check if the original function exists and has been modified
        for _, funcName in ipairs(potentialConflicts) do
            local func = _G[funcName]
            if func then
                -- No reliable way to detect if a function has been hooked
                -- This is a simplistic check that won't catch all hooks
                local info = debug.getinfo(func)
                if info.nups > 0 then
                    local hookCount = 0
                    for i = 1, info.nups do
                        local name, val = debug.getupvalue(func, i)
                        if name == "hooks" or name == "originalFunction" then
                            hookCount = hookCount + 1
                        end
                    end
                    
                    if hookCount > 1 then
                        table.insert(result.conflicts, funcName)
                        result.warning = true
                    end
                end
            end
        end
        
        if result.warning and #result.conflicts > 0 then
            result.message = "Potential hook conflicts detected: " .. table.concat(result.conflicts, ", ")
        end
        
        return result
    end)
end

-- Register library compatibility tests
function CT:RegisterLibraryTests()
    -- Test Ace3 compatibility
    self:RegisterTest("libraries", "ace3_compatibility", function()
        local result = {
            success = true,
            warning = false,
            message = "All required Ace3 libraries available",
            missingLibraries = {}
        }
        
        -- List of required Ace3 libraries
        local requiredLibraries = {
            "AceAddon-3.0",
            "AceConfig-3.0",
            "AceConsole-3.0",
            "AceDB-3.0",
            "AceEvent-3.0",
            "AceGUI-3.0",
            "AceHook-3.0",
            "AceLocale-3.0",
            "AceSerializer-3.0",
            "AceTimer-3.0"
        }
        
        -- Check for LibStub
        if not LibStub then
            table.insert(result.missingLibraries, "LibStub")
            result.success = false
        else
            -- Check each library
            for _, lib in ipairs(requiredLibraries) do
                if not LibStub:GetLibrary(lib, true) then
                    table.insert(result.missingLibraries, lib)
                    result.success = false
                end
            end
        end
        
        if not result.success then
            result.message = "Missing required libraries: " .. table.concat(result.missingLibraries, ", ")
        end
        
        return result
    end)
    
    -- Test other library dependencies
    self:RegisterTest("libraries", "utility_libraries", function()
        local result = {
            success = true,
            warning = false,
            message = "All utility libraries available",
            missingLibraries = {}
        }
        
        -- List of utility libraries
        local utilityLibraries = {
            "LibDeflate",
            "CallbackHandler-1.0"
        }
        
        -- Check for LibStub
        if not LibStub then
            table.insert(result.missingLibraries, "LibStub")
            result.success = false
        else
            -- Check each library
            for _, lib in ipairs(utilityLibraries) do
                if not LibStub:GetLibrary(lib, true) then
                    table.insert(result.missingLibraries, lib)
                    result.success = false
                end
            end
        end
        
        if not result.success then
            result.message = "Missing utility libraries: " .. table.concat(result.missingLibraries, ", ")
        end
        
        return result
    end)
    
    -- Test library versions
    self:RegisterTest("libraries", "library_versions", function()
        local result = {
            success = true,
            warning = false,
            message = "All libraries meet minimum version requirements",
            versionWarnings = {}
        }
        
        -- Library version requirements
        local requiredVersions = {
            ["AceAddon-3.0"] = "3.0.0",
            ["AceDB-3.0"] = "3.0.0",
            ["AceGUI-3.0"] = "3.0.0",
            ["LibDeflate"] = "1.0.0"
        }
        
        -- Check if LibStub exists
        if not LibStub then
            result.success = false
            result.message = "LibStub not found, cannot check library versions"
            return result
        end
        
        -- Check each library version
        for lib, minVersion in pairs(requiredVersions) do
            local libObj = LibStub:GetLibrary(lib, true)
            if libObj then
                local version = libObj.version or libObj.Version or "unknown"
                
                -- Simple version comparison (not perfect)
                if version ~= "unknown" and type(version) == "string" and version < minVersion then
                    table.insert(result.versionWarnings, lib .. " (have: " .. version .. ", need: " .. minVersion .. ")")
                    result.warning = true
                end
            end
        end
        
        if result.warning and #result.versionWarnings > 0 then
            result.message = "Library version warnings: " .. table.concat(result.versionWarnings, ", ")
        end
        
        return result
    end)
end

-- Register UI compatibility tests
function CT:RegisterUITests()
    -- Test scale and resolution compatibility
    self:RegisterTest("ui", "scale_resolution", function()
        local result = {
            success = true,
            warning = false,
            message = "UI scale compatible with current resolution",
            scaleInfo = {}
        }
        
        -- Get screen dimensions
        local screenWidth, screenHeight = GetPhysicalScreenSize()
        
        -- Get UI scale
        local uiScale = UIParent:GetScale()
        
        -- Calculate effective screen dimensions
        local effectiveWidth = screenWidth / uiScale
        local effectiveHeight = screenHeight / uiScale
        
        result.scaleInfo = {
            screenWidth = screenWidth,
            screenHeight = screenHeight,
            uiScale = uiScale,
            effectiveWidth = effectiveWidth,
            effectiveHeight = effectiveHeight
        }
        
        -- Check for extremely low or high resolutions
        if screenWidth < 1024 or screenHeight < 768 then
            result.warning = true
            result.message = "Low resolution detected (" .. screenWidth .. "x" .. screenHeight .. "), UI elements may be clipped"
        end
        
        -- Check for unusual aspect ratios
        local aspectRatio = screenWidth / screenHeight
        if aspectRatio < 1.3 or aspectRatio > 2.5 then
            result.warning = true
            result.message = "Unusual aspect ratio detected (" .. string.format("%.2f", aspectRatio) .. "), UI layout may be affected"
        end
        
        return result
    end)
    
    -- Test UI frame conflicts
    self:RegisterTest("ui", "frame_conflicts", function()
        local result = {
            success = true,
            warning = false,
            message = "No UI frame conflicts detected",
            conflicts = {}
        }
        
        -- Check for overlaps with known UI elements
        local knownConflicts = {
            {name = "Minimap", detection = function() return Minimap and Minimap:IsVisible() end},
            {name = "ObjectiveTracker", detection = function() return ObjectiveTrackerFrame and ObjectiveTrackerFrame:IsVisible() end},
            {name = "ChatFrames", detection = function() return ChatFrame1 and ChatFrame1:IsVisible() end}
        }
        
        -- VUI frames to check
        local vuiFrames = {}
        if VUI.frames then
            for name, frame in pairs(VUI.frames) do
                if frame and type(frame) == "table" and frame.IsObjectType and frame:IsObjectType("Frame") then
                    table.insert(vuiFrames, {name = name, frame = frame})
                end
            end
        end
        
        -- Check each VUI frame against known UI elements
        for _, vuiFrame in ipairs(vuiFrames) do
            if vuiFrame.frame:IsVisible() then
                local x, y = vuiFrame.frame:GetCenter()
                local width, height = vuiFrame.frame:GetSize()
                
                for _, conflict in ipairs(knownConflicts) do
                    if conflict.detection() then
                        -- This is a simplistic overlap detection
                        -- A real implementation would check actual frame bounds
                        -- For now, we just note that these frames exist simultaneously
                        table.insert(result.conflicts, vuiFrame.name .. " and " .. conflict.name)
                        result.warning = true
                    end
                end
            end
        end
        
        if result.warning and #result.conflicts > 0 then
            result.message = "Potential UI frame conflicts: " .. table.concat(result.conflicts, ", ")
        end
        
        return result
    end)
    
    -- Test taint issues
    self:RegisterTest("ui", "taint_protection", function()
        local result = {
            success = true,
            warning = false,
            message = "No taint issues detected",
            taintedGlobals = {}
        }
        
        -- Check for common taint sources
        local taintSensitiveFunctions = {
            "StaticPopup_Show",
            "GuildInvite",
            "InviteUnit",
            "UninviteUnit",
            "GetNumGroupMembers"
        }
        
        for _, funcName in ipairs(taintSensitiveFunctions) do
            local func = _G[funcName]
            if func and type(func) == "function" then
                -- Check if we're hooking it safely
                local hookFound = false
                if VUI.hooks and VUI.hooks[_G] and VUI.hooks[_G][funcName] then
                    hookFound = true
                    -- Safe hook found
                end
                
                -- Check if anyone else has modified it directly
                if not hookFound then
                    local info = debug.getinfo(func)
                    if info.source and not info.source:match("^%[C%]") then
                        table.insert(result.taintedGlobals, funcName)
                        result.warning = true
                    end
                end
            end
        end
        
        if result.warning and #result.taintedGlobals > 0 then
            result.message = "Potential taint issues with: " .. table.concat(result.taintedGlobals, ", ")
        end
        
        return result
    end)
end

-- Register with slash command handler
if VUI.RegisterSlashCommand then
    VUI:RegisterSlashCommand("compatibility", function(input)
        -- Parse options
        local category = nil
        if input and input ~= "" then
            category = input
        end
        
        -- Register standard tests
        CT:RegisterStandardTests()
        
        -- Run tests
        if category and CT.tests[category] then
            CT:InitResults()
            CT:RunCategory(category)
        else
            CT:RunAll()
        end
    end, "Run compatibility tests. Use 'compatibility [category]' to run specific test categories.")
end

-- Return the compatibility tester
return CT