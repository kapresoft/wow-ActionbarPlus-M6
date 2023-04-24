--- @type Namespace
local ns = select(2, ...)
local GC = ns.O.GlobalConstants
local O, C = ns.O, GC.C

--- @class ActionbarPlusM6 : BaseObject_WithAceEvent
local _obj = ns:NewAddOn()
--- @alias ActionbarPlusM6Operations ActionbarPlusM6 | AceConsole
local A = _obj
local p = A:GetLogger()



local eventHandler = O.EventHandler:NewEventHandler(A)
eventHandler:RegisterEvents()

local frame = CreateFrame("Frame", nil, UIParent)
frame.ctx = { addon = A }

frame:SetScript('OnEvent', OnPlayerEnteringWorld)
frame:RegisterEvent('PLAYER_ENTERING_WORLD')


--[[-----------------------------------------------------------------------------
API
-------------------------------------------------------------------------------]]
ABP_M6 = A
