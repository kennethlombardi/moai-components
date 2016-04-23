--Resource Manager Testing Suite

module(..., package.seeall)

local testTexture = "moai.png"
local testTexturePack = "test2.lua"

function suite_setup()
    ResourceManager = require("ResourceManager")
end

function suite_teardown()
    ResourceManager.shutdown()
    ResourceManager = nil
end

function setup()
    ResourceManager.initialize()
end

function teardown()
    ResourceManager.shutdown()
end

function test_loadATexture()
    local data = ResourceManager.load("Texture", testTexture)
    assert_userdata(data, "Texture failed to load, userdata not returned")
    local width, height = data:getSize()
    assert_gt(0, width, "Width of texture was incorrect, not > 0")
    assert_gt(0, height, "Height of texture was incorrect, not > 0")
end

function test_countIsCorrectlyIncrementedWhenLoadingATexture()
    local elements = ResourceManager.resourceCount()
    local data = ResourceManager.load("Texture", testTexture)

    assert_userdata(data, "Texture failed to load, userdata not returned")
    local width, height = data:getSize()
    assert_gt(0, width, "Width of texture was incorrect, not > 0")
    assert_gt(0, height, "Height of texture was incorrect, not > 0")

    local afterElements = ResourceManager.resourceCount()

    assert_gt(elements, afterElements, "Counting is incorrect, count did not increase after loading")

    data = nil

    ResourceManager.flush()

    elements = ResourceManager.resourceCount()
    assert_lt(afterElements, elements, "Count did not decrease after flushing cache")
end

function test_handlesInvalidTypename()
    local data = ResourceManager.load("ThisDoesNotExist", testTexture)
    assert_nil(data, "Something not nil was returned, nothing should have loaded")
end

function test_handleInvalidTextureFilename()
    local data = ResourceManager.load("Texture", "derp.png")
    assert_nil(data, "Something not nil was returned, nothing should have loaded")
end

function test_weakTableGarbageCollectionWithTexture()
    local elements = ResourceManager.resourceCount()
    assert_equal(elements, 0, "Fresh cache was not empty")

    local data = ResourceManager.load("Texture", testTexture)
    assert_userdata(data, "Texture failed to load, userdata not returned")
    local width, height = data:getSize()
    assert_gt(0, width, "Width of texture was incorrect, not > 0")
    assert_gt(0, height, "Height of texture was incorrect, not > 0")

    elements = ResourceManager.resourceCount()
    assert_equal(elements, 1, "Texture not showing in cache")

    collectgarbage()
    elements = ResourceManager.resourceCount()
    assert_equal(elements, 1, "Texture was garbage collected when it shouldn't be")

    data = nil
    collectgarbage()

    elements = ResourceManager.resourceCount()
    assert_equal(elements, 0, "texture was not garbage collected")

end

function test_holdProtectsAgainstGarbageCollection()
    local elements = ResourceManager.resourceCount()
    assert_equal(elements, 0, "Fresh cache was not empty")

    local data = ResourceManager.loadAndHold("Texture", testTexture)
    assert_userdata(data, "Texture failed to load, userdata not returned")
    local width, height = data:getSize()
    assert_gt(0, width, "Width of texture was incorrect, not > 0")
    assert_gt(0, height, "Height of texture was incorrect, not > 0")

    elements = ResourceManager.resourceCount()
    assert_equal(elements, 1, "Texture not showing in cache")

    collectgarbage()
    elements = ResourceManager.resourceCount()
    assert_equal(elements, 1, "Texture was garbage collected when it shouldn't be")

    data = nil
    collectgarbage()

    elements = ResourceManager.resourceCount()
    assert_equal(elements, 1, "Texture was garbage collected when it shouldn't be")

    ResourceManager.releaseHold("Texture", testTexture)
    collectgarbage()

    elements = ResourceManager.resourceCount()
    assert_equal(elements, 0, "texture was not garbage collected")
end

function test_texturePackLoadingAndMethods()
    local data = ResourceManager.load("TexturePack", testTexturePack)
    assert_table(data, "A table was not returned for a texture pack load")

    assert_userdata(data:getDeck(), "A deck wasn't found in pack")
    local texture = data:getTexture()
    assert_userdata(texture, "TexturePack texture was incorrect")

    local width, height = texture:getSize()
    assert_gt(0, width, "Width of texture was incorrect, not > 0")
    assert_gt(0, height, "Height of texture was incorrect, not > 0")

    local sizes = data:getSizes()
    assert_table(sizes, "Sizes should be a table")
    assert_gt(0, #sizes, "Sizes should have some elements")

    local names = data:getNames()
    assert_table(names, "Names should be a table")
    assert_gt(0, #names, "Names should have some elements")

    for i, name in ipairs(names) do
        local index = data:getIndex(name)
        assert_equal(i, index, "Index didn't match for a name")
    end

    for i in ipairs(names) do
        local sizeWidth, sizeHeight = data:getSize(i)
        assert_gt(0, sizeWidth, "Width of texture was incorrect, not > 0")
        assert_gt(0, sizeHeight, "Height of texture was incorrect, not > 0")
    end
end
