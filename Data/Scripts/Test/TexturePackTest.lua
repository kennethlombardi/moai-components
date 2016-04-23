local ResourceManager = require('ResourceManager')

ResourceManager.initialize()

MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_MODEL_BOUNDS, 2, 1, 1, 1 )
MOAIDebugLines.setStyle ( MOAIDebugLines.PROP_WORLD_BOUNDS, 1, 0.5, 0.5, 0.5 )

print ("Starting TexturePack test")
local tpack = ResourceManager.load("TexturePack", "test2.lua")

print ("Loaded pack with textures: ")
for i, v in ipairs(tpack:getNames()) do
    print (i, v)
end

local DEVICE_WIDTH = 1280
local DEVICE_HEIGHT = 720

local viewport = MOAIViewport.new()
viewport:setSize(DEVICE_WIDTH, DEVICE_HEIGHT)
viewport:setScale(DEVICE_WIDTH, DEVICE_HEIGHT)

local prop1Index = 1
local PADDING = 32
local prop1 = MOAIProp2D:new()
prop1:setDeck(tpack:getDeck())
prop1:setIndex(prop1Index)
prop1:setLoc(0, 0)

local width1, height1 = tpack:getSize(prop1Index)
local prop2 = MOAIProp2D:new()
prop2:setDeck(tpack:getDeck())
prop2:setIndex(prop1Index + 1)
prop2:setLoc(width1 + PADDING, 0)

local layer = MOAILayer2D:new()
layer:setViewport(viewport)
layer:insertProp(prop1)
layer:insertProp(prop2)
MOAISim.pushRenderPass(layer)

ResourceManager.shutdown()

