--[[
    Fel Energy completion sound metadata for AngryKeystones
    
    In a real WoW addon, this would be a .ogg file.
    For development/testing purposes, this file contains metadata that describes how the sound should be.
    
    Sound description:
    - Starts with a low demonic growl
    - Quickly builds with fel energy sizzling sounds
    - Climaxes with a powerful fel explosion and demonic laughter
    - Duration: approximately 3.2 seconds
    - Overall feeling: corrupting, powerful, demonic
    
    This would be paired with a green fel explosion visual effect when a mythic+ dungeon is completed
]]--

-- Sound metadata
local soundInfo = {
    name = "fel_energy_dungeon_completion",
    duration = 3.2,
    description = "Demonic growl building to fel energy sounds and a powerful fel explosion",
    theme = "felenergy",
    module = "angrykeystone",
    category = "completion",
    volume = 1.0,
    channel = "SFX"
}

return soundInfo