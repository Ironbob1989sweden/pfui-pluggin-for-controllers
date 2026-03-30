-- Konfiguration: Koppla din keybind-text till rätt ikonfil
-- Se till att namnen (t.ex. "1", "s-2") matchar exakt vad pfUI visar på knappen
local iconMapping = {
    ["1"]   = "button_A",
    ["2"]   = "button_B",
    ["3"]   = "button_X",
    ["4"]   = "button_Y",
    ["s-1"] = "button_L1_A", -- Exempel för Shift+1
    ["s-2"] = "button_L1_B",
    -- Fyll på med fler här...
}

local function UpdatePFUIIcons()
    -- Loopa igenom pfUI:s actionbars
    for bar=1, 6 do
        for btnIdx=1, 12 do
            local buttonName = "pfActionBar"..bar.."Button"..btnIdx
            local hotkey = getglobal(buttonName.."HotKey")
            
            if hotkey then
                local currentText = hotkey:GetText()
                
                -- Om texten finns i vår mapping, ersätt den med en ikon-sträng
                if currentText and iconMapping[currentText] then
                    local iconPath = "Interface\\AddOns\\pfUI-SteamDeck\\Icons\\" .. iconMapping[currentText]
                    
                    -- Formatet är: |T Sökväg : Bredd : Höjd : X-offset : Y-offset |t
                    -- Vi sätter 20x20 pixlar som standard, men du kan justera siffrorna nedan
                    local iconString = "|T" .. iconPath .. ":20:20:0:0|t"
                    
                    hotkey:SetText(iconString)
                    hotkey:SetAlpha(1) -- Se till att den syns
                end
            end
        end
    end
end

-- Skapa en frame för att bevaka när vi behöver uppdatera ikonerna
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ACTIONBAR_PAGE_CHANGED") -- Om du byter bar (t.ex. Stealth/Stance)

f:SetScript("OnEvent", function()
    -- Vi lägger in en kort delay (0.5s) så pfUI hinner skriva dit sin text först
    local elapsed = 0
    f:SetScript("OnUpdate", function()
        elapsed = elapsed + arg1
        if elapsed > 0.5 then
            UpdatePFUIIcons()
            f:SetScript("OnUpdate", nil) -- Stoppa loopen
        end
    end)
end)
