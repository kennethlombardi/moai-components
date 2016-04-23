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

function test_testAll()

end