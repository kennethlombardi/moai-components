module(..., package.seeall)

function suite_setup()
    require "States.State"
    require "StateMachine2"
    require "States.BaseState"
    Factory = require("Factory")
end

function setup()
    machine = StateMachine:new()
    Factory.shutdown()
    Factory = require("Factory")
end

function test_classWorks()
    assert_not_nil(machine)
end


function test_verifyInitialStateIsNil()
    assert_nil(machine.state)
end

function test_verifyInitialStateIsNullWithStates()
    local initial = "playing"
    machine:addState(initial)
    machine:addState("stopped")
    assert_nil(machine.state)
end

function test_verifyInitialStateIsNotNil()
    local initial = "playing"
    machine:addState(initial)
    machine:addState("stopped")
    machine:setInitialState(initial)
    assert_equal(initial, machine.state)
end

function test_enter()
    local t = {}
    local hitCallback = false
    function t.onPlayingEnter(event)
        assert_equal(event.toState, "playing")
        assert_equal(event.fromState, "idle")
        hitCallback = true
    end
    machine:addState("idle")
    machine:addState("playing", { enter = t.onPlayingEnter, from="*"})
    machine:setInitialState("idle")
    assert_true(machine:canChangeStateTo("playing"), "Not alowed to change to state playing.")
    assert_true(machine:changeState("playing"))
    assert_equal("playing", machine.state)
    assert_true(hitCallback, "Didn't hit the onPlayingEnter callback.")
end

function test_preventInitialOnEnterEvent()
    local t = {}
    local hitCallback = false
    function t.onPlayingEnter(event)
        hitCallback = true
    end
    machine:addState("idle")
    machine:addState("playing", { enter = t.onPlayingEnter, from="*"})
    machine:setInitialState("idle")
    assert_false(hitCallback, "Hit the callback when I had no initial state set.")
end

function test_exit()
    local t = {}
    local hitCallback = false
    function t.onPlayingExit(event)
        hitCallback = true
    end
    machine:addState("idle", {exit = t.onPlayingExit})
    machine:addState("playing", {from="*"})
    machine:setInitialState("idle")
    machine:changeState("playing")
    assert_true(hitCallback, "Never called onPlayingExit.")
end

function test_ensurePathAcceptable()
    machine:addState("prone")
    machine:addState("standing", {from="*"})
    machine:addState("running", {from={"standing"}})
    machine:setInitialState("standing")
    assert_true(machine:changeState("running"), "Failed to ensure correct path.")
end

function test_ensurePathUnacceptable()
    machine:addState("prone")
    machine:addState("standing", {from="*"})
    machine:addState("running", {from={"standing"}})
    machine:setInitialState("prone")
    assert_false(machine:changeState("running"), "Failed to ensure correct path.")
end

function test_hierarchical()
    local t = {}
    local calledonAttack = false
    local calledOnMeleeAttack = false
    function t.onAttack(event)
        calledonAttack = true
    end

    function t.onMeleeAttack(event)
        calledOnMeleeAttack = true
    end

    machine:addState("idle", {from="*"})
    machine:addState("attack",{from = "idle", enter = t.onAttack})
    machine:addState("melee attack", {parent = "attack", from = "attack", enter = t.onMeleeAttack})
    machine:addState("smash",{parent = "melee attack", enter = t.onSmash})
    machine:addState("missle attack",{parent = "attack", enter = onMissle})

    machine:setInitialState("idle")

    assert_true(machine:canChangeStateTo("attack"), "Cannot change to state attack from idle!?")
    assert_false(machine:canChangeStateTo("melee attack"), "Somehow we're allowed to change to melee attack even though we're not in the attack base state.")
    assert_false(machine:changeState("melee attack"), "We're somehow allowed to bypass the attack state and go straigt into the melee attack state.")
    assert_true(machine:changeState("attack"), "We're not allowed to go to the attack state from the idle state?")
    assert_false(machine:canChangeStateTo("attack"), "We're allowed to change to a state we're already in?")
    assert_true(machine:canChangeStateTo("melee attack"), "We're not allowed to go to our child state melee attack from attack?")
    assert_true(machine:changeState("melee attack"), "I don't get it, we're in the parent attack state, why can't we change?")
    assert_true(machine:canChangeStateTo("smash"), "We're not allowed to go to our smash child state from our parent melee attack state?")

    assert_true(machine:canChangeStateTo("attack"), "We're not allowed to go back to our parent attack state?")
    assert_true(machine:changeState("smash"), "We're not allowed to actually change state to our smash child state.")
    assert_false(machine:changeState("attack"))
    assert_true(machine:changeState("melee attack"))
    assert_true(machine:canChangeStateTo("attack"))
    assert_true(machine:canChangeStateTo("smash"))
    assert_true(machine:changeState("attack"))
end

function test_classBasedAddStateNoCrash()
    local entity = {}
    function entity:asdf() end
    machine = StateMachine:new(entity)
    require("States.ReadyState")
    require("States.WalkState")
    machine:addState2(ReadyState:new())
    machine:addState2(WalkState:new())
    machine:setInitialState("ReadyState")

    assert_false(machine:canChangeStateTo("ReadyState"), "Should already be in ReadyState")
    assert_true(machine:canChangeStateTo("WalkState"), "Should be able to get to WalkState")
end

function test_runToReadyFail()
    local entity = {}
    machine = StateMachine:new(entity)
    require("States.ReadyState")
    require("States.WalkState")
    require("States.RunState")
    machine:addState2(ReadyState:new())
    machine:addState2(WalkState:new())
    machine:addState2(RunState:new())
    machine:setInitialState("ReadyState")

    local function testBeingInReadyState()
        assert_false(machine:canChangeStateTo("RunState"), "Should not be able to reach run state from ReadyState")
        assert_true(machine:canChangeStateTo("WalkState"), "Should be able to change state to WalkState from ReadyState")
    end

    local function testBeingInWalkState()
        assert_false(machine:canChangeStateTo("WalkState"), "Should not be able to move from WalkState to WalkState")
        assert_true(machine:canChangeStateTo("ReadyState"), "Should be able to reach ReadyState from WalkState")
        assert_true(machine:canChangeStateTo("RunState"), "Should be able to reach RunState from WalkState")
    end

    local function testBeingInRunState()
        assert_false(machine:canChangeStateTo("RunState"), "Should not be able to move from RunState to RunState")
        assert_true(machine:canChangeStateTo("WalkState"), "Should be able to move from RunState to WalkState")
        assert_false(machine:canChangeStateTo("ReadyState"), "Should not be able to move from RunState to ReadyState")
    end

    testBeingInReadyState()
    machine:changeStateToAtNextTick("WalkState")
    machine:tick()

    testBeingInWalkState()
    machine:changeStateToAtNextTick("RunState")
    machine:tick()

    testBeingInRunState()
    machine:changeStateToAtNextTick("WalkState")
    machine:tick()

    testBeingInWalkState()
    machine:changeStateToAtNextTick("ReadyState")
    machine:tick()

    testBeingInReadyState()

end

function test_parentToChildThenBackToParent()
    require("States.ChildState")
    require("States.ParentState")
    local entity = MOAIProp2D.new()
    machine = StateMachine:new(entity)
    machine:addState2(ParentState:new())
    machine:addState2(ChildState:new())

    machine:setInitialState("ParentState")
    assert_true(machine:canChangeStateTo("ChildState"), "Should be able to change from ParentState to ChildState")
    machine:changeState("ChildState")
    assert_true(not machine:canChangeStateTo("ChildState"), "Shouldn't be able to change from ChildState to ChildState")
    assert_true(machine:canChangeStateTo("ParentState"), "Why can't I go from child to parent?")
    machine:changeState("ParentState")
end
