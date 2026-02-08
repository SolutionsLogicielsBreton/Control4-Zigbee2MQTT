JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

gAvailableZigbeeDeviceNameToZigbeeId = {}

-- NAME USED FOR LOGGING
gLogName = "Z2MQTT_GENERIC_CONTACT_SENSOR"

-- DRIVER LIFETIME
function ON_DRIVER_LATEINIT.DRIVER (dit)
    C4:AddVariable("BATTERY_LEVEL", Properties["Battery Level"] ~= "Unknown" and tonumber(Properties["Battery Level"]) or 0, "NUMBER")
    C4:AddVariable("CONTACT", Properties["Contact"] ~= "Unknown" and NumberToStringBool(Properties["Contact"]) or "0", "BOOL")
    Dbg:Debug("Driver OnDriverLateInit done.")
end

-- DEVICE STATE UPDATES
function DEVICE_SYNC.CONTACT(contact)
    if string.lower(tostring(contact)) ~= string.lower(Properties["Contact"]) then
        C4:UpdateProperty("Contact", Capitalize(contact));

        C4:SetVariable("CONTACT", BoolToStringBool(contact))
        C4:FireEvent("When The Contact Changes")

        if string.lower(tostring(contact)) == "true" then
            C4:SendToProxy(1, "OPENED",{}, "NOTIFY")
        elseif string.lower(tostring(contact)) == "false" then
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
function CONDITIONALS.BOOL_CONTACT(tParams)
    local value = tParams["VALUE"]
    return string.lower(value) == string.lower(Properties["Contact"])
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