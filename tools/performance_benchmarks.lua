-- VUI Performance Benchmarks
-- Tools for measuring and benchmarking addon performance
local addonName, VUI = ...

-- Fallback for test environments
if not VUI then VUI = _G.VUI end

-- Create the Performance Benchmarks namespace
VUI.PerformanceBenchmarks = {
    version = "1.0.0",
    author = "VUI Team",
    results = {},
    benchmarks = {},
    options = {
        verboseOutput = true,
        outputToChat = true,
        iterationCount = 5,
        categories = {
            "memory",
            "cpu",
            "framerate",
            "texture",
            "database",
            "combat",
            "module"
        }
    }
}

-- Performance Benchmarks reference
local PB = VUI.PerformanceBenchmarks

-- Get memory usage in KB
function PB:GetMemoryUsage()
    UpdateAddOnMemoryUsage()
    return GetAddOnMemoryUsage(addonName or "VUI")
end

-- Log a message with color
function PB:Log(level, category, message)
    if not self.options.verboseOutput and level == "info" then
        return
    end
    
    local colors = {
        info = "ffffff",
        success = "00ff00",
        warning = "ffff00",
        error = "ff0000"
    }
    
    local prefix = "[PB:" .. category .. "] "
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
function PB:InitResults()
    self.results = {
        startTime = time(),
        endTime = nil,
        totalTime = nil,
        memoryBefore = self:GetMemoryUsage(),
        memoryAfter = nil,
        memoryChange = nil,
        categories = {},
        benchmarkResults = {}
    }
    
    -- Initialize categories
    for _, category in ipairs(self.options.categories) do
        self.results.categories[category] = {
            benchmarks = 0,
            totalTime = 0,
            avgTime = 0
        }
    end
end

-- Register a benchmark
function PB:RegisterBenchmark(category, name, func, iterations)
    if not self.benchmarks[category] then
        self.benchmarks[category] = {}
    end
    
    self.benchmarks[category][name] = {
        func = func,
        iterations = iterations or self.options.iterationCount,
        executed = false
    }
    
    self:Log("info", "Registration", "Registered benchmark: " .. category .. " - " .. name)
end

-- Run a specific benchmark
function PB:RunBenchmark(category, name)
    if not self.benchmarks[category] or not self.benchmarks[category][name] then
        self:Log("error", "Execution", "Benchmark not found: " .. category .. " - " .. name)
        return nil
    end
    
    local benchmark = self.benchmarks[category][name]
    
    -- Skip if already executed
    if benchmark.executed then
        return self.results.benchmarkResults[category .. ":" .. name]
    end
    
    -- Execute the benchmark
    self:Log("info", "Execution", "Running benchmark: " .. category .. " - " .. name .. 
        " (" .. benchmark.iterations .. " iterations)")
    
    local memoryBefore = self:GetMemoryUsage()
    local iterationTimes = {}
    local totalTime = 0
    local success = true
    local errors = {}
    
    -- Run the benchmark multiple times
    for i = 1, benchmark.iterations do
        local startTime = debugprofilestop()
        local iterationSuccess, iterationResult = pcall(benchmark.func)
        local iterationTime = debugprofilestop() - startTime
        
        table.insert(iterationTimes, iterationTime)
        totalTime = totalTime + iterationTime
        
        if not iterationSuccess then
            success = false
            table.insert(errors, "Iteration " .. i .. ": " .. tostring(iterationResult))
        end
    end
    
    local memoryAfter = self:GetMemoryUsage()
    local avgTime = totalTime / benchmark.iterations
    
    -- Calculate min/max/median times
    table.sort(iterationTimes)
    local minTime = iterationTimes[1]
    local maxTime = iterationTimes[#iterationTimes]
    local medianTime = iterationTimes[math.ceil(#iterationTimes / 2)]
    
    -- Calculate standard deviation
    local variance = 0
    for _, time in ipairs(iterationTimes) do
        variance = variance + (time - avgTime)^2
    end
    variance = variance / #iterationTimes
    local stdDev = math.sqrt(variance)
    
    -- Record the result
    benchmark.executed = true
    
    local result = {
        category = category,
        name = name,
        success = success,
        iterations = benchmark.iterations,
        totalTime = totalTime,
        avgTime = avgTime,
        minTime = minTime,
        maxTime = maxTime,
        medianTime = medianTime,
        stdDev = stdDev,
        memoryBefore = memoryBefore,
        memoryAfter = memoryAfter,
        memoryChange = memoryAfter - memoryBefore,
        errors = errors
    }
    
    -- Update category stats
    self.results.categories[category].benchmarks = self.results.categories[category].benchmarks + 1
    self.results.categories[category].totalTime = self.results.categories[category].totalTime + totalTime
    self.results.categories[category].avgTime = self.results.categories[category].totalTime / self.results.categories[category].benchmarks
    
    -- Store the result
    self.results.benchmarkResults[category .. ":" .. name] = result
    
    -- Log the result
    if success then
        self:Log("success", "Execution", "Benchmark completed: " .. category .. " - " .. name .. 
            " - Avg: " .. string.format("%.2f", avgTime) .. "ms" ..
            " - Memory change: " .. string.format("%.2f", result.memoryChange) .. "KB")
    else
        self:Log("error", "Execution", "Benchmark failed: " .. category .. " - " .. name .. 
            " - Errors: " .. #errors)
    end
    
    return result
end

-- Run all benchmarks in a category
function PB:RunCategory(category)
    if not self.benchmarks[category] then
        self:Log("error", "Execution", "Category not found: " .. category)
        return nil
    end
    
    self:Log("info", "Execution", "Running all benchmarks in category: " .. category)
    
    local results = {}
    for name, _ in pairs(self.benchmarks[category]) do
        local result = self:RunBenchmark(category, name)
        if result then
            table.insert(results, result)
        end
    end
    
    return results
end

-- Run all benchmarks
function PB:RunAll()
    self:InitResults()
    
    self:Log("info", "Execution", "Running all benchmarks")
    
    local results = {}
    for category, _ in pairs(self.benchmarks) do
        local categoryResults = self:RunCategory(category)
        if categoryResults then
            for _, result in ipairs(categoryResults) do
                table.insert(results, result)
            end
        end
    end
    
    -- Record end time and memory usage
    self.results.endTime = time()
    self.results.totalTime = self.results.endTime - self.results.startTime
    self.results.memoryAfter = self:GetMemoryUsage()
    self.results.memoryChange = self.results.memoryAfter - self.results.memoryBefore
    
    -- Generate report
    self:GenerateReport()
    
    return results
end

-- Generate a benchmark report
function PB:GenerateReport()
    local report = {
        "=== VUI Performance Benchmark Report ===",
        "Run Date: " .. date("%Y-%m-%d %H:%M:%S", self.results.startTime),
        "Total Time: " .. self.results.totalTime .. " seconds",
        "Memory Usage: " .. string.format("%.2f", self.results.memoryBefore) .. "KB -> " .. 
            string.format("%.2f", self.results.memoryAfter) .. "KB (" .. 
            string.format("%+.2f", self.results.memoryChange) .. "KB)",
        "",
        "--- Category Summary ---"
    }
    
    -- Add category summary
    for category, data in pairs(self.results.categories) do
        if data.benchmarks > 0 then
            table.insert(report, category .. ": " .. data.benchmarks .. " benchmarks, " .. 
                "Avg time: " .. string.format("%.2f", data.avgTime) .. "ms")
        end
    end
    
    table.insert(report, "")
    table.insert(report, "--- Benchmark Details ---")
    
    -- Sort benchmarks by category
    local sortedBenchmarks = {}
    for id, result in pairs(self.results.benchmarkResults) do
        table.insert(sortedBenchmarks, result)
    end
    
    table.sort(sortedBenchmarks, function(a, b)
        if a.category == b.category then
            return a.avgTime > b.avgTime
        else
            return a.category < b.category
        end
    end)
    
    -- Add benchmark details
    local currentCategory = nil
    for _, result in ipairs(sortedBenchmarks) do
        if currentCategory ~= result.category then
            currentCategory = result.category
            table.insert(report, "")
            table.insert(report, "== " .. currentCategory .. " ==")
        end
        
        local status = result.success and "PASS" or "FAIL"
        table.insert(report, result.name .. " [" .. status .. "]: " .. 
            "Avg: " .. string.format("%.2f", result.avgTime) .. "ms, " .. 
            "Min: " .. string.format("%.2f", result.minTime) .. "ms, " .. 
            "Max: " .. string.format("%.2f", result.maxTime) .. "ms, " .. 
            "StdDev: " .. string.format("%.2f", result.stdDev) .. "ms, " .. 
            "Memory: " .. string.format("%+.2f", result.memoryChange) .. "KB")
    end
    
    -- Save report to variable
    self.report = table.concat(report, "\n")
    
    -- Print summary
    self:Log("info", "Report", "Performance Summary: " .. #sortedBenchmarks .. " benchmarks completed")
    
    -- Save report to file
    if VUI_BenchmarkReport then
        VUI_BenchmarkReport = self.report
    end
    
    return self.report
end

-- Register standard benchmarks
function PB:RegisterStandardBenchmarks()
    -- Memory benchmarks
    self:RegisterMemoryBenchmarks()
    
    -- CPU benchmarks
    self:RegisterCPUBenchmarks()
    
    -- Framerate benchmarks
    self:RegisterFramerateBenchmarks()
    
    -- Texture benchmarks
    self:RegisterTextureBenchmarks()
    
    -- Database benchmarks
    self:RegisterDatabaseBenchmarks()
    
    -- Combat benchmarks
    self:RegisterCombatBenchmarks()
    
    -- Module benchmarks
    self:RegisterModuleBenchmarks()
end

-- Register memory benchmarks
function PB:RegisterMemoryBenchmarks()
    -- Test memory usage during idle
    self:RegisterBenchmark("memory", "idle_usage", function()
        -- Measure idle memory usage
        local initialMemory = self:GetMemoryUsage()
        
        -- Simulate idle state (wait a short time)
        C_Timer.After(0.5, function() end)
        
        -- Measure again
        local finalMemory = self:GetMemoryUsage()
        
        return {
            initialMemory = initialMemory,
            finalMemory = finalMemory,
            change = finalMemory - initialMemory
        }
    end)
    
    -- Test memory usage during module load/unload
    self:RegisterBenchmark("memory", "module_load_unload", function()
        if not VUI.ModuleManager or not VUI.ModuleManager.EnableModule or not VUI.ModuleManager.DisableModule then
            error("ModuleManager functions not found")
        end
        
        -- Select a non-critical module to test with
        local testModule = "InfoFrame" -- This should be customized to a module that can be safely disabled
        
        -- Measure memory before
        local memoryBefore = self:GetMemoryUsage()
        
        -- Disable module
        VUI.ModuleManager:DisableModule(testModule)
        
        -- Measure memory after disable
        local memoryAfterDisable = self:GetMemoryUsage()
        
        -- Enable module
        VUI.ModuleManager:EnableModule(testModule)
        
        -- Measure memory after enable
        local memoryAfterEnable = self:GetMemoryUsage()
        
        return {
            memoryBefore = memoryBefore,
            memoryAfterDisable = memoryAfterDisable,
            memoryAfterEnable = memoryAfterEnable,
            disableChange = memoryAfterDisable - memoryBefore,
            enableChange = memoryAfterEnable - memoryAfterDisable,
            totalChange = memoryAfterEnable - memoryBefore
        }
    end)
    
    -- Test frame pool memory efficiency
    self:RegisterBenchmark("memory", "frame_pool_efficiency", function()
        -- Test modules with frame pools
        local testModules = {
            "BuffOverlay",
            "MultiNotification"
        }
        
        local results = {}
        
        for _, moduleName in ipairs(testModules) do
            local module = VUI.modules[moduleName]
            if not module or not module.frames or not module.frames.pool then
                results[moduleName] = { error = "Module or frame pool not found" }
            else
                -- Measure memory before
                local memoryBefore = self:GetMemoryUsage()
                
                -- Create and release frames
                local testFrames = {}
                for i = 1, 10 do
                    local frame = module.frames.pool:Acquire()
                    table.insert(testFrames, frame)
                end
                
                -- Measure memory after creation
                local memoryAfterCreate = self:GetMemoryUsage()
                
                -- Release frames
                for _, frame in ipairs(testFrames) do
                    module.frames.pool:Release(frame)
                end
                
                -- Measure memory after release
                local memoryAfterRelease = self:GetMemoryUsage()
                
                results[moduleName] = {
                    memoryBefore = memoryBefore,
                    memoryAfterCreate = memoryAfterCreate,
                    memoryAfterRelease = memoryAfterRelease,
                    createChange = memoryAfterCreate - memoryBefore,
                    releaseChange = memoryAfterRelease - memoryAfterCreate,
                    efficiency = 1 - ((memoryAfterRelease - memoryBefore) / (memoryAfterCreate - memoryBefore))
                }
            end
        end
        
        return results
    end)
end

-- Register CPU benchmarks
function PB:RegisterCPUBenchmarks()
    -- Test theme switching performance
    self:RegisterBenchmark("cpu", "theme_switching", function()
        if not VUI.theme or not VUI.theme.SetTheme or not VUI.theme.themes then
            error("Theme system not found")
        end
        
        -- Get available themes
        local availableThemes = {}
        for name, _ in pairs(VUI.theme.themes) do
            table.insert(availableThemes, name)
        end
        
        if #availableThemes < 2 then
            error("Not enough themes available for testing")
        end
        
        -- Save current theme
        local currentTheme = VUI.theme.current and VUI.theme.current.name or nil
        
        -- Select two themes to switch between
        local theme1 = availableThemes[1]
        local theme2 = availableThemes[2]
        
        -- Test theme switching
        local switchTimes = {}
        
        -- Switch to theme1 first
        VUI.theme:SetTheme(theme1)
        
        -- Perform switches
        for i = 1, 5 do
            -- Switch to theme2
            local startTime1 = debugprofilestop()
            VUI.theme:SetTheme(theme2)
            local endTime1 = debugprofilestop()
            table.insert(switchTimes, endTime1 - startTime1)
            
            -- Switch to theme1
            local startTime2 = debugprofilestop()
            VUI.theme:SetTheme(theme1)
            local endTime2 = debugprofilestop()
            table.insert(switchTimes, endTime2 - startTime2)
        end
        
        -- Restore original theme if needed
        if currentTheme and currentTheme ~= theme1 then
            VUI.theme:SetTheme(currentTheme)
        end
        
        -- Calculate average switch time
        local totalTime = 0
        for _, time in ipairs(switchTimes) do
            totalTime = totalTime + time
        end
        
        return {
            switchTimes = switchTimes,
            avgSwitchTime = totalTime / #switchTimes
        }
    end)
    
    -- Test atlas texture rendering
    self:RegisterBenchmark("cpu", "atlas_texture_rendering", function()
        if not VUI.Atlas or not VUI.Atlas.GetTexture then
            error("Atlas system not found")
        end
        
        -- Test rendering 20 atlas textures
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetSize(400, 400)
        frame:SetPoint("CENTER")
        frame:Hide() -- Don't show for the test
        
        local renderTimes = {}
        local textures = {}
        
        -- Create textures
        for i = 1, 20 do
            local startTime = debugprofilestop()
            
            local texture = frame:CreateTexture(nil, "ARTWORK")
            texture:SetSize(32, 32)
            texture:SetPoint("TOPLEFT", 20 * (i % 5), -20 * math.floor(i / 5))
            
            -- Use atlas texture if available, otherwise default icon
            local atlasTexture = VUI.Atlas:GetTexture("icon_" .. (i % 5 + 1)) or "Interface\\Icons\\INV_Misc_QuestionMark"
            
            if type(atlasTexture) == "string" then
                texture:SetTexture(atlasTexture)
            else
                texture:SetTexture(atlasTexture.texture)
                texture:SetTexCoord(atlasTexture.left, atlasTexture.right, atlasTexture.top, atlasTexture.bottom)
            end
            
            table.insert(textures, texture)
            
            local endTime = debugprofilestop()
            table.insert(renderTimes, endTime - startTime)
        end
        
        -- Calculate average render time
        local totalTime = 0
        for _, time in ipairs(renderTimes) do
            totalTime = totalTime + time
        end
        
        -- Clean up
        for _, texture in ipairs(textures) do
            texture:Hide()
            texture:SetTexture(nil)
        end
        frame:Hide()
        
        return {
            renderTimes = renderTimes,
            avgRenderTime = totalTime / #renderTimes
        }
    end)
end

-- Register framerate benchmarks
function PB:RegisterFramerateBenchmarks()
    -- Benchmark UI update frequency
    self:RegisterBenchmark("framerate", "ui_update_frequency", function()
        -- Create a frame for testing
        local testFrame = CreateFrame("Frame", nil, UIParent)
        testFrame:SetSize(200, 200)
        testFrame:SetPoint("CENTER")
        testFrame:Hide() -- Don't show for the test
        
        -- Add elements to test frame
        local texture = testFrame:CreateTexture(nil, "ARTWORK")
        texture:SetAllPoints()
        texture:SetColorTexture(1, 1, 1, 0.5)
        
        local text = testFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        text:SetPoint("CENTER")
        text:SetText("Performance Test")
        
        -- Set up animation
        local animGroup = testFrame:CreateAnimationGroup()
        local rotateAnim = animGroup:CreateAnimation("Rotation")
        rotateAnim:SetDuration(2)
        rotateAnim:SetDegrees(360)
        
        -- Track frame updates
        local updateTimes = {}
        local updateCount = 0
        local startTime = debugprofilestop()
        local testDuration = 500 -- ms
        
        testFrame:SetScript("OnUpdate", function(self, elapsed)
            updateCount = updateCount + 1
            table.insert(updateTimes, debugprofilestop())
            
            -- Update appearance for load
            self:SetAlpha(math.sin(debugprofilestop() / 200) * 0.5 + 0.5)
            
            -- Stop after test duration
            if debugprofilestop() - startTime > testDuration then
                self:SetScript("OnUpdate", nil)
            end
        end)
        
        -- Start test
        testFrame:Show()
        animGroup:Play()
        
        -- Wait for test to complete
        C_Timer.After(testDuration / 1000 + 0.1, function() end)
        
        -- Calculate update frequency
        local averageUpdatesPerSecond = updateCount / (testDuration / 1000)
        
        -- Calculate update intervals
        local intervals = {}
        for i = 2, #updateTimes do
            table.insert(intervals, updateTimes[i] - updateTimes[i-1])
        end
        
        -- Calculate average interval
        local totalInterval = 0
        for _, interval in ipairs(intervals) do
            totalInterval = totalInterval + interval
        end
        local avgInterval = #intervals > 0 and totalInterval / #intervals or 0
        
        -- Clean up
        testFrame:Hide()
        testFrame:SetScript("OnUpdate", nil)
        animGroup:Stop()
        
        return {
            updatesPerSecond = averageUpdatesPerSecond,
            updateIntervals = intervals,
            avgInterval = avgInterval,
            updateCount = updateCount,
            testDuration = testDuration
        }
    end)
end

-- Register texture benchmarks
function PB:RegisterTextureBenchmarks()
    -- Test texture atlas loading
    self:RegisterBenchmark("texture", "atlas_loading", function()
        if not VUI.Atlas or not VUI.Atlas.GetTexture then
            error("Atlas system not found")
        end
        
        -- Test loading different textures
        local testTextures = {
            "icon_1",
            "icon_2",
            "icon_3",
            "icon_4",
            "icon_5",
            "background_1",
            "background_2",
            "border_1",
            "border_2"
        }
        
        local loadTimes = {}
        local results = {}
        
        for _, textureName in ipairs(testTextures) do
            local startTime = debugprofilestop()
            local texture = VUI.Atlas:GetTexture(textureName)
            local endTime = debugprofilestop()
            local loadTime = endTime - startTime
            
            table.insert(loadTimes, loadTime)
            results[textureName] = {
                loadTime = loadTime,
                found = texture ~= nil
            }
        end
        
        -- Calculate average load time
        local totalTime = 0
        for _, time in ipairs(loadTimes) do
            totalTime = totalTime + time
        end
        
        return {
            textures = results,
            loadTimes = loadTimes,
            avgLoadTime = totalTime / #loadTimes
        }
    end)
    
    -- Test texture compression
    self:RegisterBenchmark("texture", "compression_performance", function()
        if not VUI.Atlas or not VUI.Atlas.CompressTexture then
            error("Atlas compression system not found")
        end
        
        -- Create a dummy texture for testing
        local frame = CreateFrame("Frame", nil, UIParent)
        frame:SetSize(256, 256)
        frame:Hide()
        
        local texture = frame:CreateTexture(nil, "ARTWORK")
        texture:SetAllPoints()
        texture:SetColorTexture(1, 1, 1, 1)
        
        -- Test compression at different quality levels
        local qualityLevels = {
            high = 0.9,
            medium = 0.5,
            low = 0.3
        }
        
        local compressionTimes = {}
        local results = {}
        
        for quality, level in pairs(qualityLevels) do
            local startTime = debugprofilestop()
            
            -- Call compression function if it exists
            local compressed = nil
            if VUI.Atlas.CompressTexture then
                compressed = VUI.Atlas:CompressTexture(texture, level)
            end
            
            local endTime = debugprofilestop()
            local compressionTime = endTime - startTime
            
            table.insert(compressionTimes, compressionTime)
            results[quality] = {
                compressionTime = compressionTime,
                compressionLevel = level,
                success = compressed ~= nil
            }
        end
        
        -- Calculate average compression time
        local totalTime = 0
        for _, time in ipairs(compressionTimes) do
            totalTime = totalTime + time
        end
        
        -- Clean up
        frame:Hide()
        
        return {
            compressionLevels = results,
            compressionTimes = compressionTimes,
            avgCompressionTime = totalTime / #compressionTimes
        }
    end)
end

-- Register database benchmarks
function PB:RegisterDatabaseBenchmarks()
    -- Test database access performance
    self:RegisterBenchmark("database", "db_access", function()
        if not VUI.db or not VUI.db.profile then
            error("Database not found")
        end
        
        -- Test reading and writing to the database
        local readTimes = {}
        local writeTimes = {}
        
        -- Temporary unique key for testing
        local testKey = "benchmark_test_" .. tostring(debugprofilestop())
        
        -- Test writes
        for i = 1, 10 do
            local startTime = debugprofilestop()
            VUI.db.profile[testKey .. i] = i
            local endTime = debugprofilestop()
            table.insert(writeTimes, endTime - startTime)
        end
        
        -- Test reads
        for i = 1, 10 do
            local startTime = debugprofilestop()
            local value = VUI.db.profile[testKey .. i]
            local endTime = debugprofilestop()
            table.insert(readTimes, endTime - startTime)
        end
        
        -- Clean up test keys
        for i = 1, 10 do
            VUI.db.profile[testKey .. i] = nil
        end
        
        -- Calculate average times
        local totalReadTime = 0
        for _, time in ipairs(readTimes) do
            totalReadTime = totalReadTime + time
        end
        
        local totalWriteTime = 0
        for _, time in ipairs(writeTimes) do
            totalWriteTime = totalWriteTime + time
        end
        
        return {
            readTimes = readTimes,
            writeTimes = writeTimes,
            avgReadTime = totalReadTime / #readTimes,
            avgWriteTime = totalWriteTime / #writeTimes
        }
    end)
    
    -- Test database optimization
    self:RegisterBenchmark("database", "db_optimizer", function()
        if not VUI.db_optimizer or not VUI.db_optimizer.GetStatus then
            error("Database optimizer not found")
        end
        
        -- Get optimizer status
        local status = VUI.db_optimizer:GetStatus()
        
        -- Test cache hits
        local cacheHits = 0
        local cacheMisses = 0
        local accessTimes = {}
        
        for i = 1, 20 do
            local key = "test_key_" .. (i % 5) -- Create some repeated access
            
            local startTime = debugprofilestop()
            local value = VUI.db_optimizer:GetValue("profile", key, i)
            local endTime = debugprofilestop()
            
            table.insert(accessTimes, endTime - startTime)
            
            -- Check if it was a cache hit (this is approximate)
            if i > 5 and i % 5 == 0 then
                cacheHits = cacheHits + 1
            else
                cacheMisses = cacheMisses + 1
            end
        end
        
        -- Calculate average access time
        local totalAccessTime = 0
        for _, time in ipairs(accessTimes) do
            totalAccessTime = totalAccessTime + time
        end
        
        return {
            status = status,
            cacheHits = cacheHits,
            cacheMisses = cacheMisses,
            hitRate = cacheHits / (cacheHits + cacheMisses),
            accessTimes = accessTimes,
            avgAccessTime = totalAccessTime / #accessTimes
        }
    end)
end

-- Register combat benchmarks
function PB:RegisterCombatBenchmarks()
    -- Test combat performance optimization
    self:RegisterBenchmark("combat", "combat_optimization", function()
        if not VUI.combat_performance or not VUI.combat_performance.SimulateCombat then
            error("Combat performance system not found")
        end
        
        -- Simulate combat and measure performance
        local startTime = debugprofilestop()
        local metrics = VUI.combat_performance:SimulateCombat(5) -- 5 seconds of simulated combat
        local endTime = debugprofilestop()
        
        return {
            executionTime = endTime - startTime,
            metrics = metrics
        }
    end)
end

-- Register module benchmarks
function PB:RegisterModuleBenchmarks()
    -- Test module initialization time
    self:RegisterBenchmark("module", "initialization_time", function()
        if not VUI.ModuleManager or not VUI.ModuleManager.InitializeModule then
            error("Module manager not found")
        end
        
        -- Select a module to test
        local testModules = {
            "InfoFrame",
            "MultiNotification",
            "BuffOverlay"
        }
        
        local initTimes = {}
        local results = {}
        
        for _, moduleName in ipairs(testModules) do
            -- Disable the module first
            if VUI.ModuleManager.DisableModule then
                VUI.ModuleManager:DisableModule(moduleName)
            end
            
            -- Measure initialization time
            local startTime = debugprofilestop()
            local success = pcall(function() VUI.ModuleManager:InitializeModule(moduleName) end)
            local endTime = debugprofilestop()
            
            -- Re-enable the module
            if VUI.ModuleManager.EnableModule then
                VUI.ModuleManager:EnableModule(moduleName)
            end
            
            local initTime = endTime - startTime
            table.insert(initTimes, initTime)
            
            results[moduleName] = {
                initTime = initTime,
                success = success
            }
        end
        
        -- Calculate average initialization time
        local totalTime = 0
        for _, time in ipairs(initTimes) do
            totalTime = totalTime + time
        end
        
        return {
            modules = results,
            initTimes = initTimes,
            avgInitTime = totalTime / #initTimes
        }
    end)
end

-- Register with slash command handler
if VUI.RegisterSlashCommand then
    VUI:RegisterSlashCommand("benchmark", function(input)
        -- Parse options
        local category = nil
        if input and input ~= "" then
            category = input
        end
        
        -- Register standard benchmarks
        PB:RegisterStandardBenchmarks()
        
        -- Run benchmarks
        if category and PB.benchmarks[category] then
            PB:InitResults()
            PB:RunCategory(category)
        else
            PB:RunAll()
        end
    end, "Run performance benchmarks. Use 'benchmark [category]' to run specific benchmark categories.")
end

-- Return the performance benchmarks
return PB