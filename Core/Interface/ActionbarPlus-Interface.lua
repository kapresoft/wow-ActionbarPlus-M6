--[[-----------------------------------------------------------------------------
Interface files that need to be synced with ActionbarPlus codebase
-------------------------------------------------------------------------------]]
--- @alias ButtonHandlerFunction fun(btnWidget:ButtonUIWidget) | "function(btnWidget) print(btnWidget:GetName()) end"
--- @alias ButtonPredicateFunction fun(btnWidget:ButtonUIWidget) | "function(btnWidget) return true end"

--[[-----------------------------------------------------------------------------
Interface:: ActionbarPlusAPI
-------------------------------------------------------------------------------]]
--- @class ActionbarPlusAPI
--- @field GetVersion fun(self:ActionbarPlusAPI) : string
--- @field GetLastUpdate fun(self:ActionbarPlusAPI) : string
--- @field IsActionbarPlusM6OutOfDate fun(self:ActionbarPlusAPI) : boolean, string
--- @field GetItemInfo fun(self:ActionbarPlusAPI, itemIDOrName:number|string):ItemInfo
--- @field GetItemCooldown fun(self:ActionbarPlusAPI, itemIDOrName:number|string):CooldownInfo
--- @field GetSpellCooldown fun(self:ActionbarPlusAPI, spellNameOrID:number|string):CooldownInfo
--- @field GetSpell fun(self:ActionbarPlusAPI, spellNameOrID:number|string): SpellName, SpellID
--- @field UpdateMacros fun(self:ActionbarPlusAPI, btnHandlerFn:ButtonHandlerFunction)
--- @field UpdateM6Macros fun(self:ActionbarPlusAPI, btnHandlerFn:ButtonHandlerFunction)
--- @field UpdateMacrosByName fun(self:ActionbarPlusAPI, macroName:string, btnHandlerFn:ButtonHandlerFunction)
--- @field FindMacros fun(self:ActionbarPlusAPI, predicateFn:ButtonPredicateFunction):table<number, ButtonUIWidget>
--- @field IsM6Macro fun(self:ActionbarPlusAPI, macroName:string):boolean

--[[-----------------------------------------------------------------------------
Interface: ButtonUIWidget
-------------------------------------------------------------------------------]]
--- @class ButtonUIWidget
--- @field GetSpellData fun(self:ButtonUIWidget):Profile_Spell
--- @field GetItemData fun(self:ButtonUIWidget):Profile_Item
--- @field GetMacroData fun(self:ButtonUIWidget):Profile_Macro
--- @field GetMacroName fun(self:ButtonUIWidget):string
--- @field GetName fun(self:ButtonUIWidget):string
--- @field SetIcon fun(self:ButtonUIWidget, icon:Icon)
--- @field UpdateItemStateByItem fun(self:ButtonUIWidget, itemIDOrName:number|string)
--- @field UpdateItemStateByItemInfo fun(self:ButtonUIWidget, itemInfo:ItemInfo)
--- @field SetActionUsable fun(self:ButtonUIWidget, isUsable:boolean)
--- @field SetNameText fun(self:ButtonUIWidget, text:string)
--- @field SetText fun(self:ButtonUIWidget, text:string)
--- @field UpdateSpellCharges fun(self:ButtonUIWidget, spellName:SpellName)
--- @field IsUsableItem fun(self:ButtonUIWidget, item:ItemID_Link_Or_Name):boolean
--- @field IsStealthSpell fun(self:ButtonUIWidget):boolean

--[[-----------------------------------------------------------------------------
Interface: Profile_Spell
-------------------------------------------------------------------------------]]
--- @class Profile_Spell
--- @field minRange number The minimum range of the spell.
--- @field id number The unique ID of the spell.
--- @field label string The spell label, including name and rank, with color encoding. Example: "Windfury Weapon |c00747474(Rank 1)|r",
--- @field name string The name of the spell. Example: "Windfury Weapon",
--- @field castTime number The cast time of the spell.
--- @field link string The hyperlink for the spell, with color encoding. Example: "|cff71d5ff|Hspell:8232:0|h[Windfury Weapon]|h|r"
--- @field maxRange number The maximum range of the spell.
--- @field icon number The icon ID of the spell.
--- @field rank string The rank of the spell. Example: "Rank 1"

--[[-----------------------------------------------------------------------------
Interface: Profile_Item
-------------------------------------------------------------------------------]]
--- @class Profile_Item
--- @field name string The name of the item.
--- @field link string The hyperlink for the item, with color encoding.
--- @field id number The unique ID of the item.
--- @field stackCount number The maximum number of items that can stack in a single slot.
--- @field icon number The icon ID of the item.
--- @field count number The current count of the item in the player's possession.

--[[-----------------------------------------------------------------------------
Interface: Profile_Macro
-------------------------------------------------------------------------------]]
--- @class Profile_Macro
--- @field type string The type of the profile element, in this case, "macro".
--- @field index number The index of the macro in the macro UI.
--- @field name string The name of the macro.
--- @field icon number The primary icon ID of the macro.
--- @field icon2 number An alternate icon ID, used by third-party plugins.
--- @field body string The macro commands/body.

--[[-----------------------------------------------------------------------------
Interface: CooldownInfo
-------------------------------------------------------------------------------]]
--- @class CooldownInfo
--- @field start number|nil The start time of the cooldown. `nil` if the cooldown is not active.
--- @field duration number|nil The duration of the cooldown. `nil` if the cooldown is not active.
--- @field enabled number Indicates whether the cooldown is enabled (1) or not (0).
--- @field name string The name of the spell or item on cooldown.
--- @field isItem boolean Indicates whether the cooldown is for an item (`true`) or a spell (`false`).

--[[-----------------------------------------------------------------------------
Type: SpellInfoBasic
-------------------------------------------------------------------------------]]
--- @class SpellInfoBasic
--- @field public id SpellID The spell ID
--- @field public name SpellName The spell Name
--- @field public icon Icon The icon ID
