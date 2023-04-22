--[[-----------------------------------------------------------------------------
Modules
-------------------------------------------------------------------------------]]
local addon, ns = ...

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
    Logger = 'Logger',
    LogFactory = 'LogFactory',
    PrettyPrint = 'PrettyPrint',
    Table = 'Table',
    String = 'String',
    Safecall = 'Safecall',
    LuaEvaluator = 'LuaEvaluator',
    Assert = 'Assert',
}

--- @class GlobalObjects
local GlobalObjectsTemplate = {
    --- @type LocalLibStub
    LibStub = {},
    --- @type Kapresoft_LibUtil_AceLibraryObjects
    AceLibrary = {},
    --- @type Kapresoft_LibUtil_Assert
    Assert = {},
    --- @type Logger
    Logger = {},
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
}

L.M = M
ns.M = M

--- @type Modules
ns.O = ns.O or {}
ns.O.Modules = L
