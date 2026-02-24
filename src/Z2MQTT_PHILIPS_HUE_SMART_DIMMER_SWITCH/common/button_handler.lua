-- button_handler.lua

local ButtonHandler = {}
ButtonHandler.__index = ButtonHandler

function ButtonHandler.new(buttonConfig)
    local self = setmetatable({}, ButtonHandler)

    self.buttonId = buttonConfig.id
    self.pressEvent = buttonConfig.pressEvent
    self.releaseEvent = buttonConfig.releaseEvent
    self.holdReleaseEvent = buttonConfig.holdReleaseEvent
    self.holdEvent = buttonConfig.holdEvent

    self.lastAction = nil
    self.clickTimer = nil

    return self
end

function ButtonHandler:handleAction(action)
    action = string.lower(action)

    if (self.lastAction ~= action and action == "press") then
        self.lastAction = action
        C4:FireEvent(self.pressEvent)
        self:resetClickTimer()
    elseif (self.lastAction ~= action and action == "press_release") then
        self.lastAction = action
        C4:FireEvent(self.releaseEvent)

        if(self.clickTimer ~= nil) then
            self:cancelClickTimer()
            C4:SendToProxy(self.buttonId, "DO_CLICK", {}, "COMMAND")
        else
            C4:SendToProxy(self.buttonId, "DO_RELEASE", {}, "COMMAND")
        end
    elseif (self.lastAction ~= action and action == "hold_release") then
        self.lastAction = action
        C4:FireEvent(self.holdReleaseEvent)
        C4:SendToProxy(self.buttonId, "DO_RELEASE", {}, "COMMAND")
    elseif (self.lastAction ~= action and action == "hold") then
        self.lastAction = action
        self:cancelClickTimer()
        C4:FireEvent(self.holdEvent)
    end
end

function ButtonHandler:resetClickTimer()
    if(self.clickTimer ~= nil) then
        self.clickTimer:Cancel()
        self.clickTimer = nil
    end

    self.clickTimer = C4:SetTimer(250, function() self:timerExpired() end)
end

function ButtonHandler:cancelClickTimer()
    if(self.clickTimer ~= nil) then
        self.clickTimer:Cancel()
        self.clickTimer = nil
    end
end

function ButtonHandler:timerExpired()
    if(self.clickTimer ~= nil) then
        C4:SendToProxy(self.buttonId, "DO_PUSH", {}, "COMMAND")
        self.clickTimer:Cancel()
        self.clickTimer = nil
    end
end

return ButtonHandler
