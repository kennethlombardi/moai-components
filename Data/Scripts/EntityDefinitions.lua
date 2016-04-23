local _ = "DEFAULT"

require("Props.MDProp2D")
require("Props.MDLayer2D")

local definitions = 
{

Goomba = 
{
    attributes = {
        ["life"] = {type = "NumberAttribute", value = 1},
    },
    components = {
        LifeComponent = 1,
    },
},

Mario = 
{
    attributes = {
        ["life"] = {type = "NumberAttribute", value = 1},
    },
    components = {
        HatComponent = 1,
        LifeComponent = 3,
    }
},

KoopaTrooper = 
{
    attributes = {
        ["life"] = {type = "NumberAttribute", value = 1},
    },
    components = {
        LifeComponent = _,
    }
},

Layer2D =
{
    attributes = {
        ["visible"] = {type = "BoolAttribute", value = true},
        ["viewport"] = {type = "ViewportAttribute"},
        ["camera"] = {type = "CameraAttribute"}
    },
    components = {
        LayerTestComponent = _,
    }
},

}

return definitions