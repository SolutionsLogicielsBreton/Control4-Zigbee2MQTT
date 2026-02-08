JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

gAvailableZigbeeDeviceNameToZigbeeId = {}

-- NAME USED FOR LOGGING
gLogName = "Z2MQTT_GENERIC_SMART_PLUG"

-- DRIVER LIFETIME
function ON_DRIVER_LATEINIT.DRIVER (dit)
    C4:AddVariable("STATE", Properties["State"] ~= "Unknown" and NumberToStringBool(Properties["State"]) or "0", "BOOL")
    Dbg:Debug("Driver OnDriverLateInit done.")
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

-- CONDITIONALS
function CONDITIONALS.BOOL_STATE(tParams)
    local value = tParams["VALUE"]
    return string.lower(value) == string.lower(Properties["State"])
end