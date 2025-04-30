--[[
    Arcane Mystic completion sound metadata for AngryKeystones
    
    In a real WoW addon, this would be a .ogg file.
    For development/testing purposes, this file contains metadata that describes how the sound should be.
    
    Sound description:
    - Begins with magical chimes and tinkling sounds
    - Builds with swirling arcane energy sounds
    - Peaks with a resonant magical "whoosh" and explosion
    - Duration: approximately 3 seconds
    - Overall feeling: mystical, arcane, otherworldly
    
    This would be paired with a visual arcane rune effect when a mythic+ dungeon is completed
]]--

-- Sound metadata
local soundInfo = {
    name = "arcane_mystic_dungeon_completion",
    duration = 3.0,
    description = "Magical chimes and arcane energy building to a resonant magical explosion",
    theme = "arcanemystic",
    module = "angrykeystone",
    category = "completion",
    volume = 1.0,
    channel = "SFX"
}

return soundInfo