--[[
    A module that will assist in some inheritance

    Note: Either one of 2 things must be true of super or class
    1) Super must define a :constructor method
    2) once class is returned it must define a :constructor method

    If both of these things are false then the class cannot be created

    TODO: Possibly create a default constructor if one does not exist
]]
local Class = {}

---[[
function Class.create(super)
    local class = {}
    local classMetatable = {__index = class}
    class.super = super

    if super and type(super) == 'table' then
        setmetatable(class, {__index = super})
    end

    function class.new(...)
        local instance = {}
        setmetatable(instance, classMetatable)
        -- initialize our new instance
        instance:constructor(...)
        return instance
    end

    return class
end
--]]

return Class