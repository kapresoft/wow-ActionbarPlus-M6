--[[-----------------------------------------------------------------------------
Interface files that need to be synced with ActionbarPlus codebase
-------------------------------------------------------------------------------]]
--- @alias ButtonHandlerFunction fun(btnWidget:ButtonUIWidget) | "function(btnWidget) print(btnWidget:GetName()) end"
--- @alias ButtonPredicateFunction fun(btnWidget:ButtonUIWidget) | "function(btnWidget) return true end"

--[[-----------------------------------------------------------------------------
Interface:: ActionbarPlusAPI
-------------------------------------------------------------------------------]]
--- @class ActionbarPlusAPI
local ActionbarPlusAPI = {}
--- @param o ActionbarPlusAPI
local function ActionbarPlusAPI_Methods(o)

    --- @param itemIDOrName number|string The itemID or itemName
    --- @return ItemInfo
    function o:GetItemInfo(itemIDOrName) end

    --- @param itemIDOrName number|string The itemID or itemName
    --- @return CooldownInfo
    function o:GetItemCooldown(itemIDOrName)  end

    --- @param spellNameOrID number|string Spell ID or Name. When passing a name requires the spell to be in your Spellbook.
    --- @return CooldownInfo
    function o:GetSpellCooldown(spellNameOrID) end

    --- @param macroName string
    --- @return boolean
    function o:IsM6Macro(macroName) end

    --- @param btnHandlerFn ButtonHandlerFunction
    function o:UpdateMacros(btnHandlerFn) end

    --- @param btnHandlerFn ButtonHandlerFunction
    function o:UpdateM6Macros(btnHandlerFn) end

    --- @param macroName string
    --- @param btnHandlerFn ButtonHandlerFunction
    function o:UpdateMacrosByName(macroName, btnHandlerFn) end

    --- @param predicateFn ButtonPredicateFunction
    --- @return table<number, ButtonUIWidget>
    function o:FindMacros(predicateFn) end
end
ActionbarPlusAPI_Methods(ActionbarPlusAPI)

--[[-----------------------------------------------------------------------------
Interface:: ButtonUIWidget
-------------------------------------------------------------------------------]]

--- @class ButtonUIWidget
local ButtonUIWidget = {}

--- @param o ButtonUIWidget
local function ButtonUIWidget_Methods(o)

    --- @return Profile_Spell
    function o:GetSpellData() end
    --- @return Profile_Item
    function o:GetItemData() end
    --- @return Profile_Macro
    function o:GetMacroData() end

    --- @return string
    function o:GetName() end
    --- @param icon Icon
    function o:SetIcon(icon) end

    --- @param itemIDOrName number|string The itemID or itemName
    function o:UpdateItemStateByItem(itemIDOrName) end
    ---@param itemInfo ItemInfo
    function o:UpdateItemStateByItemInfo(itemInfo) end

end
ButtonUIWidget_Methods(ButtonUIWidget)

--- @class Profile_Spell
local Profile_Spell = {
    ["minRange"] = 0,
    ["id"] = 8232,
    ["label"] = "Windfury Weapon |c00747474(Rank 1)|r",
    ["name"] = "Windfury Weapon",
    ["castTime"] = 0,
    ["link"] = "|cff71d5ff|Hspell:8232:0|h[Windfury Weapon]|h|r",
    ["maxRange"] = 0,
    ["icon"] = 136018,
    ["rank"] = "Rank 1"
}
--- @class Profile_Item
local Profile_Item = {
    ["name"] = "Arcane Powder",
    ["link"] = "|cffffffff|Hitem:17020::::::::70:::::::::|h[Arcane Powder]|h|r",
    ["id"] = 17020,
    ["stackCount"] = 20,
    ["icon"] = 133848,
    ["count"] = 40,
}
--- @class Profile_Macro
local Profile_Macro = {
    ["type"] = "macro",
    ["index"] = 41,
    ["name"] = "z#LOL",
    ["icon"] = 132093,
    -- This macro is used by third-party plugins
    ["icon2"] = 132093,
    ["body"] = "/lol\n",
}

--- @class ItemInfo
local ItemInfo = {
    id = 1,
    name = 'item name',
    link = 'item link',
    icon = 1,
    quality = 1,
    level = 1,
    minLevel = 1,
    type = 'type',
    subType = 'subType',
    stackCount = 1,
    count = 1,
    equipLoc='loc', classID=1, subclassID=1, bindType=1,
    isCraftingReagent = false,
}

--- @class CooldownInfo
local CooldownInfo = {
    start=nil,
    duration=nil,
    enabled=0,
    name = 'spell or item',
    isItem = false
}
