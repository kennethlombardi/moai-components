require "States.BaseState"
ParentState = {}

function ParentState:new()
    --local parent = nil
    --local from = ""
    local state = BaseState:new("ParentState", parent, from)
    
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

return ParentState