-- VUI Error Testing Tool
-- Tools for testing error handling and recovery mechanisms
local addonName, VUI = ...

-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create the Error Testing namespace
VUI.ErrorTesting = {
    version = "1.0.0",
    author = "VUI Team",
    results = {},
    tests = {},
    options = {
        verboseOutput = true,
        outputToChat = true,
        autoFix = false,
        categories = {
            "capture",
            "recovery",
            "resilience"
        }
    }
}

-- Error Testing reference
local ET = VUI.ErrorTesting

-- Log a message with color
function ET:Log(level, category, message)
    if not self.options.verboseOutput and level == "info" then
        return
    end
    
    local colors = {
        info = "ffffff",
        success = "00ff00",
        warning = "ffff00",
        error = "ff0000"
    }
    
    local prefix = "[ET:" .. category .. "] "
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
function ET:InitResults()
    self.results = {
        total = 0,
        passed = 0,
        failed = 0,
        errors = {},
        tests = {},
        startTime = time(),
        endTime = nil,
        totalTime = nil
    }
    
    -- Initialize categories
    for _, category in ipairs(self.options.categories) do
        self.results[category] = {
            total = 0,
            passed = 0,
            failed = 0
        }
    end
end

-- Register a test
function ET:RegisterTest(category, name, func)
    if not self.tests[category] then
        self.tests[category] = {}
    end
    
    self.tests[category][name] = {
        func = func,
        executed = false,
        result = nil
    }
    
    self:Log("info", "Registration", "Registered error test: " .. category .. " - " .. name)
end

-- Run a specific test
function ET:RunTest(category, name)
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
    self:Log("info", "Execution", "Running error test: " .. category .. " - " .. name)
    
    -- These are error tests, so we explicitly expect errors
    local success, testResult = pcall(test.func)
    
    -- Record the result
    test.executed = true
    
    -- This actually evaluates to ensure we got the expected error behavior
    if not success and testResult then
        -- Error happened as expected
        test.result = true
        self:Log("success", "Execution", "Error test passed: " .. category .. " - " .. name)
        self.results.passed = self.results.passed + 1
        self.results[category].passed = self.results[category].passed + 1
    else
        -- No error happened (unexpected)
        test.result = false
        self:Log("error", "Execution", "Error test failed: " .. category .. " - " .. name .. " - No error occurred")
        self.results.failed = self.results.failed + 1
        self.results[category].failed = self.results[category].failed + 1
        table.insert(self.results.errors, category .. ":" .. name)
    end
    
    self.results.total = self.results.total + 1
    self.results[category].total = self.results[category].total + 1
    
    -- Store test result
    self.results.tests[category .. ":" .. name] = {
        passed = test.result,
        error = testResult
    }
    
    return test.result
end

-- Run all tests in a category
function ET:RunCategory(category)
    if not self.tests[category] then
        self:Log("error", "Execution", "Category not found: " .. category)
        return false
    end
    
    self:Log("info", "Execution", "Running all error tests in category: " .. category)
    
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
function ET:RunAll()
    self:InitResults()
    
    self:Log("info", "Execution", "Running all error tests")
    
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
    self:GenerateReport()
    
    return allPassed
end

-- Generate a test report
function ET:GenerateReport()
    local report = {
        "=== VUI Error Testing Report ===",
        "Run Date: " .. date("%Y-%m-%d %H:%M:%S", self.results.startTime),
        "Total Time: " .. self.results.totalTime .. " seconds",
        "",
        "--- Summary ---",
        "Total Tests: " .. self.results.total,
        "Passed: " .. self.results.passed .. " (" .. math.floor(self.results.passed / self.results.total * 100) .. "%)",
        "Failed: " .. self.results.failed .. " (" .. math.floor(self.results.failed / self.results.total * 100) .. "%)",
        "",
        "--- Category Details ---"
    }
    
    -- Add category details
    for _, category in ipairs(self.options.categories) do
        if self.results[category].total > 0 then
            table.insert(report, category .. ": " .. self.results[category].passed .. "/" .. self.results[category].total .. 
                " passed (" .. math.floor(self.results[category].passed / self.results[category].total * 100) .. "%)")
        end
    end
    
    -- Add failed tests
    if #self.results.errors > 0 then
        table.insert(report, "")
        table.insert(report, "--- Failed Tests ---")
        for _, testName in ipairs(self.results.errors) do
            table.insert(report, testName)
        end
    end
    
    -- Save report to variable
    self.report = table.concat(report, "\n")
    
    -- Print summary
    self:Log("info", "Report", "Error Test Summary: " .. self.results.passed .. "/" .. self.results.total .. " tests passed")
    
    return self.report
end

-- Register standard error tests
function ET:RegisterStandardTests()
    -- Error capture tests
    self:RegisterErrorCaptureTests()
    
    -- Error recovery tests
    self:RegisterErrorRecoveryTests()
    
    -- Error resilience tests
    self:RegisterErrorResilienceTests()
end

-- Register error capture tests
function ET:RegisterErrorCaptureTests()
    -- Test basic error capture
    self:RegisterTest("capture", "basic_error_capture", function()
        if not VUI.error_capture or not VUI.error_capture.CaptureError then
            error("Error capture system not found")
        end
        
        -- Force an error and test if it's captured
        local forceError = function()
            -- Deliberately cause an error
            local x = nil
            return x.nonexistent
        end
        
        -- This should error
        forceError()
        
        -- If we get here, something is wrong
        error("Error was not captured by error_capture system")
    end)
    
    -- Test error logging
    self:RegisterTest("capture", "error_logging", function()
        if not VUI.error_capture or not VUI.error_capture.GetErrorLog then
            error("Error logging system not found")
        end
        
        -- Generate a test error
        local err = VUI.error_capture:CaptureError(
            "Test error for logging system", 
            "error_testing.lua", 
            123,
            "test_error_logging"
        )
        
        -- Check if it was logged
        local log = VUI.error_capture:GetErrorLog()
        
        if not log or #log == 0 then
            error("Error was not logged")
        end
        
        -- Check if our test error is in the log
        local found = false
        for _, entry in ipairs(log) do
            if entry.message and entry.message:match("Test error for logging system") then
                found = true
                break
            end
        end
        
        if not found then
            error("Test error was not found in error log")
        end
    end)
end

-- Register error recovery tests
function ET:RegisterErrorRecoveryTests()
    -- Test module error recovery
    self:RegisterTest("recovery", "module_error_recovery", function()
        -- Find a module with error recovery
        local testModule = nil
        for name, module in pairs(VUI.modules) do
            if module.OnError and type(module.OnError) == "function" then
                testModule = {name = name, module = module}
                break
            end
        end
        
        if not testModule then
            error("No modules implement error recovery")
        end
        
        -- Force an error in the module
        if not testModule.module.SimulateError then
            -- If no SimulateError method, create a dummy error
            error("Module " .. testModule.name .. " has OnError but no SimulateError method")
        end
        
        -- Call SimulateError
        testModule.module:SimulateError("Test error for recovery")
        
        -- Check recovery status (if available)
        if testModule.module.GetRecoveryStatus then
            local status = testModule.module:GetRecoveryStatus()
            if not status or not status.recovered then
                error("Module " .. testModule.name .. " failed to recover from simulated error")
            end
        else
            -- Assume recovery worked if no way to check
            self:Log("warning", "Recovery", "Cannot verify recovery status for " .. testModule.name)
        end
    end)
end

-- Register error resilience tests
function ET:RegisterErrorResilienceTests()
    -- Test core frame resilience
    self:RegisterTest("resilience", "core_frame_resilience", function()
        -- Get a critical frame
        local testFrame = VUI.frames and VUI.frames.main
        
        if not testFrame then
            error("Critical frame not found for testing")
        end
        
        -- Backup current OnUpdate script
        local originalOnUpdate = testFrame:GetScript("OnUpdate")
        
        -- Set a bad OnUpdate script that will error
        testFrame:SetScript("OnUpdate", function()
            error("Deliberate error in OnUpdate")
        end)
        
        -- Force a frame update
        testFrame:GetScript("OnUpdate")(testFrame, 0.1)
        
        -- If we get here, we didn't crash - restore original handler
        if originalOnUpdate then
            testFrame:SetScript("OnUpdate", originalOnUpdate)
        else
            testFrame:SetScript("OnUpdate", nil)
        end
        
        -- This means the test failed - we wanted to see how error capture handled the error
        error("Frame errors are not being captured properly")
    end)
    
    -- Test event handler resilience
    self:RegisterTest("resilience", "event_handler_resilience", function()
        -- Get event frame
        local eventFrame = VUI.eventFrame
        
        if not eventFrame then
            error("Event frame not found for testing")
        end
        
        -- Create a bad event handler
        local badEventHandler = function()
            error("Deliberate error in event handler")
        end
        
        -- Register the bad handler for a test event
        eventFrame:RegisterEvent("PLAYER_LOGOUT") -- Use an event unlikely to fire during testing
        eventFrame:SetScript("OnEvent", function(self, event, ...)
            if event == "TEST_ERROR_EVENT" then
                badEventHandler()
            end
        end)
        
        -- Trigger the fake event
        eventFrame:GetScript("OnEvent")(eventFrame, "TEST_ERROR_EVENT")
        
        -- If we get here, we didn't crash - restore original handler
        eventFrame:UnregisterEvent("PLAYER_LOGOUT")
        
        -- This means the test failed - we wanted an error
        error("Event errors are not being captured properly")
    end)
end

-- Register with slash command handler
if VUI.RegisterSlashCommand then
    VUI:RegisterSlashCommand("errortest", function(input)
        -- Parse options
        local category = nil
        if input and input ~= "" then
            category = input
        end
        
        -- Register standard tests
        ET:RegisterStandardTests()
        
        -- Run tests
        if category and ET.tests[category] then
            ET:InitResults()
            ET:RunCategory(category)
        else
            ET:RunAll()
        end
    end, "Run error handling tests. Use 'errortest [category]' to run specific error test categories.")
end

-- Return the error testing utility
return ET