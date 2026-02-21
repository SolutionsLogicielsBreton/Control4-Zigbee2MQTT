JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

-- NAME USED FOR LOGGING
gLogName = "Z2MQTT_AQARA_PS-S04D"

-- DRIVER LIFETIME
function ON_DRIVER_LATEINIT.DRIVER (dit)
    C4:AddVariable("POWER_OUTAGE_COUNT", Properties["Power Outage Count"] ~= "Unknown" and tonumber(Properties["Power Outage Count"]) or 0, "NUMBER")
    C4:AddVariable("MOTION_SENSITIVITY", Properties["Motion Sensitivity"], "STRING")
    C4:AddVariable("BATTERY_LEVEL", Properties["Battery Level"] ~= "Unknown" and tonumber(Properties["Battery Level"]) or 0, "NUMBER")
    C4:AddVariable("VOLTAGE", Properties["Voltage"] ~= "Unknown" and tonumber(Properties["Voltage"]) or 0, "NUMBER")
    C4:AddVariable("PRESENCE", Properties["Presence"] ~= "Unknown" and BoolToStringBool(Properties["Presence"]) or "0", "BOOL")
    C4:AddVariable("PIR_DETECTION", Properties["Pir Detection"] ~= "Unknown" and BoolToStringBool(Properties["Pir Detection"]) or "0", "BOOL")
    C4:AddVariable("PRESENCE_DETECTION_OPTIONS", Properties["Presence Detection Options"], "STRING")
    C4:AddVariable("AI_INTERFERENCE_SOURCE_SELF_IDENTIFICATION", Properties["AI Interference Source Self Identification"] ~= "Unknown" and BoolToStringBool(Properties["AI Interference Source Self Identification"]) or "0", "BOOL")
    C4:AddVariable("AI_SENSITIVITY_ADAPTIVE", Properties["AI Sensitivity Adaptive"] ~= "Unknown" and BoolToStringBool(Properties["AI Sensitivity Adaptive"]) or "0", "BOOL")
    C4:AddVariable("ABSENCE_DELAY_TIMER", Properties["Absence Delay Timer"] ~= "Unknown" and tonumber(Properties["Absence Delay Timer"]) or 0, "NUMBER")
    C4:AddVariable("PIR_DETECTION_INTERVAL", Properties["Pir Detection Interval"] ~= "Unknown" and tonumber(Properties["Pir Detection Interval"]) or 0, "NUMBER")
    C4:AddVariable("ILLUMINANCE", Properties["Illuminance"] ~= "Unknown" and tonumber(Properties["Illuminance"]) or 0, "NUMBER")
    C4:AddVariable("HUMIDITY", Properties["Humidity"] ~= "Unknown" and tonumber(Properties["Humidity"]) or 0, "NUMBER")
    C4:AddVariable("TEMPERATURE", Properties["Temperature"] ~= "Unknown" and tonumber(Properties["Temperature"]) or 0, "NUMBER")
    C4:AddVariable("TEMP_AND_HUMIDITY_SAMPLING", Properties["Temp And Humidity Sampling"], "STRING")
    C4:AddVariable("TEMP_AND_HUMIDITY_SAMPLING_PERIOD", Properties["Temp And Humidity Sampling Period"] ~= "Unknown" and tonumber(Properties["Temp And Humidity Sampling Period"]) or 0, "NUMBER")
    C4:AddVariable("TEMP_REPORTING_INTERVAL", Properties["Temp Reporting Interval"] ~= "Unknown" and tonumber(Properties["Temp Reporting Interval"]) or 0, "NUMBER")
    C4:AddVariable("TEMP_REPORTING_THRESHOLD", Properties["Temp Reporting Threshold"] ~= "Unknown" and tonumber(Properties["Temp Reporting Threshold"]) or 0, "NUMBER")
    C4:AddVariable("TEMP_REPORTING_MODE", Properties["Temp Reporting Mode"], "STRING")
    C4:AddVariable("HUMIDITY_REPORTING_INTERVAL", Properties["Humidity Reporting Interval"] ~= "Unknown" and tonumber(Properties["Humidity Reporting Interval"]) or 0, "NUMBER")
    C4:AddVariable("HUMIDITY_REPORTING_THRESHOLD", Properties["Humidity Reporting Threshold"] ~= "Unknown" and tonumber(Properties["Humidity Reporting Threshold"]) or 0, "NUMBER")
    C4:AddVariable("HUMIDITY_REPORT_MODE", Properties["Humidity Report Mode"], "STRING")
    C4:AddVariable("LIGHT_SAMPLING", Properties["Light Sampling"], "STRING")
    C4:AddVariable("LIGHT_SAMPLING_PERIOD", Properties["Light Sampling Period"] ~= "Unknown" and tonumber(Properties["Light Sampling Period"]) or 0, "NUMBER")
    C4:AddVariable("LIGHT_REPORTING_INTERVAL", Properties["Light Reporting Interval"] ~= "Unknown" and tonumber(Properties["Light Reporting Interval"]) or 0, "NUMBER")
    C4:AddVariable("LIGHT_REPORTING_THRESHOLD", Properties["Light Reporting Threshold"] ~= "Unknown" and tonumber(Properties["Light Reporting Threshold"]) or 0, "NUMBER")
    C4:AddVariable("LIGHT_REPORT_MODE", Properties["Light Report Mode"], "STRING")
    C4:AddVariable("TARGET_DISTANCE", Properties["Target Distance"] ~= "Unknown" and tonumber(Properties["Target Distance"]) or 0, "NUMBER")
    C4:AddVariable("DETECTION_RANGE", Properties["Detection Range"] ~= "Unknown" and tonumber(Properties["Detection Range"]) or 0, "NUMBER")
    C4:AddVariable("LED_DISABLED_NIGHT", Properties["Led Disabled Night"] ~= "Unknown" and BoolToStringBool(Properties["Led Disabled Night"]) or "0", "BOOL")
    C4:AddVariable("SCHEDULE_START_TIME", Properties["Schedule Start Time"], "STRING")
    C4:AddVariable("SCHEDULE_END_TIME", Properties["Schedule End Time"], "STRING")

    Dbg:Debug("Driver OnDriverLateInit done.")
end

-- ON BINDING CHANGES
OBC[3] = function (idBinding, strClass, bIsBound, otherDeviceId, otherBindingId)
	Dbg:Debug("OBC.TEMPERATURE")

	if(bIsBound and Properties["Temperature"] ~= "Unknown") then
        C4:SendToProxy(idBinding, "VALUE_INITIALIZE", { CELSIUS = tonumber(Properties["Temperature"])})
	end
end

OBC[4] = function (idBinding, strClass, bIsBound, otherDeviceId, otherBindingId)
	Dbg:Debug("OBC.HUMIDITY")

	if(bIsBound and Properties["Humidity"] ~= "Unknown") then
        C4:SendToProxy(idBinding, "VALUE_INITIALIZE", { VALUE = tonumber(Properties["Humidity"])})
	end
end

-- ON PROPERTY CHANGES
function OPC.Motion_Sensitivity(motion_sensitivity)
    if(gDeviceData.zigbee_device_id ~= nil) then
        motion_sensitivity = string.lower(motion_sensitivity)

        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["motion_sensitivity"] = motion_sensitivity}) })
    end
end

function OPC.Presence_Detection_Options(presence_detection_options)
    if(gDeviceData.zigbee_device_id ~= nil) then
        presence_detection_options = string.lower(presence_detection_options)

        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["presence_detection_options"] = presence_detection_options}) })
    end
end

function OPC.AI_Interference_Source_Self_Identification(ai_interference_source_self_identification)
    if(gDeviceData.zigbee_device_id ~= nil) then
        local zibgeeValue = string.lower(tostring(ai_interference_source_self_identification)) == "true" and "ON" or "OFF"
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["ai_interference_source_selfidentification"] = zibgeeValue}) })
    end
end

function OPC.AI_Sensitivity_Adaptive(ai_sensitivity_adaptive)
    if(gDeviceData.zigbee_device_id ~= nil) then
        local zibgeeValue = string.lower(tostring(ai_sensitivity_adaptive)) == "true" and "ON" or "OFF"
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["ai_sensitivity_adaptive"] = zibgeeValue}) })
    end
end

function OPC.Absence_Delay_Timer(absence_delay_timer)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["absence_delay_timer"] = tonumber(absence_delay_timer)}) })
    end
end

function OPC.Pir_Detection_Interval(pir_detection_interval)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["pir_detection_interval"] = tonumber(pir_detection_interval)}) })
    end
end

function OPC.Temp_And_Humidity_Sampling(temp_and_humidity_sampling)
    if(gDeviceData.zigbee_device_id ~= nil) then
        temp_and_humidity_sampling = string.lower(temp_and_humidity_sampling)

        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["temp_and_humidity_sampling"] = temp_and_humidity_sampling}) })
    end
end

function OPC.Temp_And_Humidity_Sampling_Period(temp_and_humidity_sampling_period)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["temp_and_humidity_sampling_period"] = tonumber(temp_and_humidity_sampling_period)}) })
    end
end

function OPC.Temp_Reporting_Interval(temp_reporting_interval)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["temp_reporting_interval"] = tonumber(temp_reporting_interval)}) })
    end
end

function OPC.Temp_Reporting_Threshold(temp_reporting_threshold)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["temp_reporting_threshold"] = tonumber(temp_reporting_threshold)}) })
    end
end

function OPC.Temp_Reporting_Mode(temp_reporting_mode)
    if(gDeviceData.zigbee_device_id ~= nil) then
        temp_reporting_mode = string.lower(temp_reporting_mode)

        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["temp_reporting_mode"] = temp_reporting_mode}) })
    end
end

function OPC.Humidity_Reporting_Interval(humidity_reporting_interval)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["humidity_reporting_interval"] = tonumber(humidity_reporting_interval)}) })
    end
end

function OPC.Humidity_Reporting_Threshold(humidity_reporting_threshold)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["humidity_reporting_threshold"] = tonumber(humidity_reporting_threshold)}) })
    end
end

function OPC.Humidity_Report_Mode(humidity_report_mode)
    if(gDeviceData.zigbee_device_id ~= nil) then
        humidity_report_mode = string.lower(humidity_report_mode)

        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["humidity_report_mode"] = humidity_report_mode}) })
    end
end

function OPC.Light_Sampling(light_sampling)
    if(gDeviceData.zigbee_device_id ~= nil) then
        light_sampling = string.lower(light_sampling)

        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["light_sampling"] = light_sampling}) })
    end
end

function OPC.Light_Sampling_Period(light_sampling_period)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["light_sampling_period"] = tonumber(light_sampling_period)}) })
    end
end

function OPC.Light_Reporting_Interval(light_reporting_interval)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["light_reporting_interval"] = tonumber(light_reporting_interval)}) })
    end
end

function OPC.Light_Reporting_Threshold(light_reporting_threshold)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["light_reporting_threshold"] = tonumber(light_reporting_threshold)}) })
    end
end

function OPC.Light_Report_Mode(light_report_mode)
    if(gDeviceData.zigbee_device_id ~= nil) then
        light_report_mode = string.lower(light_report_mode)

        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["light_report_mode"] = light_report_mode}) })
    end
end

function OPC.Detection_Range(detection_range)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["detection_range"] = tonumber(detection_range)}) })
    end
end

function OPC.Led_Disabled_Night(led_disabled_night)
    if(gDeviceData.zigbee_device_id ~= nil) then
        local zigbeeValue = string.lower(tostring(led_disabled_night)) == "true" and true or false
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["led_disabled_night"] = zigbeeValue}) })
    end
end

function OPC.Schedule_Start_Time(schedule_start_time)
    if(gDeviceData.zigbee_device_id ~= nil) then
        C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["schedule_start_time"] = schedule_start_time}) })
    end
end

function OPC.Schedule_End_Time(schedule_end_time)
  if(gDeviceData.zigbee_device_id ~= nil) then
      C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["schedule_end_time"] = schedule_end_time}) })
  end
end

-- EXECUTE COMMANDS
function EX_CMD.SET_MOTION_SENSITIVITY(tParams)
    OPC.Motion_Sensitivity(tParams["Sensitivity"])
end

function EX_CMD.SET_PRESENCE_DETECTION_OPTIONS(tParams)
    OPC.Presence_Detection_Options(tParams["Options"])
end

function EX_CMD.SET_AI_INTERFERENCE_SOURCE_SELF_IDENTIFICATION(tParams)
    OPC.Ai_Interference_Source_Self_Identification(tParams["SelfIdentification"])
end

function EX_CMD.SET_AI_SENSITIVITY_ADAPTIVE(tParams)
    OPC.Ai_Sensitivity_Adaptive(tParams["Adaptive"])
end

function EX_CMD.SET_ABSENCE_DELAY_TIMER(tParams)
    OPC.Absence_Delay_Timer(tParams["Timer"])
end

function EX_CMD.SET_PIR_DETECTION_INTERVAL(tParams)
    OPC.Pir_Detection_Interval(tParams["Interval"])
end

function EX_CMD.SET_TEMP_AND_HUMIDITY_SAMPLING(tParams)
    OPC.Temp_And_Humidity_Sampling(tParams["Sampling"])
end

function EX_CMD.SET_TEMP_AND_HUMIDITY_SAMPLING_PERIOD(tParams)
    OPC.Temp_And_Humidity_Sampling_Period(tParams["Period"])
end

function EX_CMD.SET_TEMP_REPORTING_INTERVAL(tParams)
    OPC.Temp_Reporting_Interval(tParams["Interval"])
end

function EX_CMD.SET_TEMP_REPORTING_THRESHOLD(tParams)
    OPC.Temp_Reporting_Threshold(tParams["Threshold"])
end

function EX_CMD.SET_TEMP_REPORTING_MODE(tParams)
    OPC.Temp_Reporting_Mode(tParams["Mode"])
end

function EX_CMD.SET_HUMIDITY_REPORTING_INTERVAL(tParams)         
    OPC.Humidity_Reporting_Interval(tParams["Interval"])
end

function EX_CMD.SET_HUMIDITY_REPORTING_THRESHOLD(tParams)
    OPC.Humidity_Reporting_Threshold(tParams["Threshold"])
end

function EX_CMD.SET_HUMIDITY_REPORT_MODE(tParams)
    OPC.Humidity_Report_Mode(tParams["Mode"])
end

function EX_CMD.SET_LIGHT_SAMPLING(tParams)
    OPC.Light_Sampling(tParams["Sampling"])
end

function EX_CMD.SET_LIGHT_SAMPLING_PERIOD(tParams)
    OPC.Light_Sampling_Period(tParams["Period"])
end

function EX_CMD.SET_LIGHT_REPORTING_INTERVAL(tParams)
    OPC.Light_Reporting_Interval(tParams["Interval"])
end

function EX_CMD.SET_LIGHT_REPORTING_THRESHOLD(tParams)
    OPC.Light_Reporting_Threshold(tParams["Threshold"])
end

function EX_CMD.SET_LIGHT_REPORT_MODE(tParams)
    OPC.Light_Report_Mode(tParams["Mode"])
end

function EX_CMD.SET_DETECTION_RANGE(tParams)
    OPC.Detection_Range(tParams["Range"])
end

function EX_CMD.SET_LED_DISABLED_NIGHT(tParams)
    OPC.Led_Disabled_Night(tParams["Disabled"])
end

function EX_CMD.SET_SCHEDULE_START_TIME(tParams)
    OPC.Schedule_Start_Time(tParams["Start Time"])
end

function EX_CMD.SET_SCHEDULE_END_TIME(tParams)
  OPC.Schedule_End_Time(tParams["End Time"])
end

function EX_CMD.START_SPATIAL_LEARNING(tParams)
  if(gDeviceData.zigbee_device_id ~= nil) then
      C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["spatial_learning"] = "Start Learning"}) })
  end
end

function EX_CMD.RESTART(tParams)
  if(gDeviceData.zigbee_device_id ~= nil) then
      C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["restart_device"] = "Restart Device"}) })
  end
end

function EX_CMD.IDENTIFY(tParams)
  if(gDeviceData.zigbee_device_id ~= nil) then
      C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["identify"] = "identify"}) })
  end
end

function EX_CMD.TRACK_TARGET_DISTANCE(tParams)
  if(gDeviceData.zigbee_device_id ~= nil) then
      C4:SendToProxy(999, "UPDATE_DEVICE", { ZIGBEE_DEVICE = tostring(gDeviceData.zigbee_device_id), ZIGBEE_TOPIC = "/set", content = C4:JsonEncode({ ["track_target_distance"] = "start_tracking_distance"}) })
  end
end

-- DEVICE STATE UPDATES
function DEVICE_SYNC.POWER_OUTAGE_COUNT(power_outage_count)
    if string.lower(tostring(power_outage_count)) ~= string.lower(Properties["Power Outage Count"]) then
        C4:UpdateProperty("Power Outage Count", tostring(power_outage_count))

        C4:SetVariable("POWER_OUTAGE_COUNT", tonumber(power_outage_count))
        C4:FireEvent("When The Power Outage Count Changes")
    end
end

function DEVICE_SYNC.MOTION_SENSITIVITY(motion_sensitivity)
    local motionSensitivity = tostring(motion_sensitivity)

    if(string.lower(motionSensitivity) ~= string.lower(Properties["Motion Sensitivity"])) then
        C4:UpdateProperty("Motion Sensitivity", Capitalize(string.lower(motionSensitivity)))

        C4:SetVariable("MOTION_SENSITIVITY", tostring(motionSensitivity))
        C4:FireEvent("When The Motion Sensitivity Changes")
    end
end

function DEVICE_SYNC.BATTERY(battery)
    if string.lower(tostring(battery)) ~= string.lower(Properties["Battery Level"]) then
        C4:UpdateProperty("Battery Level", tostring(battery))

        C4:SetVariable("BATTERY_LEVEL", tonumber(battery))
        C4:FireEvent("When The Battery Level Changes")
    end
end

function DEVICE_SYNC.VOLTAGE(voltage)
    if string.lower(tostring(voltage)) ~= string.lower(Properties["Voltage"]) then
        C4:UpdateProperty("Voltage", tostring(voltage))

        C4:SetVariable("VOLTAGE", tonumber(voltage))
        C4:FireEvent("When The Voltage Changes")
    end
end

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

function DEVICE_SYNC.PIR_DETECTION(pir_detection)
    if string.lower(tostring(pir_detection)) ~= string.lower(Properties["Pir Detection"]) then
        C4:UpdateProperty("Pir Detection", Capitalize(pir_detection))

        C4:SetVariable("PIR_DETECTION", BoolToStringBool(pir_detection))
        C4:FireEvent("When The Pir Detection Changes")

        if string.lower(tostring(pir_detection)) == "true" then
            C4:SendToProxy(2, "OPENED",{}, "NOTIFY")
        elseif string.lower(tostring(pir_detection)) == "false" then
            C4:SendToProxy(2, "CLOSED",{}, "NOTIFY")
        end
    end
end

function DEVICE_SYNC.PRESENCE_DETECTION_OPTIONS(presence_detection_options)
    if(string.lower(tostring(presence_detection_options)) ~= string.lower(Properties["Presence Detection Options"])) then
        if(string.lower(tostring(presence_detection_options)) == "mmwave") then
            C4:UpdateProperty("Presence Detection Options", "MMWave")
        else
            C4:UpdateProperty("Presence Detection Options", Capitalize(string.lower(presence_detection_options)))
        end

        C4:SetVariable("PRESENCE_DETECTION_OPTIONS", tostring(presence_detection_options))
        C4:FireEvent("When The Presence Detection Options Changes")
    end
end

function DEVICE_SYNC.AI_INTERFERENCE_SOURCE_SELFIDENTIFICATION(ai_interference_source_self_identification)
    local boolValue = string.lower(tostring(ai_interference_source_self_identification)) == "on" and true or false

    if string.lower(tostring(boolValue)) ~= string.lower(Properties["AI Interference Source Self Identification"]) then
        C4:UpdateProperty("AI Interference Source Self Identification", Capitalize(boolValue))

        C4:SetVariable("AI_INTERFERENCE_SOURCE_SELF_IDENTIFICATION", BoolToStringBool(boolValue))
        C4:FireEvent("When The AI Interference Source Self Identification Changes")
    end
end

function DEVICE_SYNC.AI_SENSITIVITY_ADAPTIVE(ai_sensitivity_adaptive)
    local boolValue = string.lower(tostring(ai_sensitivity_adaptive)) == "on" and true or false

    if string.lower(tostring(boolValue)) ~= string.lower(Properties["AI Sensitivity Adaptive"]) then
        C4:UpdateProperty("AI Sensitivity Adaptive", Capitalize(boolValue))

        C4:SetVariable("AI_SENSITIVITY_ADAPTIVE", BoolToStringBool(boolValue))
        C4:FireEvent("When The Ai Sensitivity Adaptive Changes")
    end
end

function DEVICE_SYNC.ABSENCE_DELAY_TIMER(absence_delay_timer)
    if string.lower(tostring(absence_delay_timer)) ~= string.lower(Properties["Absence Delay Timer"]) then
        C4:UpdateProperty("Absence Delay Timer", tostring(absence_delay_timer))

        C4:SetVariable("ABSENCE_DELAY_TIMER", tonumber(absence_delay_timer))
        C4:FireEvent("When The Absence Delay Timer Changes")
    end
end

function DEVICE_SYNC.PIR_DETECTION_INTERVAL(pir_detection_interval)
    if string.lower(tostring(pir_detection_interval)) ~= string.lower(Properties["Pir Detection Interval"]) then
        C4:UpdateProperty("Pir Detection Interval", tostring(pir_detection_interval))

        C4:SetVariable("PIR_DETECTION_INTERVAL", tonumber(pir_detection_interval))
        C4:FireEvent("When The Pir Detection Interval Changes")
    end
end

function DEVICE_SYNC.ILLUMINANCE(illuminance)
    if string.lower(tostring(illuminance)) ~= string.lower(Properties["Illuminance"]) then
        C4:UpdateProperty("Illuminance", tostring(illuminance))

        C4:SetVariable("ILLUMINANCE", tonumber(illuminance))
        C4:FireEvent("When The Illuminance Changes")
    end
end

function DEVICE_SYNC.HUMIDITY(humidity)
    if string.lower(tostring(humidity)) ~= string.lower(Properties["Humidity"]) then
        C4:UpdateProperty("Humidity", tostring(humidity))

        C4:SetVariable("HUMIDITY", tonumber(humidity))
        C4:FireEvent("When The Humidity Changes")

        C4:SendToProxy(4, "VALUE_CHANGED", { VALUE = tonumber(humidity)})
    end
end

function DEVICE_SYNC.TEMPERATURE(temperature)
    if string.lower(tostring(temperature)) ~= string.lower(Properties["Temperature"]) then
        C4:UpdateProperty("Temperature", tostring(temperature))

        C4:SetVariable("TEMPERATURE", tonumber(temperature))
        C4:FireEvent("When The Temperature Changes")

        C4:SendToProxy(3, "VALUE_CHANGED", { CELSIUS = tonumber(temperature)})
    end
end

function DEVICE_SYNC.TEMP_AND_HUMIDITY_SAMPLING(temp_and_humidity_sampling)
    if(string.lower(tostring(temp_and_humidity_sampling)) ~= string.lower(Properties["Temp And Humidity Sampling"])) then
        C4:UpdateProperty("Temp And Humidity Sampling", Capitalize(string.lower(temp_and_humidity_sampling)))

        C4:SetVariable("TEMP_AND_HUMIDITY_SAMPLING", tostring(temp_and_humidity_sampling))
        C4:FireEvent("When The Temp And Humidity Sampling Changes")
    end
end

function DEVICE_SYNC.TEMP_AND_HUMIDITY_SAMPLING_PERIOD(temp_and_humidity_sampling_period)
    if string.lower(tostring(temp_and_humidity_sampling_period)) ~= string.lower(Properties["Temp And Humidity Sampling Period"]) then
        C4:UpdateProperty("Temp And Humidity Sampling Period", tostring(temp_and_humidity_sampling_period))

        C4:SetVariable("TEMP_AND_HUMIDITY_SAMPLING_PERIOD", tonumber(temp_and_humidity_sampling_period))
        C4:FireEvent("When The Temp And Humidity Sampling Period Changes")
    end
end

function DEVICE_SYNC.TEMP_REPORTING_INTERVAL(temp_reporting_interval)
    if string.lower(tostring(temp_reporting_interval)) ~= string.lower(Properties["Temp Reporting Interval"]) then
        C4:UpdateProperty("Temp Reporting Interval", tostring(temp_reporting_interval))

        C4:SetVariable("TEMP_REPORTING_INTERVAL", tonumber(temp_reporting_interval))
        C4:FireEvent("When The Temp Reporting Interval Changes")
    end
end

function DEVICE_SYNC.TEMP_REPORTING_THRESHOLD(temp_reporting_threshold)
    if string.lower(tostring(temp_reporting_threshold)) ~= string.lower(Properties["Temp Reporting Threshold"]) then
        C4:UpdateProperty("Temp Reporting Threshold", tostring(temp_reporting_threshold))

        C4:SetVariable("TEMP_REPORTING_THRESHOLD", tonumber(temp_reporting_threshold))
        C4:FireEvent("When The Temp Reporting Threshold Changes")
    end
end

function DEVICE_SYNC.TEMP_REPORTING_MODE(temp_reporting_mode)
    if(string.lower(tostring(temp_reporting_mode)) ~= string.lower(Properties["Temp Reporting Mode"])) then
        C4:UpdateProperty("Temp Reporting Mode", Capitalize(string.lower(temp_reporting_mode)))

        C4:SetVariable("TEMP_REPORTING_MODE", tostring(temp_reporting_mode))
        C4:FireEvent("When The Temp Reporting Mode Changes")
    end
end

function DEVICE_SYNC.HUMIDITY_REPORTING_INTERVAL(humidity_reporting_interval)
    if string.lower(tostring(humidity_reporting_interval)) ~= string.lower(Properties["Humidity Reporting Interval"]) then
        C4:UpdateProperty("Humidity Reporting Interval", tostring(humidity_reporting_interval))

        C4:SetVariable("HUMIDITY_REPORTING_INTERVAL", tonumber(humidity_reporting_interval))
        C4:FireEvent("When The Humidity Reporting Interval Changes")
    end
end

function DEVICE_SYNC.HUMIDITY_REPORTING_THRESHOLD(humidity_reporting_threshold)
    if string.lower(tostring(humidity_reporting_threshold)) ~= string.lower(Properties["Humidity Reporting Threshold"]) then
        C4:UpdateProperty("Humidity Reporting Threshold", tostring(humidity_reporting_threshold))

        C4:SetVariable("HUMIDITY_REPORTING_THRESHOLD", tonumber(humidity_reporting_threshold))
        C4:FireEvent("When The Humidity Reporting Threshold Changes")
    end
end

function DEVICE_SYNC.HUMIDITY_REPORT_MODE(humidity_report_mode)
    if(string.lower(tostring(humidity_report_mode)) ~= string.lower(Properties["Humidity Report Mode"])) then
        C4:UpdateProperty("Humidity Report Mode", Capitalize(string.lower(humidity_report_mode)))

        C4:SetVariable("HUMIDITY_REPORT_MODE", tostring(humidity_report_mode))
        C4:FireEvent("When The Humidity Report Mode Changes")
    end
end

function DEVICE_SYNC.LIGHT_SAMPLING(light_sampling)
    if(string.lower(tostring(light_sampling)) ~= string.lower(Properties["Light Sampling"])) then
        C4:UpdateProperty("Light Sampling", Capitalize(string.lower(light_sampling)))

        C4:SetVariable("LIGHT_SAMPLING", tostring(light_sampling))
        C4:FireEvent("When The Light Sampling Changes")
    end
end

function DEVICE_SYNC.LIGHT_SAMPLING_PERIOD(light_sampling_period)
    if string.lower(tostring(light_sampling_period)) ~= string.lower(Properties["Light Sampling Period"]) then
        C4:UpdateProperty("Light Sampling Period", tostring(light_sampling_period))

        C4:SetVariable("LIGHT_SAMPLING_PERIOD", tonumber(light_sampling_period))
        C4:FireEvent("When The Light Sampling Period Changes")
    end
end

function DEVICE_SYNC.LIGHT_REPORTING_INTERVAL(light_reporting_interval)
    if string.lower(tostring(light_reporting_interval)) ~= string.lower(Properties["Light Reporting Interval"]) then
        C4:UpdateProperty("Light Reporting Interval", tostring(light_reporting_interval))

        C4:SetVariable("LIGHT_REPORTING_INTERVAL", tonumber(light_reporting_interval))
        C4:FireEvent("When The Light Reporting Interval Changes")
    end
end

function DEVICE_SYNC.LIGHT_REPORTING_THRESHOLD(light_reporting_threshold)
    if string.lower(tostring(light_reporting_threshold)) ~= string.lower(Properties["Light Reporting Threshold"]) then
        C4:UpdateProperty("Light Reporting Threshold", tostring(light_reporting_threshold))

        C4:SetVariable("LIGHT_REPORTING_THRESHOLD", tonumber(light_reporting_threshold))
        C4:FireEvent("When The Light Reporting Threshold Changes")
    end
end

function DEVICE_SYNC.LIGHT_REPORT_MODE(light_report_mode)
    if(string.lower(tostring(light_report_mode)) ~= string.lower(Properties["Light Report Mode"])) then
        C4:UpdateProperty("Light Report Mode", Capitalize(string.lower(light_report_mode)))

        C4:SetVariable("LIGHT_REPORT_MODE", tostring(light_report_mode))
        C4:FireEvent("When The Light Report Mode Changes")
    end
end

function DEVICE_SYNC.TARGET_DISTANCE(target_distance)
    if string.lower(tostring(target_distance)) ~= string.lower(Properties["Target Distance"]) then
        C4:UpdateProperty("Target Distance", tostring(target_distance))

        C4:SetVariable("TARGET_DISTANCE", tonumber(target_distance))
        C4:FireEvent("When The Target Distance Changes")
    end
end

function DEVICE_SYNC.DETECTION_RANGE(detection_range)
    if string.lower(tostring(detection_range)) ~= string.lower(Properties["Detection Range"]) then
        C4:UpdateProperty("Detection Range", tostring(detection_range))

        C4:SetVariable("DETECTION_RANGE", tonumber(detection_range))
        C4:FireEvent("When The Detection Range Changes")
    end
end

function DEVICE_SYNC.LED_DISABLED_NIGHT(led_disabled_night)
    if string.lower(tostring(led_disabled_night)) ~= string.lower(Properties["Led Disabled Night"]) then
        C4:UpdateProperty("Led Disabled Night", Capitalize(led_disabled_night))

        C4:SetVariable("LED_DISABLED_NIGHT", BoolToStringBool(led_disabled_night))
        C4:FireEvent("When The Led Disabled Night Changes")
    end
end

function DEVICE_SYNC.SCHEDULE_START_TIME(schedule_start_time)
    if(string.lower(tostring(schedule_start_time)) ~= string.lower(Properties["Schedule Start Time"])) then
        C4:UpdateProperty("Schedule Start Time", tostring(schedule_start_time))

        C4:SetVariable("SCHEDULE_START_TIME", tostring(schedule_start_time))
        C4:FireEvent("When The Schedule Start Time Changes")
    end
end

function DEVICE_SYNC.SCHEDULE_END_TIME(schedule_end_time)
    if(string.lower(tostring(schedule_end_time)) ~= string.lower(Properties["Schedule End Time"])) then
        C4:UpdateProperty("Schedule End Time", tostring(schedule_end_time))

        C4:SetVariable("SCHEDULE_END_TIME", tostring(schedule_end_time))
        C4:FireEvent("When The Schedule End Time Changes")
    end
end

-- CONDITIONALS
function CONDITIONALS.BOOL_PRESENCE(tParams)
    local value = tParams["VALUE"]
    return string.lower(value) == string.lower(Properties["Presence"])
end

function CONDITIONALS.BOOL_PIR_DETECTION(tParams)
    local value = tParams["VALUE"]
    return string.lower(value) == string.lower(Properties["Pir Detection"])
end

function CONDITIONALS.BOOL_AI_INTERFERENCE_SOURCE_SELF_IDENTIFICATION(tParams)
    local value = tParams["VALUE"]
    return string.lower(value) == string.lower(Properties["AI Interference Source Self Identification"])
end

function CONDITIONALS.BOOL_AI_SENSITIVITY_ADAPTIVE(tParams)
  local value = tParams["VALUE"]
  return string.lower(value) == string.lower(Properties["AI Sensitivity Adaptive"])
end

function CONDITIONALS.BOOL_LED_DISABLED_NIGHT(tParams)
    local value = tParams["VALUE"]
    return string.lower(value) == string.lower(Properties["Led Disabled Night"])
end

function CONDITIONALS.NUMBER_POWER_OUTAGE_COUNT(tParams)
    if Properties["Power Outage Count"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Power Outage Count"]), tonumber(strValue))
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

function CONDITIONALS.NUMBER_VOLTAGE(tParams)
    if Properties["Voltage"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Voltage"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_ABSENCE_DELAY_TIMER(tParams)
    if Properties["Absence Delay Timer"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Absence Delay Timer"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_PIR_DETECTION_INTERVAL(tParams)
    if Properties["Pir Detection Interval"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Pir Detection Interval"]), tonumber(strValue))
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

function CONDITIONALS.NUMBER_HUMIDITY(tParams)
    if Properties["Humidity"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Humidity"]), tonumber(strValue))
    else
        return false
    end
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

function CONDITIONALS.NUMBER_TEMP_AND_HUMIDITY_SAMPLING_PERIOD(tParams)
    if Properties["Temp And Humidity Sampling Period"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Temp And Humidity Sampling Period"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_TEMP_REPORTING_INTERVAL(tParams)
    if Properties["Temp Reporting Interval"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Temp Reporting Interval"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_TEMP_REPORTING_THRESHOLD(tParams)
    if Properties["Temp Reporting Threshold"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Temp Reporting Threshold"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_HUMIDITY_REPORTING_INTERVAL(tParams)
    if Properties["Humidity Reporting Interval"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Humidity Reporting Interval"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_HUMIDITY_REPORTING_THRESHOLD(tParams)
    if Properties["Humidity Reporting Threshold"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Humidity Reporting Threshold"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_LIGHT_SAMPLING_PERIOD(tParams)
    if Properties["Light Sampling Period"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Light Sampling Period"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_LIGHT_REPORTING_INTERVAL(tParams)
    if Properties["Light Reporting Interval"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Light Reporting Interval"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_LIGHT_REPORTING_THRESHOLD(tParams)
    if Properties["Light Reporting Threshold"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Light Reporting Threshold"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_TARGET_DISTANCE(tParams)
    if Properties["Target Distance"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Target Distance"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.NUMBER_DETECTION_RANGE(tParams)
    if Properties["Detection Range"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Detection Range"]), tonumber(strValue))
    else
        return false
    end
end

function CONDITIONALS.LIST_MOTION_SENSITIVITY(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Motion Sensitivity"], strValue)
end

function CONDITIONALS.LIST_PRESENCE_DETECTION_OPTIONS(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Presence Detection Options"], strValue)
end

function CONDITIONALS.LIST_TEMP_AND_HUMIDITY_SAMPLING(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Temp And Humidity Sampling"], strValue)
end

function CONDITIONALS.LIST_TEMP_REPORTING_MODE(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Temp Reporting Mode"], strValue)
end

function CONDITIONALS.LIST_HUMIDITY_REPORT_MODE(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Humidity Report Mode"], strValue)
end

function CONDITIONALS.LIST_LIGHT_SAMPLING(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Light Sampling"], strValue)
end

function CONDITIONALS.LIST_LIGHT_REPORT_MODE(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Light Report Mode"], strValue)
end

function CONDITIONALS.LIST_SCHEDULE_START_TIME(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Schedule Start Time"], strValue)
end

function CONDITIONALS.LIST_SCHEDULE_END_TIME(tParams)
    local logic = tParams["LOGIC"]
    local strValue = tParams["VALUE"]
    return C4:EvaluateExpression(logic, Properties["Schedule End Time"], strValue)
end
