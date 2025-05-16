-- an effect that does nothing
local AddonName, Addon = ...
-- Use global reference pattern for localization
local L = _G["VUICC"].L or {None = "None"}

local NoopEffect = _G["VUICC"].FX:Create("none", L.None)

function NoopEffect:Run()
end
