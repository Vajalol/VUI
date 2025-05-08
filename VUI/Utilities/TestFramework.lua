-- VUI Test Framework
-- Provides testing utilities for VUI modules
-- Author: VortexQ8

local AddonName, VUI = ...

-- Create the Test namespace
VUI.Test = VUI.Test or {}

-- Test status constants
VUI.Test.Status = {
    PASSED = 1,
    FAILED = 2,
    SKIPPED = 3,
    NOT_TESTED = 4
}

-- List of registered tests
VUI.Test.RegisteredTests = {}

-- Test results
VUI.Test.Results = {}

-- Register a test case
function VUI.Test:RegisterTest(moduleName, testName, testFunc, dependencies)
    if not self.RegisteredTests[moduleName] then
        self.RegisteredTests[moduleName] = {}
    end
    
    self.RegisteredTests[moduleName][testName] = {
        func = testFunc,
        dependencies = dependencies or {},
        status = self.Status.NOT_TESTED,
        errorMsg = nil
    }
    
    VUI:Debug("Test", "Registered test: " .. moduleName .. "." .. testName)
end

-- Run all tests for a specific module
function VUI.Test:RunModuleTests(moduleName)
    if not self.RegisteredTests[moduleName] then
        VUI:Print("No tests registered for module: " .. moduleName)
        return
    end
    
    VUI:Print("Running tests for " .. moduleName .. "...")
    
    local results = {
        passed = 0,
        failed = 0,
        skipped = 0,
        total = 0
    }
    
    -- Clear previous results
    self.Results[moduleName] = {}
    
    -- Run each test
    for testName, testInfo in pairs(self.RegisteredTests[moduleName]) do
        results.total = results.total + 1
        
        -- Check dependencies
        local skipTest = false
        for _, dependency in ipairs(testInfo.dependencies) do
            local dependModule, dependTest = dependency:match("([^.]+)%.(.+)")
            
            if not dependModule or not dependTest then
                -- Invalid dependency format
                skipTest = true
                testInfo.status = self.Status.SKIPPED
                testInfo.errorMsg = "Invalid dependency format: " .. dependency
                break
            end
            
            if not self.Results[dependModule] or 
               not self.Results[dependModule][dependTest] or 
               self.Results[dependModule][dependTest].status ~= self.Status.PASSED then
                -- Dependency not satisfied
                skipTest = true
                testInfo.status = self.Status.SKIPPED
                testInfo.errorMsg = "Dependency not satisfied: " .. dependency
                break
            end
        end
        
        if skipTest then
            results.skipped = results.skipped + 1
            VUI:Print("  - " .. testName .. ": |cFFFFFF00SKIPPED|r - " .. testInfo.errorMsg)
        else
            -- Run the test
            local success, errorMsg = pcall(testInfo.func)
            
            if success then
                results.passed = results.passed + 1
                testInfo.status = self.Status.PASSED
                VUI:Print("  - " .. testName .. ": |cFF00FF00PASSED|r")
            else
                results.failed = results.failed + 1
                testInfo.status = self.Status.FAILED
                testInfo.errorMsg = errorMsg
                VUI:Print("  - " .. testName .. ": |cFFFF0000FAILED|r - " .. errorMsg)
            end
        end
        
        -- Store results
        self.Results[moduleName][testName] = {
            status = testInfo.status,
            errorMsg = testInfo.errorMsg
        }
    end
    
    -- Print summary
    VUI:Print(string.format("Test results for %s: %d passed, %d failed, %d skipped (out of %d total)",
        moduleName, results.passed, results.failed, results.skipped, results.total))
        
    return results
end

-- Run all tests for all modules
function VUI.Test:RunAllTests()
    VUI:Print("Running all tests...")
    
    local totalResults = {
        passed = 0,
        failed = 0,
        skipped = 0,
        total = 0
    }
    
    for moduleName, _ in pairs(self.RegisteredTests) do
        local results = self:RunModuleTests(moduleName)
        
        totalResults.passed = totalResults.passed + results.passed
        totalResults.failed = totalResults.failed + results.failed
        totalResults.skipped = totalResults.skipped + results.skipped
        totalResults.total = totalResults.total + results.total
    end
    
    -- Print total summary
    VUI:Print(string.format("Total test results: %d passed, %d failed, %d skipped (out of %d total)",
        totalResults.passed, totalResults.failed, totalResults.skipped, totalResults.total))
        
    return totalResults
end

-- Assertion functions for use in tests
function VUI.Test:AssertEqual(actual, expected, message)
    if actual ~= expected then
        error(string.format("%s: Expected %s but got %s", 
            message or "Assertion failed", tostring(expected), tostring(actual)))
    end
    return true
end

function VUI.Test:AssertNotEqual(actual, expected, message)
    if actual == expected then
        error(string.format("%s: Expected value to differ from %s", 
            message or "Assertion failed", tostring(expected)))
    end
    return true
end

function VUI.Test:AssertTrue(value, message)
    if value ~= true then
        error(string.format("%s: Expected true but got %s", 
            message or "Assertion failed", tostring(value)))
    end
    return true
end

function VUI.Test:AssertFalse(value, message)
    if value ~= false then
        error(string.format("%s: Expected false but got %s", 
            message or "Assertion failed", tostring(value)))
    end
    return true
end

function VUI.Test:AssertNil(value, message)
    if value ~= nil then
        error(string.format("%s: Expected nil but got %s", 
            message or "Assertion failed", tostring(value)))
    end
    return true
end

function VUI.Test:AssertNotNil(value, message)
    if value == nil then
        error(string.format("%s: Expected non-nil value", 
            message or "Assertion failed"))
    end
    return true
end

function VUI.Test:AssertTable(value, message)
    if type(value) ~= "table" then
        error(string.format("%s: Expected table but got %s", 
            message or "Assertion failed", type(value)))
    end
    return true
end

function VUI.Test:AssertFunction(value, message)
    if type(value) ~= "function" then
        error(string.format("%s: Expected function but got %s", 
            message or "Assertion failed", type(value)))
    end
    return true
end

function VUI.Test:AssertString(value, message)
    if type(value) ~= "string" then
        error(string.format("%s: Expected string but got %s", 
            message or "Assertion failed", type(value)))
    end
    return true
end

function VUI.Test:AssertNumber(value, message)
    if type(value) ~= "number" then
        error(string.format("%s: Expected number but got %s", 
            message or "Assertion failed", type(value)))
    end
    return true
end

function VUI.Test:AssertBoolean(value, message)
    if type(value) ~= "boolean" then
        error(string.format("%s: Expected boolean but got %s", 
            message or "Assertion failed", type(value)))
    end
    return true
end

-- Add tests for Animation.lua
VUI.Test:RegisterTest("Animations", "FadeIn", function()
    -- Create a test frame
    local frame = CreateFrame("Frame")
    frame:SetAlpha(0)
    
    -- Run the test only if Animations module exists
    if not VUI.Animations or not VUI.Animations.FadeIn then
        error("Animations module is not available")
    end
    
    -- Test the FadeIn function
    VUI.Animations:FadeIn(frame, 0.1, function()
        VUI.Test:AssertEqual(frame:GetAlpha(), 1, "Alpha should be 1 after fade in")
    end)
    
    return true
end)

VUI.Test:RegisterTest("Animations", "FadeOut", function()
    -- Create a test frame
    local frame = CreateFrame("Frame")
    frame:SetAlpha(1)
    
    -- Run the test only if Animations module exists
    if not VUI.Animations or not VUI.Animations.FadeOut then
        error("Animations module is not available")
    end
    
    -- Test the FadeOut function
    VUI.Animations:FadeOut(frame, 0.1, function()
        VUI.Test:AssertEqual(frame:GetAlpha(), 0, "Alpha should be 0 after fade out")
    end)
    
    return true
end)

-- Register slash command for testing
SLASH_VUITEST1 = "/vuitest"
SlashCmdList["VUITEST"] = function(msg)
    if msg and msg ~= "" then
        VUI.Test:RunModuleTests(msg)
    else
        VUI.Test:RunAllTests()
    end
end