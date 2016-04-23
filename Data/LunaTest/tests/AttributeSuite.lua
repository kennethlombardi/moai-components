module(..., package.seeall)

local pickle = require("Pickle").pickle

local PASSED = true
local FAILED = false

local resourceDirectory = "./Data/LunaTest/resources/"
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

function test_assertFactory()
    assert_not_nil(Factory)
end

function test_numberAttribute()
    local attributeDefinition = require("AttributeDefinitions").NumberAttribute
    local entityDefinition = require("EntityDefinitions").Mario
    local entity = Factory.create("Mario")
    local attribute = entity:getAttribute("life")
    assert_not_nil(attribute, "life attribute not present in Mario")
    local number = attribute:getNumber()
    assert_equal(entityDefinition.attributes.life.value, number, "Attribute did not get the default")
end

function test_cameraAttributeBehavesLikeMoaiCamera2D()
    local definition = {
        attributes = {
              ["life"] = {type = "NumberAttribute", value = 1},
        },
        components = {
            ["HatComponent"] = 0,
            ["LifeComponent"] = 0,
            ["CameraTestListenerComponent"] = 0,
        },
    }
    definition.attributes = require("AttributeDefinitions")
    definition.attributes["ViewportAttribute"] = nil -- viewport should only be added to layers
    local entity = Factory.create("Mario", definition)
    local cameraAttribute = entity:getAttribute("CameraAttribute")
    local camera = cameraAttribute:getCamera()
    camera:setLoc(1, 1)
    cameraAttribute:set(camera) -- this trigger should make test listener component set life to life - 1
    local position = {}
    position.x, position.y = camera:getLoc()
    assert_equal(0, entity:getAttribute("life"):getNumber(), "Check if event was triggered")
    assert_equal(1, position.y, "Camera didn't return the correct y position")

    local layer = Factory.create("Layer2D")
    layer:setCamera(camera)
end