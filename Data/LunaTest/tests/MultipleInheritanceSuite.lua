module(..., package.seeall)

local pickle = require("Pickle").pickle

local PASSED = true
local FAILED = false

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


function test_goombaKoopaMarioTypeNamesCorrect()
    layer = MOAILayer2D.new ()
    --[[
    viewport = MOAIViewport.new ()
    viewport:setSize ( 320, 480 )
    viewport:setScale ( 320, -480 )

    layer = MOAILayer2D.new ()
    layer:setViewport ( viewport )
    MOAISim.pushRenderPass ( layer )

    gfxQuad = MOAIGfxQuad2D.new ()
    gfxQuad:setTexture ( "Data/Art/moai.png" )
    gfxQuad:setRect ( -64, -64, 64, 64 )
    gfxQuad:setUVRect ( 0, 0, 1, 1 )
--]]

    local goomba = Factory.create("Goomba")
    local koopa = Factory.create("KoopaTrooper")
    local mario = Factory.create("Mario")

    goomba:setLoc(100, 0)
    goomba:setDeck ( gfxQuad )
    layer:insertProp ( goomba )

    goomba:moveRot ( 360, 1.5 )
    assert_equal("MDProp2D", goomba:getClassName(), "Goomba class name incorrect")
    assert_equal("MDProp2D", koopa:getClassName(), "KoopaTrooper class name incorrect")
    assert_equal("MDProp2D", mario:getClassName(), "Mario class name incorrect")
end

function test_marioLoopUpdateNoCrash()
    local mario = Factory.create("Mario")
    assert_true(mario ~= nil, "Factory returned a bad object")
    for i = 1, 100 do mario:update(0.0167) end
end

function test_createTwoMariosAndCheckForSharedData()
    local mario1 = Factory.create("Mario", {
        attributes = {
            ["life"] = {type = "NumberAttribute", value = 2},
            ["life2"] = {type = "TableAttribute", value = {position = {x = 0, y = 0, z = 0}}},
        },
        components = {
            HatComponent = 1,
            LifeComponent = 3,
        } 
    })
    local mario2 = Factory.create("Mario", {
        attributes = {
            ["life"] = {type = "NumberAttribute", value = 3},
            ["life2"] = {type = "TableAttribute", value = {position = {x = 1, y = 0, z = 0}}},
        },
        components = {
            HatComponent = 1,
            LifeComponent = 3,
        } 
    })
    local mario1attribute = mario1:getAttribute("life"):getNumber()
    local mario2attribute = mario2:getAttribute("life"):getNumber()
    assert_gt(mario1attribute, mario2attribute, "Marios ended up sharing life data")
    assert_equal(2, mario1attribute, "Mario 1 didn't have expected attribute")
    assert_equal(3, mario2attribute, "Mario 2 didn't have expected attribute")
end

function test_canCreateMDLayer()
    require("Props.MDLayer2D")
    local layer = MDLayer2D.new()
    assert_not_nil(layer, "Layer wasn't created")
end

function test_MDLayerConstructor()
    require("Props.MDLayer2D")
    local layer = MDLayer2D.new():constructor()
end

function test_MDLayerCanHaveMDPropAddedToIt()
    require("Props.MDLayer2D")
    local layer = MDLayer2D.new():constructor()
    local mario = Factory.create("Mario")
    layer:insertProp(mario)
end

function test_LayerCanGetPartition()
    require("Props.MDLayer2D")
    local layer = MDLayer2D.new():constructor()
    local mario = Factory.create("Mario")
    layer:insertProp(mario)
    assert_not_nil(layer:getPartition(), "Layer didn't create its partition by default")
end

function test_CreateLayerFromFactoryAndAddPropToLayer()
    require("Props.MDLayer2D")
    local layer = Factory.create("Layer2D")
    local mario = Factory.create("Mario")
    layer:insertProp(mario)
end

function test_createAttributesAutomatically()
    local definition = {
        attributes = {
            ["life"] = {type = "NumberAttribute", value = 1},
        },
        components = {
            HatComponent = 1,
            LifeComponent = 3,
        } 
    }
    local entity = Factory.create("Layer2D", definition)
    assert_not_nil(entity:getAttribute("visible"):getBool(), "Attribute not created automatically")
end