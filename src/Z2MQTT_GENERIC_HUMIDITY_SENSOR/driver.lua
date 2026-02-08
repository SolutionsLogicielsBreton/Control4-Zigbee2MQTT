JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

gAvailableZigbeeDeviceNameToZigbeeId = {}

-- NAME USED FOR LOGGING
gLogName = "Z2MQTT_GENERIC_HUMIDITY_SENSOR"

function ON_DRIVER_LATEINIT.DRIVER (dit)
    C4:AddVariable("HUMIDITY_PERCENT", Properties["Humidity %"] ~= "Unknown" and tonumber(Properties["Humidity %"]) or 0, "NUMBER")
    C4:AddVariable("BATTERY_LEVEL", Properties["Battery Level"] ~= "Unknown" and tonumber(Properties["Battery Level"]) or 0, "NUMBER")

    Dbg:Debug("Driver OnDriverLateInit done.")
end

-- ON BINDING CHANGES
OBC[1] = function (idBinding, strClass, bIsBound, otherDeviceId, otherBindingId)
	Dbg:Debug("OBC.HUMIDITY")

	if(bIsBound and Properties["Humidity %"] ~= "Unknown") then
        C4:SendToProxy(1, "VALUE_INITIALIZE", { VALUE = tonumber(Properties["Humidity %"])})
	end
end

function DEVICE_SYNC.HUMIDITY(humidity)
    if string.lower(tostring(humidity)) ~= string.lower(Properties["Humidity %"]) then
        C4:UpdateProperty("Humidity %", tostring(humidity))

        C4:SetVariable("HUMIDITY_PERCENT", tonumber(humidity))
        C4:FireEvent("When The Humidity % Changes")

        C4:SendToProxy(1, "VALUE_CHANGED", { VALUE = tonumber(humidity)})
    end
end

function DEVICE_SYNC.BATTERY(battery)
    if string.lower(tostring(battery)) ~= string.lower(Properties["Battery Level"]) then
        C4:UpdateProperty("Battery Level", tostring(battery));

        C4:SetVariable("BATTERY_LEVEL", tonumber(battery))
        C4:FireEvent("When The Battery Level Changes")
    end
end

-- CONDITIONALS
function CONDITIONALS.NUMBER_HUMIDITY_PERCENT(tParams)
    if Properties["Humidity %"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Humidity %"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_BATTERY_LEVEL(tParams)
    if Properties["Battery Level"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Battery Level"]), tonumber(strValue))
    else
        return false
    end
end