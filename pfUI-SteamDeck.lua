local addonName = "pfUI-SteamDeck"
local iconPath = "Interface\\AddOns\\" .. addonName .. "\\tga\\"

-- 1. INITIALIZE CONFIG (Nu med 'true' som standard för show_icons)
pfUI_config = pfUI_config or {}
pfUI_config.pfsd = pfUI_config.pfsd or {}
if pfUI_config.pfsd.show_icons == nil then pfUI_config.pfsd.show_icons = true end
if pfUI_config.pfsd.icon_size == nil then pfUI_config.pfsd.icon_size = 14 end

local iconSize = pfUI_config.pfsd.icon_size

-- 2. UPDATE BUTTON FUNCTION
local function UpdateButton(btn, iconFile, modFile)
    if not btn or not btn:GetName() then return end

    local mainTex = getglobal(btn:GetName().."FinalMain") or btn:CreateTexture(btn:GetName().."FinalMain", "OVERLAY")
    local modTex = getglobal(btn:GetName().."FinalMod") or btn:CreateTexture(btn:GetName().."FinalMod", "OVERLAY")

    -- Hide default pfUI hotkey text
    local hk = getglobal(btn:GetName().."HotKey")
    if hk then hk:SetAlpha(0) end

    -- GLOBAL TOGGLE: If "Show Icons" is unchecked, hide everything and stop
    if not pfUI_config.pfsd.show_icons then
        mainTex:Hide()
        modTex:Hide()
        return
    end

    -- Draw Modifier (R4/R5)
    if modFile then
        modTex:SetTexture(iconPath .. modFile .. ".tga")
        modTex:SetWidth(iconSize)
        modTex:SetHeight(iconSize)
        modTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
        modTex:Show()
    else
        modTex:Hide()
    end

    -- Draw Primary Button (A/B/X/Y)
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

local buttonIcons = {
    [1] = "y", [2] = "x", [3] = "a", [4] = "b",
    [5] = "up", [6] = "left", [7] = "down", [8] = "right",
}

local function Refresh()
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

-- ... (Keep your existing variable declarations and UpdateButton function) ...

-- 3. CREATE SETTINGS WINDOW (Modified with Import Logic)
-- [Inside your settings window creation block]

-- BUTTON: EXPORT (Existing)
local exportBtn = CreateFrame("Button", nil, settings, "UIPanelButtonTemplate")
exportBtn:SetWidth(90) -- Smaller to fit import next to it
exportBtn:SetHeight(25)
exportBtn:SetPoint("TOPLEFT", bindBtn, "BOTTOMLEFT", 0, -10)
exportBtn:SetText("Export")

-- NEW BUTTON: IMPORT
local importBtn = CreateFrame("Button", nil, settings, "UIPanelButtonTemplate")
importBtn:SetWidth(90)
importBtn:SetHeight(25)
importBtn:SetPoint("LEFT", exportBtn, "RIGHT", 5, 0)
importBtn:SetText("Import SD")

-- THE EXPORT/IMPORT BOX
local exportBox = CreateFrame("EditBox", "PFSD_ExportBox", settings)
exportBox:SetHeight(60) -- Taller for easier pasting
exportBox:SetWidth(180)
exportBox:SetPoint("TOP", exportBtn, "BOTTOM", 0, -10)
exportBox:SetFontObject(GameFontHighlightSmall)
exportBox:SetMultiLine(true)
exportBox:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1})
exportBox:SetBackdropColor(0,0,0,1)
exportBox:SetText("PASTE CODE HERE")
exportBox:SetScript("OnEditFocusGained", function() this:HighlightText() end)
exportBox:Hide()

-- Logic for Export Button
exportBtn:SetScript("OnClick", function()
    if exportBox:IsShown() then exportBox:Hide() else 
        exportBox:Show() 
        -- Fill with current string if you want to export
        exportBox:SetText("Y3AAZgBVAEkAXwBjAG8AbgBmAGkAZwAgAD0AIAB7...") 
        exportBox:SetFocus() 
    end
end)

-- Logic for Import Button
importBtn:SetScript("OnClick", function()
    if not exportBox:IsShown() then
        exportBox:Show()
        exportBox:SetText("")
        exportBox:SetFocus()
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99pfUI-SD:|r Paste code into the box and click Import again.")
        return
    end

    local rawData = exportBox:GetText()
    
    -- Use pfUI's built-in decoder if available
    -- Note: pfUI uses 'pfUI.api.Base64Decode' and 'loadstring'
    if pfUI and pfUI.api and pfUI.api.Base64Decode then
        local decoded = pfUI.api.Base64Decode(rawData)
        local func = loadstring(decoded)
        if func then
            func() -- This executes the "pfUI_config = ..." script inside the string
            DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99pfUI-SD:|r Profile Imported! Reloading UI...")
            ReloadUI()
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99pfUI-SD:|r Error: Invalid Profile Data.")
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99pfUI-SD:|r Error: pfUI API not found.")
    end
end)

-- ... (Rest of your Slash Command and Refresh Loop) ...
-- 4. SLASH COMMAND
SLASH_PFSD1 = "/pfsd"
SlashCmdList["PFSD"] = function()
    if settings:IsShown() then settings:Hide() else settings:Show() end
end

-- 5. REFRESH LOOP
local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function()
    this.elapsed = (this.elapsed or 0) + arg1
    if this.elapsed > 2 then
        Refresh()
        this.elapsed = 0
    end
end)

DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99pfUI-SD:|r Loaded. Type /pfsd for settings.")
