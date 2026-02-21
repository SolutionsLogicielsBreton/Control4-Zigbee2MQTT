gDebugTimer = nil
DEVICE_SYNC = {}
CONDITIONALS = {}
gAvailableZigbeeDeviceNameToZigbeeId = {}

function OnDriverInit (dit)
end

function OnDriverDestroyed (dit)
end

function ON_DRIVER_LATEINIT.Boilerplate (dit)
    -- Logging
    pcall(function() 
        Dbg = Log.Create()
        Dbg:SetLogName(gLogName)
        LogLevelChanged(Properties["Log Level"])
        LogModeChanged(Properties["Log Mode"])
    end)

    gDeviceData = C4:PersistGetValue("DeviceData", false)

    if(gDeviceData == nil) then
        Dbg:Debug("Initializing new persisted data.")
        gDeviceData = {}
    end

    C4:SendToProxy(999, "DEVICE_LIST_REQUEST", { DEVICE_ID = C4:GetDeviceID() })

    C4:AddVariable("CONNECTION_STATUS", Properties["Connection Status"], "STRING")

    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "SET_SELECTED_DEVICE", { DEVICE_ID = C4:GetDeviceID(), ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id) })
    end

    Dbg:Debug("Base OnDriverLateInit done.")
end

OBC[999] = function (idBinding, strClass, bIsBound, otherDeviceId, otherBindingId)
	Dbg:Debug("OBC.ZIG_TO_MQTT_LINK")

	if(bIsBound) then
        if(gDeviceData.zigbee_device_id ~= nil) then
            C4:SendToProxy(999, "SET_SELECTED_DEVICE", { DEVICE_ID = C4:GetDeviceID(), ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id) })
        end
	end
end

function OPC.Zigbee_Device(zigbeeDeviceName)
    if(gAvailableZigbeeDeviceNameToZigbeeId[zigbeeDeviceName] ~= nil) then
        gDeviceData.zigbee_device_id = gAvailableZigbeeDeviceNameToZigbeeId[zigbeeDeviceName]
        C4:UpdateProperty("Zigbee Device", zigbeeDeviceName)
        C4:UpdateProperty("IEEE Address", gDeviceData.zigbee_device_id)
        C4:PersistSetValue("DeviceData", gDeviceData, false)
	    C4:SendToProxy(999, "SET_SELECTED_DEVICE", { DEVICE_ID = C4:GetDeviceID(), ZIGBEE_DEVICE = tostring(gAvailableZigbeeDeviceNameToZigbeeId[zigbeeDeviceName]) })
        Dbg:Debug("Sent selected device: " .. gAvailableZigbeeDeviceNameToZigbeeId[zigbeeDeviceName])
    else
        Dbg:Debug("Ignoring device binding: Unknown Zigbee Device")
    end
end

function EX_CMD.Z2M_DEVICE_LIST_UPDATE(tParams)
    if(tParams ~= nil) then
        local availableDeviceProperty = {}
        local selectedDeviceProperty = ""

        local availableDevices = JSON:decode(tParams["DEVICES"])

        gAvailableZigbeeDeviceNameToZigbeeId = {}

        for zigbeeDeviceId, zigbeeDevice in pairs(availableDevices) do
            local devicePropertyName = "[" .. zigbeeDevice.VENDOR .. " " .. zigbeeDevice.MODEL .. "] " .. tostring(zigbeeDevice.NAME) .. " (ID: " .. tostring(zigbeeDeviceId) ..  ")"
            gAvailableZigbeeDeviceNameToZigbeeId[devicePropertyName] = zigbeeDeviceId
            table.insert(availableDeviceProperty, devicePropertyName)

            if(tostring(gDeviceData.zigbee_device_id) == tostring(zigbeeDeviceId)) then
                selectedDeviceProperty = devicePropertyName
            end
        end

        table.sort(availableDeviceProperty)
        C4:UpdatePropertyList("Zigbee Device", table.concat(availableDeviceProperty, ","), selectedDeviceProperty)

        Dbg:Info("Updated available device list.")
    end
end

function EX_CMD.Z2M_SYNC_REQUEST(tParams)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "SET_SELECTED_DEVICE", { DEVICE_ID = C4:GetDeviceID(), ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id) })
    end
end

function EX_CMD.Z2M_DEVICE_SYNC(tParams)
    if (tParams ~= nil) then
        if(tParams["DEVICE"] ~= nil) then
            local success, zDeviceState = pcall(function()
                return JSON:decode(tParams["DEVICE"])
            end)

            if (success and zDeviceState ~= nil and zDeviceState.z2m_state ~= nil) then
                for name, value in pairs(zDeviceState.z2m_state) do
                    Dbg:Debug("DEVICE_SYNC(" .. name .. ")")

                    pcall(function()
                        if(value == nil) then
                            Dbg:Trace("-- device state (" .. name .. ")" .." empty.")
                        else
                            Dbg:Trace(Dump(value))
                        end
                    end)

                    local deviceSyncFunc = string.upper(string.gsub(tostring(name), " ", "_"))
                    local status, ret

                    if (DEVICE_SYNC[deviceSyncFunc] ~= nil and type(DEVICE_SYNC[deviceSyncFunc]) == "function") then
                        status, ret = pcall(DEVICE_SYNC[deviceSyncFunc], value)
                    else
                        Dbg:Info("DeviceSync: Unhandled property = " .. deviceSyncFunc)
                        status = true
                    end

                    if (not status) then
                        Dbg:Error("LUA_ERROR: " .. ret)
                    end
                end
            else
                pcall(function()
                    Dbg:Trace("[Z2M_DEVICE_SYNC] Failed to decode JSON: " .. tParams["DEVICE"])
                end)
            end
        end
    end
end

function DEVICE_SYNC.LINKQUALITY(linkquality)
    if (string.lower(tostring(linkquality)) ~= string.lower(Properties["Connection Quality"])) then
        C4:UpdateProperty("Connection Quality", tostring(linkquality))
    end
end

function DEVICE_SYNC.LINKSTATUS(linkstatus)
    if (string.lower(tostring(linkstatus)) ~= string.lower(Properties["Connection Status"])) then
        C4:UpdateProperty("Connection Status", Capitalize(linkstatus))

        C4:SetVariable("CONNECTION_STATUS", Capitalize(linkstatus))
        C4:FireEvent("When The Connection Status Changes")
    end
end

function OPC.Log_Mode(propertyValue)
    LogModeChanged(propertyValue)
end

function OPC.Log_Level(propertyValue)
    LogLevelChanged(propertyValue)
end

function IntegerToString(intValue)
    if(tonumber(intValue) == 0) then
        return "False"
    else
        return "True"
    end
end

function Clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end
    return math.max(lower, math.min(upper, val))
end

function StopDebugTimer()
    if gDebugTimer then
        gDebugTimer:Cancel()
        gDebugTimer = nil
    end
end

function StartDebugTimer()
    StopDebugTimer()
    gDebugTimer = C4:SetTimer(15 * 60 * 1000, OnDebugTimerExpired)
end

function OnDebugTimerExpired()
    Dbg:Debug("Turning Log Mode Off (timer expired)")
    C4:UpdateProperty("Log Mode", "Off")
    LogModeChanged("Off")
end

function Dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. Dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end

function TestCondition(name, tParams)
    local status
    local retVal = false

    Dbg:Trace("Testing conditionals: " .. name)

    if (CONDITIONALS[name] ~= nil and type(CONDITIONALS[name]) == "function") then
        status, retVal = pcall(CONDITIONALS[name], tParams)
    else
        Dbg:Warn("DeviceSync: Unhandled conditionals = " .. name)
        status = true
    end

    if (not status) then
        Dbg:Error("LUA_ERROR: " .. retVal)
    end

    Dbg:Trace("Conditional [" .. name .. "] result = " .. tostring(retVal))
    return retVal
end

function CONDITIONALS.BOOL_CONNECTION_STATUS(tParams)
    local value = tParams["VALUE"]
    return string.lower(value) == string.lower(Properties["Connection Status"])
end

function Capitalize(str)
    return (tostring(str):gsub("^%l", string.upper))
end

function NumberToStringBool(intValue)
    if(tonumber(intValue) == 0) then
        return "0"
    else
        return "1"
    end
end

function BoolToStringBool(boolValue)
    if(string.lower(tostring(boolValue)) == "false") then
        return "0"
    else
        return "1"
    end
end

function LogModeChanged(propertyValue)
    if(gDebugTimer == nil and propertyValue ~= "Off") then
        print("New Log Mode: " .. propertyValue)
    end

    Dbg:Debug("New Log Mode: " .. propertyValue)
    StopDebugTimer()
    Dbg:OutputPrint(propertyValue:find("Print") ~= nil)
    Dbg:OutputC4Log(propertyValue:find("Log") ~= nil)
    if (propertyValue == "Off") then return end
    StartDebugTimer()
end

function LogLevelChanged(propertyValue)
    local logLevel = 0
    if propertyValue == "Off" then 
        logLevel = 0 
        Dbg:Debug("New SetLogLevel: Off")
        print("Log Level is now: Off")
    end

    if propertyValue == "Fatal" then 
        logLevel = 1
        Dbg:Debug("New SetLogLevel: Fatal")
        print("Log Level is now: Fatal")
    end

    if propertyValue == "Error" then 
        logLevel = 2
        Dbg:Debug("New SetLogLevel: Error")
        print("Log Level is now: Error")
    end

    if propertyValue == "Warn" then 
        logLevel = 3 
        Dbg:Debug("New SetLogLevel: Warn")
        print("Log Level is now: Warn")
    end

    if propertyValue == "Info" then 
        logLevel = 4 
        Dbg:Debug("New SetLogLevel: Info")
        print("Log Level is now: Info")
    end

    if propertyValue == "Debug" then 
        logLevel = 5 
        Dbg:Debug("New SetLogLevel: Debug")
        print("Log Level is now: Debug")
    end

    if propertyValue == "Trace" then 
        logLevel = 6 
        Dbg:Debug("New SetLogLevel: Trace")
        print("Log Level is now: Trace")
    end

    Dbg:SetLogLevel(logLevel)
end