--[[
    Thunder Storm completion sound metadata for AngryKeystones
    
    In a real WoW addon, this would be a .ogg file.
    For development/testing purposes, this file contains metadata that describes how the sound should be.
    
    Sound description:
    - Begins with a low thunderclap that builds in intensity
    - Several lightning cracks in rapid succession
    - Concludes with a heroic orchestral chord with lightning effects
    - Duration: approximately 3.5 seconds
    - Overall feeling: powerful, electric, resonant
    
    This would be paired with a visual lightning effect when a mythic+ dungeon is completed
]]--

-- Sound metadata
local soundInfo = {
    name = "thunder_storm_dungeon_completion",
    duration = 3.5,
    description = "A building thunderclap followed by rapid lightning strikes, ending with heroic orchestral chord",
    theme = "thunderstorm",
    module = "angrykeystone",
    category = "completion",
    volume = 1.0,
    channel = "SFX"
}

return soundInfo