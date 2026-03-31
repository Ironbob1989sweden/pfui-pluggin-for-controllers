local addonName = "pfUI-SteamDeck"
local iconPath = "Interface\\AddOns\\" .. addonName .. "\\tga\\"
local iconSize = 14

local buttonIcons = {
    [1] = "y", [2] = "x", [3] = "a", [4] = "b",
    [5] = "up", [6] = "left", [7] = "down", [8] = "right",
}

local function UpdateButton(btn, iconFile, modFile)
    if not btn or not btn:GetName() then return end

    -- 1. STÄDA BORT GAMLA SPÖKEN (Från tidigare kodversioner)
    local oldNames = {"DeckMain", "DeckMod", "_DeckIcon", "ModIcon", "_SD_Main", "_SD_Mod"}
    for _, suffix in pairs(oldNames) do
        local old = getglobal(btn:GetName()..suffix)
        if old then old:Hide() end
    end

    -- 2. DÖDA pfUI TEXT
    local hk = getglobal(btn:GetName().."HotKey")
    if hk then hk:SetAlpha(0) end

    -- 3. SKAPA DEN PERFEKTA IKONEN (Vi använder helt nya namn nu: "FinalMain" och "FinalMod")
    local mainTex = getglobal(btn:GetName().."FinalMain") or btn:CreateTexture(btn:GetName().."FinalMain", "OVERLAY")
    local modTex = getglobal(btn:GetName().."FinalMod") or btn:CreateTexture(btn:GetName().."FinalMod", "OVERLAY")

    -- Nollställ
    mainTex:Hide()
    modTex:Hide()
    mainTex:ClearAllPoints()
    modTex:ClearAllPoints()

    -- 4. RITA MODIFIER (R4/R5)
    if modFile then
        modTex:SetTexture(iconPath .. modFile .. ".tga")
        modTex:SetWidth(iconSize)
        modTex:SetHeight(iconSize)
        modTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
        modTex:Show()
    end

    -- 5. RITA KNAPP (A/B/X/Y)
    if iconFile then
        mainTex:SetTexture(iconPath .. iconFile .. ".tga")
        mainTex:SetWidth(iconSize)
        mainTex:SetHeight(iconSize)
        if modFile then
            -- Lägg bokstaven precis till vänster om R4/R5
            mainTex:SetPoint("RIGHT", modTex, "LEFT", 0, 0)
        else
            -- Annars i hörnet
            mainTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
        end
        mainTex:Show()
    end
end

local function Refresh()
    for i=1, 12 do
        local m = getglobal("pfActionBarMainButton"..i)
        local l = getglobal("pfActionBarLeftButton"..i)
        local t = getglobal("pfActionBarTopButton"..i)

        -- HÄR STYRS VAD SOM SKA SYNAS VAR:
        if m then UpdateButton(m, buttonIcons[i], nil) end    -- Main: Bara A/B/X/Y
        if l then UpdateButton(l, buttonIcons[i], "r5") end   -- Left: R5 + A/B/X/Y
        if t then UpdateButton(t, buttonIcons[i], "r4") end   -- Top:  R4 + A/B/X/Y
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    this:SetScript("OnUpdate", function()
        this.elapsed = (this.elapsed or 0) + arg1
        if this.elapsed > 2 then -- Uppdatera varannan sekund
            Refresh()
            this.elapsed = 0
        end
    end)
end)
