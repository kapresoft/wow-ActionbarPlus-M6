--[[-----------------------------------------------------------------------------
Interface files that need to be synced with ActionbarPlus codebase
-------------------------------------------------------------------------------]]
--- @alias ButtonHandlerFunction fun(btnWidget:ButtonUIWidget) | "function(btnWidget) print(btnWidget:GetName() end"
--- @alias ButtonPredicateFunction fun(btnWidget:ButtonUIWidget) | "function(btnWidget) return true end"

--- @class ButtonUIWidget
local ButtonUIWidget = {
}
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

