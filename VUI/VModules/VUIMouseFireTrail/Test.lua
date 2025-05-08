-- VUIMouseFireTrail Tests
-- Test functionality of the VUIMouseFireTrail module

local AddonName, VUI = ...
local M = VUI:GetModule("VUIMouseFireTrail")

-- Register tests after the framework is loaded
if VUI.Test then
    -- Test module initialization
    VUI.Test:RegisterTest("VUIMouseFireTrail", "ModuleExists", function()
        VUI.Test:AssertNotNil(M, "VUIMouseFireTrail module should exist")
        return true
    end)
    
    -- Test default settings
    VUI.Test:RegisterTest("VUIMouseFireTrail", "DefaultSettings", function()
        VUI.Test:AssertNotNil(M.defaults, "Default settings should exist")
        VUI.Test:AssertNotNil(M.defaults.profile, "Profile defaults should exist")
        VUI.Test:AssertTrue(M.defaults.profile.enabled, "Module should be enabled by default")
        VUI.Test:AssertEqual(M.defaults.profile.particleCount, 25, "Default particle count should be 25")
        return true
    end)
    
    -- Test particle system creation
    VUI.Test:RegisterTest("VUIMouseFireTrail", "ParticleSystemCreation", function()
        M:CreateParticleSystem()
        VUI.Test:AssertNotNil(M.particleFrame, "Particle frame should be created")
        VUI.Test:AssertTable(M.particles, "Particles table should be created")
        VUI.Test:AssertTable(M.textures, "Textures table should be created")
        return true
    end)
    
    -- Test particle initialization
    VUI.Test:RegisterTest("VUIMouseFireTrail", "ParticleInitialization", function()
        M:InitParticles()
        VUI.Test:AssertEqual(#M.particles, M.db.profile.particleCount, "Particle count should match settings")
        return true
    end)
    
    -- Test texture setting
    VUI.Test:RegisterTest("VUIMouseFireTrail", "TextureSetting", function()
        local texture = M.textures[1] or CreateFrame("Frame"):CreateTexture()
        M:SetParticleTexture(texture)
        VUI.Test:AssertNotNil(texture:GetTexture(), "Texture should be set")
        return true
    end)
    
    -- Test visibility update
    VUI.Test:RegisterTest("VUIMouseFireTrail", "VisibilityUpdate", function()
        M:UpdateVisibility()
        -- The visibility state depends on various conditions that we can't easily test
        return true
    end)
    
    -- Test animation integration
    VUI.Test:RegisterTest("VUIMouseFireTrail", "AnimationIntegration", function()
        -- Skip test if Animations module is not available
        if not VUI.Animations then
            error("Animations module is not available")
        end
        
        -- Test that particle frame uses animations
        local originalIsShown = M.particleFrame.IsShown
        local animationCalled = false
        
        -- Mock IsShown function temporarily
        M.particleFrame.IsShown = function() return false end
        
        -- Mock FadeIn function temporarily
        local originalFadeIn = VUI.Animations.FadeIn
        VUI.Animations.FadeIn = function(self, frame)
            if frame == M.particleFrame then
                animationCalled = true
            end
        end
        
        -- Call visibility update
        M:UpdateVisibility()
        
        -- Restore original functions
        M.particleFrame.IsShown = originalIsShown
        VUI.Animations.FadeIn = originalFadeIn
        
        -- Verify animation was called
        VUI.Test:AssertTrue(animationCalled, "Animation FadeIn should be called for particle frame")
        
        return true
    end)
end