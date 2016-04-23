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

function test_serializeEntityWithAllKnownTypesOfAttributes()
    local definition = {
        attributes = {
              ["life"] = {type = "NumberAttribute", value = 1},
        },
        components = {
            ["HatComponent"] = 0,
            ["LifeComponent"] = 0,
        },
    }
    definition.attributes = require("AttributeDefinitions")
    --definition.attributes["ViewportAttribute"] = nil
    --definition.attributes["CameraAttribute"] = nil
    local entity = Factory.create("Layer2D", definition)
    local file = io.open(resourceDirectory.."entitySerialized.txt", "wt")
    assert_not_nil(file, "Unable to open test file")
    local context = {tabs = 0, tabSize = 5}
    entity:textSerialize(file, context)
    file:close()
end
