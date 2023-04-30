--[[
    ActionbarPlus Addon
--]]
--[[-----------------------------------------------------------------------------
Lua Vars
-------------------------------------------------------------------------------]]
local sformat = string.format

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]
--- @type Namespace
local _, ns = ...

---@type AceLocale
local L = LibStub("AceLocale-3.0"):GetLocale(ns.name)
if not L then return end

-- General
ABP_M6_TITLE                                    = "ActionbarPlus-M6"
ABP_M6_CATEGORY                                 = "AddOns/" .. ABP_TITLE

