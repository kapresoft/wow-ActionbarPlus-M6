--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, pformat, sformat = ns.O, ns.pformat, string.format
local GC, AceEvent, String = O.GlobalConstants, O.AceLibrary.AceEvent, O.String
local IsBlank, IsNotBlank, StartsWithIgnoreCase = String.IsBlank, String.IsNotBlank, String.StartsWithIgnoreCase
local L = GC:GetAceLocale()

local ABP_API_NAME = 'ActionbarPlus-ActionbarPlusAPI-1.0'
local M6_DEFAULT_ICON = 10741611000
local MISSING_ICON = 134400

local primaryFallbackYellow = CreateColorFromHexString('ffFFD200')
local secondaryFallbackBlue = CreateColorFromHexString('ff668BFF')
local tertiaryFallbackWhite = CreateColorFromHexString('ffFFFFFF')
--- Note that some global fonts are not available in classic-era
--- @type Kapresoft_LibUtil_ColorDefinition2
local tooltipColors = {
    primary   = DARKYELLOW_FONT_COLOR or YELLOW_FONT_COLOR or primaryFallbackYellow,
    secondary = HIGHLIGHT_LIGHT_BLUE or BLUE_FONT_COLOR or secondaryFallbackBlue,
    tertiary = WHITE_FONT_COLOR or tertiaryFallbackWhite
}
local c = K_Constants:NewConsoleHelper(tooltipColors)
local ec = PURE_RED_COLOR or RED_FONT_COLOR or CreateColorFromHexString('ffFF1919')
local grayc = COMMON_GRAY_COLOR or GRAY_FONT_COLOR or CreateColorFromHexString('ffA8A8A8')

local SEPARATOR = c:T(' :: ')
local MACRO_M6_FORMAT = SEPARATOR .. c:P('%s')

--- This will be populated later
--- @type ActionbarPlusAPI
local ABPI

--[[-----------------------------------------------------------------------------
Temporary Localization
-------------------------------------------------------------------------------]]

local INACTIVE_M6_MACRO = DIM_RED_FONT_COLOR:WrapTextInColorCode(L['Inactive M6 Macro'])

--[[-----------------------------------------------------------------------------
New Instance: M6Support
-------------------------------------------------------------------------------]]
--- @class M6Support : BaseObject_WithAceEvent
local S = ns:NewObject('M6Support')
local p = S:GetLogger()

--[[-----------------------------------------------------------------------------
Event Handler
-------------------------------------------------------------------------------]]
--- @class M6_EventHandler
local H = {}

--[[-----------------------------------------------------------------------------
Notes
-------------------------------------------------------------------------------]]
--- Given a macro name:  `_M6+s01`
---   - The key is `s01`
---
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
local function api() return ns.LibStubAce(ABP_API_NAME) end

---@param text string
local function fatal(text) return ec:WrapTextInColorCode('<<FATAL>> ') .. text end
---@param text string
local function err(text) return ec:WrapTextInColorCode('<<ERROR>> ') .. text end

---@param bw ButtonUIWidget
local function GetHint(bw) return S:macroHintByMacroName(bw:GetMacroData().name) end
---@alias HintFn fun(bw:ButtonUIWidget, optionalHint: M6Support_MacroHint_Extended, ) | "function(bw, hint) print('hello') end"
---@param bw ButtonUIWidget
---@param hintFn HintFn
local function IfHint(bw, hintFn)
    local hint = GetHint(bw); if not hint then return end
    hintFn(hint)
end

---@param bw ButtonUIWidget
local function UpdateIconByWidget(bw)
    if bw:IsEmpty() then return end
    IfHint(bw, function(hint)
        if hint.icon == nil then return end
        bw:SetIcon(hint.icon)
    end)
end

---@param bw ButtonUIWidget
local function UpdateMacroDisplayName(bw)
    IfHint(bw, function(hint) bw:SetNameText(hint.label) end)
end

---@param bw ButtonUIWidget
local function UpdateItemStateByWidget(bw)
    local usableItem = false
    local itemInfo = S:itemInfoByMacroName(bw)
    if not itemInfo then bw:SetText(''); return end

    bw:UpdateItemStateByItemInfo(itemInfo)
    usableItem = bw:IsUsableItem(itemInfo.id)
    bw:SetActionUsable(usableItem)
end

---@param bw ButtonUIWidget
local function UpdateCooldownByWidget(bw)
    IfHint(bw, function(hint)
        local cd = S:GetCooldownInfo(hint.spell); if not cd then return end
        bw:SetCooldown(cd.start, cd.duration)
    end)
end

---@param bw ButtonUIWidget
local function UpdateMacro(bw)
    UpdateIconByWidget(bw)
    UpdateItemStateByWidget(bw)
    UpdateCooldownByWidget(bw)
    UpdateMacroDisplayName(bw)
end

local function InitializeM6Icons()
    --- Initially, the m6 icons set. The icons are identifiers to slotIDs
    --- Grab the slotID and retrieve the real icons
    ABPI:UpdateM6Macros(function(bw)
        local d = bw:GetMacroData()
        local m6Icon = bw:GetIcon()
        local slotID = S:slotIDFromIcon(m6Icon)
        local icon
        local spell
        local label
        if slotID then
            local hint = S:macroHintBySlotID(slotID)
            if hint then
                icon, spell = hint.icon or d.icon2, hint.spell
                label = hint.label
            elseif d.icon2 then
                icon = d.icon2
            end
            if not icon then icon = MISSING_ICON end
        end
        if icon then bw:SetIcon(icon) end
        if spell then
            C_Timer.NewTicker(0.2, function()
                bw:UpdateItemStateByItem(spell)
            end, 1)
        end
        if IsNotBlank(label) then
            C_Timer.NewTicker(.2, function() bw:SetNameText(label) end, 3)
        end
        UpdateMacroDisplayName(bw)
        UpdateCooldownByWidget(bw)
    end)
end

local function RemoveInactiveMacros()
    C_Timer.NewTicker(0.1, function()
        ABPI:UpdateMacros(function(bw)
            local d = bw:GetMacroData()
            local n = d.name; if not n then return end
            local slotID = S:slotIDByMacroName(n); if not slotID then return end
            if S:IsSlotActive(slotID) then return end

            bw:SetButtonAsEmpty()
            bw:SetText(nil)
            return false
        end, 3)
    end)
end

---@param macroName string
---@param m6MacroName string
---@param hint M6Support_MacroHint_Extended
local function AddM6Info(macroName, m6MacroName, hint)
    local nameRight = ''
    if IsNotBlank(hint.label) then nameRight = c:S(L['Name'] .. ': ') .. m6MacroName end
    local m6MacroLabel = c:S('M6 ' .. L['Macro'] .. ': ') .. macroName
    GameTooltip:AddLine(' ')
    GameTooltip:AddDoubleLine(m6MacroLabel, nameRight)
    if IsShiftKeyDown() == true or InCombatLockdown() == true then return end
end

--- @param w ButtonUIWidget
local function ShowTooltip(w)
    local md = w:GetMacroData(); if not md then return end
    local m = md.name; if IsBlank(m) then return end
    local slotID = S:slotIDByMacroName(m); if not slotID then return end

    local hint = S:macroHintBySlotID(slotID);
    if not hint then
        GameTooltip:SetText(INACTIVE_M6_MACRO)
        GameTooltip:AppendText(sformat(MACRO_M6_FORMAT, m))
        return
    end

    local m6MacroName, spellName, displayName = hint.name, hint.spell, hint.name

    if IsNotBlank(hint.label) then displayName = hint.label end

    local spell = S:GetSpellInfo(spellName)
    if spell and spell.id then
        GameTooltip:SetSpellByID(spell.id)
        AddM6Info(m, m6MacroName, hint)
        GameTooltip:AppendText(MACRO_M6_FORMAT:format(displayName))
        return
    end

    local item = ABPI:GetItemInfo(spellName)
    if item and item.id then
        GameTooltip:SetItemByID(item.id)
        AddM6Info(m, m6MacroName, hint)
        GameTooltip:AppendText(MACRO_M6_FORMAT:format(displayName))
        return
    end

    if IsNotBlank(m6MacroName) then
        GameTooltip:SetText(L['Macro'])
        AddM6Info(m, m6MacroName, hint)
        GameTooltip:AppendText(MACRO_M6_FORMAT:format(displayName))
    end

end
--[[-----------------------------------------------------------------------------
M6 Support: Properties & Methods
-------------------------------------------------------------------------------]]
---@param o M6Support
local function PropertiesAndMethods(o)

    --- @param macroName string The macro name i.e '_M6+s01'
    --- @return string The slotId, i.e. 's01' from '_M6+s01'
    function o:slotIDByMacroName(macroName)
        if IsBlank(macroName) or StartsWithIgnoreCase(macroName, "_m6") ~= true then return nil end
        local _, slotID = string.gmatch(macroName, "(%w+)%+(%w+)")()
        return slotID
    end

    ---@param slotID number
    ---@return string The macro name, i.e. '_M6+s01'
    function o:macroNameBySlot(slotID)
        if not slotID then return nil end
        return ("_M6+%s"):format(slotID)
    end

    --- @return number The icon
    function o:iconByIconKey(icon)
        local slotID = self:slotIDFromIcon(icon)
        if not slotID then return nil end
        local h = self:macroHintBySlotID(slotID); if not h then return nil end
        return h.icon
    end

    --- @see M6::Core.lua::GetHint(slotID)
    --- @return M6Support_MacroHint
    --- @param slotID string The numeric slotID. Returns null if slot is not active.
    function o:macroHintBySlotIDBase(slotID)
        local m6Name, isActive, _, iconId, spellOrItemName,
        itemCount, unknown1, unknown2, fn, unknown3,
        unknown4, label = M6:GetHint(slotID)
        if IsBlank(m6Name) then return nil end
        --- @type M6Support_MacroHint
        local ret = {
            name = m6Name, isActive = isActive or false, icon = iconId,
            spell = spellOrItemName, itemCount = itemCount,
            unknown1 = unknown1, unknown2 = unknown2, fn=fn,
            unknown3 = unknown3, unknown4 = unknown4,
            label = label }
        return ret
    end

    --- #### Example Call:
    --- ```
    --- macroName, isActive, _, iconID, spellName = M6Support:GetMacroHint('_M6+s01')
    --- macroName, isActive, _, iconID, itemName, itemCount = M6Support:GetMacroHint('_M6+s01')
    ---```
    --- #### Example Macro:
    --- ```/dump M6S:GetMacroHint('_M6+s01')```
    --- ```
    --- Spell: {   'BuffSelf', true, 512, 135932, 'Arcane Intellect', 0, 0, 0, [[function 1]], 24 }
    --- Item:  {   'BuffSelf', true, 0, 134029, 'Conjured Cinnamon Roll', 15, 0, 0, [[function 1]], 1 }
    --- ```
    --- @see M6::Core.lua::GetHint(slotID)
    --- @return M6Support_MacroHint_Extended
    --- @param slotID string The numeric slotID. Returns null if slot is not active.
    function o:macroHintBySlotID(slotID)
        if not slotID then return nil end
        --- @type M6Support_MacroHint_Extended
        local ret = self:macroHintBySlotIDBase(slotID)
        if not ret then return nil end
        --if ret.icon == nil then return ret end

        local macroName = S:macroNameBySlot(slotID); if IsBlank(macroName)then return ret end
        --- Extended Fields
        ret.macroName = macroName
        ret.slotID = slotID

        return ret
    end

    --- @type M6Support_MacroHint_Extended
    --- @param macroName string
    function o:macroHintByMacroName(macroName)
        local slotID = self:slotIDByMacroName(macroName)
        if not slotID then return nil end
        --- @type M6Support_MacroHint_Extended
        local ret = self:macroHintBySlotIDBase(slotID)
        if not ret then return nil end
        ret.slotID = slotID
        ret.macroName = macroName
        return ret
    end

    --- @param icon number
    --- @return string The slotID
    function o:slotIDFromIcon(icon) return M6:GetIconKey(icon) end

    --- @return SpellInfo
    function o:GetSpellInfo(spellNameOrId)
        local name, _, icon, castTime, minRange, maxRange, id = GetSpellInfo(spellNameOrId)
        return { name = name, id = id, icon = icon }
    end

    --- @param slotID string The numeric slotID
    --- @return boolean
    function o:IsSlotActive(slotID) return M6:GetHint(slotID) ~= nil end

    ---@param bw ButtonUIWidget
    function o:itemInfoByMacroName(bw)
        local n = bw:GetMacroName()
        local hint = S:macroHintByMacroName(n); if not hint then return end
        return ABPI:GetItemInfo(hint.spell)
    end

    ---@param spellOrItemName string
    ---@return CooldownInfo
    function o:GetCooldownInfo(spellOrItemName)

        local itemInfo = ABPI:GetItemInfo(spellOrItemName)
        if itemInfo then
            return ABPI:GetItemCooldown(spellOrItemName)
        end

        local spellInfo = self:GetSpellInfo(spellOrItemName)
        if spellInfo then
            return ABPI:GetSpellCooldown(spellOrItemName)
        end

    end

    ---@param level number 0 to 100
    function S:LL(level)
        if level >= 0 then GC:SetLogLevel(level) end
        return GC:GetLogLevel()
    end

    function S:InitializeHooks()
        hooksecurefunc(M6UI, "Hide", H.OnM6EditFrameHide)
        InitializeM6Icons()
    end

    function S:RegisterCallbacks()
        AceEvent:RegisterMessage(GC.M.OnSpellUpdateUsable, H.OnSpellUpdateUsable)
        AceEvent:RegisterMessage(GC.M.ABP_MacroAttributeSetter_OnSetIcon, H.OnSetIcon)
        AceEvent:RegisterMessage(GC.M.ABP_MacroAttributeSetter_OnShowTooltip, H.OnShowTooltip)
        AceEvent:RegisterMessage(GC.M.ABP_OnSpellCastSucceeded, H.OnSpellCastSucceeded)
        AceEvent:RegisterMessage(GC.M.ABP_OnBagUpdateExt, H.OnBagUpdate)
        AceEvent:RegisterMessage(GC.M.ABP_OnSpellCastSentExt, H.OnSpellCastSent)
        AceEvent:RegisterMessage(GC.M.ABP_OnSpellCastStopExt, H.OnSpellCastStop)
        AceEvent:RegisterMessage(GC.M.ABP_OnSpellCastFailedExt, H.OnSpellCastFailed)
        AceEvent:RegisterMessage(GC.M.ABP_OnButtonPostClickExt, H.OnPostClick)
    end

end


--[[-----------------------------------------------------------------------------
Event Handler: Properties & Methods
-------------------------------------------------------------------------------]]
---@alias UpdateM6MacrosFn fun(handlerFn:ButtonHandlerFunction) | "function(btnWidget) print(btnWidget:GetName()) end"
---@alias WidgetSupplierFn fun() : ButtonUIWidget

---@param o M6_EventHandler
local function EventHandlerPropertiesAndMethods(o)

    function o.OnM6EditFrameHide()
        ABPI:UpdateM6Macros(UpdateMacro)
        RemoveInactiveMacros()
    end

    ---@param msg string
    ---@param source string
    ---@param fn WidgetSupplierFn
    function o.OnShowTooltip(msg, source, fn)
        local widget = fn()
        ShowTooltip(widget)
    end

    ---@param msg string
    ---@param source string
    ---@param fn WidgetSupplierFn
    function o.OnSetIcon(msg, source, fn)
        local bw = fn()
        local icon = S:iconByIconKey(bw:GetIcon())
        local d = bw:GetMacroData()
        if icon and icon < M6_DEFAULT_ICON then d.icon2 = icon end

        if not icon then icon = d.icon2 end
        if not icon then icon = MISSING_ICON end
        bw:SetIcon(icon)

        UpdateItemStateByWidget(bw)
        C_Timer.NewTicker(0.1, function()
            UpdateMacroDisplayName(bw) end, 3)
    end

    ---@param msg string
    ---@param source string
    ---@param updateM6MacrosFn UpdateM6MacrosFn
    function o.OnBagUpdate(msg, source, updateM6MacrosFn)
        p:log(30, 'MSG[%s]: %s', tostring(source), msg)
        updateM6MacrosFn(UpdateItemStateByWidget)
    end

    --- ### Which events?
    --- - qsequence needs icon updates even if action failed
    ---@param msg string
    ---@param source string
    ---@param updateM6MacrosFn UpdateM6MacrosFn
    function o.OnPostClick(msg, source, updateM6MacrosFn)
        p:log(30, 'MSG [%s]: %s', tostring(source), msg)
        updateM6MacrosFn(UpdateMacro)
    end

    --- ### Which events?
    ---  - Instant cast spells (failed or succeeded)
    ---@param msg string
    ---@param source string
    ---@param updateM6MacrosFn UpdateM6MacrosFn
    function o.OnSpellCastSent(msg, source, updateM6MacrosFn)
        p:log(30, 'MSG[%s]: %s', tostring(source), msg)
        updateM6MacrosFn(UpdateMacro)
    end

    ---@param msg string
    ---@param source string
    ---@param updateM6MacrosFn UpdateM6MacrosFn
    function o.OnSpellCastSucceeded(msg, source)
        p:log(30, 'MSG[%s]: %s', tostring(source), msg)
        ABPI:UpdateM6Macros(UpdateMacro)
    end

    --- ### Which events?
    ---  - Conjure mana gem when there is already a mana gem in bag
    ---  - Moving while eating/drinking
    ---@param msg string
    ---@param source string
    ---@param updateM6MacrosFn UpdateM6MacrosFn
    function o.OnSpellCastFailed(msg, source, updateM6MacrosFn)
        p:log(30, 'MSG[%s]: %s', tostring(source), msg)
        updateM6MacrosFn(function(bw) bw:ResetCooldown() end)
    end

    --- ### Which events?
    ---  - Casting a portal then moving before cast completed
    ---@param msg string
    ---@param source string
    ---@param updateM6MacrosFn UpdateM6MacrosFn
    function o.OnSpellCastStop(msg, source, updateM6MacrosFn)
        p:log(30, 'MSG[%s]: %s', tostring(source), msg)
        updateM6MacrosFn(UpdateCooldownByWidget)
    end

    --- Only triggers when energy/mana is not full
    ---@param msg string
    ---@param source string
    function o.OnSpellUpdateUsable(msg, source) ABPI:UpdateM6Macros(UpdateMacro) end

end

PropertiesAndMethods(S)
EventHandlerPropertiesAndMethods(H)

--[[-----------------------------------------------------------------------------
Message Callbacks
-------------------------------------------------------------------------------]]
AceEvent:RegisterMessage(GC.M.ABP_PLAYER_ENTERING_WORLD,function(msg, source, ...)
    ABPI = api()
    if not ABPI then
        p:log(fatal 'Lib was not available: %s', ABP_API_NAME)
        return
    end

    S:InitializeHooks()
    S:RegisterCallbacks()
end)

-- todo next: update item charges
-- todo next: update usable
