require "States.BaseState"
WalkState = {}

function WalkState:new()
    --local parent = "ReadyState"
    --local from = "ReadyState"
    local state = BaseState:new("WalkState")
    
    function state:onEnterState(event)
        self:reset()
        print("Entered WalkState")
    end
    
    function state:onExitState(event)
    end
    
    function state:tick(time)

    end
    
    function state:reset()
    end
    
    return state
end

return WalkState