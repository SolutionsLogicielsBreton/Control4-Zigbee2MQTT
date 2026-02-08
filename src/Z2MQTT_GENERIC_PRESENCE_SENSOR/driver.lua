JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

gAvailableZigbeeDeviceNameToZigbeeId = {}

-- NAME USED FOR LOGGING
gLogName = "Z2MQTT_GENERIC_PRESENCE_SENSOR"

-- DRIVER LIFETIME
function ON_DRIVER_LATEINIT.DRIVER (dit)
    C4:AddVariable("BATTERY_LEVEL", Properties["Battery Level"] ~= "Unknown" and tonumber(Properties["Battery Level"]) or 0, "NUMBER")
    C4:AddVariable("PRESENCE", Properties["Presence"], "STRING")

    Dbg:Debug("Driver OnDriverLateInit done.")
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