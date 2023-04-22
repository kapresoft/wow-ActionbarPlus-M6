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

