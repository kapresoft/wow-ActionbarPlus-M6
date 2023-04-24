--[[-----------------------------------------------------------------------------
M6 Interfaces
-------------------------------------------------------------------------------]]

--- @class M6SupportDBProfile
local M6Support_DB_Profile = {
    --- @type table<string, number>
    ["slots"] = {
        ["s01"] = 1,
        ["s02"] = 2,
    }
}

--- @class M6Support_DB
local M6SupportDB = {
    --- @type M6SupportDBProfile
    profiles = {},
    --- @type table<number, table>
    actions = {},
}
--- @class M6Support_MacroHint
local M6Support_MacroHint = {
    name = 'm6-name',
    isActive = true,
    icon = 123456,
    spell = 'spell-or-item',
    itemCount = 1,
    unknown1 = 0,
    unknown2 = 0,
    fn = function()  end,
    unknown3 = 0,
    --- Add-On Specific fields
    slotID = 1,
    macroName = '_M6+s01',
}


--[[-----------------------------------------------------------------------------
Interface:: ActionbarPlusAPI
-------------------------------------------------------------------------------]]
--- @class ButtonUIWidget
local ButtonUIWidget = {
}
---@param o ButtonUIWidget
local function ButtonUIWidget_Methods(o)
    --- @return string
    function o:GetName() end
    ---@param icon Icon
    function o:SetIcon(icon) end
end
ButtonUIWidget_Methods(ButtonUIWidget)

--- @alias ButtonHandlerFunction fun(btnWidget:ButtonUIWidget) | "function(btnWidget) print(btnWidget:GetName() end"
--- @alias ButtonPredicateFunction fun(btnWidget:ButtonUIWidget) | "function(btnWidget) return true end"
--- @class ActionbarPlusAPI
local ActionbarPlusAPI = {}
---@param o ActionbarPlusAPI
local function ActionbarPlusAPI_Methods(o)

    ---@param btnHandlerFn ButtonHandlerFunction
    function o:UpdateMacros(btnHandlerFn) end

    ---@param macroName string
    ---@param btnHandlerFn ButtonHandlerFunction
    function o:UpdateMacrosByName(macroName, btnHandlerFn) end

    ---@param predicateFn ButtonPredicateFunction
    ---@return table<number, ButtonUIWidget>
    function o:FindMacros(predicateFn) end
end
ActionbarPlusAPI_Methods(ActionbarPlusAPI)
