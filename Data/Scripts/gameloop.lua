local done = false

local Environment = nil
local Graphics = nil
local Simulation = nil
local ResourceManager = nil
local Event = nil
local Input = nil
local Factory = nil

local function preInitialize()
    Event = require("Event")
    Environment = require("Environment")
    Graphics = require("Graphics")
    Simulation = require("Simulation")
    ResourceManager = require('ResourceManager')
    Factory = require("Factory")
    Input =  require('Input')
    require("Test.TestAll") -- Put this behind an ENV e.g. ENV[DEBUG|TEST]
end

local function initialize()
    Event.initialize()
    Environment.initialize()
    Graphics.initialize()
    Simulation.initialize()
    ResourceManager.initialize()
    Factory.initialize()
    Input.initialize()

    --register key hack
    Input.registerKeyCallback("gl_input", onKeyboardEvent)
end

local function preShutdown()
end

local function shutdown()
    Input.shutdown()
    Factory.shutdown()
    ResourceManager.shutdown()
    Simulation.shutdown()
    Graphics.shutdown()
    Environment.shutdown()
    Event.shutdown()

    Simulation = nil
    Graphics = nil
    Environment = nil
    ResourceManager = nil
    Event = nil
    Input = nil
    Factory = nil
end

local function update(dt)
    Event.update(dt)
    Environment.update(dt)
    Simulation.update(dt)
    ResourceManager.update(dt)
    Input.update(dt)
    Graphics.update(dt)
    Factory.update(dt)
end

-- input hack
function onKeyboardEvent ( data )
    if not data or data.type ~= "keyboard" then
        print "Something screwed up, not keyboard data"
        return
    end

    local esc = 27
    if data.is_down == false and data.key == esc then
        done = true
    end
end

function gameloop ()
    preInitialize()
    initialize()
    while not done do
        update(Simulation.getStep()) --TODO: Get a real time step
        coroutine.yield()
    end
    preShutdown()
    shutdown()
    os.exit()
end

return gameloop
