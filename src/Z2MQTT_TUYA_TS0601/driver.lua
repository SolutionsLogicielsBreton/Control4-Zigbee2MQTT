JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

gAvailableZigbeeDeviceNameToZigbeeId = {}

-- NAME USED FOR LOGGING
gLogName = "Z2MQTT_TUYA_TS0601"

function ON_DRIVER_LATEINIT.DRIVER (dit)
    C4:AddVariable("TEMPERATURE", Properties["Temperature"] ~= "Unknown" and tonumber(Properties["Temperature"]) or 0, "NUMBER")
    C4:AddVariable("HUMIDITY_PERCENT", Properties["Humidity %"] ~= "Unknown" and tonumber(Properties["Humidity %"]) or 0, "NUMBER")
    C4:AddVariable("BATTERY_STATE", Properties["Battery State"], "STRING")

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

OBC[2] = function (idBinding, strClass, bIsBound, otherDeviceId, otherBindingId)
	Dbg:Debug("OBC.HUMIDITY")

	if(bIsBound and Properties["Humidity %"] ~= "Unknown") then
        C4:SendToProxy(2, "VALUE_INITIALIZE", { VALUE = tonumber(Properties["Humidity %"])})
	end
end

-- ON PROPERTY CHANGE
function OPC.Temperature_Unit(temperature_unit)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["temperature_unit"] = string.lower(temperature_unit)}) })
    end
end

-- EXECUTE COMMANDS
function EX_CMD.SET_TEMPERATURE_UNIT(tParams)
    OPC.Temperature_Unit(tParams["Unit"])
end

-- DEVICE STATE UPDATES
function DEVICE_SYNC.TEMPERATURE_UNIT(temperature_unit)
    C4:UpdateProperty("Temperature Unit",  Capitalize(temperature_unit));

    if string.lower(tostring(temperature_unit)) ~= string.lower(Properties["Temperature Unit"]) then
        C4:FireEvent("When The Temperature Unit Changes")
    end
end

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

function DEVICE_SYNC.HUMIDITY(humidity)
    if string.lower(tostring(humidity)) ~= string.lower(Properties["Humidity %"]) then
        C4:UpdateProperty("Humidity %", tostring(humidity))

        C4:SetVariable("HUMIDITY_PERCENT", tonumber(humidity))
        C4:FireEvent("When The Humidity % Changes")

        C4:SendToProxy(2, "VALUE_CHANGED", { VALUE = tonumber(humidity)})
    end
end

function DEVICE_SYNC.BATTERY_STATE(battery_state)
    if string.lower(tostring(battery_state)) ~= string.lower(Properties["Battery State"]) then
        C4:UpdateProperty("Battery State", Capitalize(battery_state))

        C4:SetVariable("BATTERY_STATE", Capitalize(battery_state))
        C4:FireEvent("When The Battery State Changes")
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

function CONDITIONALS.NUMBER_HUMIDITY_PERCENT(tParams)
    if Properties["Humidity %"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Humidity %"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.LIST_BATTERY_STATE(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Battery State"], strValue)
end

function CONDITIONALS.LIST_TEMPERATURE_UNIT(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Temperature Unit"], strValue)
end