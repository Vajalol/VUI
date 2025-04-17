-- VUI Integration Test Utility
-- This file provides tools to verify that all components are connected and functioning correctly
local _, VUI = ...

-- Create test namespace
VUI.Test = {}

-- Store test results
VUI.Test.results = {}

-- Function to run all tests
function VUI.Test:RunAll()
    self:TestCore()
    self:TestFrameworks()
    self:TestModules()
    self:TestIntegration()
    
    -- Print summary report
    self:PrintReport()
end

-- Test core functionality
function VUI.Test:TestCore()
    local test = {
        name = "Core Components",
        results = {}
    }
    
    -- Basic namespace tests
    self:AddResult(test, "VUI Global", VUI ~= nil)
    self:AddResult(test, "VUI.db", VUI.db ~= nil)
    self:AddResult(test, "VUI Options", VUI.options ~= nil)
    self:AddResult(test, "VUI Version", VUI.version ~= nil)
    
    -- Helper functions
    self:AddResult(test, "VUI:Print", type(VUI.Print) == "function")
    self:AddResult(test, "VUI:RegisterModule", type(VUI.RegisterModule) == "function")
    self:AddResult(test, "VUI:IsModuleEnabled", type(VUI.IsModuleEnabled) == "function")
    
    -- Core system interactions
    self:AddResult(test, "Database Access", self:TryFunction(function() 
        return VUI.db.profile.general ~= nil
    end))
    
    -- Store results
    self.results.core = test
end

-- Test framework components
function VUI.Test:TestFrameworks()
    local test = {
        name = "Framework Components",
        results = {}
    }
    
    -- UI framework
    self:AddResult(test, "UI Framework", VUI.UI ~= nil)
    if VUI.UI then
        self:AddResult(test, "UI.CreateFrame", type(VUI.UI.CreateFrame) == "function")
        self:AddResult(test, "UI.CreateButton", type(VUI.UI.CreateButton) == "function")
        self:AddResult(test, "UI.CreateCheckButton", type(VUI.UI.CreateCheckButton) == "function")
    end
    
    -- Widgets framework
    self:AddResult(test, "Widgets Framework", VUI.Widgets ~= nil)
    if VUI.Widgets then
        self:AddResult(test, "Widgets.CreatePanel", type(VUI.Widgets.CreatePanel) == "function")
        self:AddResult(test, "Widgets.CreateProgressBar", type(VUI.Widgets.CreateProgressBar) == "function")
        self:AddResult(test, "Widgets.CreateIconGrid", type(VUI.Widgets.CreateIconGrid) == "function")
    end
    
    -- Media system
    self:AddResult(test, "Media System", VUI.media ~= nil)
    if VUI.media then
        self:AddResult(test, "Media Textures", VUI.media.textures ~= nil)
        self:AddResult(test, "Media Fonts", VUI.media.fonts ~= nil)
        self:AddResult(test, "Media Themes", VUI.media.themes ~= nil)
    end
    
    -- Utilities
    self:AddResult(test, "Utils System", VUI.Utils ~= nil)
    if VUI.Utils then
        self:AddResult(test, "Utils.CopyTable", type(VUI.Utils.CopyTable) == "function")
        self:AddResult(test, "Utils.ColorText", type(VUI.Utils.ColorText) == "function")
        self:AddResult(test, "Utils.FormatTime", type(VUI.Utils.FormatTime) == "function")
    end
    
    -- Module template system
    self:AddResult(test, "Module Template", VUI.ModuleTemplate ~= nil)
    if VUI.ModuleTemplate then
        self:AddResult(test, "ModuleTemplate.Create", type(VUI.ModuleTemplate.Create) == "function")
        self:AddResult(test, "ModuleTemplate.Extend", type(VUI.ModuleTemplate.Extend) == "function")
    end
    
    -- Module API
    self:AddResult(test, "Module API", VUI.ModuleAPI ~= nil)
    if VUI.ModuleAPI then
        self:AddResult(test, "ModuleAPI.CreateModule", type(VUI.ModuleAPI.CreateModule) == "function")
        self:AddResult(test, "ModuleAPI.InitializeModuleSettings", type(VUI.ModuleAPI.InitializeModuleSettings) == "function")
    end
    
    -- Integration system
    self:AddResult(test, "Integration System", VUI.Integration ~= nil)
    if VUI.Integration then
        self:AddResult(test, "Integration.Initialize", type(VUI.Integration.Initialize) == "function")
        self:AddResult(test, "Integration.ConnectSystems", type(VUI.Integration.ConnectSystems) == "function")
    end
    
    -- Store results
    self.results.frameworks = test
end

-- Test module components
function VUI.Test:TestModules()
    local test = {
        name = "Module Components",
        results = {}
    }
    
    -- Check for modules
    self:AddResult(test, "Modules Table", VUI.modules ~= nil)
    
    -- Count modules
    local count = 0
    if VUI.modules then
        for name, module in pairs(VUI.modules) do
            count = count + 1
        end
    end
    
    self:AddResult(test, "Module Count", count > 0)
    
    -- Check core module functions
    if count > 0 then
        local anyModule
        for name, module in pairs(VUI.modules) do
            anyModule = module
            break
        end
        
        if anyModule then
            self:AddResult(test, "Module.Initialize", type(anyModule.Initialize) == "function")
            self:AddResult(test, "Module.Enable", type(anyModule.Enable) == "function")
            self:AddResult(test, "Module.Disable", type(anyModule.Disable) == "function")
        end
    end
    
    -- Test basic module interactions
    self:AddResult(test, "Module Settings Access", self:TryFunction(function()
        for name, module in pairs(VUI.modules) do
            if VUI.db.profile.modules[name] == nil then
                return false
            end
        end
        return true
    end))
    
    -- Store results
    self.results.modules = test
end

-- Test integration between components
function VUI.Test:TestIntegration()
    local test = {
        name = "System Integration",
        results = {}
    }
    
    -- Test UI-Media integration
    self:AddResult(test, "UI-Media Integration", self:TryFunction(function()
        if not VUI.UI or not VUI.UI.GetThemeColors then
            return false
        end
        
        local colors = VUI.UI:GetThemeColors()
        return colors and colors.backdrop and colors.text
    end))
    
    -- Test UI-Widgets integration
    self:AddResult(test, "UI-Widgets Integration", self:TryFunction(function()
        if not VUI.Widgets or not VUI.UI then
            return false
        end
        
        -- Check if widgets can access theme colors
        if not VUI.Widgets.GetThemeColors then
            return false
        end
        
        return true
    end))
    
    -- Test module-framework integration
    self:AddResult(test, "Module-Framework Integration", self:TryFunction(function()
        if not VUI.modules then
            return false
        end
        
        for name, module in pairs(VUI.modules) do
            if module.ConnectUI == nil or module.ConnectWidgets == nil or module.ConnectMedia == nil then
                return false
            end
        end
        
        return true
    end))
    
    -- Test theme application
    self:AddResult(test, "Theme System Integration", self:TryFunction(function()
        -- Check if theme changes propagate to UI
        return VUI.db.profile.appearance.theme ~= nil and 
               VUI.media.themes[VUI.db.profile.appearance.theme] ~= nil
    end))
    
    -- Test config system integration
    self:AddResult(test, "Config System Integration", self:TryFunction(function()
        return VUI.options and VUI.options.args and VUI.options.args.modules
    end))
    
    -- Store results
    self.results.integration = test
end

-- Helper function to add a test result
function VUI.Test:AddResult(test, name, success)
    table.insert(test.results, {name = name, success = success})
end

-- Helper function to safely try a test function
function VUI.Test:TryFunction(func)
    local success, result = pcall(func)
    return success and result
end

-- Print test report
function VUI.Test:PrintReport()
    VUI:Print("|cFF00FF00VUI Integration Test Report|r")
    
    local totalTests = 0
    local passedTests = 0
    
    -- Print results for each category
    for category, test in pairs(self.results) do
        VUI:Print("|cFFFFD100" .. test.name .. "|r")
        
        for _, result in ipairs(test.results) do
            local status = result.success and "|cFF00FF00PASS|r" or "|cFFFF0000FAIL|r"
            VUI:Print("  • " .. result.name .. ": " .. status)
            
            totalTests = totalTests + 1
            if result.success then
                passedTests = passedTests + 1
            end
        end
        
        VUI:Print(" ")
    end
    
    -- Print summary
    local successRate = totalTests > 0 and (passedTests / totalTests * 100) or 0
    local summaryColor = successRate >= 90 and "|cFF00FF00" or
                          successRate >= 70 and "|cFFFFFF00" or 
                          "|cFFFF0000"
    
    VUI:Print(summaryColor .. "Test Summary: " .. passedTests .. "/" .. totalTests .. 
              " tests passed (" .. math.floor(successRate) .. "%)|r")
    
    if successRate < 100 then
        VUI:Print("|cFFFF6600Some components may not be properly connected.|r")
        VUI:Print("|cFFFF6600Check the test results above for specific issues.|r")
    else
        VUI:Print("|cFF00FF00All components are properly connected and functioning!|r")
    end
end

-- Register the test command
SLASH_VUITEST1 = "/vuitest"
SlashCmdList["VUITEST"] = function()
    VUI.Test:RunAll()
end