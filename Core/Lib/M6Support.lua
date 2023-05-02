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
local HOLD_SHIFT_TEXT = grayc:WrapTextInColorCode(L['Hold SHIFT before hovering for additional details'])

--- This will be populated later
--- @type ActionbarPlusAPI
local ABPI

--[[-----------------------------------------------------------------------------
Temporary Localization
-------------------------------------------------------------------------------]]

local INACTIVE_M6_MACRO = DIM_RED_FONT_COLOR:WrapTextInColorCode(L['Inactive'])

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class M6Support : BaseObject_WithAceEvent
local S = ns:NewObject('M6Support')
local p = S:GetLogger()

--[[-----------------------------------------------------------------------------
Notes
-------------------------------------------------------------------------------]]
--- Given a macro name:  `_M6+s01`
---   - The key is `s01`
---
--[[-----------------------------------------------------------------------------
Support Functions
-------------------------------------------------------------------------------]]
---@param text string
local function fatal(text) return ec:WrapTextInColorCode('<<FATAL>> ') .. text end
---@param text string
local function err(text) return ec:WrapTextInColorCode('<<ERROR>> ') .. text end

local function InitializeM6Icons()
    --- Initially, the m6 icons set. The icons are identifiers to slotIDs
    --- Grab the slotID and retrieve the real icons
    ABPI:UpdateM6Macros(function(bw)
        local d = bw:GetMacroData()
        local m6Icon = bw:GetIcon()
        local slotID = S:slotIDFromIcon(m6Icon)
        local icon
        local spell
        if slotID then
            local hint = S:macroHintBySlotID(slotID)
            if hint then
                icon, spell = hint.icon or d.icon2, hint.spell
            elseif d.icon2 then
                icon = d.icon2
            end
            if not icon then icon = MISSING_ICON end
        end
        if icon then bw:SetIcon(icon) end
        if spell then
            C_Timer.NewTicker(0.2, function()
                bw:UpdateItemStateByItem(spell)
                -- todo UpdateText
                -- todo UpdateCooldown()
            end, 1)
        end
    end)
end

---@param bw ButtonUIWidget
local function UpdateIconByWidget(bw)
    local d = bw:GetMacroData()
    local n = d.name
    local hint = S:macroHintByMacroName(n); if not hint then return end
    p:log(30, '[%s]: hint=%s', n, pformat(hint))
    if hint.icon then
        C_Timer.After(0.1, function()
            hint = S:macroHintByMacroName(n); if not hint then return end
            if hint.icon ~= nil then bw:SetIcon(hint.icon) end
        end)
    end
end

---@param bw ButtonUIWidget
local function UpdateStateByWidget(bw)
    local itemInfo = S:itemInfoByMacroName(bw)
    if not itemInfo then bw:SetText('')
    else
        bw:UpdateItemStateByItemInfo(itemInfo)

    end
    -- todo next: add spell updates
end

---@param bw ButtonUIWidget
local function UpdateCooldownByWidget(bw)
    local n = bw:GetMacroData().name
    local hint = S:macroHintByMacroName(n); if not hint then return end
    p:log(30, 'hint=%s', pformat(hint))
    if not hint.spell then return end

    local cd = S:GetCooldownInfo(hint.spell)
    p:log(30, 'cd[%s]: spell=%s %s', n, hint.spell, pformat(cd))
    if cd then
        bw:SetCooldown(cd.start, cd.duration)
    end
end

local function RemoveInactiveMacros()
    ABPI:UpdateMacros(function(bw)
        local d = bw:GetMacroData()
        local n = d.name; if not n then return end
        local slotID = S:slotIDByMacroName(n); if not slotID then return end
        if S:IsSlotActive(slotID) then return end

        bw:SetButtonAsEmpty()
        bw:SetText(nil)
        return false
    end)
end

---@param actionID number
local function ActionContentToTooltipText(actionID)
    local tbl = S:actionAsTable(actionID)
    local txt = ''
    if not tbl then return end
    for i, v in ipairs(tbl) do
        if "imptext" ~= v then txt = txt .. v .. "\n" end
    end
    return txt
end

---@param actionID number
---@param m6MacroName string
---@param hint M6Support_MacroHint_Extended
local function AppendExtendedDetails(actionID, m6MacroName, hint)
    if InCombatLockdown() or IsShiftKeyDown() ~= true then return end
    local content = c:P('\n\n' .. ActionContentToTooltipText(actionID))
    GameTooltip:AppendText(content)
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
    GameTooltip:AddLine(HOLD_SHIFT_TEXT)
end

--- @param w ButtonUIWidget
local function ShowTooltip(w)
    if not S:profile() then return nil end

    local md = w:GetMacroData(); if not md then return end
    local m = md.name; if IsBlank(m) then return end
    local slotID = S:slotIDByMacroName(m); if not slotID then return end
    local actionID = S:profile().slots[slotID]
    if not actionID then
        p:log("%s to show tooltip for unknown actionID, slotID=%s macro=%s",
                ec:WrapTextInColorCode('Failed'), slotID, m)
        return
    end

    local hint = S:macroHintBySlotID(slotID);
    if not hint then
        GameTooltip:SetText(INACTIVE_M6_MACRO)
        GameTooltip:AppendText(sformat(MACRO_M6_FORMAT, '', m))
        return
    end

    local m6MacroName, spellName, displayName = hint.name, hint.spell, hint.name

    if IsNotBlank(hint.label) then displayName = hint.label end

    local spell = S:GetSpellInfo(spellName)
    if spell and spell.id then
        GameTooltip:SetSpellByID(spell.id)
        AddM6Info(m, m6MacroName, hint)
        GameTooltip:AppendText(MACRO_M6_FORMAT:format(displayName))
        AppendExtendedDetails(actionID, m6MacroName, hint)
        return
    end

    local item = ABPI:GetItemInfo(spellName)
    if item and item.id then
        GameTooltip:SetItemByID(item.id)
        AddM6Info(m, m6MacroName, hint)
        GameTooltip:AppendText(MACRO_M6_FORMAT:format(displayName))
        AppendExtendedDetails(actionID, m6MacroName, hint)
        return
    end

    if IsNotBlank(m6MacroName) then
        GameTooltip:SetText(L['Macro'])
        AddM6Info(m, m6MacroName, hint)
        GameTooltip:AppendText(MACRO_M6_FORMAT:format(displayName))
        AppendExtendedDetails(actionID, m6MacroName, hint)
    end

end


--[[-----------------------------------------------------------------------------
Event Handler
-------------------------------------------------------------------------------]]
--- @class M6_EventHandler
local H = {}
---@param o M6_EventHandler
local function EventHandlerPropertiesAndMethods(o)

    --- Called When an M6 Macro is Saved
    --- @param userIcon Icon
    --- @param actionID number
    function o:OnSetActionIcon(actionID, userIcon)
        --[[if userIcon then
            -- todo next: This is an icon set by a user
        end]]

        local hint = S:macroHintByAction(actionID); if hint == nil then return end
        p:log(30, '[%s::%s]:: hint=%s', hint.name, actionID, pformat(hint))
        local icon, itemCount, macroName = hint.icon, hint.itemCount, hint.macroName
        if not icon then icon = MISSING_ICON end

        ABPI:UpdateMacrosByName(macroName, function(bw)
            bw:SetIcon(icon)
            UpdateStateByWidget(bw)
        end)

        RemoveInactiveMacros()

    end

    --- @param actionID number
    function o:OnDeactivateAction(actionID)
        local active = S:IsActionActive(actionID)
        p:log('OnDeactivate: %s isActive=%s', actionID, active)
        if active == true then return end

        RemoveInactiveMacros()
    end

end
EventHandlerPropertiesAndMethods(H)

--[[-----------------------------------------------------------------------------
Properties & Methods
-------------------------------------------------------------------------------]]
---@param o M6Support
local function PropertiesAndMethods(o)

    --- @return M6Support_DB
    function o:db() return _G['M6DB'] end

    --- @return M6SupportDBProfile
    function o:profile()
        if not self:db() then
            p:log(fatal("Failed to access M6 database [M6DB]"))
            return nil
        end
        local realm, name = GetRealmName(), UnitName("player")
        local pr = self:db().profiles[realm][name]
        if not pr then
            p:log(fatal('Profile not found for character=[%s] on realm=[%s]:'), name, realm)
            return nil
        end

        -- 1 = main, 2, 3
        local specIndex = (GetSpecialization and GetSpecialization()) or 1
        p:log(1, 'Profile index=%s for character=%s (%s)', specIndex, name, realm)
        if pr and pr[specIndex] then
            p:log(5, 'Profile found for specIndex[%s] with action slots %s',
                    tostring(specIndex), pformat(pr[specIndex].slots))
            return pr[specIndex]
        end

        p:log(fatal('Profile not found for specIndex[%s]:'), tostring(specIndex))
        return nil
    end

    --- @param macroName string The macro name i.e '_M6+s01'
    --- @return string The slotId, i.e. 's01' from '_M6+s01'
    function o:slotIDByMacroName(macroName)
        if IsBlank(macroName) or StartsWithIgnoreCase(macroName, "_m6") ~= true then return nil end
        local _, slotID = string.gmatch(macroName, "(%w+)%+(%w+)")()
        return slotID
    end

    ---@param actionID number
    function o:action(actionID) return M6:GetAction(actionID) end
    ---@param actionID number
    function o:actionAsTable(actionID) return { M6:GetAction(actionID) } end

    --- @param actionID number
    --- @return string The slotID, i.e. 's01','s02', etc...
    function o:slotIDByAction(actionID)
        if not actionID then return nil end
        local slots = self:profile().slots
        if type(slots) ~= 'table' then return end
        for slotID, aID in pairs(slots) do
            --- Inactive slotIDs will not be in the list
            if aID == actionID then return slotID end
        end
        return nil
    end

    ---@param actionID number
    ---@return string The macro name, i.e. '_M6+s01'
    function o:macroNameByAction(actionID)
        if not actionID then return nil end
        local slotID = self:slotIDByAction(actionID); if not slotID then return nil end
        return ("_M6+%s"):format(slotID)
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

    --- @param actionID number
    --- @return M6Support_MacroHint_Extended
    function o:macroHintByAction(actionID)
        local slotID = self:slotIDByAction(actionID)
        return self:macroHintBySlotID(slotID)
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

    ---@param actionID number
    function o:IsActionActive(actionID)
        if actionID then return M6:IsActionActivated(actionID) end
        return false
    end

    ---@param actionID number
    function o:IsActionValid(actionID) return actionID and M6:IsActionValid(actionID) end

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
        local n = bw:GetMacroData().name
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

    function S:InitializeHooks()
        local pr = self:profile(); if not pr then return nil end

        --- @param userIcon Icon
        --- @param actionID number
        hooksecurefunc(M6, "SetActionIcon", function(m6API, actionID, userIcon)
            p:log(30, 'hooksecurefunc()::SetAction::id: %s', actionID);
            if not actionID then return end
            H:OnSetActionIcon(actionID, userIcon)
        end)

        hooksecurefunc(M6, "DeactivateAction", function(m6API, actionID)
            p:log(30, 'hooksecurefunc()::DeactivateAction::id: %s', actionID)
            H:OnDeactivateAction(actionID)
        end)

        InitializeM6Icons()
    end

    ---@param level number 0 to 100
    function S:LL(level)
        if level >= 0 then GC:SetLogLevel(level) end
        return GC:GetLogLevel()
    end

end
PropertiesAndMethods(S)

ABP_M6 = S

--[[-----------------------------------------------------------------------------
Message Callbacks
-------------------------------------------------------------------------------]]
AceEvent:RegisterMessage(GC.M.ABP_PLAYER_ENTERING_WORLD,function(msg, source, ...)
    ABPI = ns.LibStubAce(ABP_API_NAME)
    if not ABPI then
        p:log(fatal 'Lib was not available: %s', ABP_API_NAME)
        return
    end
    S:InitializeHooks()

end)

AceEvent:RegisterMessage(GC.M.ABP_MacroAttributeSetter_OnSetIcon,function(msg, source, fn)
    --- @type ButtonUIWidget
    local bw = fn()
    local icon = S:iconByIconKey(bw:GetIcon())
    local d = bw:GetMacroData()
    if icon and icon < M6_DEFAULT_ICON then d.icon2 = icon end

    if not icon then icon = d.icon2 end
    if not icon then icon = MISSING_ICON end
    bw:SetIcon(icon)

    UpdateStateByWidget(bw)
end)
AceEvent:RegisterMessage(GC.M.ABP_MacroAttributeSetter_OnShowTooltip,function(msg, source, fn)
    --p:log(30, 'Received message from [%s]: %s', tostring(source), msg)
    --- @type ButtonUIWidget
    local widget = fn()
    ShowTooltip(widget)
end)

AceEvent:RegisterMessage(GC.M.ABP_OnSpellCastSucceeded,function(msg, source)
    p:log(30, 'MSG[%s]: %s', tostring(source), msg)

    ABPI:UpdateM6Macros(function(bw)
        UpdateIconByWidget(bw)
        UpdateStateByWidget(bw)
        UpdateCooldownByWidget(bw)
        -- todo next: update cooldown
    end)

end)

---@alias UpdateM6MacrosFn fun(handlerFn:ButtonHandlerFunction) | "function(btnWidget) print(btnWidget:GetName()) end"
---@param updateM6MacrosFn UpdateM6MacrosFn
AceEvent:RegisterMessage(GC.M.ABP_OnBagUpdateExt,function(msg, source, updateM6MacrosFn)
    p:log(30, 'MSG[%s]: %s', tostring(source), msg)
    updateM6MacrosFn(function(bw)
        UpdateStateByWidget(bw)
    end)
end)

--- casting a non GC spell like mage portal
---@alias UpdateM6MacrosFn fun(handlerFn:ButtonHandlerFunction) | "function(btnWidget) print(btnWidget:GetName()) end"
---@param updateM6MacrosFn UpdateM6MacrosFn
AceEvent:RegisterMessage(GC.M.ABP_OnSpellCastStartExt .. 'OFF',function(msg, source, updateM6MacrosFn)
    p:log(30, 'MSG[%s]: %s', tostring(source), msg)
    updateM6MacrosFn(function(bw) UpdateStateByWidget(bw) end)
end)

--- instant cast spells
---@alias UpdateM6MacrosFn fun(handlerFn:ButtonHandlerFunction) | "function(btnWidget) print(btnWidget:GetName()) end"
---@param updateM6MacrosFn UpdateM6MacrosFn
AceEvent:RegisterMessage(GC.M.ABP_OnSpellCastSentExt,function(msg, source, updateM6MacrosFn)
    p:log(30, 'MSG[%s]: %s', tostring(source), msg)
    updateM6MacrosFn(function(bw)
        UpdateStateByWidget(bw)
        UpdateCooldownByWidget(bw)
        UpdateIconByWidget(bw)
    end)
end)

--- i.e. Casting a portal and moving triggers this event
---@alias UpdateM6MacrosFn fun(handlerFn:ButtonHandlerFunction) | "function(btnWidget) print(btnWidget:GetName()) end"
---@param updateM6MacrosFn UpdateM6MacrosFn
AceEvent:RegisterMessage(GC.M.ABP_OnSpellCastStopExt,function(msg, source, updateM6MacrosFn)
    p:log(30, 'MSG[%s]: %s', tostring(source), msg)
    updateM6MacrosFn(function(bw) bw:ResetCooldown() end)
end)

--- i.e. Conjure mana gem when there is already a mana gem in bag, triggers this event
---@alias UpdateM6MacrosFn fun(handlerFn:ButtonHandlerFunction) | "function(btnWidget) print(btnWidget:GetName()) end"
---@param updateM6MacrosFn UpdateM6MacrosFn
AceEvent:RegisterMessage(GC.M.ABP_OnSpellCastFailedExt,function(msg, source, updateM6MacrosFn)
    p:log(30, 'MSG[%s]: %s', tostring(source), msg)
    updateM6MacrosFn(function(bw) bw:ResetCooldown() end)
end)

---@alias UpdateM6MacrosFn fun(handlerFn:ButtonHandlerFunction) | "function(btnWidget) print(btnWidget:GetName()) end"
---@param updateM6MacrosFn UpdateM6MacrosFn
AceEvent:RegisterMessage(GC.M.ABP_OnButtonPostClickExt,function(msg, source, updateM6MacrosFn)
    p:log(30, 'MSG [%s]: %s', tostring(source), msg)
    updateM6MacrosFn(function(bw)
        UpdateIconByWidget(bw)
        UpdateStateByWidget(bw)
        UpdateCooldownByWidget(bw)
    end)
end)

-- todo next: update item charges
-- todo next: update usable
-- todo next: m6 todo items
-- bag updates
-- handle spell and item states: usable, count, charge

