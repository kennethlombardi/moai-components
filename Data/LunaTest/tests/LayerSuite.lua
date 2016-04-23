module(..., package.seeall)

local pickle = require("Pickle").pickle

local PASSED = true
local FAILED = false

local DT = 0.0167

local testDirectory = "./Data/Scripts/Test/"
function passResult()
end

local function START_THE_REACTOR()
    Factory.initialize()
end

local function STOP_THE_REACTOR()
    Factory.shutdown()
end

local function RESTART_THE_REACTOR()
    STOP_THE_REACTOR()
    Factory = require("Factory")
    START_THE_REACTOR()
end

function suite_setup()
    Factory = require("Factory")
end

function setup()
   RESTART_THE_REACTOR()
end

function test_createLayer()
    local definition = require("EntityDefinitions").Layer2D
    local layer = Factory.create("Layer2D", definition)
    assert_not_nil(layer, "Layer2D wasn't created")
end

function test_updateLayerUsingLayerTestComponentTriggersVisibilityAttributeFalse()
    local definition = require("EntityDefinitions").Layer2D
    local layer = Factory.create("Layer2D", definition)
    for i = 1, 60 do 
        layer:update(DT)
    end
    assert_equal(false, layer:getAttribute("visible"):getBool(), "LayerTestComponent didn't trigger invisible state after 1 second")
end