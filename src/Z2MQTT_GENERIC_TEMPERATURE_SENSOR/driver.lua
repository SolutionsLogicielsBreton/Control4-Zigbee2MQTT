JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

gAvailableZigbeeDeviceNameToZigbeeId = {}

-- NAME USED FOR LOGGING
gLogName = "Z2MQTT_GENERIC_TEMPERATURE_SENSOR"

function ON_DRIVER_LATEINIT.DRIVER (dit)
    C4:AddVariable("TEMPERATURE", Properties["Temperature"] ~= "Unknown" and tonumber(Properties["Temperature"]) or 0, "NUMBER")
    C4:AddVariable("BATTERY_LEVEL", Properties["Battery Level"] ~= "Unknown" and tonumber(Properties["Battery Level"]) or 0, "NUMBER")

    Dbg:Debug("Driver OnDriverLateInit done.")
end

-- ON BINDING CHANGES
OBC[1] = function (idBinding, strClass, bIsBound, otherDeviceId, otherBindingId)
	Dbg:Debug("OBC.TEMPERATURE")

	if(bIsBound and Properties["Temperature"] ~= "Unknown") then
        if(Properties["Temperature Unit"] == "Celsius") then
            C4:SendToProxy(1, "VALUE_INITIALIZE", { CELSIUS = tonumber(Properties["Temperature"])})
        elseif(Properties["Temperature Unit"] == "Fahrenheit") then
            C4:SendToProxy(1, "VALUE_INITIALIZE", { FAHRENHEIT = tonumber(Properties["Temperature"])})
        end
	end
end

-- ON PROPERTY CHANGE
function OPC.Temperature_Unit(temperature_unit)
    C4:FireEvent("When The Temperature Unit Changes")
end

-- EXECUTE COMMANDS
function EX_CMD.SET_TEMPERATURE_UNIT(tParams)
    if string.lower(tostring(tParams["Unit"])) ~= string.lower(Properties["Temperature Unit"]) then
        C4:UpdateProperty("Temperature Unit",  Capitalize(tParams["Unit"]))
        C4:FireEvent("When The Temperature Unit Changes")
    end
end

-- DEVICE STATE UPDATES
function DEVICE_SYNC.TEMPERATURE(temperature)
    if string.lower(tostring(temperature)) ~= string.lower(Properties["Temperature"]) then
        C4:UpdateProperty("Temperature", tostring(temperature))

        C4:SetVariable("TEMPERATURE", tonumber(temperature))
        C4:FireEvent("When The Temperature Changes")

        if(Properties["Temperature Unit"] == "Celsius") then
            C4:SendToProxy(1, "VALUE_CHANGED", { CELSIUS = tonumber(temperature)})
        elseif(Properties["Temperature Unit"] == "Fahrenheit") then
            C4:SendToProxy(1, "VALUE_CHANGED", { FAHRENHEIT = tonumber(temperature)})
        end
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
function CONDITIONALS.NUMBER_TEMPERATURE_LEVEL(tParams)
    if Properties["Temperature"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Temperature"]), tonumber(strValue))
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

function CONDITIONALS.LIST_TEMPERATURE_UNIT(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Temperature Unit"], strValue)
end