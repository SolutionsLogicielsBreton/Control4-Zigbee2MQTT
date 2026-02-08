JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

gAvailableZigbeeDeviceNameToZigbeeId = {}

-- NAME USED FOR LOGGING
gLogName = "Z2MQTT_IHSENO_TS0601"

-- DRIVER LIFETIME
function ON_DRIVER_LATEINIT.DRIVER (dit)
    C4:AddVariable("BATTERY_LEVEL", Properties["Battery Level"] ~= "Unknown" and tonumber(Properties["Battery Level"]) or 0, "NUMBER")
    C4:AddVariable("PRESENCE", Properties["Presence"], "STRING")
    C4:AddVariable("SENSITIVITY", Properties["Sensitivity"], "STRING")
    C4:AddVariable("DELAY_TIME", Properties["Delay Time"], "STRING")

    Dbg:Debug("Driver OnDriverLateInit done.")
end

-- ON PROPERTY CHANGE
function OPC.Sensitivity(sensitivity)
    C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["sensitivity"] = string.lower(tostring(sensitivity))}) })
end

function OPC.Delay_Time(delay_time)
    C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["delay_time"] = tostring(delay_time)}) })
end

-- EXECUTE COMMANDS
function EX_CMD.SET_DELAY_TIME(tParams)
    OPC.Delay_Time(tParams["Delay"])
end

function EX_CMD.SET_SENSITIVITY(tParams)
    OPC.Sensitivity(tParams["Sensitivity"])
end

-- DEVICE STATE UPDATES
function DEVICE_SYNC.PRESENCE(presence)
    if string.lower(tostring(presence)) ~= string.lower(Properties["Presence"]) then
        C4:UpdateProperty("Presence", Capitalize(presence))
        C4:SetVariable("PRESENCE", BoolToStringBool(presence))
        C4:FireEvent("When The Presence Changes")

        if string.lower(tostring(presence)) == "true" then
            C4:SendToProxy(1, "OPENED",{}, "NOTIFY")
        elseif string.lower(tostring(presence)) == "false" then
            C4:SendToProxy(1, "CLOSED",{}, "NOTIFY")
        end
    end
end

function DEVICE_SYNC.SENSITIVITY(sensitivity)
    if(string.lower(tostring(sensitivity)) ~= string.lower(Properties["Sensitivity"])) then
        C4:UpdateProperty("Sensitivity", Capitalize(sensitivity))
        C4:SetVariable("SENSITIVITY", Capitalize(sensitivity))
        C4:FireEvent("When The Sensitivity Changes")
    end
end

function DEVICE_SYNC.DELAY_TIME(delay_time)
    if(string.lower(tostring(delay_time)) ~= string.lower(Properties["Delay Time"])) then
        C4:UpdateProperty("Delay Time", tostring(delay_time))
        C4:SetVariable("DELAY_TIME", tostring(delay_time))
        C4:FireEvent("When The Delay Time Changes")
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
function CONDITIONALS.BOOL_PRESENCE(tParams)
    local value = tParams["VALUE"]
    return string.lower(value) == string.lower(Properties["Presence"])
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

function CONDITIONALS.LIST_SENSITIVITY(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Sensitivity"], strValue)
end

function CONDITIONALS.LIST_DELAY_TIME(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Delay Time"], strValue)
end