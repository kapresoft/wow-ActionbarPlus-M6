--- @type Namespace
local ns = select(2, ...)
local LibStub = ns.LibStub

local A = LibStub:NewAddon(ns.name)
print('Add-On Loaded ::', tostring(A))

