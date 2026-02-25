-- dial_handler.lua

local DialHandler = {}
DialHandler.__index = DialHandler

function DialHandler.new(dialConfig)
    local self = setmetatable({}, DialHandler)
    self.lastAction = nil
    self.releaseTimer = nil

    return self
end

function DialHandler:handleAction(action)
    if (action == "dial_rotate_left_step" or action == "dial_rotate_left_slow" or action == "dial_rotate_left_fast") then
        self:resetReleaseTimer("left")

        if(self.lastAction ~= "left") then
            C4:FireEvent("When Dial Starts Rotating Left")
            C4:SendToProxy(6, "DO_PUSH", {}, "COMMAND")
            print("SENT LEFT PUSH")
        end

        self.lastAction = "left"
    elseif (action == "dial_rotate_right_step" or action == "dial_rotate_right_slow" or action == "dial_rotate_right_fast") then
        self:resetReleaseTimer("right")

        if(self.lastAction ~= "right") then
            C4:FireEvent("When Dial Starts Rotating Right")
            C4:SendToProxy(5, "DO_PUSH", {}, "COMMAND")
            print("SENT RIGHT PUSH")
        end

        self.lastAction = "right"
    end
end

function DialHandler:resetReleaseTimer(direction)
    print("resetReleaseTimer: " .. direction)

    if (self.releaseTimer ~= nil) then
        self.releaseTimer:Cancel()
        self.releaseTimer = nil

        if(self.lastAction ~= direction) then
            if (self.lastAction == "left") then
                C4:SendToProxy(6, "DO_RELEASE", {}, "COMMAND")
                C4:FireEvent("When Dial Stops Rotating Left")
                print("SENT LEFT RELEASE DUE TO DIRECTION CHANGE")
            elseif (self.lastAction == "right") then
                C4:SendToProxy(5, "DO_RELEASE", {}, "COMMAND")
                C4:FireEvent("When Dial Stops Rotating Right")
                print("SENT RIGHT RELEASE DUE TO DIRECTION CHANGE")
            end

            self.lastAction = "release"
        end
    end

    self.releaseTimer = C4:SetTimer(tonumber(Properties["Dial Release Timeout (in milliseconds)"]), function() self:timerExpired(direction) end)
end

function DialHandler:timerExpired(direction)
    print("DialHandler:timerExpired: " .. direction)

    if (self.releaseTimer ~= nil) then
        if (direction == "left") then
            C4:SendToProxy(6, "DO_RELEASE", {}, "COMMAND")
            C4:FireEvent("When Dial Stops Rotating Left")
            print("SENT LEFT RELEASE TIMER EXPIRED")
        elseif (direction == "right") then
            C4:SendToProxy(5, "DO_RELEASE", {}, "COMMAND")
            C4:FireEvent("When Dial Stops Rotating Right")
            print("SENT RIGHT RELEASE TIMER EXPIRED")
        end

        self.lastAction = "release"
        self.releaseTimer:Cancel()
        self.releaseTimer = nil
    end
end

return DialHandler
