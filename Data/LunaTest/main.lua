package.path = "Data/LunaTest/?.lua;"..package.path 
package.path = "Data/?.lua;"..package.path
package.path = "Data/Scripts/?.lua;"..package.path

function runUnitTestSuite()
	require "testsmain"
end

runUnitTestSuite()