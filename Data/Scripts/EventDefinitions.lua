--[[
    The event definitions for the event system.
    The purpose of these definitions is to try and keep some kind of error checking
    and centralized location for the types and arguments for events.

    It should be obvious that this definition is going to explode in size pretty quickly

    We will need to split up events into "System" events and "User" events.
    User events will need some kind of routing configuration or convention
]]

local Event = require("Class").create({})
function Event:constructor(...)
end

local ExplosionEvent = require("Class").create(Event)
function ExplosionEvent:constructor(arguments)
    self.super:constructor(arguments)
    self.type = "EXPLOSION_EVENT"
    self.arguments = {
        position = arguments.position
    }
end

local YellEvent = require("Class").create(Event)
function YellEvent:constructor(arguments)
    self.super:constructor(arguments)
    self.type = "YELL_EVENT"
    self.arguments = {
        position = arguments.position,
        volume = arguments.volume,
    }
end

local definitions = {
    ["EXPLOSION_EVENT"] = ExplosionEvent,
    ["YELL_EVENT"] = YellEvent,
}

return definitions
