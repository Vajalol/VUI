-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

if GetLocale() ~= "frFR" then return end

-- French localization
-- Values set to true use the English default

-- General
L["VUI Gfinder"] = "VUI Gfinder"
L["Enhances the Group Finder with advanced filtering"] = "Améliore le Recherche de Groupe avec un filtrage avancé"

-- UI Text
L["Enable"] = "Activer"
L["Open Filter Dialog"] = "Ouvrir le Dialogue de Filtre"
L["Dialog Scale"] = "Échelle du Dialogue"
L["Enhanced Tooltips"] = "Infobulles Améliorées"
L["One-Click Sign Up"] = "Inscription en Un Clic"
L["Remember Sign Up Notes"] = "Se Souvenir des Notes d'Inscription"
L["Sign Up on Enter"] = "S'inscrire avec Entrée"
L["Show Filter Button"] = "Afficher le Bouton de Filtre"

-- Advanced Filter
L["Enable Advanced Mode"] = "Activer le Mode Avancé"
L["Filter Expression"] = "Expression de Filtre"
L["Enable Custom Sorting"] = "Activer le Tri Personnalisé"
L["Sorting Expression"] = "Expression de Tri"

-- Difficulties
L["Normal"] = "Normal"
L["Heroic"] = "Héroïque"
L["Mythic"] = "Mythique"
L["Mythic+"] = "Mythique+"
L["Arena 2v2"] = "Arène 2c2"
L["Arena 3v3"] = "Arène 3c3"

-- Dialog
L["Minimum Difficulty"] = "Difficulté Minimale"
L["Maximum Difficulty"] = "Difficulté Maximale"
L["Min Mythic+ Level"] = "Niveau Mythique+ Min"
L["Max Mythic+ Level"] = "Niveau Mythique+ Max"
L["Min Rating"] = "Côte Minimale"
L["Max Rating"] = "Côte Maximale"
L["Find Groups"] = "Rechercher des Groupes"
L["Reset Filters"] = "Réinitialiser les Filtres"
L["Close"] = "Fermer"

-- Tooltip
L["Group Details"] = "Détails du Groupe"
L["Activity"] = "Activité"
L["Difficulty"] = "Difficulté"
L["Leader Score"] = "Score du Chef"
L["Members"] = "Membres"
L["Created"] = "Créé"
L["ago"] = "il y a"

-- Categories
L["Dungeon"] = "Donjon"
L["Raid"] = "Raid"
L["Arena"] = "Arène"
L["Rated Battleground"] = "Champ de Bataille Coté"

-- Roles
L["Tank"] = "Tank"
L["Healer"] = "Soigneur"
L["DPS"] = "DPS"

-- Misc
L["Advanced Filtering"] = "Filtrage Avancé"
L["Use Expression"] = "Utiliser Expression"
L["Expression Help"] = "Aide sur les Expressions"