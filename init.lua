-- Registrera din modul i pfUI
pfUI:RegisterModule("pfsd", function ()
    -- Skapa standardvärden om de saknas
    pfUI_config.pfsd = pfUI_config.pfsd or {}
    pfUI_config.pfsd.icon_size = pfUI_config.pfsd.icon_size or "24"

    -- Lägg till inställningen i pfUI-menyn
    -- Denna kommer dyka upp under "Third Party" eller en egen flik
    pfUI.gui.tabs.custom.widgets.pfsd = pfUI.gui.tabs.custom.widgets.pfsd or {}
    table.insert(pfUI.gui.tabs.custom.widgets.pfsd, {
        type = "group",
        order = 1,
        name = "Steam Deck Plugin",
        desc = "Inställningar för Steam Deck-ikoner",
        args = {
            icon_size = {
                type = "range",
                name = "Symbolstorlek",
                desc = "Ändra storleken på dina ikoner",
                min = 10, max = 80, step = 1,
                get = function() return pfUI_config.pfsd.icon_size end,
                set = function(val) 
                    pfUI_config.pfsd.icon_size = val
                    -- Här anropar du din funktion som ritar om ikonerna
                    if pfUI.pfsd then pfUI.pfsd:UpdateIcons() end
                end,
            },
        },
    })
end)