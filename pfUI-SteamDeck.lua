local addonName = "pfUI-SteamDeck"
local iconPath = "Interface\\AddOns\\" .. addonName .. "\\tga\\"

-- 1. CONFIG
pfUI_config = pfUI_config or {}
pfUI_config.pfsd = pfUI_config.pfsd or {}
if pfUI_config.pfsd.show_icons == nil then pfUI_config.pfsd.show_icons = true end
if pfUI_config.pfsd.icon_size == nil then pfUI_config.pfsd.icon_size = 14 end

-- 2. ICONS LOGIC
local buttonIcons = {[1]="y",[2]="x",[3]="a",[4]="b",[5]="up",[6]="left",[7]="down",[8]="right"}

local function UpdateButton(btn, iconFile, modFile)
    if not btn or not btn:GetName() then return end
    local name = btn:GetName()
    local mainTex = getglobal(name.."FinalMain") or btn:CreateTexture(name.."FinalMain", "OVERLAY")
    local modTex = getglobal(name.."FinalMod") or btn:CreateTexture(name.."FinalMod", "OVERLAY")
    
    if not pfUI_config.pfsd.show_icons then 
        mainTex:Hide() modTex:Hide() return 
    end

    local size = pfUI_config.pfsd.icon_size
    if modFile then
        modTex:SetTexture(iconPath .. modFile .. ".tga")
        modTex:SetWidth(size) modTex:SetHeight(size)
        modTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2)
        modTex:Show()
    else modTex:Hide() end

    if iconFile then
        mainTex:SetTexture(iconPath .. iconFile .. ".tga")
        mainTex:SetWidth(size) mainTex:SetHeight(size)
        mainTex:ClearAllPoints()
        if modFile then mainTex:SetPoint("RIGHT", modTex, "LEFT", 0, 0)
        else mainTex:SetPoint("TOPRIGHT", btn, "TOPRIGHT", -2, -2) end
        mainTex:Show()
    else mainTex:Hide() end
end

local function Refresh()
    for i=1, 12 do
        local m, l, t = getglobal("pfActionBarMainButton"..i), getglobal("pfActionBarLeftButton"..i), getglobal("pfActionBarTopButton"..i)
        if m then UpdateButton(m, buttonIcons[i], nil) end
        if l then UpdateButton(l, buttonIcons[i], "r5") end
        if t then UpdateButton(t, buttonIcons[i], "r4") end
    end
end

-- 3. THE SETTINGS UI
PFSD_Settings = CreateFrame("Frame", "PFSD_SettingsFrame", UIParent)
PFSD_Settings:SetWidth(250) PFSD_Settings:SetHeight(300) PFSD_Settings:SetPoint("CENTER", 0, 0)
PFSD_Settings:SetBackdrop({bgFile="Interface\\ChatFrame\\ChatFrameBackground", edgeFile="Interface\\Tooltips\\UI-Tooltip-Border", tile=true, tileSize=16, edgeSize=16, insets={left=3,right=3,top=3,bottom=3}})
PFSD_Settings:SetBackdropColor(0,0,0,0.9) PFSD_Settings:SetMovable(true) PFSD_Settings:EnableMouse(true)
PFSD_Settings:RegisterForDrag("LeftButton") PFSD_Settings:SetScript("OnDragStart", function() this:StartMoving() end) PFSD_Settings:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
PFSD_Settings:Hide()

local title = PFSD_Settings:CreateFontString(nil, "OVERLAY", "GameFontNormal")
title:SetPoint("TOP", 0, -10) title:SetText("Steam Deck Settings")

-- Import Instructions
local help = PFSD_Settings:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
help:SetPoint("TOP", 0, -35) help:SetText("1. Click 'Get String'\n2. Ctrl+C to copy code\n3. Open pfUI -> share -> replace code ->Import")

-- The String Box (Hidden until button click)
local editBox = CreateFrame("EditBox", "PFSD_ExportBox", PFSD_Settings, "InputBoxTemplate")
editBox:SetWidth(200) editBox:SetHeight(30) editBox:SetPoint("TOP", 0, -80)
editBox:SetAutoFocus(false) editBox:Hide()

local sd_profile_string = "Y3AAZgBVAEkAXwBjAG8AbgBmAGkAZwAgAD0AIAB7AAoAIAAgAFsAIgBkAGkAcwBhAGIAbABlAGQAIgBdAAsBDQEPARABEQEiAHQAbwB0AGUAbQBzABwBHgEiADAAIgAsACABEAESAXAAaQB4AGUAbABwAGUAcgBmAGUAYwB0ACoBDAEsAS4BMAEiAXMAawBpAG4AXwBTADgBbABsAGIAbwBvAGsAPwEgAEEBLwEhAUQBRgFIAU8AcAB0AGkABgFzACAALQAgAFMAbwB1AG4AGwEdAUABLQFVASEBEgFFAUcBXwBaAVwBXgFgASAAVgBpAGQAZQBvAFIBVAFDARIBZQFsAG8AYwBRAWgBUwFqAX0BIgBuAUgBRwBNAGIBdQByAHYAZQB5AHsBhgFWARIBdAByAGEAggFHAWcAkwFCAZUBIgCAASUBnQFrATEBIgA7AQkBZgFlAGEAdABoAKMBhwFjAGgAqwEFAXAAkgGEAXwBnwGsAWkAcgBkAHAAYQByAHQAeQAtAHYAYQBuAGkATAFhAK4BnwGJAV8ARQCQAXIAoQFrACAAQgByAG8AYQBkAGMAYQBzAFwBbgCcAbYBlAFsAYgBWAFfAFAAZQBcAXIBbgDJAeABbQBhAHAA6QGlAcsBUgCqAWQAeQCwATwBgwErAd8B7wHiAVQAmAFHATkB7gFXAW8BQgC+AWIAOQFzAGgAbwDtAd4BngHgAcsBUADUATsBcwBzAF0B6AELAqQBIgEkAW8AbABcAQoC+AEMAvoBbwFUAGEAGQFuAHQAKQEWAq8BdQDaAW8AbQAAAhIBaABkAGcAmAFwAGgAaQBjAHsBMQAfAiIBcABsAGEAeQD/ASgCnwFhAGYAawDYAS0CQQLgAXUAcABkAKsBZQBuACUBaQBmALUBHgIXAi8CZQEmAXIAYgC+AS4CIgDWAWQAXgFYAW4AQAJUAocBZQFpAHQAeAAdAmkBOgJtAeIBUQB1ADYCawBIAKoBbABcAssBTQBhAMYBTgF4AHYC4gFGAGwACQFoAHQA6wHaAWMCawJVAiIAYgB1AGYAZgB3ALIBrQFIAu8BSgI5AXcAbwB3AFwC6wFwAHIAZQCQASMCXAJaAmcAJwIrATkCiALLAQMCoQJoAHACXAKwAasBXAJhAHUAJAEHAlECPgGRAhgCvgFnAOUBdAC3ArkCuwK0AmQCuAGOAXQAGQEtAJUClwK1AhIBZgCBASoCfQJvAUMAsQGYAT0BhgKFAWwCIgD9AWcBvwLgAWcCJwFjAIACggGrAtkBdABaAnIAzAJIAVQAsAJvAHIAaQCeAscC4QFvAXEBFAJfAWEBTgBlAMYC2AIgAooBcAJsAGQAIADxAWcAFQGXAVsC7ALLAVMAlQKCAWIBPAJnAuQCXwBzAjcBCgNDABoC6AIgAFAAcQLSArcB4AG6AnIAuAJ0ABgDGgN2AjYBbADDAWwAdQBlAAoD/AHEAXMAbQBvAN0B9gIBAkgBUAAJAkoCIABEAOoCgAGhAgoD7wJzAWEBSQAlAjkBZgCZASQD7AIcA+UBCgNEAJsCEgIgAFUAcAAgAEYAmAFtAEADLAMSAWIAoQIFAZsCmAK6AdQBvwFpAE4DcgCiAocChwF3AjkBrAIlAnYCzwJPA14DygHiAeQBdABiAboCGAFlACAAeAKFAuMC7AKvAiQBkAFmAegCnwKLAmYAegNiAG4DXQPTAqUC+wHBAhkBeALGAQoDQgBPAWsAgAMWA6UBqgFyA2UAZwArA2cDDQLiAQMCGwMZAQgBNgH7Ak0ARwFaA+wBCgNHAPkC+wIiAuIC1wKUA6UBiwJfAHQAdQBrAKoCAgNYASUDmAF4AVwCMgJ5ADQCXgFcAm4AYQBtAHAAlgIVA/kBIgFeArkD7AJHAQgBZwCCAlwCZQEqAhcBGQFcAmkC4gJcAnEAIwPaAdoCRwJQAyIAbQCeA5kCmAJkAXMAeQHOAVwCOAG+AqgDIgE+A3IAbQApA7QDQQM1ArsBvQG/AVMC5QNtAm8BRwC8A28DTQBOAnUAXAJ3ADUCcwA4AXIAmgJvAHgA8QOBA18DbgLUA2sDTAAqA1wC1AFMAZgC7AEFAYABXANcAmUAcQAFAb0DvgFmAwUEQgJkAF8CbgAXBL0B5AMbBA0CYwCbAk4CBwKiAewCTgI5AWcAeQBcAd4C7AJnANcD8gPtAkgBSwCRAUIARwEUAdwBjAPBAxIBMgJkAWoCIwT3Al8A5gK/ARkBIABMAEYAVAAPBCUEJQF3AKoB9wE0BMMDbgCKAhsDxAPYA8sBTANpAE4CZAA9BNQCgAHYAecBPALLAuwCBQIbAzkBJAEmASgBDgNvAEcBEgNxAkoCiAOrAcICZQCaA/oCYgFUAxoEjQMtA18AeAJOBAoDQQB1AD0BFAIIAioCewQ+BDUEXwBvAmUA2gEgAFQAWgPAA9QCvQFiAnUCsAMhAoQDbwNTAAgCQgR8BPMDSAFSAHkCZAACAVwCCALOAWIAOgQKAzsD/gM8ASIEngSKBFoBmQFnAgQErwTjA0IDrgSJBLsDTgM8Ak0CjAOkAgYEAgJ0BJkDXAT6AqEDbwASAmkASgPEAfsCjATaAVwCCAFcA5cBZQGuAoQEBgHRAwIDgQE0A+oDJQNPARsCyQRfBIgCBQEaAl8CdwAVAtgDFwROAb4DRwEmAukBfQBrAX4BxQF0AGYATQONBFIBDgGfAVsBvQL2BEMBpQFwAOICJgF4AKwDVQO2ATsDWAI+A2MAZQBcAFwAQQAdBE8AbgBzAAoFAAECAQoFWgNnAAoF4gJfADIC1gFcBGMDFwKlAf8EZQABBY4BewQFBT0DPwMKBQwFZAAOBRAFXAASBUkAFAVtABYFXAAYBRoFFAFOAj4BFwLuBIcBtwT7BFYBpQFoAqwBPAJ2BK4EaAB0AqwB8wHoAR4FOwIgBSIFAwUrASUFOgEnBQsFDQUPBREFAQEvBVwAFQUXBb4BGQWzAxwFOAX8BCIBTAUCBSQFPANRBQgFKAVUBSwFLgUwBTIFNAVeBTcFOgL9BP4DPwM4AnIFIgF3AHcBrAE4AjYAwQM/BQEFvgNQBM8BQwV7AYEFOQFIBXcFMgHoAgADCQO2AekCyANgBT4FYgV7AxMCegB7BDEANgCJBSIARQWBAq4EMgAyAJoFigKMAowDVABPAFAAUgBJAEcASABMBEoFlgEBBWgAmgKdBXsBZgKXAZwCOgI6BbgBPAWEAfcEPgUyAWMFIwV7AVAFBwUJBVMFKgVVBS0FVwVtBVsFcgBdBRsFcQWtBYkCvgEABWQFwQVmBcMFaQXGBWsFyQVZBTEFywXNBTYFHQVhBTIBdAUIBXYF0AW+A78B/QGuBG8AjAKaBZwFkAV7ATcAtwXhBN0CRQLgAoUFvwNyACAAlQK7AToAIACyApsDkwQ9Aj8CcwMeAbwFQgI3AbEBXwBkAQAD3AF7BC4AOAA1AJoF3AJxAtgBzgS2Ab8EkgXjBb0B5QUYBpoF/gTSBSEF1AUEBdYFUgUpBSsFVgUTBdwFbgVcBTUFXwWaBUAFhgVyAI8FyQO2ATIGiAXQBXkFZAB7BRgGfQWhBSEGTQVlBQYFJgZqBSkGWAVaBTMFLQZwBeEFGgYTAWUAogVmAKQFpgWoBaoFrAXiBSIA6AWMBa4EmQORBb0FiQKUBWkAlgV8BZoFKAR3AFAAVgBQAOYFVwbvBTUGKwGfBaEFlAV7AewFfAM5BeEEKgIkAW0APgPrA6MC1AJjAHcGLAJ7AaAFiALWAj0FXgY6BDYCqwHoAl8AvgNSBqcFqQWrBZoFzgEvBCMC1wR8BtAFQAWwBVwGewFPAmICEwb1BRYGrgQZBl4GeAFmABEEeQO1Av0EvwVOBUABwgVEBtkFRgbKBUkGzAUuBs8FVwbWAr0BHQSbAXsBEgY5BnoFkAIrATQAMAAuAPIF0AV+BisCeQbWAZcFEwZ/Bm0ApgYFBmkBLgAxACwAwgbSBtQGLACiBp8BxgZ4BmYAdQBMAbAFagZNBusBuwPOBpMBLgAyANMG5gboBjQA1waaBckCxgbkBt4BLgA2AOoG6AbnBtgG4AGqBkIGJgVoBcUFKAbIBSoGSAZvBc4FTAZeBpgGcAAIBWYFmwb2A0UFIwKsAWIA"

local getStringBtn = CreateFrame("Button", nil, PFSD_Settings, "UIPanelButtonTemplate")
getStringBtn:SetWidth(180) getStringBtn:SetHeight(30) getStringBtn:SetPoint("TOP", 0, -120)
getStringBtn:SetText("Get Import String")
getStringBtn:SetScript("OnClick", function()
    PFSD_ExportBox:Show()
    PFSD_ExportBox:SetText(sd_profile_string)
    PFSD_ExportBox:HighlightText()
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99pfUI-SD:|r String generated! Press Ctrl+C to copy.")
end)

local bindBtn = CreateFrame("Button", nil, PFSD_Settings, "UIPanelButtonTemplate")
bindBtn:SetWidth(180) bindBtn:SetHeight(25) bindBtn:SetPoint("TOP", 0, -160)
bindBtn:SetText("Update Key binds")
bindBtn:SetScript("OnClick", function() 
    for i=1,8 do SetBinding("SHIFT-"..i, "MULTIACTIONBAR1BUTTON"..i) SetBinding("CTRL-"..i, "MULTIACTIONBAR2BUTTON"..i) end 
    SaveBindings(GetCurrentBindingSet()) 
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99pfUI-SD:|r Binds updated!") 
end)

-- 4. SLASH COMMAND
SLASH_PFSD1 = "/pfsd"
SlashCmdList["PFSD"] = function() 
    if PFSD_Settings:IsShown() then PFSD_Settings:Hide() else PFSD_Settings:Show() end 
end

-- 5. UPDATE LOOP
local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function()
    this.elapsed = (this.elapsed or 0) + arg1
    if this.elapsed > 2 then Refresh() this.elapsed = 0 end
end)
