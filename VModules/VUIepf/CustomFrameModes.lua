-- VUIepf Custom Frame Modes
-- Contains definitions for all the custom player frame appearances

local AddonName, VUI = ...
local M = VUI:GetModule("VUIepf")
local L = LibStub("AceLocale-3.0"):GetLocale("VUI")

-- Custom frame modes
local modes = M.CUSTOM_FRAME_MODES

-- Death Knight frame
table.insert(modes, function(m) 
    return {
        m.CLASSES["DEATHKNIGHT"] and m.CLASSES["DEATHKNIGHT"].name[2] or L["Death Knight"],
        m.CLASSES["DEATHKNIGHT"].color,
        m.SetLayeredTextures(m.SetTexture({
            ["file"] = m:GetMediaPath("textures/CustomTextures.blp"),
            ["file-2x"] = m:GetMediaPath("textures/CustomTextures-2x.blp"),
            ["width"] = 267,
            ["height"] = 116,
            ["leftTexCoord"] = 0/1024,
            ["rightTexCoord"] = 534/1024,
            ["topTexCoord"] = 0/512,
            ["bottomTexCoord"] = 232/512
        }, m.SetPointOffset(-5,-3)), m.SetTexture({
            ["file"] = m:GetMediaPath("textures/CustomTextures.blp"),
            ["file-2x"] = m:GetMediaPath("textures/CustomTextures-2x.blp"),
            ["width"] = 56,
            ["height"] = 98,
            ["leftTexCoord"] = 0/1024,
            ["rightTexCoord"] = 112/1024,
            ["topTexCoord"] = 232/512,
            ["bottomTexCoord"] = 428/512
        }, m.SetPointOffset(-12,-5))),
        m.SetPointOffset(-3,13),
        function(m) return m.db.profile.classSelection and m.playerClass == "DEATHKNIGHT" end
    }
end)

-- Demon Hunter frame
table.insert(modes, function(m) 
    return {
        m.CLASSES["DEMONHUNTER"] and m.CLASSES["DEMONHUNTER"].name[2] or L["Demon Hunter"],
        m.CLASSES["DEMONHUNTER"].color,
        m.SetLayeredTextures(m.SetTexture({
            ["file"] = m:GetMediaPath("textures/CustomTextures.blp"),
            ["file-2x"] = m:GetMediaPath("textures/CustomTextures-2x.blp"),
            ["width"] = 267,
            ["height"] = 116,
            ["leftTexCoord"] = 0/1024,
            ["rightTexCoord"] = 534/1024,
            ["topTexCoord"] = 0/512,
            ["bottomTexCoord"] = 232/512
        }, m.SetPointOffset(-5,-3)), m.SetTexture({
            ["file"] = m:GetMediaPath("textures/CustomTextures.blp"),
            ["file-2x"] = m:GetMediaPath("textures/CustomTextures-2x.blp"),
            ["width"] = 56,
            ["height"] = 98,
            ["leftTexCoord"] = 534/1024,
            ["rightTexCoord"] = 646/1024,
            ["topTexCoord"] = 0/512,
            ["bottomTexCoord"] = 196/512
        }, m.SetPointOffset(-12,-5))),
        m.SetPointOffset(-3,13),
        function(m) return m.db.profile.classSelection and m.playerClass == "DEMONHUNTER" end
    }
end)

-- Druid frame
table.insert(modes, function(m) 
    return {
        m.CLASSES["DRUID"] and m.CLASSES["DRUID"].name[2] or L["Druid"],
        m.CLASSES["DRUID"].color,
        m.SetLayeredTextures(m.SetTexture({
            ["file"] = m:GetMediaPath("textures/CustomTextures.blp"),
            ["file-2x"] = m:GetMediaPath("textures/CustomTextures-2x.blp"),
            ["width"] = 267,
            ["height"] = 116,
            ["leftTexCoord"] = 0/1024,
            ["rightTexCoord"] = 534/1024,
            ["topTexCoord"] = 0/512,
            ["bottomTexCoord"] = 232/512
        }, m.SetPointOffset(-5,-3)), m.SetTexture({
            ["file"] = m:GetMediaPath("textures/CustomTextures.blp"),
            ["file-2x"] = m:GetMediaPath("textures/CustomTextures-2x.blp"),
            ["width"] = 56,
            ["height"] = 98,
            ["leftTexCoord"] = 112/1024,
            ["rightTexCoord"] = 224/1024,
            ["topTexCoord"] = 232/512,
            ["bottomTexCoord"] = 428/512
        }, m.SetPointOffset(-12,-5))),
        m.SetPointOffset(-3,13),
        function(m) return m.db.profile.classSelection and m.playerClass == "DRUID" end
    }
end)

-- Evoker frame
table.insert(modes, function(m) 
    return {
        m.CLASSES["EVOKER"] and m.CLASSES["EVOKER"].name[2] or L["Evoker"],
        m.CLASSES["EVOKER"].color,
        m.SetLayeredTextures(m.SetTexture({
            ["file"] = m:GetMediaPath("textures/CustomTextures.blp"),
            ["file-2x"] = m:GetMediaPath("textures/CustomTextures-2x.blp"),
            ["width"] = 267,
            ["height"] = 116,
            ["leftTexCoord"] = 0/1024,
            ["rightTexCoord"] = 534/1024,
            ["topTexCoord"] = 0/512,
            ["bottomTexCoord"] = 232/512
        }, m.SetPointOffset(-5,-3)), m.SetTexture({
            ["file"] = m:GetMediaPath("textures/CustomTextures.blp"),
            ["file-2x"] = m:GetMediaPath("textures/CustomTextures-2x.blp"),
            ["width"] = 56,
            ["height"] = 98,
            ["leftTexCoord"] = 224/1024,
            ["rightTexCoord"] = 336/1024,
            ["topTexCoord"] = 232/512,
            ["bottomTexCoord"] = 428/512
        }, m.SetPointOffset(-12,-5))),
        m.SetPointOffset(-3,13),
        function(m) return m.db.profile.classSelection and m.playerClass == "EVOKER" end
    }
end)

-- Hunter frame
table.insert(modes, function(m) 
    return {
        m.CLASSES["HUNTER"] and m.CLASSES["HUNTER"].name[2] or L["Hunter"],
        m.CLASSES["HUNTER"].color,
        m.SetLayeredTextures(m.SetTexture({
            ["file"] = m:GetMediaPath("textures/CustomTextures.blp"),
            ["file-2x"] = m:GetMediaPath("textures/CustomTextures-2x.blp"),
            ["width"] = 267,
            ["height"] = 116,
            ["leftTexCoord"] = 0/1024,
            ["rightTexCoord"] = 534/1024,
            ["topTexCoord"] = 0/512,
            ["bottomTexCoord"] = 232/512
        }, m.SetPointOffset(-5,-3)), m.SetTexture({
            ["file"] = m:GetMediaPath("textures/CustomTextures.blp"),
            ["file-2x"] = m:GetMediaPath("textures/CustomTextures-2x.blp"),
            ["width"] = 56,
            ["height"] = 98,
            ["leftTexCoord"] = 336/1024,
            ["rightTexCoord"] = 448/1024,
            ["topTexCoord"] = 232/512,
            ["bottomTexCoord"] = 428/512
        }, m.SetPointOffset(-12,-5))),
        m.SetPointOffset(-3,13),
        function(m) return m.db.profile.classSelection and m.playerClass == "HUNTER" end
    }
end)

-- Add other class frames here following the same pattern
-- Mage, Monk, Paladin, Priest, Rogue, Shaman, Warlock, Warrior

-- Custom race-themed frames could also be added here

-- Generic elite dragon frame (simple custom example)
table.insert(modes, function(m) 
    return {
        L["Enhanced Elite"],
        CreateColor(1, 0.84, 0),  -- Gold color
        m.SetLayeredTextures(m.SetTexture({
            ["file"] = m:GetMediaPath("textures/CustomTextures.blp"),
            ["file-2x"] = m:GetMediaPath("textures/CustomTextures-2x.blp"),
            ["width"] = 267,
            ["height"] = 116,
            ["leftTexCoord"] = 0/1024,
            ["rightTexCoord"] = 534/1024,
            ["topTexCoord"] = 0/512,
            ["bottomTexCoord"] = 232/512
        }, m.SetPointOffset(-5,-3))),
        m.SetPointOffset(-3,13),
        function(m) return true end  -- Always available
    }
end)