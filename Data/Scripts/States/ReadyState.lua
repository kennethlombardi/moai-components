require "States.BaseState"
ReadyState = {}

function ReadyState:new()
    --local parent = nil
    local from = "WalkState"
    local state = BaseState:new("ReadyState", parent, from)
    
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

return ReadyState