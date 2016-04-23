
pcall(require, "luacov")    --measure code coverage, if luacov is present
require "lunatest"

local function addTest(suite)
    lunatest.suite(suite)
    local message = "-- Running "..suite.." Tests --"
    local header = ""
    for i = 0, #message do
        header = header.."-"
    end
    print(header)
    print(message)
    print(header)
end

addTest("tests.StateMachineSuite")
addTest("tests.EventSuite")
addTest("tests.MultipleInheritanceSuite")
addTest("tests.FactorySuite")
addTest("tests.ComponentSuite")
addTest("tests.LayerSuite")
addTest("tests.AttributeSuite")
addTest("tests.SerializationSuite")
addTest("tests.ResourceManagerSuite")
addTest("tests.VisualSuite")
lunatest.run()
