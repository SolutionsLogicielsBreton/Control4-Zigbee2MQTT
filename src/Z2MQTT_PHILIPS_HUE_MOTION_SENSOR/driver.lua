JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

gAvailableZigbeeDeviceNameToZigbeeId = {}

-- NAME USED FOR LOGGING
gLogName = "Z2MQTT_PHILIPS_HUE_MOTION_SENSOR"

-- DRIVER LIFETIME
function ON_DRIVER_LATEINIT.DRIVER (dit)
    C4:AddVariable("TEMPERATURE", Properties["Temperature"] ~= "Unknown" and tonumber(Properties["Temperature"]) or 0, "NUMBER")
    C4:AddVariable("ILLUMINANCE", Properties["Illuminance"] ~= "Unknown" and tonumber(Properties["Illuminance"]) or 0, "NUMBER")
    C4:AddVariable("BATTERY_LEVEL", Properties["Battery Level"] ~= "Unknown" and tonumber(Properties["Battery Level"]) or 0, "NUMBER")
    C4:AddVariable("OCCUPANCY", Properties["Occupancy"] ~= "Unknown" and NumberToStringBool(Properties["Occupancy"]) or "0", "BOOL")
    C4:AddVariable("MOTION_SENSITIVITY", Properties["Motion Sensitivity"], "STRING")
    C4:AddVariable("OCCUPANCY_TIMEOUT", Properties["Occupancy Timeout"] ~= "Unknown" and tonumber(Properties["Occupancy Timeout"]) or 0, "NUMBER")
    C4:AddVariable("LED_INDICATION", Properties["Led Indication"] ~= "Unknown" and NumberToStringBool(Properties["Led Indication"]) or "0", "BOOL")

    Dbg:Debug("Driver OnDriverLateInit done.")
end

-- ON BINDING CHANGES
OBC[1] = function (idBinding, strClass, bIsBound, otherDeviceId, otherBindingId)
	Dbg:Debug("OBC.TEMPERATURE")

	if(bIsBound and Properties["Temperature"] ~= "Unknown") then
        C4:SendToProxy(1, "VALUE_INITIALIZE", { CELSIUS = tonumber(Properties["Temperature"])})
	end
end

OBC[2] = function (idBinding, strClass, bIsBound, otherDeviceId, otherBindingId)
	Dbg:Debug("OBC.MOTION_SENSOR")

	if(bIsBound and Properties["Temperature"] ~= "Unknown") then
        C4:SendToProxy(1, "VALUE_INITIALIZE", { CELSIUS = tonumber(Properties["Temperature"])})
	end
end

-- ON PROPERTY CHANGES
function OPC.Motion_Sensitivity(motion_sensitivity)
    if(gDeviceData.zigbee_device_id ~= nil) then
        if(motion_sensitivity == "Very High") then
            motion_sensitivity = "very_high"
        else
            motion_sensitivity = string.lower(motion_sensitivity)
        end

        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["motion_sensitivity"] = motion_sensitivity}) })
    end
end

function OPC.Led_Indication(led_indication)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["led_indication"] = string.lower(led_indication)}) })
    end
end

function OPC.Occupancy_Timeout(occupancy_timeout)
    C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["occupancy_timeout"] = tonumber(occupancy_timeout)}) })
end

-- EXECUTE COMMANDS
function EX_CMD.SET_MOTION_SENSITIVITY(tParams)
    OPC.Motion_Sensitivity(tParams["Sensitivity"])
end

function EX_CMD.SET_LED_INDICATION(tParams)
     OPC.Led_Indication(tParams["Indication"])
end

function EX_CMD.SET_OCCUPANCY_TIMEOUT(tParams)
    OPC.Occupancy_Timeout(tParams["Timeout"])
end

-- DEVICE STATE UPDATES
function DEVICE_SYNC.TEMPERATURE(temperature)
    if string.lower(tostring(temperature)) ~= string.lower(Properties["Temperature"]) then
        C4:UpdateProperty("Temperature", tostring(temperature))

        C4:SetVariable("TEMPERATURE", tonumber(temperature))
        C4:FireEvent("When The Temperature Changes")

        C4:SendToProxy(1, "VALUE_CHANGED", { CELSIUS = tonumber(temperature)})
    end
end

function DEVICE_SYNC.ILLUMINANCE(illuminance)
    if string.lower(tostring(illuminance)) ~= string.lower(Properties["Illuminance"]) then
        C4:UpdateProperty("Illuminance", tostring(illuminance))

        C4:SetVariable("ILLUMINANCE", tonumber(illuminance))
        C4:FireEvent("When The Illuminance Changes")
    end
end

function DEVICE_SYNC.OCCUPANCY(occupancy)
    if string.lower(tostring(occupancy)) ~= string.lower(Properties["Occupancy"]) then
        C4:UpdateProperty("Occupancy", Capitalize(occupancy))

        C4:SetVariable("OCCUPANCY", BoolToStringBool(occupancy))
        C4:FireEvent("When The Occupancy Changes")

        if string.lower(tostring(occupancy)) == "true" then
            C4:SendToProxy(2, "OPENED",{}, "NOTIFY")
        elseif string.lower(tostring(occupancy)) == "false" then
            C4:SendToProxy(2, "CLOSED",{}, "NOTIFY")
        end
    end
end

function DEVICE_SYNC.MOTION_SENSITIVITY(motion_sensitivity)
    local motionSensitivity = tostring(motion_sensitivity)

    if(motionSensitivity == "very_high") then
        motionSensitivity = "Very High"
    else
        motionSensitivity = Capitalize(string.lower(motionSensitivity))
    end

    if(string.lower(motionSensitivity) ~= string.lower(Properties["Motion Sensitivity"])) then
        C4:UpdateProperty("Motion Sensitivity", tostring(motionSensitivity))

        C4:SetVariable("MOTION_SENSITIVITY", tostring(motionSensitivity))
        C4:FireEvent("When The Motion Sensitivity Changes")
    end
end

function DEVICE_SYNC.OCCUPANCY_TIMEOUT(occupancy_timeout)
    if string.lower(tostring(occupancy_timeout)) ~= string.lower(Properties["Occupancy Timeout"]) then
        C4:UpdateProperty("Occupancy Timeout", tostring(occupancy_timeout))

        C4:SetVariable("OCCUPANCY_TIMEOUT", tonumber(occupancy_timeout))
        C4:FireEvent("When The Occupancy Timeout Changes")
    end
end

function DEVICE_SYNC.LED_INDICATION(led_indication)
    if string.lower(tostring(led_indication)) ~= string.lower(Properties["Led Indication"]) then
        C4:UpdateProperty("Led Indication", Capitalize(led_indication))

        C4:SetVariable("LED_INDICATION", BoolToStringBool(led_indication))
        C4:FireEvent("When The Led Indication Changes")
    end
end

function DEVICE_SYNC.BATTERY(battery)
    if string.lower(tostring(battery)) ~= string.lower(Properties["Battery Level"]) then
        C4:UpdateProperty("Battery Level", tostring(battery))

        C4:SetVariable("BATTERY_LEVEL", tonumber(battery))
        C4:FireEvent("When The Battery Level Changes")
    end
end

-- CONDITIONALS
function CONDITIONALS.BOOL_LED_INDICATION(tParams)
    local value = tParams["VALUE"]
    return string.lower(value) == string.lower(Properties["Led Indication"])
end

function CONDITIONALS.BOOL_OCCUPANCY(tParams)
    local value = tParams["VALUE"]
    return string.lower(value) == string.lower(Properties["Occupancy"])
end

function CONDITIONALS.NUMBER_TEMPERATURE_LEVEL(tParams)
    if Properties["Temperature"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Temperature"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_OCCUPANCY_TIMEOUT(tParams)
    if Properties["Occupancy Timeout"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Occupancy Timeout"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_ILLUMINANCE(tParams)
    if Properties["Illuminance"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Illuminance"]), tonumber(strValue))
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

function CONDITIONALS.LIST_MOTION_SENSITIVITY(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Motion Sensitivity"], strValue)
end