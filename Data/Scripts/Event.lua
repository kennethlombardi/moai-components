--[[
    A listener must define the onEvent method

    listeners looks like
    {
        eventType1: [listener1, listener2]
        eventType2: [listener1, listenerx]
    }

    The queue is meant to store up events from the frame. 
    Only in the update will the events be sent out.
    This gives us control over when the events are received in the loop

    queue looks like
    {
        eventType1: [event, event,...]
    }

    Once all events are received the update will
    Create a reference to the current queue and set master queue = {}
        for the next frame so messages can be sent in response to messages
    For each event type in queue
        For each listener in listeners of event type
            Call the OnEvent method of listener
    queue will forget about all events

    When an object registers to listen to an event the object will be referenced in
    a table. When the object destroys itself I expect it to stop listening.
]]

local m = {
    listeners = {},
    queue = {},
}

-- helpers
local function QueueEvent(Event)
    if m.queue[Event.type] == nil then
        m.queue[Event.type] = {}
    end
    table.insert(m.queue[Event.type], Event)
end

function m._getListenerCount(eventType)
    local count = 0
    for k,v in pairs(m.listeners[eventType] or {}) do
        count = count + 1
    end
    return count
end

-- class definition
function m.ignore(eventType, listener)
    if m.listeners[eventType] == nil then return end
    -- if the listener isn't listening to event type it doesn't matter
    -- because nil will be assigned nil and have 0 effect
    m.listeners[eventType][listener] = nil
end

function m.initialize()
    m.queue = {}
    m.listeners = {}
    m.definitions = require("EventDefinitions")
end

function m.listen(eventType, listener)
    if m.listeners[eventType] == nil then
        m.listeners[eventType] = {}
    end
    -- listener of event type is the key and value
    -- so I can easily let the listener ignore events
    m.listeners[eventType][listener] = listener
end

function m.send(eventType, arguments)
    if m.definitions[eventType] == nil then
        print("Event type", eventType, "does not exist")
        return
    end
    local event = m.definitions[eventType].new(arguments)
    QueueEvent(event)
end

function m.shutdown()
    m.queue = nil
    m.listeners = nil
end

function m.update(dt)
    -- getting a reference to the current queue to iterate through 
    -- so messages can be sent during the current loop and be stored 
    -- in the new queue for the next frame
    local queue = m.queue
    m.queue = {}
    for eventType, events in pairs(queue) do
        for i, event in pairs(events or {}) do
            for listener, _ in pairs(m.listeners[eventType] or {}) do
                listener:onEvent(event)
            end
        end
    end
end

return m