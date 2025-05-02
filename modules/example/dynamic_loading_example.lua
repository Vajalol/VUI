--[[
    VUI - Example Dynamic Loading Module
    Author: VortexQ8
    
    Demonstrates the use of dynamic module loading in VUI modules.
]]

local _, VUI = ...
local ExampleModule = VUI:GetModule("Example") or VUI:NewModule("Example")

-- Reference to the dynamic loading system
local DynamicLoading = VUI.DynamicModuleLoading

-- Example function to demonstrate loading a module
function ExampleModule:DemonstrateDynamicLoading()
    VUI:Print("Dynamic Loading Example:")
    
    -- Check if dynamic loading is available
    if not DynamicLoading then
        VUI:Print("|cFFFF0000Dynamic Module Loading system not available|r")
        return
    end
    
    -- Get module list
    local moduleList = DynamicLoading:GetModuleList()
    VUI:Print(string.format("Total registered modules: %d", #moduleList))
    
    -- Display loaded and unloaded modules
    local loadedCount = 0
    local unloadedCount = 0
    
    for _, info in ipairs(moduleList) do
        if info.state >= 2 then -- LOADED or higher
            loadedCount = loadedCount + 1
        else
            unloadedCount = unloadedCount + 1
        end
    end
    
    VUI:Print(string.format("Loaded modules: %d, Unloaded modules: %d", loadedCount, unloadedCount))
    
    -- Get memory usage stats
    local memStats = DynamicLoading:GetMemoryUsage()
    VUI:Print(string.format("Total memory used by modules: %.2f KB", memStats.totalMemory))
    
    -- Display largest modules
    VUI:Print("Top memory usage modules:")
    for i, info in ipairs(memStats.largestModules) do
        VUI:Print(string.format("%d. %s: %.2f KB", i, info.name, info.memory))
    end
    
    -- Display module status information
    VUI:Print("Module Status:")
    VUI:Print("Core modules (always loaded):")
    for _, info in ipairs(moduleList) do
        if info.isCore then
            local stateText
            if info.state == 0 then
                stateText = "|cFFFF0000UNLOADED|r"
            elseif info.state == 1 then
                stateText = "|cFFFFFF00LOADING|r"
            elseif info.state == 2 then
                stateText = "|cFF00FF00LOADED|r"
            elseif info.state == 3 then
                stateText = "|cFF00FF00INITIALIZED|r"
            elseif info.state == 4 then
                stateText = "|cFF00FF00ENABLED|r"
            else
                stateText = "|cFFFF0000ERROR|r"
            end
            
            VUI:Print(string.format("- %s: %s (%.2f KB, load time: %.2fms)", 
                info.name, stateText, info.memoryUsage or 0, info.loadTime or 0))
        end
    end
    
    -- Example: Load a module dynamically
    VUI:Print("\nDemonstrating dynamic loading:")
    
    -- Choose a module that isn't loaded yet
    local moduleToLoad
    for _, info in ipairs(moduleList) do
        if not info.isCore and info.state == 0 then
            moduleToLoad = info.name
            break
        end
    end
    
    if moduleToLoad then
        VUI:Print("Loading module: " .. moduleToLoad)
        
        DynamicLoading:LoadModule(moduleToLoad, function(success, message)
            if success then
                VUI:Print(string.format("|cFF00FF00Successfully loaded %s|r", moduleToLoad))
                
                -- Get updated module info
                local updatedList = DynamicLoading:GetModuleList()
                local moduleInfo
                
                for _, info in ipairs(updatedList) do
                    if info.name == moduleToLoad then
                        moduleInfo = info
                        break
                    end
                end
                
                if moduleInfo then
                    VUI:Print(string.format("Module memory usage: %.2f KB", moduleInfo.memoryUsage or 0))
                    VUI:Print(string.format("Module load time: %.2f ms", moduleInfo.loadTime or 0))
                end
                
                -- Example: Now unload it
                C_Timer.After(2, function()
                    VUI:Print("Unloading module: " .. moduleToLoad)
                    
                    local unloadSuccess = DynamicLoading:UnloadModule(moduleToLoad)
                    if unloadSuccess then
                        VUI:Print("|cFF00FF00Successfully unloaded " .. moduleToLoad .. "|r")
                    else
                        VUI:Print("|cFFFF0000Failed to unload " .. moduleToLoad .. "|r")
                    end
                end)
            else
                VUI:Print("|cFFFF0000Failed to load " .. moduleToLoad .. ": " .. message .. "|r")
            end
        end)
    else
        VUI:Print("No suitable module found for dynamic loading demonstration")
    end
    
    -- Example: Module dependency handling
    VUI:Print("\nDemonstrating dependency handling:")
    
    -- Find a module with dependencies
    local dependentModule
    for _, info in ipairs(moduleList) do
        if #info.dependencies > 0 then
            dependentModule = info.name
            break
        end
    end
    
    if dependentModule then
        VUI:Print("Loading module with dependencies: " .. dependentModule)
        
        DynamicLoading:LoadModule(dependentModule, function(success, message)
            if success then
                VUI:Print("|cFF00FF00Successfully loaded " .. dependentModule .. " and all its dependencies|r")
            else
                VUI:Print("|cFFFF0000Failed to load " .. dependentModule .. ": " .. message .. "|r")
            end
        end)
    else
        VUI:Print("No module with dependencies found for demonstration")
    end
    
    -- Example: Performance optimization
    VUI:Print("\nPerformance metrics:")
    if DynamicLoading:GetPerformanceMetrics then
        local metrics = DynamicLoading:GetPerformanceMetrics()
        
        VUI:Print(string.format("Total memory usage: %.2f KB", metrics.totalMemory or 0))
        VUI:Print(string.format("Loaded modules: %d / %d", metrics.loadedModules or 0, metrics.totalModules or 0))
        
        if metrics.slowestModules and #metrics.slowestModules > 0 then
            VUI:Print("Slowest loading modules:")
            for i, info in ipairs(metrics.slowestModules) do
                if i <= 3 then
                    VUI:Print(string.format("%d. %s: %.2f ms (%.2f KB)", 
                        i, info.name, info.loadTime or 0, info.memory or 0))
                end
            end
        end
    else
        VUI:Print("Performance metrics not available")
    end
end

-- Register with VUI Module system
VUI:RegisterModuleScript("Example", "dynamic_loading_example")