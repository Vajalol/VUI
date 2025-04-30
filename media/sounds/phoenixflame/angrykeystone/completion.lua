--[[
    Phoenix Flame completion sound metadata for AngryKeystones
    
    In a real WoW addon, this would be a .ogg file.
    For development/testing purposes, this file contains metadata that describes how the sound should be.
    
    Sound description:
    - A dramatic cymbal crash followed by ascending fire whoosh
    - Ends with a triumphant brass chord
    - Duration: approximately 3 seconds
    - Overall feeling: triumphant, powerful, fiery
    
    This would be paired with a visual flame effect when a mythic+ dungeon is completed
]]--

-- Sound metadata
local soundInfo = {
    name = "phoenix_flame_dungeon_completion",
    duration = 3.0,
    description = "A dramatic cymbal crash followed by ascending fire whoosh, ending with a triumphant brass chord",
    theme = "phoenixflame",
    module = "angrykeystone",
    category = "completion",
    volume = 1.0,
    channel = "SFX"
}

return soundInfo