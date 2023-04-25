--- @class Namespace : LibPackMixin
local Namespace = {
    --- @type string
    name = "",
    --- @type GlobalObjects
    O = {},
    --- @type Module
    M = {},

    --- @type Kapresoft_LibUtil
    Kapresoft_LibUtil = {},

    --- @type fun(): Kapresoft_LibUtil
    K = {},

    --- @type LocalLibStub
    LibStub = {},

    --- Used in TooltipFrame and BaseAttributeSetter to coordinate the GameTooltip Anchor
    --- @see TooltipAnchor#SCREEN_* vars
    --- @type string
    GameTooltipAnchor = "",
    --- @type fun(o:any, ...) : void
    pformat = {}
}

--- @class LibPackMixin
local LibPackMixin = {
    --- @type GlobalObjects
    O = {}
}

--- @param o BaseObject | BaseObject_WithAceEvent
local function ApplyLoggerMethods(o)
    --- @type Logger
    o.logger = {}

    --- @return Logger
    function o:GetLogger()

    end

end

--- @class LoggerOperations
local LoggerOperations = {
    --- @type Logger
    logger = {},
    --- @return Logger
    --- @param self BaseObject_WithAceEvent
    GetLogger = function(self)
    end
}

--- @class BaseObject
local BaseObject = {}
ApplyLoggerMethods(BaseObject)

--- @class BaseObject_WithAceEvent : AceEvent
local BaseObject_WithAceEvent = {}
ApplyLoggerMethods(BaseObject_WithAceEvent)

--- @class SpellInfo
local SpellInfo = {
    id = 1,
    name = 'Arcane Intellect',
    icon = 1,
}

--- @class ItemInfo
local ItemInfo = {
    id = 1,
    name = 'item name',
    icon = 1,
    level = 1,
    minLevel = 1,
    link = 'item link',
    stackCount = 1,
    count = 1,
    isCraftingReagent = false,
    type = 'type',
    subType = 'subType',
    equipLoc='loc', classID=1, subclassID=1, bindType=1
}
