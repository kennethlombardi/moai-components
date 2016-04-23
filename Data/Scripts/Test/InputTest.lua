inputSystem = require('Input')
print "Starting input system test."
print "----------------------------\n"
if not inputSystem then
    print "Input system reference not passed, value was nil"
    print "TEST FAILED!\n"
    return
end

if not inputSystem.is_initialized() then
    print "System not initialized, running init"
    inputSystem.initialize()
end

print "System is initiialized\n"

local function inputTestLoop (inputSystem)

local keyOK = false
local pointerOK = false
local lclickOK = false
local rclickOK = false

local exitTest = false

local function keyTestCB(data)
    print "keyTestCB"
    for k,v in pairs(data) do
        print (k,v)
    end

    keyOK = true
    print (keyOK)
end

local function pointerTestCB (data)
    print "pointTestCB"
    for k,v in pairs(data) do
        print (k,v)
    end
    pointerOK = true
end

local function lclickTestCB(data)
    print "lclickTestCB"
    for k,v in pairs(data) do
        print (k,v)
    end

    lclickOK = true
end

local function rclickTestCB(data)
    print "rclickTestCB"
    for k,v in pairs(data) do
        print (k,v)
    end

    rclickOK = true
end

local function testSkip(data)
    if data.type == "keyboard" and data.key == 32 then
        print "Ending test early"
        keyOK = true
        pointerOK = true
        lclickOK = true
        rclickOK = true
    end
end



print "Registering callbacks"

inputSystem.registerKeyCallback("testKey", keyTestCB)
inputSystem.registerPointerCallback("testPoint", pointerTestCB)
inputSystem.registerLClickCallback("testLclick", lclickTestCB)
inputSystem.registerRClickCallback("testRclick", rclickTestCB)
inputSystem.registerKeyCallback("testSkip", testSkip)

print "Use the keyboard, pointer, left click, and right click to test callbacks"
print "Press Space to leave early"


print "Test loop started"

local keyDone = false
local pDone = false
local lDone = false
local rDone = false

while not exitTest do
    if keyOK and not keyDone then
        inputSystem.clearCallback("testKey")
        print "Keyboard Callback Test passed, clearing it"
        keyDone = true
    end

    if pointerOK and not pDone then
        inputSystem.clearCallback("testPoint")
        print "Pointer callback test passed, clearing it"
        pDone = true
    end

    if lclickOK and not lDone then
        inputSystem.clearCallback("testLclick")
        print "Left click callback test passed, clearing it"
        lDone = true
    end

    if rclickOK and not rDone then
        inputSystem.clearCallback("testRclick")
        print "Right click callback test passed, clearing it"
        rDone = true
    end

    if keyDone and pDone and lDone and rDone then
        print "All callback tests passed, Input looks OK\n"
        exitTest = true
    end

    coroutine.yield()
end

inputSystem.clearCallback("testSkip")
end

local testThread = MOAIThread.new()
testThread:run(inputTestLoop, inputSystem)


print "END INPUT TEST"
print "------------------------\n"