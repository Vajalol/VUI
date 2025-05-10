-------------------------------------------------------------------------------
-- VUI Gfinder (based on Premade Groups Filter)
-- Module for VUI - Vortex UI Addon Suite
-------------------------------------------------------------------------------

local VUI = _G.VUI
local Module = VUI:GetModule("VUIGfinder")
if not Module then return end

local VUIGfinder = _G.VUIGfinder
local L = VUIGfinder.L

if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end

-- Spanish localization (Spain and Mexico)
-- Values set to true use the English default

-- General
L["VUI Gfinder"] = "VUI Buscador de Grupos"
L["Enhances the Group Finder with advanced filtering"] = "Mejora el Buscador de Grupos con filtrado avanzado"

-- UI Text
L["Enable"] = "Activar"
L["Open Filter Dialog"] = "Abrir diálogo de filtro"
L["Dialog Scale"] = "Escala del diálogo"
L["Enhanced Tooltips"] = "Información emergente mejorada"
L["One-Click Sign Up"] = "Inscribirse con un clic"
L["Remember Sign Up Notes"] = "Recordar notas de inscripción"
L["Sign Up on Enter"] = "Inscribirse al pulsar Enter"
L["Show Filter Button"] = "Mostrar botón de filtro"

-- Advanced Filter
L["Enable Advanced Mode"] = "Activar modo avanzado"
L["Filter Expression"] = "Expresión de filtro"
L["Enable Custom Sorting"] = "Activar ordenación personalizada"
L["Sorting Expression"] = "Expresión de ordenación"

-- Difficulties
L["Normal"] = "Normal"
L["Heroic"] = "Heroico"
L["Mythic"] = "Mítico"
L["Mythic+"] = "Mítico+"
L["Arena 2v2"] = "Arena 2v2"
L["Arena 3v3"] = "Arena 3v3"

-- Dialog
L["Minimum Difficulty"] = "Dificultad mínima"
L["Maximum Difficulty"] = "Dificultad máxima"
L["Min Mythic+ Level"] = "Nivel Mítico+ mínimo"
L["Max Mythic+ Level"] = "Nivel Mítico+ máximo"
L["Min Rating"] = "Clasificación mínima"
L["Max Rating"] = "Clasificación máxima"
L["Find Groups"] = "Buscar grupos"
L["Reset Filters"] = "Restablecer filtros"
L["Close"] = "Cerrar"

-- Tooltip
L["Group Details"] = "Detalles del grupo"
L["Activity"] = "Actividad"
L["Difficulty"] = "Dificultad"
L["Leader Score"] = "Puntuación del líder"
L["Members"] = "Miembros"
L["Created"] = "Creado"
L["ago"] = "hace"

-- Categories
L["Dungeon"] = "Mazmorra"
L["Raid"] = "Banda"
L["Arena"] = "Arena"
L["Rated Battleground"] = "Campo de batalla clasificatorio"

-- Roles
L["Tank"] = "Tanque"
L["Healer"] = "Sanador"
L["DPS"] = "DPS"

-- Misc
L["Advanced Filtering"] = "Filtrado avanzado"
L["Use Expression"] = "Usar expresión"
L["Expression Help"] = "Ayuda de expresiones"