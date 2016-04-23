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

function test_createEntityReceiveSomeKindOfObjectBack()
    local goomba = Factory.create("Goomba", {["LifeComponent"] = 1})
    local result = PASSED
        and goomba ~= nil

    return assert_true(result, "Factory did not return an object")
end

function test_createGoombaCheckLifeComponentExists()
    local goomba = Factory.create("Goomba", {["LifeComponent"] = 1})
    local result = PASSED
        and goomba:getComponent("LifeComponent") ~= nil

    return assert_true(result, "Life component did not exist")    
end

function test_createGoombaGetLifeComponentValue()
    local definition = 
        {
            attributes = {
                ["life"] = {type = "NumberAttribute", value = 1},
            },
            components = {
                LifeComponent = 333,
            },
        }  
    --definition = require("EntityDefinitions").Goomba
    local goomba = Factory.create("Goomba", definition)
    local value = goomba:getComponent("LifeComponent"):getValue()
    return assert_equal(333, value, "Component didn't retain value after creation")
end

function test_createGoombaWithoutComponentSpecifiedExpectSomeKindOfObjectBack()
    local goomba = Factory.create("Goomba", {})
    local result = PASSED
        and goomba ~= nil
    return assert_true(result, "Default object was not created automatically")
end

function test_createGoombaWithoutComponentDefinitionCheckComponentExists()
    local goomba = Factory.create("Goomba", {})
    local result = PASSED
        and goomba:getComponent("LifeComponent") ~= nil
    local failMessage = "Default object did not correctly create its default components"
    return assert_true(result, failMessage)
end

function test_createGoombaWithNilComponentDefinitionCheckSomeKindOfObjectBack()
    local goomba = Factory.create("Goomba")
    return assert_true(goomba ~= nil, "Returned object is nil")
end

function test_createGoombaWithNilComponentDefinitionCheckComponentExists()
    local goomba = Factory.create("Goomba")
    return assert_true(goomba:getComponent("LifeComponent") ~= nil, "Component wasn't created")
end

function test_createGoombaWithNilComponentDefinitionCheckComponentDefaultExists()
    local goomba = Factory.create("Goomba")
    local componentValue = goomba:getComponent("LifeComponent"):getValue()
    local failMessage = "Default value wasn't correct."
    return assert_equal(0, componentValue, failMessage)
end

function test_createGoombaWithNilComponentDefinitionCheckAllExpectedComponentsExist()
    local goomba = Factory.create("Goomba")
    local entityDefinition = require("EntityDefinitions")["Goomba"]
    local allComponentsExist = true
    for k,v in pairs(entityDefinition.components) do
        local component = goomba:getComponent(k)
        if component == nil then 
            allComponentsExist = false
            break
        end
    end
    return assert_true(allComponentsExist, "All components not created")
end

function test_createKoopaTrooperWithNilComponentDefinitionCheckAllExpectedComponents()
    local trooper = Factory.create("KoopaTrooper")
    local entityDefinition = require("EntityDefinitions")["KoopaTrooper"]
    local allComponentsExist = true
    for k,v in pairs(entityDefinition.components) do
        local component = trooper:getComponent(k)
        if component == nil then 
            allComponentsExist = false
            break
        end
    end
    return assert_true(allComponentsExist, "All components not created")
end

function test_createAllEntitiesExpectSomeKindOfObjectBack()
    local entityDefinitions = require("EntityDefinitions")
    local result = PASSED
    local failEntity = ""

    for k,v in pairs(entityDefinitions) do
        local entity = Factory.create(k,v)
        if entity == nil then 
            result = FAILED
            failEntity = k
            break
        end
    end
    return assert_true(result, failEntity.." failed to create")
end

function test_createAllEntitiesCheckAllComponentsExist()
    local entityDefinitions = require("EntityDefinitions")
    local result = PASSED
    local failEntity = ""

    -- for the entities
    for entityName,definition in pairs(entityDefinitions) do
        local entity = Factory.create(entityName,definition)
        -- for the components in the entity definition make sure entity has component
        for componentName,_ in pairs(definition.components) do
            if entity:getComponent(componentName) == nil then
                failEntity = entityName
                result = FAILED
                break
            end
        end
        if result == FAILED then
            break
        end
    end
    return assert_true(result, "Entity "..failEntity.." failed to create all components")
end

function test_readEntityInFromFileAndCreateAtLeastAnObject()
    function trimWhitespace(s)
      return (s:gsub("^%s*(.-)%s*$", "%1"))
    end

    local function getType(file)
        local type = ""
        local char = file:read(1)
        while char ~= "=" do 
            type = type..char
            char = file:read(1)
            assert_not_nil(char, "Reached end of file trying to get type")
        end 
        type = trimWhitespace(type)
        return type
    end

    local function getDefinition(file)
        local char = ""
        while char ~= "{" do 
            char = file:read(1)
        end
        local definition = char
        local scope = 1
        while scope ~= 0 do 
            char = file:read(1)
            if char == "}" then scope = scope - 1
            elseif char == "{" then scope = scope + 1
            end
            assert_not_nil(char, "Read to end of file looking for entity definition")
            definition = definition..char
        end
        return definition
    end

    local path = resourceDirectory.."SingleGoombaLayer.txt"
    local file = io.open(path)
    local type = getType(file);
    local definition = getDefinition(file);
    local entity = Factory.create(type, loadstring("return"..definition)())
    assert_not_nil(entity, "Factory created a nil object")
    assert_equal("MDProp2D", entity:getClassName(), "Goomba doesn't have the correct class name")
    assert_equal(100, entity:getAttribute("life"):getNumber(), "Goomba doesn't have the correct value for life attribute")
end

function test_readTwoEntitiesFromFileUsingFactoryCreateFromFile()
    function trimWhitespace(s)
        return (s:gsub("^%s*(.-)%s*$", "%1"))
    end

    local path = resourceDirectory.."TwoGoombaLayer.txt"
    file = io.open(path)
    assert_not_nil(file, "Unable to open file "..path)
    local readCount = 0
    local type = ""
    local char = file:read(1)
    while char ~= nil do 
        if char == "=" then
            type = trimWhitespace(type)
            local entity = Factory.createFromFile(type, file)
            assert_not_nil(entity, "Creating of object "..type.." failed")
            type = ""
            readCount = readCount + 1
        else
            type = type..char
        end
        char = file:read(1)
    end
    return assert_true(readCount == 2, "2 objects not created"..readCount)
end

function test_createMarioAndUpdateMarioUpdatesSuperClassAndHimself()
    local mario = Factory.create("Mario")
    for i = 0, 60 do
        mario:update()
    end
end