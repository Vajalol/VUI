-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

if GetLocale() ~= "deDE" then return end

-- German localization
-- Values set to true use the English default

-- General
L["VUI Gfinder"] = "VUI Gfinder"
L["Enhances the Group Finder with advanced filtering"] = "Erweitert den Gruppensucher mit fortgeschrittener Filterung"

-- UI Text
L["Enable"] = "Aktivieren"
L["Open Filter Dialog"] = "Filter-Dialog öffnen"
L["Dialog Scale"] = "Dialog-Skalierung"
L["Enhanced Tooltips"] = "Verbesserte Tooltips"
L["One-Click Sign Up"] = "Ein-Klick-Anmeldung"
L["Remember Sign Up Notes"] = "Anmeldungsnotizen speichern"
L["Sign Up on Enter"] = "Anmelden mit Enter"
L["Show Filter Button"] = "Filter-Button anzeigen"

-- Advanced Filter
L["Enable Advanced Mode"] = "Erweiterten Modus aktivieren"
L["Filter Expression"] = "Filter-Ausdruck"
L["Enable Custom Sorting"] = "Benutzerdefinierte Sortierung aktivieren"
L["Sorting Expression"] = "Sortierungs-Ausdruck"

-- Difficulties
L["Normal"] = "Normal"
L["Heroic"] = "Heroisch"
L["Mythic"] = "Mythisch"
L["Mythic+"] = "Mythisch+"
L["Arena 2v2"] = "Arena 2v2"
L["Arena 3v3"] = "Arena 3v3"

-- Dialog
L["Minimum Difficulty"] = "Mindest-Schwierigkeit"
L["Maximum Difficulty"] = "Maximale Schwierigkeit"
L["Min Mythic+ Level"] = "Min. Mythisch+ Stufe"
L["Max Mythic+ Level"] = "Max. Mythisch+ Stufe"
L["Min Rating"] = "Mind. Wertung"
L["Max Rating"] = "Max. Wertung"
L["Find Groups"] = "Gruppen finden"
L["Reset Filters"] = "Filter zurücksetzen"
L["Close"] = "Schließen"

-- Tooltip
L["Group Details"] = "Gruppendetails"
L["Activity"] = "Aktivität"
L["Difficulty"] = "Schwierigkeit"
L["Leader Score"] = "Anführer-Bewertung"
L["Members"] = "Mitglieder"
L["Created"] = "Erstellt"
L["ago"] = "vor"

-- Categories
L["Dungeon"] = "Dungeon"
L["Raid"] = "Schlachtzug"
L["Arena"] = "Arena"
L["Rated Battleground"] = "Bewertetes Schlachtfeld"

-- Roles
L["Tank"] = "Tank"
L["Healer"] = "Heiler"
L["DPS"] = "DPS"

-- Misc
L["Advanced Filtering"] = "Erweiterte Filterung"
L["Use Expression"] = "Ausdruck verwenden"
L["Expression Help"] = "Ausdrucks-Hilfe"