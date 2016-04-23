--Input system Testing suite

module(..., package.seeall)

function suite_setup()
    Input = require("Input")
end

function suite_teardown()
    Input = nil
end

function setup()
    Input.initialize()
end

function teardown()
    Input.shutdown()
end

function dumbCallback(data)
    print "Dumb callback called"
end

function test_keyCallbackSet()
    Input.registerKeyCallback("testKey", dumbCallback)
    for i=1,10 do
        Input.update(i)
    end

    Input.clearCallback("testKey")
end

function test_mouseCallbackSet()
    Input.registerPointerCallback("testPointer", dumbCallback)
    Input.registerLClickCallback("testLclick", dumbCallback)
    Input.registerRClickCallback("testRclick", dumbCallback)

    for i=1,10 do
        Input.update(i)
    end

    Input.clearCallback("testPointer")
    Input.clearCallback("testLclick")
    Input.clearCallback("testRclick")
end

function test_pauseAndResume()
    Input.registerKeyCallback("testKey", dumbCallback)
    for i=1,10 do
        Input.update(i)
    end

    Input.pauseCallback("testKey")

    for i=1,10 do
        Input.update(i)
    end

    Input.resumeCallback("testKey")

    for i=1,10 do
        Input.update(i)
    end

    Input.clearCallback("testKey")
end

function test_massCallbackRegistration()
    for i=1,100 do
        local name = "testKey" .. i
        Input.registerKeyCallback(name, dumbCallback)
    end
    for i=1,100 do
        Input.update(i)
    end

    for i=1,100 do
        local name = "testKey" .. i
        Input.clearCallback(name)
    end
end
