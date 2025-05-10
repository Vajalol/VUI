-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

if GetLocale() ~= "itIT" then return end

-- Italian localization
-- Values set to true use the English default

-- General
L["VUI Gfinder"] = "VUI Ricerca Gruppi"
L["Enhances the Group Finder with advanced filtering"] = "Migliora il Ricerca Gruppi con filtri avanzati"

-- UI Text
L["Enable"] = "Abilita"
L["Open Filter Dialog"] = "Apri finestra filtri"
L["Dialog Scale"] = "Scala finestra"
L["Enhanced Tooltips"] = "Tooltip migliorati"
L["One-Click Sign Up"] = "Iscrizione con un clic"
L["Remember Sign Up Notes"] = "Ricorda note di iscrizione"
L["Sign Up on Enter"] = "Iscrizione con Invio"
L["Show Filter Button"] = "Mostra pulsante filtro"

-- Advanced Filter
L["Enable Advanced Mode"] = "Abilita modalità avanzata"
L["Filter Expression"] = "Espressione di filtro"
L["Enable Custom Sorting"] = "Abilita ordinamento personalizzato"
L["Sorting Expression"] = "Espressione di ordinamento"

-- Difficulties
L["Normal"] = "Normale"
L["Heroic"] = "Eroica"
L["Mythic"] = "Mitica"
L["Mythic+"] = "Mitica+"
L["Arena 2v2"] = "Arena 2v2"
L["Arena 3v3"] = "Arena 3v3"

-- Dialog
L["Minimum Difficulty"] = "Difficoltà minima"
L["Maximum Difficulty"] = "Difficoltà massima"
L["Min Mythic+ Level"] = "Livello Mitica+ minimo"
L["Max Mythic+ Level"] = "Livello Mitica+ massimo"
L["Min Rating"] = "Valutazione minima"
L["Max Rating"] = "Valutazione massima"
L["Find Groups"] = "Trova gruppi"
L["Reset Filters"] = "Reimposta filtri"
L["Close"] = "Chiudi"

-- Tooltip
L["Group Details"] = "Dettagli gruppo"
L["Activity"] = "Attività"
L["Difficulty"] = "Difficoltà"
L["Leader Score"] = "Punteggio capo"
L["Members"] = "Membri"
L["Created"] = "Creato"
L["ago"] = "fa"

-- Categories
L["Dungeon"] = "Spedizione"
L["Raid"] = "Incursione"
L["Arena"] = "Arena"
L["Rated Battleground"] = "Campo di battaglia classificato"

-- Roles
L["Tank"] = "Difensore"
L["Healer"] = "Guaritore"
L["DPS"] = "DPS"

-- Misc
L["Advanced Filtering"] = "Filtraggio avanzato"
L["Use Expression"] = "Usa espressione"
L["Expression Help"] = "Aiuto espressioni"