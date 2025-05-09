-- Generate a question mark icon for placeholder usage
local AddonName, VUI = ...

-- Create and export the question mark icon as a texture path
-- This is a simple placeholder texture for use when no consumable is active
local media = VUI.Media or {}
if not media.textures then media.textures = {} end
if not media.textures.consumables then media.textures.consumables = {} end

-- Reference the standard question mark icon from the game's interface
media.textures.consumables.question = "Interface\\Icons\\INV_Misc_QuestionMark"
media.textures.consumables.flask = "Interface\\Icons\\inv_potion_27"
media.textures.consumables.food = "Interface\\Icons\\INV_Misc_Food_15"
media.textures.consumables.potion = "Interface\\Icons\\INV_Potion_01" 
media.textures.consumables.rune = "Interface\\Icons\\inv_misc_rune_04"

VUI.Media = media