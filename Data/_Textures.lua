local Textures = VUI:NewModule('Data.Textures');
local LSM = LibStub("LibSharedMedia-3.0")

local LSM_StatusBarTexturesList = LSM:List('statusbar')
local LSM_StatusBarTexturesHash = LSM:HashTable('statusbar')

local LSM_Textures = VUI:LSB_Helper(LSM_StatusBarTexturesList, LSM_StatusBarTexturesHash)

Textures.data = LSM_Textures
