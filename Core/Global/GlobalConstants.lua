--[[-----------------------------------------------------------------------------
Global Variables Initialization
-------------------------------------------------------------------------------]]

--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Blizzard Vars
-------------------------------------------------------------------------------]]
local GetAddOnMetadata, GetBuildInfo, GetCVarBool = GetAddOnMetadata, GetBuildInfo, GetCVarBool
local date = date

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
-- Use the bare namespace here since this is the very first file to be loaded
local addon, ns = ...

--- @type fun(o:any, ...) : void
local pformat = ns.pformat

--- @type Kapresoft_LibUtil
local K = ns.Kapresoft_LibUtil
local String = K.Objects.String
local IsBlank, IsNotBlank, EqualsIgnoreCase = String.IsBlank, String.IsNotBlank, String.EqualsIgnoreCase

--[[-----------------------------------------------------------------------------
New Instance
-------------------------------------------------------------------------------]]
--- @class GlobalConstants
local L = {}

--[[-----------------------------------------------------------------------------
Methods: GlobalConstants
-------------------------------------------------------------------------------]]
--- @param o GlobalConstants
local function GlobalConstantProperties(o)


    --- @class ConstantNames
    local C = {
        ADDON_NAME = addon,
        DB_NAME = 'ABP_M6_DB',
        LOG_LEVEL_VAR = 'ABP_M6_LOG_LEVEL',
        ADDON_INFO_FMT = '%s|cfdeab676: %s|r',
        --- @type Kapresoft_LibUtil_ColorDefinition
        COLOR_DEF = {
            primary   = '2db9fb',
            secondary = 'fbeb2d',
            tertiary = 'ffffff'
        }
    }

    --- @class EventNames
    local Events = {
        OnEnter = 'OnEnter',
    }

    local function newMsg(msg) return sformat("%s::%s", addon, msg) end
    local function newMsgABP(msg) return sformat("%s::%s", 'ActionbarPlus', msg) end

    --- @class MessageNames
    local Messages = {
        OnAddOnInitialized             = newMsg('OnAddOnInitialized'),
        OnAddOnReady                   = newMsg('OnAddOnReady'),

        --- ActionbarPlus Messages
        ABP_PLAYER_ENTERING_WORLD               = newMsgABP('PLAYER_ENTERING_WORLD'),
        ABP_OnUpdateMacroState                  = newMsgABP('OnUpdateMacroState'),
        ABP_OnSpellCastSucceeded                = newMsgABP('OnSpellCastSucceeded'),
        ABP_OnBagUpdateExt                      = newMsgABP('OnBagUpdateExt'),
        ABP_OnButtonPostClickExt                = newMsgABP('OnButtonPostClickExt'),
        ABP_OnSpellCastStartExt                 = newMsgABP('OnSpellCastStartExt'),
        ABP_OnSpellCastSentExt                  = newMsgABP('OnSpellCastSentExt'),
        ABP_OnSpellCastStopExt                  = newMsgABP('OnSpellCastStopExt'),
        ABP_OnSpellCastFailedExt                = newMsgABP('OnSpellCastFailedExt'),
        ABP_MacroAttributeSetter_OnSetIcon      = newMsgABP('MacroAttributeSetter:OnSetIcon'),
        ABP_MacroAttributeSetter_OnShowTooltip  = newMsgABP('MacroAttributeSetter:OnShowTooltip'),
    }

    o.C = C
    o.E = Events
    o.M = Messages
    o.newMsg = newMsg

end

--- @param o GlobalConstants
local function GlobalConstantMethods(o)

    function o:LibName(moduleName) return addon .. '-' .. moduleName .. '-1.0' end

    function o:AddonName() return o.C.ADDON_NAME end
    function o:GetAceLocale() return LibStub("AceLocale-3.0"):GetLocale(addon, true) end
    function o:Constants() return o.C end
    function o:Events() return o.E end

    --[[---#### Example
    ---```
    ---local version, curseForge, issues, repo, lastUpdate, useKeyDown, wowInterfaceVersion = GC:GetAddonInfo()
    ---```
    --- @return string, string, string, string, string, string, string
    function o:GetAddonInfo()
        local versionText, lastUpdate
        --@non-debug@
        versionText = GetAddOnMetadata(addon, 'Version')
        lastUpdate = GetAddOnMetadata(addon, 'X-Github-Project-Last-Changed-Date')
        --@end-non-debug@
        --@debug@
        versionText = '1.0.x.dev'
        lastUpdate = date("%m/%d/%y %H:%M:%S")
        --@end-debug@

        local wowInterfaceVersion = select(4, GetBuildInfo())

        return versionText, GetAddOnMetadata(addon, 'X-CurseForge'), GetAddOnMetadata(addon, 'X-Github-Issues'),
                    GetAddOnMetadata(addon, 'X-Github-Repo'), lastUpdate, wowInterfaceVersion
    end

    --- @return string
    function o:GetAddonInfoFormatted()
        local C = self:GetAceLocale()
        local version, curseForge, issues, repo, lastUpdate, wowInterfaceVersion = self:GetAddonInfo()
        local fmt = self.C.ADDON_INFO_FMT
        return sformat("%s:\n%s\n%s\n%s\n%s\n%s\n%s",
                C['Addon Info'],
                sformat(fmt, C['Version'], version),
                sformat(fmt, C['Curse-Forge'], curseForge),
                sformat(fmt, C['Bugs'], issues),
                sformat(fmt, C['Repo'], repo),
                sformat(fmt, C['Last-Update'], lastUpdate),
                sformat(fmt, C['Interface-Version'], wowInterfaceVersion)
        )
    end]]

    function o:GetLogLevel() return _G[o.C.LOG_LEVEL_VAR] or 0 end
    --- @param level number The log level between 1 and 100
    function o:SetLogLevel(level) _G[o.C.LOG_LEVEL_VAR] = level or 1 end
    --- @param level number
    function o:ShouldLog(level) return self:GetLogLevel() >= level end
    function o:IsVerboseLogging() return self:ShouldLog(20) end

    --- @param frameIndex number
    --- @param btnIndex number
    function o:ButtonName(frameIndex, btnIndex)
        return sformat(self.C.BUTTON_NAME_FORMAT, tostring(frameIndex), tostring(btnIndex))
    end

    --- todo next: merge with IsM6Macro
    --- @param macroName string The macro name i.e '_M6+s01'
    --- @return boolean Returns true if the macro name has the format '_M6+<slotID>', i.e. '_M6+s01'
    function o:IsM6Macro(macroName)
        if IsBlank(macroName) then return nil end
        local _, slotID = macroName:gmatch("(%w+)%+(%w+)")()
        return IsNotBlank(slotID)
    end
end

--[[-----------------------------------------------------------------------------
Initializer
-------------------------------------------------------------------------------]]
local function Init()
    GlobalConstantProperties(L)
    GlobalConstantMethods(L)

    ns.O = ns.O or {}
    ns.O.GlobalConstants = L
end

Init()
