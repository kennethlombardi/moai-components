module(..., package.seeall)

local pickle = require("Pickle").pickle

local PASSED = true
local FAILED = false

local testDirectory = "./Data/Scripts/Test/"
function passResult()
end

local function START_THE_REACTOR()
    Event:initialize()
end

local function STOP_THE_REACTOR()
    Event:shutdown()
end

local function RESTART_THE_REACTOR()
    STOP_THE_REACTOR()
    Event = require("Event")
    START_THE_REACTOR()
end

function suite_setup()
    Event = require("Event")
end

function setup()
   RESTART_THE_REACTOR()
end


function test_twoObjectsListeningAndResponding()
    -- simulate 2 objects listening and responding to messages on a certain frame
    local eventsForFrame = {}
    table.insert(eventsForFrame, 42, {
            type = 'EXPLOSION_EVENT', 
            arguments = {position = {x = 42, y = 42, z = 42}}
        })

    local kitty = {
        name = "kitty",
        exploded = false,
        explosionPosition = {x = 0, y = 0, z = 0}
    }

    function kitty:onEvent(event)
        self.exploded = true
        self.explosionPosition.x = event.arguments.position.x
        self.explosionPosition.y = event.arguments.position.y
        self.explosionPosition.z = event.arguments.position.z
        event.arguments.position.z = 100
    end

    local puppy = {
        name = "puppy",
        exploded = false,
        explosionPosition = {x = 1, y = 1, z = 1}
    }

    function puppy:onEvent(event)
        self.exploded = true
        self.explosionPosition.x = event.arguments.position.x
        self.explosionPosition.y = event.arguments.position.y
        self.explosionPosition.z = event.arguments.position.z
    end

    Event.listen("EXPLOSION_EVENT", kitty)
    Event.listen("EXPLOSION_EVENT", puppy)

    local frame = 0
    while frame < 100 do
        if eventsForFrame[frame] then
            local event = eventsForFrame[frame]
            Event.send(event.type, event.arguments)
            table.remove(eventsForFrame, frame)
        end
        Event:update(0.016)
        frame = frame + 1
    end

    local passed = PASSED
        and kitty.exploded == true
        and kitty.explosionPosition.x == 42
        and kitty.explosionPosition.y == 42
        and kitty.explosionPosition.z == 42
        and puppy.exploded == true
        and puppy.explosionPosition.x == 42
        and puppy.explosionPosition.y == 42
        and puppy.explosionPosition.z == 100 -- kitty is a dick, got the message first, and changed it

    -- The fact I am checking so many assertions means I need to break this thing up into different functions
    assert_true(passed, "Object didn't get message, or first receiver didn't change message")

end

function test_listenToMessageThenIgnore()
    local kitty = { name = "kitty", exploded = true }
    function kitty:onEvent(event) 
        if event.arguments.position.x > 0 then
            self.exploded = false
        elseif event.arguments.position.x == 0 then
            self.exploded = true
        end
        self.explosionPositionx = event.arguments.position.x
    end
    Event.listen("EXPLOSION_EVENT", kitty)
    Event.update()
    Event.send("EXPLOSION_EVENT", {position = {x = 1, y = 0, z = 0}})
    Event.update() -- kitty should not explode (explosion missed)
    Event.ignore("EXPLOSION_EVENT", kitty)
    Event.send("EXPLOSION_EVENT", {position = {x = 0, y = 0, z = 0}})
    Event.update() -- kitty should ignore the explosion event and exploded should be false

    local passed = PASSED
        and kitty.exploded == false
        and kitty.explosionPositionx == 1 -- kitty saw the x = 1 explosion but ignored the x = 0 explosion

    assert_true(passed, "Object: "..kitty.name.." did not ignore the message and exploded")
end

function test_listenToMessageThenIgnoreConfirmEventSystemHasZeroListeners()
    local kitty = {name = "kitty"}
    function kitty:onEvent(Event) end

    for i = 1, 100 do
        Event.listen("EXPLOSION_EVENT", kitty)
        Event.ignore("EXPLOSION_EVENT", kitty)
    end

    Event.listen("EXPLOSION_EVENT", kitty)
    Event.listen("EXPLOSION_EVENT", kitty)
    Event.listen("EXPLOSION_EVENT", kitty)
    Event.ignore("EXPLOSION_EVENT", kitty)

    -- probably shouldn't do this
    -- hooking directly under the event system to see how many listeners it has
    local listenerCount = Event._getListenerCount("EXPLOSION_EVENT")
    local passed = PASSED
        and listenerCount == 0

    assert_true(passed, "A listener was not removed when it ignored the message EXPLOSION_EVENT")
end

function test_listenToTwoMessages()
    local kitty = {name = "kitty", sawExplosion = false, heardYell = false}

    function kitty:onEvent(event)
        if event.type == "YELL_EVENT" then
            self.heardYell = true
        elseif event.type == "EXPLOSION_EVENT" then
            self.sawExplosion = true
        end
    end
    -- Frame 1
    Event.update()
    Event.listen("YELL_EVENT", kitty)
    Event.listen("EXPLOSION_EVENT", kitty)


    -- Frame 2
    Event.update()
    Event.send("YELL_EVENT", {position = {x = 0, y = 0, z = 0}, volume = 100})
    Event.send("EXPLOSION_EVENT", {position = {x = 0, y = 0, z = 0}})

    -- Frame 3
    Event.update() -- kitty should have heard a yell and seen an explosion

    local passed = PASSED
        and kitty.heardYell == true
        and kitty.sawExplosion == true
    assert_true(kitty.heardYell, "Kitty didn't hear a yell message")
    assert_true(kitty.sawExplosion, "Kitty didn't see the explosion message")
end

function test_objectSendsMessageInResponseToMessage()
    local kitty = {name = "kitty", positionx = 0, inDanger = true} 
    local puppy = {name = "puppy", sawExplosion = false}

    function kitty:onEvent(event)
        if event.type == "YELL_EVENT" then
            -- move kitty
            -- kitty has good hearing and doesn't care about volume
            self.inDanger = false
            self.positionx = event.arguments.position.x
        end
    end

    function puppy:onEvent(event)
        if event.type == "EXPLOSION_EVENT" then
            Event.send("YELL_EVENT", {position = {x = 100, y = 100, z = 100}, volume = 100})
        end
    end

    -- kitty will listen for a yell
    -- puppy will listen for the explosion and yell out its position of safety

    --Frame 1
    Event.update()
    Event.listen("EXPLOSION_EVENT", puppy)
    Event.listen("YELL_EVENT", kitty)
    
    --Frame 2
    Event.update()
    Event.send("EXPLOSION_EVENT", {position = {x = 0, y = 0, z = 0}})

    --Frame 3
    Event.update() -- puppy should get event notification and send out yell

    --Frame 4
    Event.update() -- kitty should get the yell event

    local passed = PASSED 
        and kitty.inDanger == false

    assert_false(kitty.inDanger, "Kitty didn't get the yell message")
end

function test_sendOneThousandMessagesAllMessagesFreedMemoryUseLessThanOrEqualAfter()
    Event.update()
    collectgarbage()
    local gcBefore = collectgarbage("count")
    for i = 1, 1000 do 
        Event.send("EXPLOSION_EVENT", {position = {x = 0, y = 0, z = 0}})
    end
    Event.update()
    collectgarbage()
    local gcAfter = collectgarbage("count")

    local passed = PASSED
        and gcAfter <= gcBefore

    assert_true(passed, "Memory usage grew by "..(gcAfter - gcBefore).."KB")
end