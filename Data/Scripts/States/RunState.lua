require "States.BaseState"
RunState = {}

function RunState:new()
    --local parent = "WalkState"
    local from = "WalkState"
    local state = BaseState:new("RunState", parent, from)
    
    function state:onEnterState(event)
        self:reset()
        print("Entered RunState")
    end
    
    function state:onExitState(event)
        print("Exit RunState")
    end
    
    function state:tick(time)

    end
    
    function state:reset()
    end
    
    return state
end

return RunState