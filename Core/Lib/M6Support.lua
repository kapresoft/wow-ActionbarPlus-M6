--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, pformat = ns.O, ns.pformat
local GC, AceEvent, String = O.GlobalConstants, O.AceLibrary.AceEvent, O.String
local IsBlank, IsNotBlank, StartsWithIgnoreCase = String.IsBlank, String.IsNotBlank, String.StartsWithIgnoreCase

local missingTexture = 134400

--- This will be populated later
--- @type ActionbarPlusAPI
local ABPI

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
local function RemoveInactiveMacros()
    ABPI:UpdateMacros(function(bw)
        local d = bw:GetMacroData()
        local n = d.name; if not n then return end
        local slotID = S:slotIDByMacroName(n); if not slotID then return end
        if S:IsSlotActive(slotID) then return end

        --local name = M6:GetHint(slotID); if IsNotBlank(name) then return end
        p:log('InActive macro: %s', n)
        bw:SetButtonAsEmpty()
        bw:SetText(nil)
        return false
    end)
end


--[[-----------------------------------------------------------------------------
Event Handler
-------------------------------------------------------------------------------]]
--- @class M6_EventHandler
local H = {}
---@param o M6_EventHandler
local function EventHandlerPropertiesAndMethods(o)

    --- @param userIcon Icon
    --- @param actionID number
    function o:OnSetActionIcon(actionID, userIcon)
        --[[if userIcon then
            -- todo next: This is an icon set by a user
        end]]

        local hint = S:macroHintByAction(actionID); if hint == nil then return end
        p:log(30, '[%s::%s]:: hint=%s', hint.name, actionID, pformat(hint))
        local icon, itemCount, macroName = hint.icon, hint.itemCount, hint.macroName
        if not icon then icon = missingTexture end

        ABPI:UpdateMacrosByName(macroName, function(bw)
            p:log(30, 'found[%s]: %s', macroName, bw:GetName())
            bw:SetIcon(hint.icon)
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
    function o:db() return M6DB end

    --- @return M6SupportDBProfile
    function o:profile()
        local realm, name = GetNormalizedRealmName(), UnitName("player")
        local pr = self:db().profiles[realm][name]
        if pr and pr[1] then return pr[1] end
        return nil
    end

    --- @param macroName string The macro name i.e '_M6+s01'
    --- @return string The slotId, i.e. 's01' from '_M6+s01'
    function o:slotIDByMacroName(macroName)
        if IsBlank(macroName) or StartsWithIgnoreCase(macroName, "_m6") ~= true then return nil end
        local _, slotID = string.gmatch(macroName, "(%w+)%+(%w+)")()
        return slotID
    end

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
    --- @return M6Support_MacroHint
    --- @param slotID string The numeric slotID
    function o:macroHintBySlotID(slotID)
        if not slotID then return nil end
        --- inactive slots will not return a hint
        local m6Name, isActive, _, iconId, spellOrItemName,
                    itemCount, unknown1, unknown2, fn, unknown3 = M6:GetHint(slotID)
        if not m6Name then return nil end

        --- @type M6Support_MacroHint
        local ret = {
            name = m6Name,
            isActive = isActive,
            icon = iconId,
            spell = spellOrItemName,
            itemCount = itemCount,
            unknown1 = unknown1, unknown2 = unknown2, fn = fn, unknown3 = unknown3,
        }
        p:log(0, 'slotID[%s]: %s', tostring(slotID), ret)

        local macroName = S:macroNameBySlot(slotID)
        if IsBlank(m6Name) or IsBlank(macroName) or ret.icon == nil then return nil end

        --- Custom Fields
        ret.macroName = macroName
        ret.slotID = slotID

        return ret
    end

    --- @param actionID number
    --- @return M6Support_MacroHint
    function o:macroHintByAction(actionID)
        local slotID = self:slotIDByAction(actionID)
        return self:macroHintBySlotID(slotID)
    end

    ---@param actionID number
    function o:IsActionActive(actionID)
        if actionID then return M6:IsActionActivated(actionID) end
        return false
    end

    --- @param slotID string The numeric slotID
    --- @return boolean
    function o:IsSlotActive(slotID) return M6:GetHint(slotID) ~= nil end

    function S:InitializeHooks()
        --- @param userIcon Icon
        --- @param actionID number
        hooksecurefunc(M6, "SetActionIcon", function(m6API, actionID, userIcon)
            p:log(30, 'hooksecurefunc()::SetAction::id: %s', actionID);
            if not actionID then return end
            H:OnSetActionIcon(actionID, userIcon)
        end)

        hooksecurefunc(M6, "DeactivateAction", function(m6API, actionID)
            p:log(0, 'hooksecurefunc()::DeactivateAction::id: %s', actionID)
            H:OnDeactivateAction(actionID)
        end)
    end

end
PropertiesAndMethods(S)

--[[-----------------------------------------------------------------------------
Message Callbacks
-------------------------------------------------------------------------------]]
AceEvent:RegisterMessage(GC.M.ABP_PLAYER_ENTERING_WORLD,function(msg, source, ...)
    p:log(30, 'Received message from [%s]: %s', tostring(source), msg)
    local apiLib = 'ActionbarPlus-ActionbarPlusAPI-1.0'
    ABPI = ns.LibStubAce('ActionbarPlus-ActionbarPlusAPI-1.0')
    if not ABPI then
        p:log(0, 'Lib was not available: %s', apiLib)
        return
    end
    S:InitializeHooks()
end)
