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

--- @class SpellInfoM6
--- @field id SpellID
--- @field name SpellName
--- @field icon Icon

