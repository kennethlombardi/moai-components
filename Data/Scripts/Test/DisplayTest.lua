local Factory = require("Factory")
local pickle = require("Pickle").pickle

local PASSED = true
local FAILED = false

local testDirectory = "./Data/Scripts/Test/"

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

local function passResult(result, failMessage, passMessage)
    if result == true then
        return PASSED, passMessage
    elseif result == false then
        return FAILED, failMessage
    end
end

local function asdf() end

local function getTest(name, func)
    return {name = name, func = func}
end

local battery = {}
local function _(x, y)
    table.insert(battery, getTest(x, y))
end

_("asdf", 
    asdf)
_("asdf", 
    asdf)
_("asdf", 
    asdf)
_("asdf", 
    asdf)
_("asdf", 
    asdf)
_("asdf", 
    asdf)
_("asdf", 
    asdf)
_("asdf", 
    asdf)
_("asdf", 
    asdf)
_("asdf", 
    asdf)
_("asdf", 
    asdf)


START_THE_REACTOR()
for k,func in pairs(battery) do
    local result, message = func.func()
    if result == PASSED then
        print("PASSED", func.name)
    elseif result == FAILED then
        print("!!!!!!!!FAILED", func.name, "\n\tMessage: ", message)
    end
    RESTART_THE_REACTOR()
end
STOP_THE_REACTOR()