--[[-----------------------------------------------------------------------------
Namespace Initialization
-------------------------------------------------------------------------------]]
local _, _ns = ...
local LibStub = LibStub

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

    --- @param o Namespace
    local function Methods(o)

        --- @param moduleName string The module name, i.e. Logger
        --- @return string The complete module name, i.e. 'ActionbarPlus-Logger-1.0'
        function o:LibName(moduleName) return self.name .. '-' .. moduleName .. '-1.0' end

        --- @param name string The module name
        --- @param obj any The object to register
        function o:Register(name, obj)
            if name == nil or obj == nil then return end
            ns.O[name] = obj
        end
    end

    Methods(ns)

    --- @class LocalLibStub : Kapresoft_LibUtil_LibStubMixin
    local LocalLibStub = ns:K().Objects.LibStubMixin:New(ns.name, 1.0,
            function(name, newLibInstance)
                --- @type Logger
                local loggerLib = LibStub(ns:LibName(ns.M.Logger))
                if loggerLib then
                    newLibInstance.logger = loggerLib:NewLogger(name)
                    newLibInstance.logger:log(30, 'New Lib: %s', newLibInstance.major)
                    function newLibInstance:GetLogger() return self.logger end
                end
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
