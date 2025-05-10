-- VUISkin Core
local AddonName, VUI = ...

-- Get our module
local VUISkin = VUI:GetModule("VUISkin")

-- Local variables
local LSM = LibStub('LibSharedMedia-3.0')
local skinName = '|cff8080ffVUI Theme|r'
local retail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

-- Initialize skinTable with references to our module path
local skinTable = {
    file = [[Interface\AddOns\Details\images\skins\flat_skin.blp]],
    author = "VUI Team",
    version = VUI.Version,
    site = "https://github.com/VUI-Team/VUI",
    desc = "VUI integrated skin for Details! Damage Meter.\n\nThis skin automatically adapts to the current VUI theme.",
    no_cache = true,

    -- micro frames
    micro_frames = {color = {1, 1, 1, 1}, font = "Accidental Presidency", size = 10, textymod = 1},

    can_change_alpha_head = true,
    icon_anchor_main = {-1, -5},
    icon_anchor_plugins = {-7, -13},
    icon_plugins_size = {19, 18},

    -- anchors:
    icon_point_anchor = {-37, 0},
    left_corner_anchor = {-107, 0},
    right_corner_anchor = {96, 0},

    icon_point_anchor_bottom = {-37, 12},
    left_corner_anchor_bottom = {-107, 0},
    right_corner_anchor_bottom = {96, 0},

    icon_on_top = true,
    icon_ignore_alpha = true,
    icon_titletext_position = {3, 3},

    instance_cprops = {
        -- titlebar
        titlebar_shown = true,
        titlebar_height = 32,
        titlebar_texture = "VUISkinHeader",
        titlebar_texture_color = {1.0, 1.0, 1.0, 1.0},
        --
        ["toolbar_icon_file"] = "Interface\\AddOns\\Details\\images\\toolbar_icons_shadow",
        ["toolbar_side"] = 1,
        ["menu_anchor"] = {
            10, -- [1]
            10, -- [2]
            ["side"] = 2
        },
        --
        ["attribute_text"] = {
            ["enabled"] = true,
            ["shadow"] = false,
            ["side"] = 1,
            ["text_size"] = 13,
            ["custom_text"] = "{name}",
            ["text_face"] = "Friz Quadrata TT",
            ["anchor"] = {
                -4, -- [1]
                10 -- [2]
            },
            ["text_color"] = {
                NORMAL_FONT_COLOR.r, -- [1]
                NORMAL_FONT_COLOR.g, -- [2]
                NORMAL_FONT_COLOR.b, -- [3]
                NORMAL_FONT_COLOR.a -- [4]
            },
            ["enable_custom_text"] = false,
            ["show_timer"] = true
        },
        --
        ["row_info"] = {
            ["texture_highlight"] = "Interface\\FriendsFrame\\UI-FriendsList-Highlight",
            ["fixed_text_color"] = {
                1, -- [1]
                1, -- [2]
                1 -- [3]
            },
            ["height"] = 28, --
            ["space"] = {["right"] = 0, ["left"] = 0, ["between"] = 4}, --
            row_offsets = {left = 29, right = -29 - 8, top = 0, bottom = 0}, --
            ["texture_background_class_color"] = false,
            ["font_face_file"] = "Interface\\Addons\\Details\\fonts\\Accidental Presidency.ttf",
            ["backdrop"] = {
                ["enabled"] = false,
                ["size"] = 12,
                ["color"] = {
                    1, -- [1]
                    1, -- [2]
                    1, -- [3]
                    1 -- [4]
                },
                ["texture"] = "Details BarBorder 2"
            },
            ["icon_file"] = "Interface\\AddOns\\VUI\\VModules\\VUISkin\\Textures\\ClassIconsTWW",
            start_after_icon = false, --
            icon_offset = {-30, 0}, --
            --
            ["textL_show_number"] = true, --
            ["textL_outline"] = false,
            ["textL_enable_custom_text"] = false, --
            ["textL_custom_text"] = "{data1}. {data3}{data2}", --
            ["textL_class_colors"] = false,
            --
            ["textR_outline"] = false, --
            ["textR_bracket"] = "(",
            ["textR_enable_custom_text"] = false,
            ["textR_custom_text"] = "{data1} ({data2}, {data3}%)",
            ["textR_class_colors"] = false,
            ["textR_show_data"] = {
                true, -- [1]
                true, -- [2]
                true -- [3]
            },
            --
            ["fixed_texture_color"] = {
                0, -- [1]
                0, -- [2]
                0 -- [3]
            },
            ["models"] = {
                ["upper_model"] = "Spells\\AcidBreath_SuperGreen.M2",
                ["lower_model"] = "World\\EXPANSION02\\DOODADS\\Coldarra\\COLDARRALOCUS.m2",
                ["upper_alpha"] = 0.5,
                ["lower_enabled"] = false,
                ["lower_alpha"] = 0.1,
                ["upper_enabled"] = false
            },
            ["texture_custom_file"] = "Interface\\",
            ["texture_custom"] = "",
            ["alpha"] = 1,
            ["no_icon"] = false,
            ["texture"] = "VUISkinBar",
            ["texture_file"] = "Interface\\AddOns\\VUI\\VModules\\VUISkin\\Textures\\bar",
            ["texture_background"] = "VUISkinBackground", --
            ["texture_background_file"] = "Interface\\AddOns\\VUI\\VModules\\VUISkin\\Textures\\background", --        

            ["fixed_texture_background_color"] = {1, 1, 1, 1}, --
            ["font_face"] = "Friz Quadrata TT", --
            ["font_size"] = 11, --
            ["textL_offset"] = 0, --
            ["text_yoffset"] = 7, --
            ["texture_class_colors"] = true,
            ["percent_type"] = 1,
            ["fast_ps_update"] = false,
            ["textR_separator"] = ",",
            ["use_spec_icons"] = true, --
            ["spec_file"] = "Interface\\AddOns\\VUI\\VModules\\VUISkin\\Textures\\specs", --
            icon_size_offset = 1.2
        },
        --
        menu_icons_alpha = 1,
        ["show_statusbar"] = false,
        ["menu_icons_size"] = 1.07,
        ["color"] = {
            0.333333333333333, -- [1]
            0.333333333333333, -- [2]
            0.333333333333333, -- [3]
            0 -- [4]
        },
        ["bg_r"] = 0.0941176470588235,
        ["hide_out_of_combat"] = false,
        ["following"] = {
            ["bar_color"] = {
                1, -- [1]
                1, -- [2]
                1 -- [3]
            },
            ["enabled"] = false,
            ["text_color"] = {
                1, -- [1]
                1, -- [2]
                1 -- [3]
            }
        },
        ["color_buttons"] = {
            1, -- [1]
            1, -- [2]
            1, -- [3]
            1 -- [4]
        },
        ["skin_custom"] = "",
        ["menu_anchor_down"] = {
            16, -- [1]
            -3 -- [2]
        },
        ["micro_displays_locked"] = true,
        ["row_show_animation"] = {["anim"] = "Fade", ["options"] = {}},
        ["tooltip"] = {["n_abilities"] = 3, ["n_enemies"] = 3},
        ["total_bar"] = {
            ["enabled"] = false,
            ["only_in_group"] = true,
            ["icon"] = "Interface\\ICONS\\INV_Sigil_Thorim",
            ["color"] = {
                1, -- [1]
                1, -- [2]
                1 -- [3]
            }
        },
        ["show_sidebars"] = false,
        ["instance_button_anchor"] = {
            -27, -- [1]
            1 -- [2]
        },
        ["plugins_grow_direction"] = 1,
        ["menu_alpha"] = {
            ["enabled"] = false,
            ["onleave"] = 1,
            ["ignorebars"] = false,
            ["iconstoo"] = true,
            ["onenter"] = 1
        },
        ["micro_displays_side"] = 2,
        ["grab_on_top"] = false,
        ["strata"] = "LOW",
        ["bars_grow_direction"] = 1,
        ["bg_alpha"] = 0, --
        ["ignore_mass_showhide"] = false,
        ["hide_in_combat_alpha"] = 0,
        ["menu_icons"] = {
            true, -- [1]
            true, -- [2]
            true, -- [3]
            true, -- [4]
            true, -- [5]
            false, -- [6]
            ["space"] = 0,
            ["shadow"] = false
        },
        ["auto_hide_menu"] = {["left"] = false, ["right"] = false},
        ["statusbar_info"] = {
            ["alpha"] = 0,
            ["overlay"] = {
                0.333333333333333, -- [1]
                0.333333333333333, -- [2]
                0.333333333333333 -- [3]
            }
        },
        ["window_scale"] = 1,
        ["libwindow"] = {["y"] = 90.9987335205078, ["x"] = -80.0020751953125, ["point"] = "BOTTOMRIGHT"},
        ["backdrop_texture"] = "Details Ground",
        ["hide_icon"] = true,
        ["bg_b"] = 0.0941176470588235,
        ["bg_g"] = 0.0941176470588235,
        ["desaturated_menu"] = false,
        ["wallpaper"] = {
            ["enabled"] = false,
            ["texcoord"] = {
                0, -- [1]
                1, -- [2]
                0, -- [3]
                0.7 -- [4]
            },
            ["overlay"] = {
                1, -- [1]
                1, -- [2]
                1, -- [3]
                1 -- [4]
            },
            ["anchor"] = "all",
            ["height"] = 114.042518615723,
            ["alpha"] = 0.5,
            ["width"] = 283.000183105469
        },
        ["stretch_button_side"] = 1,
        ["bars_sort_direction"] = 1
    }
}

-- Function to register textures with LibSharedMedia
function VUISkin:RegisterTextures()
    -- Register the textures with LibSharedMedia
    LSM:Register('statusbar', 'VUISkinHeader', [[Interface\AddOns\VUI\VModules\VUISkin\Textures\header.blp]])
    LSM:Register('statusbar', 'VUISkinBar', [[Interface\AddOns\VUI\VModules\VUISkin\Textures\bar.blp]])
    LSM:Register('statusbar', 'VUISkinBackground', [[Interface\AddOns\VUI\VModules\VUISkin\Textures\background.blp]])
end

-- Function to register the skin with Details
function VUISkin:RegisterSkin()
    -- Check if Details is loaded
    if not _G.Details then
        VUI:Debug("Details not loaded, cannot register skin.")
        return
    end
    
    -- Update skin colors to match current VUI theme
    self:UpdateSkinColors()
    
    -- Register the skin with Details
    if _G.Details.InstallSkin then
        _G.Details:InstallSkin(skinName, skinTable)
        VUI:Debug("VUISkin registered with Details.")
    else
        VUI:Debug("Details.InstallSkin not found.")
    end
end

-- Function to update skin colors based on current VUI theme
function VUISkin:UpdateSkinColors()
    -- Get current theme color
    local themeColor = VUI:GetThemeColor()
    
    -- Apply theme color to titlebar
    if themeColor then
        skinTable.instance_cprops.titlebar_texture_color = {
            themeColor.r or 1.0,
            themeColor.g or 1.0,
            themeColor.b or 1.0,
            1.0
        }
    end
end

-- Function to import the default profile
function VUISkin:ImportDefaultProfile()
    -- Check if Details is loaded
    if not _G.Details then
        VUI:Print("Details! is not loaded. Cannot import profile.")
        return false
    end
    
    -- Check if we have a default profile
    if not self.DefaultProfileImport then
        VUI:Print("Default profile not available.")
        return false
    end
    
    -- Import the profile
    local profileString = self.DefaultProfileImport
    if profileString and _G.Details.ImportProfile then
        local profileLoaded = _G.Details:ImportProfile(profileString, "VUI Default")
        if profileLoaded then
            VUI:Print("VUI Default profile for Details! has been imported.")
            return true
        else
            VUI:Print("Failed to import VUI Default profile for Details!.")
            return false
        end
    end
    
    return false
end

-- Function to apply the skin to all Details windows
function VUISkin:ApplySkin()
    -- Check if Details is loaded
    if not _G.Details then
        VUI:Print("Details! is not loaded. Cannot apply skin.")
        return
    end
    
    -- Register textures
    self:RegisterTextures()
    
    -- Register the skin
    self:RegisterSkin()
    
    -- Apply the skin to all windows
    for instanceId = 1, _G.Details:GetNumInstances() do
        local instance = _G.Details:GetInstance(instanceId)
        if (instance and instance.baseframe and instance.ativa) then
            instance:ChangeSkin(skinName)
        end
    end
    
    -- Import default profile if enabled
    if self.db.profile.useDefaultProfile then
        self:ImportDefaultProfile()
    end
    
    -- Hook into Details theme system
    if retail then
        self:ChangeAugmentationBar()
    end
    
    VUI:Debug("VUISkin applied to all Details windows.")
end

-- Function to remove the skin from all Details windows
function VUISkin:RemoveSkin()
    -- Check if Details is loaded
    if not _G.Details then
        VUI:Print("Details! is not loaded.")
        return
    end
    
    -- Set all instances to use the default skin
    for instanceId = 1, _G.Details:GetNumInstances() do
        local instance = _G.Details:GetInstance(instanceId)
        if (instance and instance.baseframe and instance.ativa) then
            instance:ChangeSkin("Minimalistic")
        end
    end
    
    VUI:Debug("VUISkin removed from all Details windows.")
end

-- Function to change augmentation bar colors (for retail only)
function VUISkin:ChangeAugmentationBar()
    if not retail or not _G.Details then return end
    
    -- Get evoker class color from Details
    local evokerColor = _G.Details.class_colors["EVOKER"]
    if not evokerColor then return end
    
    -- Apply to existing lines
    for instanceId = 1, _G.Details:GetNumInstances() do
        local instance = _G.Details:GetInstance(instanceId)
        if (instance and instance.baseframe and instance.ativa) then
            for _, line in ipairs(instance:GetAllLines()) do
                local extraStatusbar = line.extraStatusbar
                if extraStatusbar then
                    extraStatusbar:SetStatusBarTexture([[Interface\AddOns\VUI\VModules\VUISkin\Textures\augment]])
                    extraStatusbar:GetStatusBarTexture():SetVertexColor(unpack(evokerColor))
                    if extraStatusbar.texture then
                        extraStatusbar.texture:SetVertexColor(unpack(evokerColor))
                    end
                end
            end
        end
    end
    
    -- Hook into creation of new lines
    local gump = _G.Details.gump
    if gump then
        hooksecurefunc(gump, 'CreateNewLine', function(self, instance, index)
            local newLine = _G['DetailsBarra_' .. instance.meu_id .. '_' .. index]
            if newLine and newLine.extraStatusbar then
                local extraStatusbar = newLine.extraStatusbar
                extraStatusbar:SetStatusBarTexture([[Interface\AddOns\VUI\VModules\VUISkin\Textures\augment]])
                extraStatusbar:GetStatusBarTexture():SetVertexColor(unpack(evokerColor))
                if extraStatusbar.texture then
                    extraStatusbar.texture:SetVertexColor(unpack(evokerColor))
                end
            end
        end)
    end
end

-- Function to handle theme changes
function VUISkin:OnThemeChanged()
    -- Update skin colors to match new theme
    self:UpdateSkinColors()
    
    -- Reapply skin if enabled
    if self.db.profile.enabled then
        self:ApplySkin()
    end
end

-- Additional initialization for the Core component
function VUISkin:OnCoreInitialize()
    -- Register with VUI theme system
    VUI:RegisterCallback("OnThemeChanged", function() self:OnThemeChanged() end)
    
    -- Register textures right away
    self:RegisterTextures()
end

-- Hook into the main OnInitialize method to add our core initialization
local originalOnInitialize = VUISkin.OnInitialize
function VUISkin:OnInitialize()
    -- Call the original OnInitialize first
    originalOnInitialize(self)
    
    -- Then call our core-specific initialization
    self:OnCoreInitialize()
end