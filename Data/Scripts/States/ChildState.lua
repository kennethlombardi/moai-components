require "States.BaseState"
ChildState = {}

function ChildState:new()
    local parent = "ParentState"
    local from = "ParentState"
    local state = BaseState:new("ChildState", parent, from)
    
    function state:onEnterState(event)
        self:reset()
    end
    
    function state:onExitState(event)
    end
    
    function state:tick(time)
    end
    
    function state:reset()
    end
    
    return state
end

return ChildState