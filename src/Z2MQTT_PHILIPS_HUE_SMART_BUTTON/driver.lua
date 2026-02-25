JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

gLastAction = nil

function ON_DRIVER_LATEINIT.DRIVER (dit)
    C4:AddVariable("BATTERY_LEVEL", Properties["Battery Level"] ~= "Unknown" and tonumber(Properties["Battery Level"]) or 0, "NUMBER")
    Dbg:Debug("Driver OnDriverLateInit done.")
end

function DEVICE_SYNC.BATTERY(battery)
    if string.lower(tostring(battery)) ~= string.lower(Properties["Battery Level"]) then
        C4:UpdateProperty("Battery Level", tostring(battery));

        C4:SetVariable("BATTERY_LEVEL", tonumber(battery))
        C4:FireEvent("When The Battery Level Changes")
    end
end

function DEVICE_SYNC.ACTION(action)
    action = string.lower(action)

    if (gLastAction ~= action and action == "press") then
        gLastAction = action
        C4:FireEvent("When Button Is Pressed")
        C4:SendToProxy(1, "DO_PUSH", {}, "COMMAND")
    elseif (gLastAction ~= action and action == "release") then
        gLastAction = action
        C4:FireEvent("When Button Is Released")
        C4:SendToProxy(1, "DO_RELEASE", {}, "COMMAND")
    elseif (gLastAction ~= action and action == "hold") then
        gLastAction = action
        C4:FireEvent("When Button Is Held")
    elseif (gLastAction ~= "CLICK" and (action == "on" or action == "off")) then
        gLastAction = "CLICK"
        C4:FireEvent("When Button Is Clicked")
        C4:SendToProxy(1, "DO_CLICK", {}, "COMMAND")
    end
end

-- CONDITIONALS
function CONDITIONALS.NUMBER_BATTERY_LEVEL(tParams)
    if Properties["Battery Level"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Battery Level"]), tonumber(strValue))
    else
        return false
    end
end