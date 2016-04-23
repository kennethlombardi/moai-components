ResourceManager = require('ResourceManager')
ResourceManager.initialize()

local DEVICE_WIDTH = 1280
local DEVICE_HEIGHT = 720

local viewport = MOAIViewport.new()
viewport:setSize(DEVICE_WIDTH, DEVICE_HEIGHT)
viewport:setScale(DEVICE_WIDTH, DEVICE_HEIGHT)


local texture = ResourceManager.load("Texture", "test2.png")

if not texture then
	print("It didn't work, texture was nil")
	return
end
local x,y = texture:getSize()
local deck = MOAIGfxQuad2D:new()
deck:setTexture(texture)
deck:setRect(0, 0, x, y)

local prop = MOAIProp2D:new()
prop:setDeck(deck)
prop:setLoc(0, 0)



local layer = MOAILayer2D:new()
layer:setViewport(viewport)
layer:insertProp(prop)
MOAISim.pushRenderPass(layer)



ResourceManager.shutdown()
