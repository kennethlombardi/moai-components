local Class = require("Class")

local TexturePack = Class.create()
function TexturePack:constructor(texture, deck, names, sizes)
    self.texture = texture
    self.deck = deck
    if names then
        for i, v in ipairs(names) do
            self.names[i] = names[i]
        end
    else
        self.names = {}
    end

    if sizes then
        for i, v in ipairs(sizes) do
            self.sizes[i].width = sizes[i].width
            self.sizes[i].height = sizes[i].height
        end
    else
        self.sizes = {}
    end
end


function TexturePack:getDeck()
    return self.deck
end

function TexturePack:getTexture()
    return self.texture
end

function TexturePack:getNames()
    return self.names
end

function TexturePack:getSizes()
    return self.sizes
end

function TexturePack:setDeck(deck)
    self.deck = deck
end

function TexturePack:setTexture(texture)
    self.texture = texture
end

function TexturePack:setNames(names)
    for i, v in ipairs(names) do
        self.names[i] = names[i]
    end
end

function TexturePack:setSizes(sizes)
    for i, v in ipairs(sizes) do
        local width = sizes[i].width
        local height = sizes[i].height
        self.sizes[i] = {width = width, height = height}
    end
end

function TexturePack:getIndex(name)
    for i, v in ipairs(self.names) do
        if v == name then
            return i
        end
    end

    return
end

function TexturePack:getSize(index)
    return self.sizes[index].width, self.sizes[index].height
end

return TexturePack