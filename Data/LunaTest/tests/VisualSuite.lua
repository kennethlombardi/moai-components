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

function test__createWindow()
    MOAISim.openWindow("Visual Test", 640, 480)
end

function test_createSimpleScene()
    local layer = Factory.create("Layer2D")
    MOAISim.pushRenderPass(layer)

    gfxQuad = MOAIGfxQuad2D.new ()
    gfxQuad:setTexture ( "Data/Art/moai.png" )
    gfxQuad:setRect ( -64, -64, 64, 64 )

    local mario = Factory.create("Mario")
    mario:setDeck(gfxQuad)
    layer:insertProp(mario)

    mario:moveRot(360, 5)
end