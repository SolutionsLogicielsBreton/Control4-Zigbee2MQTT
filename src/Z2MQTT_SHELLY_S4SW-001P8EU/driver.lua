JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

gAvailableZigbeeDeviceNameToZigbeeId = {}

-- NAME USED FOR LOGGING
gLogName = "Z2MQTT_SHELLY_S4SW-001P8EU"

-- DRIVER LIFETIME
function ON_DRIVER_LATEINIT.DRIVER (dit)
    C4:AddVariable("STATE", Properties["State"] ~= "Unknown" and NumberToStringBool(Properties["State"]) or "0", "BOOL")
    C4:AddVariable("AC_FREQUENCY", Properties["AC Frequency"] ~= "Unknown" and tonumber(Properties["AC Frequency"]) or 0.0, "FLOAT")
    C4:AddVariable("CURRENT", Properties["Current"] ~= "Unknown" and tonumber(Properties["Current"]) or 0.0, "FLOAT")
    C4:AddVariable("DHCP_ENABLED", Properties["DHCP Enabled"] ~= "Unknown" and BoolToStringBool(Properties["DHCP Enabled"]) or "0", "BOOL")
    C4:AddVariable("ENERGY", Properties["Energy"] ~= "Unknown" and tonumber(Properties["Energy"]) or 0.0, "FLOAT")
    C4:AddVariable("IP_ADDRESS", Properties["IP Address"] or "Unknown", "STRING")
    C4:AddVariable("POWER", Properties["Power"] ~= "Unknown" and tonumber(Properties["Power"]) or 0.0, "FLOAT")
    C4:AddVariable("PRODUCED_ENERGY", Properties["Produced Energy"] ~= "Unknown" and tonumber(Properties["Produced Energy"]) or 0.0, "FLOAT")
    C4:AddVariable("VOLTAGE", Properties["Voltage"] ~= "Unknown" and tonumber(Properties["Voltage"]) or 0.0, "FLOAT")
    C4:AddVariable("WIFI_STATUS", Properties["WiFi Status"] or "Unknown", "STRING")

    Dbg:Debug("Driver OnDriverLateInit done.")
end

-- ON PROPERTY CHANGED
function OPC.DHCP_Enabled(dhcp_enabled)
    if(gDeviceData.zigbee_device_id ~= nil) then
        local zigbeeValue = string.lower(tostring(dhcp_enabled)) == "true" and true or false
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["dhcp_enabled"] = zigbeeValue}) })
    end
end

-- PROXY COMMANDS
function PRX_CMD.TOGGLE(idBinding, tParams)
    if idBinding == 1 then
        if(gDeviceData.zigbee_device_id ~= nil) then
            C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["state"] = "TOGGLE"}) })
        end
    end
end

function PRX_CMD.OPEN(idBinding, tParams)
    if idBinding == 1 then
        local current_state = string.upper(Properties["State"])

        if(gDeviceData.zigbee_device_id ~= nil and current_state ~= "ON") then
            C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["state"] = "ON"}) })
        end
    end
end

function PRX_CMD.CLOSE(idBinding, tParams)
    if idBinding == 1 then
        local current_state = string.upper(Properties["State"])

        if(gDeviceData.zigbee_device_id ~= nil and current_state ~= "OFF") then
            C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["state"] = "OFF"}) })
        end
    end
end

-- EXECUTE COMMANDS
function EX_CMD.TOGGLE(tParams)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["state"] = "TOGGLE"}) })
    end
end

function EX_CMD.SET_STATE(tParams)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["state"] = string.upper(tParams["State"])}) })
    end
end

function EX_CMD.TURN_ON_WITH_ON_TIME(tParams)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["state"] = "ON", ["on_time"] = tonumber(tParams["On Time (seconds)"])}) })
    end
end

function EX_CMD.SET_DHCP_ENABLED(tParams)
     OPC.DHCP_Enabled(tParams["Enabled"])
end

function EX_CMD.SET_WIFI_CONFIG(tParams)
    if(gDeviceData.zigbee_device_id ~= nil) then
        local wifi_config = {
            enabled = string.lower(tParams["Enabled"]),
            ssid = tParams["SSID"],
            password = tParams["Password"],
            static_ip = tParams["Static IP"],
            net_mask = tParams["Net Mask"],
            gateway = tParams["Gateway"],
            name_server = tParams["Name Server"]
        }
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["wifi_config"] = wifi_config}) })
    end
end

-- DEVICE STATE UPDATES
function DEVICE_SYNC.STATE(state)
    if string.lower(tostring(state)) == "on" and string.lower(Properties["State"]) ~= "on" then
        C4:UpdateProperty("State", Capitalize(state))
        C4:SetVariable("STATE", "1")
        C4:SendToProxy(1, "OPENED",{}, "NOTIFY")
        C4:FireEvent("When Turned On")
    elseif string.lower(tostring(state)) == "off" and string.lower(Properties["State"]) ~= "off" then
        C4:UpdateProperty("State", Capitalize(state))
        C4:SetVariable("STATE", "0")
        C4:SendToProxy(1, "CLOSED",{}, "NOTIFY")
        C4:FireEvent("When Turned Off")
    end
end

function DEVICE_SYNC.AC_FREQUENCY(frequency)
    if string.lower(tostring(frequency)) ~= string.lower(Properties["AC Frequency"]) then
        C4:UpdateProperty("AC Frequency", tostring(frequency))
        C4:SetVariable("AC_FREQUENCY", tonumber(frequency))
        C4:FireEvent("When AC Frequency Changes")
    end
end

function DEVICE_SYNC.CURRENT(current_val)
    if string.lower(tostring(current_val)) ~= string.lower(Properties["Current"]) then
        C4:UpdateProperty("Current", tostring(current_val))
        C4:SetVariable("CURRENT", tonumber(current_val))
        C4:FireEvent("When Current Changes")
    end
end

function DEVICE_SYNC.DHCP_ENABLED(enabled)
    if string.lower(tostring(enabled)) ~= string.lower(Properties["DHCP Enabled"]) then
        C4:UpdateProperty("DHCP Enabled", Capitalize(enabled))
        C4:SetVariable("DHCP_ENABLED", BoolToStringBool(enabled))
        C4:FireEvent("When DHCP Enabled Changes")
    end
end

function DEVICE_SYNC.ENERGY(energy)
    if string.lower(tostring(energy)) ~= string.lower(Properties["Energy"]) then
        C4:UpdateProperty("Energy", tostring(energy))
        C4:SetVariable("ENERGY", tonumber(energy))
        C4:FireEvent("When Energy Changes")
    end
end

function DEVICE_SYNC.IP_ADDRESS(ip)
    if string.lower(tostring(ip)) ~= string.lower(Properties["IP Address"]) then
        C4:UpdateProperty("IP Address", tostring(ip))
        C4:SetVariable("IP_ADDRESS", ip)
        C4:FireEvent("When IP Address Changes")
    end
end

function DEVICE_SYNC.POWER(power)
    if string.lower(tostring(power)) ~= string.lower(Properties["Power"]) then
        C4:UpdateProperty("Power", tostring(power))
        C4:SetVariable("POWER", tonumber(power))
        C4:FireEvent("When Power Changes")
    end
end

function DEVICE_SYNC.PRODUCED_ENERGY(energy)
    if string.lower(tostring(energy)) ~= string.lower(Properties["Produced Energy"]) then
        C4:UpdateProperty("Produced Energy", tostring(energy))
        C4:SetVariable("PRODUCED_ENERGY", tonumber(energy))
        C4:FireEvent("When Produced Energy Changes")
    end
end

function DEVICE_SYNC.VOLTAGE(voltage)
    if string.lower(tostring(voltage)) ~= string.lower(Properties["Voltage"]) then
        C4:UpdateProperty("Voltage", tostring(voltage))
        C4:SetVariable("VOLTAGE", tonumber(voltage))
        C4:FireEvent("When Voltage Changes")
    end
end

function DEVICE_SYNC.WIFI_STATUS(status)
    if string.lower(tostring(status)) ~= string.lower(Properties["WiFi Status"]) then
        C4:UpdateProperty("WiFi Status", tostring(status))
        C4:SetVariable("WIFI_STATUS", status)
        C4:FireEvent("When WiFi Status Changes")
    end
end

-- CONDITIONALS
function CONDITIONALS.BOOL_STATE(tParams)
    local value = tParams["VALUE"]
    return string.lower(value) == string.lower(Properties["State"])
end

function CONDITIONALS.NUM_AC_FREQUENCY(tParams)
    if Properties["AC Frequency"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["AC Frequency"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUM_CURRENT(tParams)
    if Properties["Current"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Current"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.BOOL_DHCP_ENABLED(tParams)
    local value = tParams["VALUE"]
    return string.lower(value) == string.lower(Properties["DHCP Enabled"])
end

function CONDITIONALS.NUM_ENERGY(tParams)
    if Properties["Energy"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Energy"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.STR_IP_ADDRESS(tParams)
    if Properties["IP Address"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, Properties["IP Address"], strValue)
    else
        return false
    end
end

function CONDITIONALS.NUM_POWER(tParams)
    if Properties["Power"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Power"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUM_PRODUCED_ENERGY(tParams)
    if Properties["Produced Energy"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Produced Energy"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUM_VOLTAGE(tParams)
    if Properties["Voltage"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Voltage"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.STR_WIFI_STATUS(tParams)
    if Properties["WiFi Status"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, Properties["WiFi Status"], strValue)
    else
        return false
    end
end