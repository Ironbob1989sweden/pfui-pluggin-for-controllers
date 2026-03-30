-- Mappning för alla 18+ knappar på Steam Deck
-- Vi utgår från att du har mappat Deck-kontrollerna till siffror och bokstäver i SteamOS
local textMapping = {
    -- HUVUDKNAPPAR (Höger sida)
    ["1"] = "|cff00ff00[A]|r", -- Grön
    ["2"] = "|cffff0000[B]|r", -- Röd
    ["3"] = "|cff5555ff[X]|r", -- Blå
    ["4"] = "|cffffff00[Y]|r", -- Gul

    -- D-PAD / PILAR (Vänster sida)
    ["5"] = "|cffffffcc[^]|r", -- Upp (D-pad Up)
    ["6"] = "|cffffffcc[v]|r", -- Ner (D-pad Down)
    ["7"] = "|cffffffcc[<]|r", -- Vänster (D-pad Left)
    ["8"] = "|cffffffcc[>]|r", -- Höger (D-pad Right)

   
    -- KOMBINATIONER (Exempel med r4/Shift som modifier)
    -- pfUI skriver oftast "s-1" för Shift+1, "c-1" för Ctrl+1
    ["s-1"] = "|cff00ff00R4+A|r",
    ["s-2"] = "|cffff0000R4+B|r",
    ["s-3"] = "|cff5555ffR4+X|r",
    ["s-4"] = "|cffffff00R4+Y|r",
    
    -- D-PAD med modifier
    ["s-5"] = "|cffffffccR4+^|r",
    ["s-6"] = "|cffffffccR4+v|r",
    ["s-7"] = "|cffffffccR4+<|r",
    ["s-8"] = "|cffffffccR4+>|r",

        -- KOMBINATIONER (Exempel med r5/ctrl som modifier)
    -- pfUI skriver oftast "s-1" för Shift+1, "c-1" för Ctrl+1
    ["c-1"] = "|cff00ff00R5+A|r",
    ["c-2"] = "|cffff0000R5+B|r",
    ["c-3"] = "|cff5555ffR5+X|r",
    ["c-4"] = "|cffffff00R5+Y|r",
    
    -- D-PAD med modifier
    ["c-5"] = "|cffffffccR5+^|r",
    ["c-6"] = "|cffffffccR5+v|r",
    ["c-7"] = "|cffffffccR5+<|r",
    ["c-8"] = "|cffffffccR5+>|r",
}

local function ApplySteamDeckText()
    -- Gå igenom pfUI:s alla 6 actionbars
    for bar=1, 6 do
        for btnIdx=1, 12 do
            local buttonName = "pfActionBar"..bar.."Button"..btnIdx
            local hotkey = getglobal(buttonName.."HotKey")
            
            if hotkey then
                local currentText = hotkey:GetText()
                
                -- Om texten på knappen finns i vår lista, byt ut den
                if currentText and textMapping[currentText] then
                    -- Vi sätter en tydlig font och storlek
                    hotkey:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
                    hotkey:SetText(textMapping[currentText])
                    hotkey:SetAlpha(1)
                    
                    -- Justera positionen lite så det ser centrerat ut i hörnet
                    hotkey:ClearAllPoints()
                    hotkey:SetPoint("TOPRIGHT", buttonName, "TOPRIGHT", -2, -2)
                end
            end
        end
    end
end

-- Kör skriptet när spelet laddas
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
f:SetScript("OnEvent", function()
    -- Vänta 0.5 sekunder så pfUI hinner rita sina egna knappar först
    local elapsed = 0
    f:SetScript("OnUpdate", function()
        elapsed = elapsed + arg1
        if elapsed > 0.5 then
            ApplySteamDeckText()
            f:SetScript("OnUpdate", nil)
        end
    end)
end)
end)
