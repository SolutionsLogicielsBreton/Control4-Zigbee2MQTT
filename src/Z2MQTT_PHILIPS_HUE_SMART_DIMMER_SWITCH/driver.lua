JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

gButtonHandler = require('common.button_handler')

gButtons = {
    gButtonHandler.new({
        id = 1,
        pressEvent = "When Top Button Is Pressed",
        releaseEvent = "When Top Button Press Is Released",
        holdEvent = "When Top Button Is Held",
        holdReleaseEvent = "When Top Button Hold Is Released"
    }),
    gButtonHandler.new({
        id = 2,
        pressEvent = "When Dim Up Button Is Pressed",
        releaseEvent = "When Dim Up Button Press Is Released",
        holdEvent = "When Dim Up Button Is Held",
        holdReleaseEvent = "When Dim Up Button Hold Is Released"
    }),
    gButtonHandler.new({
        id = 3,
        pressEvent = "When Dim Down Button Is Pressed",
        releaseEvent = "When Dim Down Button Press Is Released",
        holdEvent = "When Dim Down Button Is Held",
        holdReleaseEvent = "When Dim Down Button Hold Is Released"
    }),
    gButtonHandler.new({
        id = 4,
        pressEvent = "When Bottom Button Is Pressed",
        releaseEvent = "When Bottom Button Press Is Released",
        holdEvent = "When Bottom Button Is Held",
        holdReleaseEvent = "When Bottom Button Hold Is Released"
    })
}

-- NAME USED FOR LOGGING
gLogName = "Z2MQTT_PHILIPS_HUE_SMART_DIMMER_SWITCH"
gTopButtonClickTimer = nil
gDimUpButtonClickTimer = nil
gDimDownButtonClickTimer = nil
gBottomButtonClickTimer = nil

gTopButtonLastAction = nil
gDimUpButtonLastAction = nil
gDimDownButtonLastAction = nil
gBottomButtonLastAction = nil

function ON_DRIVER_LATEINIT.DRIVER (dit)
    C4:AddVariable("BATTERY_LEVEL", Properties["Battery Level"] ~= "Unknown" and tonumber(Properties["Battery Level"]) or 0, "NUMBER")
    Dbg:Debug("Driver OnDriverLateInit done.")
end

function DEVICE_SYNC.BATTERY(battery)
    if string.lower(tostring(battery)) ~= string.lower(Properties["Battery Level"]) then
        C4:UpdateProperty("Battery Level", tostring(battery));

        C4:SetVariable("BATTERY_LEVEL", tonumber(battery))
        C4:FireEvent("When The Battery Level Changes")
    end
end

function DEVICE_SYNC.ACTION(action)
    action = string.lower(action)

    -- Map action names to button handlers
    local buttonActions = {
        ["on_press"] = gButtons[1],
        ["on_press_release"] = gButtons[1],
        ["on_hold_release"] = gButtons[1],
        ["on_hold"] = gButtons[1],

        ["up_press"] = gButtons[2],
        ["up_press_release"] = gButtons[2],
        ["up_hold_release"] = gButtons[2],
        ["up_hold"] = gButtons[2],

        ["down_press"] = gButtons[3],
        ["down_press_release"] = gButtons[3],
        ["down_hold_release"] = gButtons[3],
        ["down_hold"] = gButtons[3],

        ["off_press"] = gButtons[4],
        ["off_press_release"] = gButtons[4],
        ["off_hold_release"] = gButtons[4],
        ["off_hold"] = gButtons[4]
    }

    local buttonHandler = buttonActions[action]

    if buttonHandler then
        local normalizedAction = NormalizeAction(action)
        buttonHandler:handleAction(normalizedAction)
    end
end

function NormalizeAction(action)
    local firstUnderscorePos = string.find(action, "_")

    if firstUnderscorePos then
        return string.sub(action, firstUnderscorePos + 1)
    end

    return action
end

-- CONDITIONALS
function CONDITIONALS.NUMBER_BATTERY_LEVEL(tParams)
    if Properties["Battery Level"] ~= "Unknown" then
        local logic = tParams["LOGIC"]
        local strValue = tParams["VALUE"]
        return C4:EvaluateExpression(logic, tonumber(Properties["Battery Level"]), tonumber(strValue))
    else
        return false
    end
end