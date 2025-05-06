-- Test script for all modules
-- This file simulates the core addon loading and tests each module

-- Set up addon environment
local addon_name, VUI = "VUI", {}
_G["VUI"] = VUI

-- Mock WoW API functions
local function MockWoWAPI()
    _G.print = print
    _G.CreateFrame = function(...) return {} end
    _G.UIParent = {}
    _G.GetTime = function() return 0 end
    _G.UnitAura = function() return nil end
    _G.UnitExists = function() return false end
    _G.tinsert = table.insert
    _G.table = table
    _G.math = math
    _G.string = string
    _G.pairs = pairs
    _G.ipairs = ipairs
    _G.next = next
    _G.type = type
    _G.tostring = tostring
    _G.select = select
    _G.unpack = unpack
    _G.format = string.format
    _G.wipe = function(t) for k in pairs(t) do t[k] = nil end end
end

-- Mock VUI API functions
local function MockVUIAPI()
    VUI.Print = function(self, msg) print("[VUI]", msg) end
    VUI.GetFont = function() return "Font", 12, "OUTLINE" end
    VUI.GetTextureCached = function() return nil end
    VUI.db = {profile = {modules = {
        buffoverlay = {},
        trufigcd = {}
    }}}
    VUI.enabledModules = {
        BuffOverlay = true,
        TrufiGCD = true
    }
    VUI.RegisterChatCommand = function() end
end

-- Initialize the test environment
local function InitTestEnvironment()
    MockWoWAPI()
    MockVUIAPI()
    
    -- Add other required initialization
    print("Test environment initialized")
end

-- Test BuffOverlay module
local function TestBuffOverlay()
    print("\nTesting BuffOverlay module...")
    local status, err = pcall(function()
        if not VUI.buffoverlay then
            print("Creating VUI.buffoverlay namespace")
            VUI.buffoverlay = {}
        end
        
        if not VUI.BuffOverlay then
            print("Creating VUI.BuffOverlay namespace")
            VUI.BuffOverlay = VUI.buffoverlay
        end
        
        -- Add debug db for buffoverlay
        if not VUI.db.profile.modules.buffoverlay then
            VUI.db.profile.modules.buffoverlay = {}
        end
        
        print("Loading buffoverlay.lua...")
        dofile("modules/buffoverlay/buffoverlay.lua")
        
        print("BuffOverlay namespace exists:", VUI.BuffOverlay ~= nil)
        print("VUI.buffoverlay is same as VUI.BuffOverlay:", VUI.buffoverlay == VUI.BuffOverlay)
        print("Initialize function exists:", type(VUI.BuffOverlay.Initialize) == "function")
    end)
    
    if status then
        print("BuffOverlay module loaded successfully")
    else
        print("Error loading BuffOverlay module:", err)
    end
end

-- Test TrufiGCD module
local function TestTrufiGCD()
    print("\nTesting TrufiGCD module...")
    local status, err = pcall(function()
        if not VUI.TrufiGCD then
            print("Creating VUI.TrufiGCD namespace")
            VUI.TrufiGCD = {}
        end
        
        -- Add debug db for TrufiGCD
        if not VUI.db.profile.modules.trufigcd then
            VUI.db.profile.modules.trufigcd = {
                position = {"CENTER", UIParent, "CENTER", 0, 0},
                size = 40,
                orientation = "HORIZONTAL"
            }
        end
        
        -- Prepare mock Atlas functions
        VUI.Atlas = {
            PreloadAtlas = function() end,
            ApplyTextureCoordinates = function() end
        }
        
        print("Loading trufigcd.lua...")
        dofile("modules/trufigcd/trufigcd.lua")
        
        print("TrufiGCD namespace exists:", VUI.TrufiGCD ~= nil)
        print("Initialize function exists:", type(VUI.TrufiGCD.Initialize) == "function")
        
        -- Test Timeline
        print("\nTesting TrufiGCD Timeline...")
        print("Loading timeline_view.lua...")
        dofile("modules/trufigcd/timeline_view.lua")
        
        print("Timeline namespace exists:", VUI.TrufiGCD.Timeline ~= nil)
    end)
    
    if status then
        print("TrufiGCD module loaded successfully")
    else
        print("Error loading TrufiGCD module:", err)
    end
end

-- Run all tests
local function RunAllTests()
    InitTestEnvironment()
    TestBuffOverlay()
    TestTrufiGCD()
    print("\nAll tests completed")
end

-- Execute the tests
RunAllTests()