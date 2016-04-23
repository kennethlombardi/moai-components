package.path = package.path .. ';./Data/Scripts/?.lua'
local DEVICE_WIDTH = 1280
local DEVICE_HEIGHT = 720

require("Graphics").openWindow("Component", DEVICE_WIDTH, DEVICE_HEIGHT)

local gameLoop = require("gameloop")
mainthread = MOAIThread.new()
mainthread:run(gameLoop)
