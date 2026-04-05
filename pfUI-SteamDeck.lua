local addonName = "pfUI-SteamDeck"
local iconPath = "Interface\\AddOns\\" .. addonName .. "\\tga\\"

-- 1. HÄMTA SPARAD STORLEK (Eller använd 14 som standard)
pfUI_config = pfUI_config or {}
pfUI_config.pfsd = pfUI_config.pfsd or { icon_size = 14 }
local iconSize = pfUI_config.pfsd.icon_size

local buttonIcons = {
    [1] = "y", [2] = "x", [3] = "a", [4] = "b",
    [5] = "up", [6] = "left", [7] = "down", [8] = "right",
}

local function UpdateButton(btn, iconFile, modFile)
    if not btn or not btn:GetName() then return end

    -- 2. DÖDA pfUI TEXT
    local hk = getglobal(btn:GetName().."HotKey")
    if hk then hk:SetAlpha(0) end

    -- 3. SKAPA/HÄMTA TEXTURER
    local mainTex = getglobal(btn:GetName().."FinalMain") or btn:CreateTexture(btn:GetName().."FinalMain", "OVERLAY")
    local modTex = getglobal(btn:GetName().."FinalMod") or btn:CreateTexture(btn:GetName().."FinalMod", "OVERLAY")

    -- 4. RITA MODIFIER (R4/R5)
    if modFile then
        modTex:SetTexture(iconPath .. modFile .. ".tga")
        modTex:SetWidth(iconSize)
        modTex:SetHeight(iconSize)
        modTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
        modTex:Show()
    else
        modTex:Hide()
    end

    -- 5. RITA KNAPP (A/B/X/Y)
    if iconFile then
        mainTex:SetTexture(iconPath .. iconFile .. ".tga")
        mainTex:SetWidth(iconSize)
        mainTex:SetHeight(iconSize)
        mainTex:ClearAllPoints()
        if modFile then
            mainTex:SetPoint("RIGHT", modTex, "LEFT", 0, 0)
        else
            mainTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
        end
        mainTex:Show()
    else
        mainTex:Hide()
    end
end

local function Refresh()
    -- Uppdatera iconSize från config innan vi ritar
    iconSize = pfUI_config.pfsd.icon_size

    for i=1, 12 do
        local m = getglobal("pfActionBarMainButton"..i)
        local l = getglobal("pfActionBarLeftButton"..i)
        local t = getglobal("pfActionBarTopButton"..i)

        if m then UpdateButton(m, buttonIcons[i], nil) end
        if l then UpdateButton(l, buttonIcons[i], "r5") end
        if t then UpdateButton(t, buttonIcons[i], "r4") end
    end
end

-- 6.1 SKAPA INSTÄLLNINGSFÖNSTRET (/pfsd)
-- Slash kommando (Viktigt: PFSD i versaler)
DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99pfUI-SD:|r ironbobs pfui pluggin is loaded typ /pfsd for Settings")
SLASH_PFSD1 = "/pfsd"
SlashCmdList["PFSD"] = function()
    if PFSD_Settings:IsShown() then
        PFSD_Settings:Hide()
    else
        PFSD_Settings:Show()
    end
end
-- 6. SKAPA INSTÄLLNINGSFÖNSTRET (/pfsd)
local settings = CreateFrame("Frame", "PFSD_Settings", UIParent)
settings:SetWidth(200)
settings:SetHeight(180) -- Gjorde fönstret högre (från 100 till 180)
settings:SetPoint("CENTER", 0, 0)
settings:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 3, right = 3, top = 3, bottom = 3 }
})
settings:SetBackdropColor(0, 0, 0, 0.9)
settings:SetMovable(true)
settings:EnableMouse(true)
settings:RegisterForDrag("LeftButton")
settings:SetScript("OnDragStart", function() this:StartMoving() end)
settings:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
settings:Hide()

-- Titel
local title = settings:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
title:SetPoint("TOP", 0, -10)
title:SetText("Steam Deck Inställningar")

-- Stängknapp
local close = CreateFrame("Button", "PFSD_CloseButton", settings, "UIPanelCloseButton")
close:SetPoint("TOPRIGHT", 2, 2)
close:SetScript("OnClick", function() settings:Hide() end)

-- Slider
local slider = CreateFrame("Slider", "PFSD_Slider", settings, "OptionsSliderTemplate")
slider:SetPoint("TOP", 0, -45)
slider:SetWidth(150)
slider:SetMinMaxValues(10, 40)
slider:SetValueStep(1)
slider:SetValue(iconSize)
getglobal(slider:GetName() .. 'Text'):SetText("Storlek: " .. iconSize)
slider:SetScript("OnValueChanged", function()
    local val = math.floor(this:GetValue())
    getglobal(this:GetName() .. 'Text'):SetText("Storlek: " .. val)
    pfUI_config.pfsd.icon_size = val
    iconSize = val
    Refresh()
end)

-- FUNKTION FÖR ATT BINDA KNAPPAR
local function BindSteamDeckKeys()
    -- Actionbar Top (pfUI Top Bar knappar 1-8) -> SHIFT-1 till SHIFT-8
    -- I pfUI heter knapparna internt MULTIACTIONBAR1BUTTON1 osv för binds
    for i=1, 8 do
        SetBinding("SHIFT-"..i, "MULTIACTIONBAR1BUTTON"..i)
    end

    -- Actionbar Left (pfUI Left Bar knappar 1-8) -> CTRL-1 till CTRL-8
    for i=1, 8 do
        SetBinding("CTRL-"..i, "MULTIACTIONBAR2BUTTON"..i)
    end

    SaveBindings(GetCurrentBindingSet()) -- Sparar ändringarna permanent
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99pfUI-SD:|r Keybinds uppdaterade! (SHIFT 1-8 & CTRL 1-8)")
end

-- KNAPP FÖR ATT AKTIVERA BINDS
local bindBtn = CreateFrame("Button", "PFSD_BindButton", settings, "UIPanelButtonTemplate")
bindBtn:SetWidth(160)
bindBtn:SetHeight(25)
bindBtn:SetPoint("TOP", 0, -85)
bindBtn:SetText("Binde")
bindBtn:SetScript("OnClick", function()
    BindSteamDeckKeys()
end)

-- INFO TEXT
local info = settings:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
info:SetPoint("TOP", bindBtn, "BOTTOM", 0, -10)
info:SetWidth(180)
info:SetText("This will binde rebinde your SHIFT/CTRL 1-8 binds.")
-- 7. STARTA LOOPEN (Din original-loop)
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    this:SetScript("OnUpdate", function()
        this.elapsed = (this.elapsed or 0) + arg1
        if this.elapsed > 2 then
            Refresh()
            this.elapsed = 0
        end
    end)
end)
