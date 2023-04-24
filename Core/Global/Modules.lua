--[[-----------------------------------------------------------------------------
Modules
-------------------------------------------------------------------------------]]
local addon, ns = ...
--- @type Kapresoft_LibUtil
local K = ns.Kapresoft_LibUtil

--- @class Modules
local L = {
    mt = {
        __tostring = function() return 'Modules' end
    }
}
setmetatable(L, L.mt)

--- @class Module
local M = {
    LibStub = 'LibStub',
    -- Kapresoft Libraries
    Mixin = 'Mixin',
    LoggerMixin = K.M,
    PrettyPrint = 'PrettyPrint',
    Table = 'Table',
    String = 'String',
    Safecall = 'Safecall',
    LuaEvaluator = 'LuaEvaluator',
    Assert = 'Assert',
    AceLibrary = 'AceLibrary',
    -- ActionbarPlus-M6 Libraries
    GlobalConstants = 'GlobalConstants',
    EventHandler = 'EventHandler',
}

--- @class GlobalObjects
local GlobalObjectsTemplate = {
    --- @type Kapresoft_LibUtil_Mixin
    Mixin = {},
    --- @type LocalLibStub
    LibStub = {},
    --- @type Kapresoft_LoggerMixin
    LoggerMixin = {},
    --- @type Kapresoft_LibUtil_AceLibraryObjects
    AceLibrary = {},
    --- @type Kapresoft_LibUtil_Assert
    Assert = {},
    --- @type Kapresoft_LibUtil_LuaEvaluator,
    LuaEvaluator = {},
    --- @type Kapresoft_LibUtil_Safecall
    Safecall = {},
    --- @type Kapresoft_LibUtil_String
    String = {},
    --- @type Kapresoft_LibUtil_Table
    Table = {},
    ---
    ---
    --- @type Modules
    Modules = {},
    --- @type GlobalConstants
    GlobalConstants = {},
    --- @type EventHandler
    EventHandler = {},
}

L.M = M
ns.M = M

--- @type Modules
ns.O = ns.O or {}
ns.O.Modules = L
