local m = {}

local Environment = require("Environment")

function m.forceGarbageCollection()
    MOAISim.forceGarbageCollection()
end

function m.getPerformance()
    return MOAISim.getPerformance()
end

function m.getStep()
    return MOAISim.getStep()
end

function m.initialize()
    if Environment.DEBUG then
        m.setHistogramEnabled()
        m.setLeakTrackingEnabled()
    end
end

function m.reportHistogram()
    MOAISim.reportHistogram()
end

function m.reportLeaks()
    MOAISim.reportLeaks()
end

function m.setHistogramEnabled(bool)
    -- MOAISim.setHistogramEnabled(bool)
    -- Find a replacement 1.7 removes this method
end

function m.setLeakTrackingEnabled(bool)
    -- MOAISim.setLeakTrackingEnabled(bool)
    -- Find a replacement 1.7 removes this method
end

function m.setLuaAllocLogEnabled(bool)
    MOAISim.setLuaAllocLogEnabled(bool)
end

function m.shutdown()
    if Environment.DEBUG == true then
        m.reportHistogram()
        m.reportLeaks()
    end
    Environment = nil
end

function m.update(dt)
end

return m
