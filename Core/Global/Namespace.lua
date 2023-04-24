--[[-----------------------------------------------------------------------------
Namespace Initialization
-------------------------------------------------------------------------------]]
local _, _ns = ...
local LibStub = LibStub

--- @type GlobalConstants
local GC = _ns.O.GlobalConstants

--- @type Kapresoft_LibUtil
local K = _ns.Kapresoft_LibUtil

--- @return Namespace
local function CreateNamespace(...)
    --- @type string
    local addon
    --- @type Namespace
    local ns

    addon, ns = ...

    --- @return Kapresoft_LibUtil
    function ns:K() return K end

    --- this is in case we are testing outside of World of Warcraft
    addon = addon

    --- @type GlobalObjects
    ns.O = ns.O or {}
    --- The AddOn Name, i.e. "ActionbarPlus"
    --- @type string
    ns.name = addon

    --- @type Module
    ns.M = ns.M or {}

    ns.pformat = ns:K().pformat:B()

    ns.O.AceLibrary = LibStub('Kapresoft-LibUtil-AceLibrary-1.0').O

    --- @param o Namespace
    local function Methods(o)


        --- @param moduleName string The module name, i.e. Logger
        --- @return string The complete module name, i.e. 'ActionbarPlus-Logger-1.0'
        function o:LibName(moduleName) return ns.O.GlobalConstants:LibName(moduleName) end

        --- @param name string The module name
        --- @param obj any The object to register
        function o:Register(name, obj)
            if name == nil or obj == nil then return end
            ns.O[name] = obj
        end

        ---@param objInstance any
        ---@param subName string
        function o:EmbedLoggerIfAvailable(subName, objInstance)
            ----- @type Logger
            local loggerLib = K.Objects.LoggerMixin
            if loggerLib then
                objInstance.logger = loggerLib:NewLogger(ns.name, GC.C.LOG_LEVEL_VAR , GC.C.COLOR_DEF, subName)
                objInstance.logger:log(0, 'Logger Applied to: %s', tostring(objInstance.major or subName or ns.name or objInstance))
                function objInstance:GetLogger() return self.logger end
            end
            return objInstance
        end

        function o:NewObject(name)
            assert(name ~= nil, "Object name is required.")
            return self:EmbedLoggerIfAvailable(name, {})
        end

        function o:NewAddOn()
            local a = ns.LibStub:NewAddon(ns.name)
            ns:EmbedLoggerIfAvailable(nil, a)
            return a
        end
    end

    Methods(ns)



    --- @class LocalLibStub : Kapresoft_LibUtil_LibStubMixin
    local LocalLibStub = ns:K().Objects.LibStubMixin:New(ns.name, 1.0,
            function(name, newLibInstance)
                ns:EmbedLoggerIfAvailable(name, newLibInstance)
                ns:Register(name, newLibInstance)
            end)
    ns.LibStub = LocalLibStub
    ns.LibStubAce = LibStub
    ns.O.LibStub = LocalLibStub

    ns.mt = { __tostring = function() return addon .. '::Namespace'  end }
    setmetatable(ns, ns.mt)

    return ns
end

if _ns.name then return end

CreateNamespace(...)

