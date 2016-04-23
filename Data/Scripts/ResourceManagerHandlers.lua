-- Contains the basic set of handlers for the resource manager

local handlers = {}

local function MOAITextureHandler(filename)
    local fullpath = string.lower(RM_PATH_TEXTURE .. filename)
    if not MOAIFileSystem.checkFileExists(RM_PATH_TEXTURE .. filename) then
        MOAILogMgr.log("Texture not found at " .. fullpath .. " load failed")
        return nil
    end

    local data = MOAITexture:new()

    data:load(fullpath)

    return data
end

local function MOAIFontHandler(filename)
    local data = MOAIFont:new()
    data:load(RM_PATH_FONT .. filename)

    return data
end

local function TexturePackHandler(packfile)
    local ResourceManager = require('ResourceManager')
    local TexturePack = require('TexturePack')
    local pdata = TexturePack.new()

    --get data from the packfile
    -- wtf global
     local tempData = dofile(RM_PATH_TEXTURE_PACK .. packfile)
     local texture_file = tempData.texture
     local frames = tempData.frames


    --load texture file and get dimensions
    local texture = ResourceManager.load("Texture", texture_file)
    pdata:setTexture( texture )
    local xdim,ydim = texture:getSize()

    --setup the deck
    local deck = MOAIGfxQuadDeck2D.new()
    deck:setTexture(texture)
    deck:reserve(#frames)

    local names = {}
    local sizes = {}
    --grab tpack elements into the deck
    for i, frame in ipairs(frames) do
        local quadCords = {}
        local recCords = {}

        --make the quad cords
        if not frame.textureRotated then
            quadCords.x0 = frame.uvRect.u0
            quadCords.y0 = frame.uvRect.v0
            quadCords.x1 = frame.uvRect.u1
            quadCords.y1 = frame.uvRect.v0
            quadCords.x2 = frame.uvRect.u1
            quadCords.y2 = frame.uvRect.v1
            quadCords.x3 = frame.uvRect.u0
            quadCords.y3 = frame.uvRect.v1
        else    --adjust for rotation too
            quadCords.x3 = frame.uvRect.u0
            quadCords.y3 = frame.uvRect.v0
            quadCords.x0 = frame.uvRect.u1
            quadCords.y0 = frame.uvRect.v0
            quadCords.x1 = frame.uvRect.u1
            quadCords.y1 = frame.uvRect.v1
            quadCords.x2 = frame.uvRect.u0
            quadCords.y2 = frame.uvRect.v1
        end

        deck:setUVQuad( i, quadCords.x0, quadCords.y0, quadCords.x1, quadCords.y1,
            quadCords.x2, quadCords.y2, quadCords.x3, quadCords.y3)

        --make and set rectangle cords
        cRect = frame.spriteColorRect
        deck:setRect( i, cRect.x, cRect.y,
            cRect.x + cRect.width, cRect.y + cRect.height)

        table.insert(names, i, frame.name)
        table.insert(sizes, i, {width = cRect.width, height = cRect.height})
    end

    pdata:setDeck(deck)
    pdata:setNames(names)
    pdata:setSizes(sizes)

    return pdata
end

local function addHandler(typename, func)
	local handler = {}
	handler.typename = string.lower(typename)
	handler.func = func
	table.insert(handlers, handler)
end

addHandler("Texture", MOAITextureHandler)
addHandler("Font", MOAIFontHandler)
addHandler("TexturePack", TexturePackHandler)

return handlers
