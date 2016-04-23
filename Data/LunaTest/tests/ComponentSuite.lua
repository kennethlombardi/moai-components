module(..., package.seeall)

local pickle = require("Pickle").pickle

local PASSED = true
local FAILED = false

local DT = 0.016

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


function test_simpleTestIntegerNativeTypeStorage()
    -- create a component that has an integer native type underneath
    local component = Factory.create("LifeComponent", 333)
    local value = component:getValue()
    assert_equal(value, 333, "LifeComponent failed to retain value")
end

function test_serializeIntegerNativeType()
    local fullPath = resourceDirectory.."test.txt"
    local file = io.open(fullPath, "wt")
    assert_not_nil(file, "Unable to open file at path "..fullPath)
    local component = Factory.create("LifeComponent", 333.33)
    component:textSerialize(file, {tabs = 0})
    file:close()
    local string = io.open(fullPath, "rt"):read("*all")
    local expected = "[\"LifeComponent\"] = 333.33"
    local passed = string == expected
    assert_equal(string, expected)
end

function test_serializeFloatNativeType()
    local fullPath = resourceDirectory.."test.txt"
    local file = io.open(fullPath, "wt")
    local component = Factory.create("FloatTestComponent", 333.33)
    component:textSerialize(file, {tabs = 0})
    file:close()
    local string = io.open(fullPath, "rt"):read("*all")
    local expected = "[\"FloatTestComponent\"] = 333.33"
    assert_equal(expected, string)
end

function test_serializeTableNativeType()
    local entity = Factory.create("Mario")
    local fullPath = resourceDirectory.."test.txt"
    local file = io.open(fullPath, "wt")
    local component = Factory.create("TableTestComponent", {life = 333.33})
    component:textSerialize(file, {tabs = 0})
    file:close()
    local string = io.open(fullPath, "rt"):read("*all")
    local expected = "[\"TableTestComponent\"] = {\n\tlife = 333.33,\n}"
    assert_equal(expected, string)
end

function test_createLifeComponentNilDefinitionComponentIsReturned()
    local component = Factory.create("LifeComponent")
    assert_not_nil(component, "Failed to create a component")
end

function test_lifeComponentCreation()
    local healthComponent = Factory.create("LifeComponent")
    assert_not_nil(healthComponent, "Factory failed to create healthComponent")
end

function test_lifeComponentUpdate()
    local healthComponent = Factory.create("LifeComponent")
    healthComponent:update(DT)
end

function test_marioSetGetAttribute()
    local mario = Factory.create("Mario", {
        attributes = {
            ["life"]      = {type = "NumberAttribute", value = 1},
            ["extraHats"] = {type = "NumberAttribute", value = 3}
        },
        components = {
            HatComponent = 1,
            LifeComponent = 3,
        }  
    })
    assert_equal(4, mario:getAttribute("life"):set(4):getNumber(), "Attribute life didn't update properly")
    assert_equal(3, mario:getAttribute("extraHats"):getNumber(), "Extrahats attribute wasn't set properly")
    assert_equal(2, mario:getAttribute("extraHats"):set(2):getNumber(), "Extrahats attribute didn't update properly")
end

function test_lifeComponentInMarioOnDamageEvent()
    local mario = Factory.create("Mario", {
        attributes = {
           ["life"]      = {type = "NumberAttribute", value = 1},
        },
        components = {
            HatComponent = 1,
            LifeComponent = 3,
        }  
    })
    assert_not_nil(mario:getComponent("LifeComponent"), "Mario LifeComponent not created or added properly")

    mario:onEvent({type = "TEST_DAMAGE", arguments = {amount = 1}})
    assert_equal(0, mario:getAttribute("life"):getNumber(), "Mario LifeComponent didn't respond to test_DAMAGE message")
end

function test_createComponentUsingDefaultHandler()
    local healthComponent = Factory.create("FloatTestComponent")
end

function test_createEntityWithAllTypesAndTestIfValueOfCameraAttributeIsMoaiCamera2D()
    local definition = {
        attributes = {
        },
        components = {
            ["HatComponent"] = 0,
            ["LifeComponent"] = 0,
        },
    }
    definition.attributes = require("AttributeDefinitions")
    definition.attributes["ViewportAttribute"] = nil
    local entity = Factory.create("Mario", definition)
    local cameraAttribute = entity:getAttribute("CameraAttribute")
    assert_not_nil(cameraAttribute, "Entity did not contain the default CameraAttribute")
    local moaiCamera = cameraAttribute:getCamera()
    assert_not_nil(moaiCamera, "Value of cameraAttribute is nil")
    assert_equal("MOAICamera2D", moaiCamera:getClassName(), "Value of camera attribute is probably not a camera")
end