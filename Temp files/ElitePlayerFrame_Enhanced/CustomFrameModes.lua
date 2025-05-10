local addon = (select(2,...))
local L = addon.LOCALISATION
local M = addon.CUSTOM_FRAME_MODES
table.insert(M,function (a) return {
		a.CLASSES["DEATHKNIGHT"] and a.CLASSES["DEATHKNIGHT"].name[2] or L["Death Knight"],
		a.CLASSES["DEATHKNIGHT"].color,
		a.SetLayeredTextures(a.SetTexture({
			["file"] = "Interface\\AddOns\\ElitePlayerFrame_Enhanced\\CustomTextures.blp",
			["file-2x"] = "Interface\\AddOns\\ElitePlayerFrame_Enhanced\\CustomTextures-2x.blp",
			["width"] = 267,
			["height"] = 116,
			["leftTexCoord"] = 0/1024,
			["rightTexCoord"] = 534/1024,
			["topTexCoord"] = 0/512,
			["bottomTexCoord"] = 232/512
		},a.SetPointOffset(-5,-3)),a.SetTexture({	--0,6.5
			["file"] = "Interface\\AddOns\\ElitePlayerFrame_Enhanced\\CustomTextures.blp",
			["file-2x"] = "Interface\\AddOns\\ElitePlayerFrame_Enhanced\\CustomTextures-2x.blp",
			["width"] = 56,
			["height"] = 98,
			["leftTexCoord"] = 0/1024,
			["rightTexCoord"] = 112/1024,
			["topTexCoord"] = 232/512,
			["bottomTexCoord"] = 428/512
		},a.SetPointOffset(-12,-5))),	-- 14,7
		a.SetPointOffset(-3,13),
		function (a) return a.settings.classSelection and a.info.character.class == "DEATHKNIGHT" end
	} end)
table.insert(M,function (a) return {
		a.CLASSES["DEMONHUNTER"] and a.CLASSES["DEMONHUNTER"].name[2] or L["Demon Hunter"],
		a.CLASSES["DEMONHUNTER"].color,
		a.SetLayeredTextures(a.SetTexture({
			["file"] = "Interface\\AddOns\\ElitePlayerFrame_Enhanced\\CustomTextures.blp",
			["file-2x"] = "Interface\\AddOns\\ElitePlayerFrame_Enhanced\\CustomTextures-2x.blp",
			["width"] = 213,
			["height"] = 161,
			["leftTexCoord"] = 534/1024,
			["rightTexCoord"] = 960/1024,
			["topTexCoord"] = 0/512,
			["bottomTexCoord"] = 322/512
		},a.SetPointOffset(16,-3)),a.SetTexture({
			["file"] = "Interface\\AddOns\\ElitePlayerFrame_Enhanced\\CustomTextures.blp",
			["file-2x"] = "Interface\\AddOns\\ElitePlayerFrame_Enhanced\\CustomTextures-2x.blp",
			["width"] = 66,
			["height"] = 81,
			["leftTexCoord"] = 112/1024,
			["rightTexCoord"] = 238/1024,
			["topTexCoord"] = 232/512,
			["bottomTexCoord"] = 394/512
		},a.SetPointOffset(-21,3))),
		a.SetPointOffset(-1,-78),
		function (a) return a.settings.classSelection and a.info.character.class == "DEMONHUNTER" end
	} end)
--[[ Example custom frame mode ]
table.insert(M,function (a)	-- Called with addon during initialisation
	return {	-- Table sent to addon for registration
		"Name",	-- Mode name
		WHITE_FONT_COLOR,	-- Mode color
		{	-- A table defining the frame and portrait modifications. Can be created using a.SetLayeredTextures(frameTable,portraitTable).
			["Frame"] = {	-- A table defining the frame psuedo-atlas (sub-level below default frame texture) and its default point offsets. Can be created using a.SetTexture(textureTable,offsetTable).
				["atlas"] = {	-- A table defining a psuedo-atlas, with similar structure as the return from C_Texture.GetAtlasInfo().
					["name"] = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged",	-- Used as atlasName for SetAtlas() (default: nil). Add a resolution suffix to the key (e.g. "name-2x") when specifying higher resolution alternative.
					["file"] = "Interface\\AddOns\\YourAddon\\CustomTextures.blp",	-- Used as file for SetTexture() if not using an atlas name (default: nil). Add a resolution suffix to the key (e.g. "file-2x") when specifying higher resolution alternative.
					["width"] = 0,	-- Used as width for SetSize() if not using an atlas name, or overriding an atlas size (default: nil)
					["height"] = 0,	-- Used as height for SetSize() if not using an atlas name, or overriding an atlas size (default: nil)
					["leftTexCoord"] = 0,	-- Used as left for SetTexCoord() if not using an atlas name (default: 0). Add a resolution suffix to the key (e.g. "leftTexCoord-2x") when specifying higher resolution alternative.
					["rightTexCoord"] = 1,	-- Used as right for SetTexCoord() if not using an atlas name (default: 1). Add a resolution suffix to the key (e.g. "rightTexCoord-2x") when specifying higher resolution alternative.
					["topTexCoord"] = 0,	-- Used as top for SetTexCoord() if not using an atlas name (default: 0). Add a resolution suffix to the key (e.g. "topTexCoord-2x") when specifying higher resolution alternative.
					["bottomTexCoord"] = 1,	-- Used as bottom for SetTexCoord() if not using an atlas name (default: 1). Add a resolution suffix to the key (e.g. "bottomTexCoord-2x") when specifying higher resolution alternative.
					["tilesHorizontally"] = nil,	-- Used as horizWrap for SetTexture() if not using an atlas name (default: nil)
					["tilesVertically"] = nil,	-- Used as vertWrap for SetTexture() if not using an atlas name (default: nil)
					["filterMode"] = nil,	-- Used as filterMode for SetAtlas(), or SetTexture() if not using an atlas name (default: nil)
					["flipHorizontally"] = false,	-- Used to easily flip an atlas texture horizontally if using an atlas name (default: false)
					["flipVertically"] = false,	-- Used to easily flip an atlas texture vertically if using an atlas name (default: false)
					["hideFrame"] = false,	-- Used to hide the default texture (default: false)
				},
				["offsets"] = {	-- A table defining the X & Y default point offsets for the texture (default: nil). Can be created using a.SetPointOffset(xOffset,yOffset).
					["x"] = 0,
					["y"] = 0,
				}
			},
			["Portrait"] = {	-- A table defining the portrait psuedo-atlas (same sub-level as default portrait texture) and its default point offsets; otherwise, it's the same structure and usage as above.
				["atlas"] = {
					["name"] = "UI-HUD-UnitFrame-Target-PortraitOn-Boss-Gold-Winged",
					["file"] = "Interface\\AddOns\\YourAddon\\CustomTextures.blp",
					["width"] = 0,
					["height"] = 0,
					["leftTexCoord"] = 0,
					["rightTexCoord"] = 1,
					["topTexCoord"] = 0,
					["bottomTexCoord"] = 1,
					["tilesHorizontally"] = nil,
					["tilesVertically"] = nil,
					["filterMode"] = nil,
					["flipHorizontally"] = false,
					["flipVertically"] = false,
				},
				["offsets"] = {
					["x"] = 0,
					["y"] = 0,
				}
			}
		},
		{	-- A table defining the X & Y default point offsets for rest icon (default: nil). Can be created using a.SetPointOffset(xOffset,yOffset).
			["x"] = 0,
			["y"] = 0,
		},
		function (a)	-- Called to determine if this texture should be selected in Auto (1) mode (called in the same order the custom textures are added e.g., this one would be called fourth, so the above textures could be selected earlier if they return true) (default: nil)
			return a.settings.classSelection and a.info.character.class == "EVOKER"
		end
	} end)
]]--