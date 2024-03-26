-- SEE: https://github.com/BigWigsMods/packager/wiki/Localization-Substitution
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
local L = LibStub("AceLocale-3.0"):NewLocale(ns.name, "enUS", true);
if not L then return end

--[[-----------------------------------------------------------------------------
Local Vars
-------------------------------------------------------------------------------]]

L['Addon Initialized Text Format V1']  = '%s by |cffB0C2FBkapresoft|r is loaded.'
L['Addon Initialized Text Format']     = '%s by kapresoft is loaded.  Type %s on the console for available commands.'
L['Missing Spell or Item']             = true
L['Inactive M6 Macro']                 = true
L['Macro']                             = true
L['Name']                              = true
