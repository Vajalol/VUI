local Layout = VUI:NewModule('Config.Layout.Chat')

function Layout:OnEnable()
    -- Database
    local db = VUI.db

    -- Layout
    Layout.layout = {
        layoutConfig = { padding = { top = 15 } },
        database = db.profile.chat,
        rows = {
            {
                header = {
                    type = 'header',
                    label = 'Chat'
                }
            },
            {
                style = {
                    key = 'style',
                    label = 'Style',
                    type = 'dropdown',
                    options = {
                        { value = 'Default', text = 'Default' },
                        { value = 'Custom', text = 'Custom' }
                    },
                    column = 5,
                    order = 1
                }
            },
            {
                chatinput = {
                    key = 'top',
                    type = 'checkbox',
                    label = 'Input on Top',
                    tooltip = 'Move chat input field to top of chat',
                    column = 4,
                    order = 1
                },
                link = {
                    key = 'link',
                    type = 'checkbox',
                    label = 'Link Copy',
                    tooltip = 'Make links clickable to copy them',
                    column = 4,
                    order = 2
                },
                copy = {
                    key = 'copy',
                    type = 'checkbox',
                    label = 'Copy Button',
                    tooltip = 'Show/Hide button to copy chat history',
                    column = 4,
                    order = 3
                },
            },
            {
                history = {
                    key = 'history',
                    type = 'checkbox',
                    label = 'Save Chat History',
                    tooltip = 'Save the last 500 lines of chat between sessions',
                    column = 6,
                    order = 1
                },
                emojis = {
                    key = 'emojis',
                    type = 'checkbox',
                    label = 'Chat Emojis',
                    tooltip = 'Enable emoji conversion in chat messages',
                    column = 6,
                    order = 2
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Sound Effects'
                }
            },
            {
                sounds = {
                    key = 'sounds',
                    type = 'checkbox',
                    label = 'Enable Sound Effects',
                    tooltip = 'Enable chat sound effects',
                    column = 5,
                    order = 1
                },
                whisperSound = {
                    key = 'whisperSound',
                    type = 'checkbox',
                    label = 'Whisper Sound',
                    tooltip = 'Play a sound when you receive a whisper',
                    column = 7,
                    order = 2
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Icons & Buttons'
                }
            },
            {
                quickjoin = {
                    key = 'quickjoin',
                    type = 'checkbox',
                    label = 'Friendlist Button',
                    tooltip = 'Show/Hide friendlist button',
                    column = 4,
                    order = 1
                },
                looticons = {
                    key = 'looticons',
                    type = 'checkbox',
                    label = 'Loot Icons',
                    tooltip = 'Display icons for loot in chat',
                    column = 4,
                    order = 2
                },
                roleicons = {
                    key = 'roleicons',
                    type = 'checkbox',
                    label = 'Role Icons',
                    tooltip = 'Display role icons in chat',
                    column = 4,
                    order = 3
                }
            },
            {
                header = {
                    type = 'header',
                    label = 'Friendlist'
                }
            },
            {
                friendlist = {
                    key = 'friendlist',
                    type = 'checkbox',
                    label = 'Class-Friendlist',
                    tooltip = 'Show character names in class color in friendlist',
                    column = 4,
                    order = 1
                }
            }
        },
    }
end
