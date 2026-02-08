JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

gAvailableZigbeeDeviceNameToZigbeeId = {}

-- NAME USED FOR LOGGING
gLogName = "Z2MQTT_GENERIC_WATER_LEAK_SENSOR"

-- DRIVER LIFETIME
function ON_DRIVER_LATEINIT.DRIVER (dit)
    C4:AddVariable("BATTERY_LEVEL", Properties["Battery Level"] ~= "Unknown" and tonumber(Properties["Battery Level"]) or 0, "NUMBER")
    C4:AddVariable("WATER_LEAK", Properties["Water Leak"] ~= "Unknown" and NumberToStringBool(Properties["Water Leak"]) or "0", "BOOL")
    Dbg:Debug("Driver OnDriverLateInit done.")
end

-- DEVICE STATE UPDATES
function DEVICE_SYNC.WATER_LEAK(water_leak)
    if string.lower(tostring(water_leak)) ~= string.lower(Properties["Water Leak"]) then
        C4:UpdateProperty("Water Leak", Capitalize(water_leak));

        C4:SetVariable("WATER_LEAK", BoolToStringBool(water_leak))
        C4:FireEvent("When The Water Leak Detection Changes")

        if string.lower(tostring(water_leak)) == "true" then
            C4:SendToProxy(1, "OPENED",{}, "NOTIFY")
        elseif string.lower(tostring(water_leak)) == "false" then
            C4:SendToProxy(1, "CLOSED",{}, "NOTIFY")
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
function CONDITIONALS.BOOL_WATER_LEAK(tParams)
    local value = tParams["VALUE"]
    return string.lower(value) == string.lower(Properties["Water Leak"])
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