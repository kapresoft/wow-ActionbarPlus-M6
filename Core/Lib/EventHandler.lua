--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local RegisterFrameForEvents, RegisterFrameForUnitEvents = FrameUtil.RegisterFrameForEvents, FrameUtil.RegisterFrameForUnitEvents

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local ns = select(2, ...)
local O, AceEvent, GC = ns.O, ns.O.AceLibrary.AceEvent, ns.O.GlobalConstants
local C, L = GC.C, GC:GetAceLocale()

--[[-----------------------------------------------------------------------------
Interface
-------------------------------------------------------------------------------]]
--- @class EventFrameInterface : _Frame
local _EventFrame = {
    --- @type EventContext
    ctx = {}
}

--- @class EventContext
local _EventContext = {
    --- @type EventFrameInterface
    frame = {},
    --- @type ActionbarPlusM6
    addon = {},
}

--- @class EventHandler :BaseObject_WithAceEvent
local _L = ns.LibStub:NewLibrary(ns.M.EventHandler); if not _L then return end
AceEvent:Embed(_L)
local p = _L:GetLogger()

---@param addon ActionbarPlusM6
---@return EventHandler
function _L:NewEventHandler(addon)
    return ns:K():CreateAndInitFromMixin(_L, addon)
end

---@param addon ActionbarPlusM6
function _L:Init(addon)
    self.addon = addon
end

--- @return EventFrameInterface
function _L:CreateEventFrame()
    local f = CreateFrame("Frame", nil, self.addon.frame)
    f.ctx = self:CreateContext(f)
    return f
end

--- @param eventFrame _Frame
--- @return EventContext
function _L:CreateContext(eventFrame)
    local ctx = {
        frame = eventFrame,
        addon = self.addon,
    }
    return ctx
end

--- @param f EventFrameInterface
--- @param event string
local function OnPlayerEnteringWorld(f, event, ...)
    local pp = f.ctx.addon:GetLogger()
    local isLogin, isReload = ...

    --@debug@
    isLogin = true
    --@end-debug@

    pp:log(sformat(L['Addon Initialized Text Format V1'], GC:GetAddonInfo()))
    pp:log(1, 'isLogin=%s isReload=%s', isLogin, isReload)
    pp:log(1, 'Log Level[%s]: %s', C.LOG_LEVEL_VAR, GC:GetLogLevel())

    AceEvent:RegisterMessage("ActionbarPlus::OnMacroAttributesSet", function(msg, widgetFn)
        local w = widgetFn()
        local macroData = w:GetMacroData()
        p:log(30, 'Msg[%s] received %s %s', msg, macroData.name, GetTime())
    end)

end

local function OnSpellEvents(f, event, ...)
    if 'SPELL_UPDATE_USABLE' == event then
        AceEvent:SendMessage(GC.M.OnSpellUpdateUsable, 'EventHandler')
    end
end

function _L:RegisterPlayerEnteringWorld()
    local f = self:CreateEventFrame()
    f:SetScript('OnEvent', OnPlayerEnteringWorld)
    RegisterFrameForEvents(f, { 'PLAYER_ENTERING_WORLD' })
end
function _L:RegisterSpellEvents()
    local f = self:CreateEventFrame()
    f:SetScript('OnEvent', OnSpellEvents)
    RegisterFrameForEvents(f, { 'SPELL_UPDATE_USABLE' })
end

function _L:RegisterEvents()
    p:log(10, 'RegisterEvents called..')
    self:RegisterPlayerEnteringWorld()
    self:RegisterSpellEvents()
end
