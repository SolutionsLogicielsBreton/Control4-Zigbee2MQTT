JSON = require ('common.json')
Log = require ('common.log')
require ('common.handlers')
require ('common.boilerplate')

gButtonHandler = require('common.button_handler')
gDialHandler = require('common.dial_handler')

gButtons = {
    gButtonHandler.new({
        id = 1,
        pressEvent = "When Button 1 Is Pressed",
        releaseEvent = "When Button 1 Is Released",
        holdEvent = "When Button 1 Is Held",
        clickEvent = "When Button 1 Is Clicked"
    }),
    gButtonHandler.new({
        id = 2,
        pressEvent = "When Button 2 Is Pressed",
        releaseEvent = "When Button 2 Is Released",
        holdEvent = "When Button 2 Is Held",
        clickEvent = "When Button 2 Is Clicked"
    }),
    gButtonHandler.new({
        id = 3,
        pressEvent = "When Button 3 Is Pressed",
        releaseEvent = "When Button 3 Is Released",
        holdEvent = "When Button 3 Is Held",
        clickEvent = "When Button 3 Is Clicked"
    }),
    gButtonHandler.new({
        id = 4,
        pressEvent = "When Button 4 Is Pressed",
        releaseEvent = "When Button 4 Is Released",
        holdEvent = "When Button 4 Is Held",
        clickEvent = "When Button 4 Is Clicked"
    })
}

gDial = gDialHandler.new()

-- NAME USED FOR LOGGING
gLogName = "Z2MQTT_PHILIPS_HUE_TAP_DIAL_SWITCH"

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

    if(action == "dial_rotate_left_step"
        or action == "dial_rotate_left_slow"
        or action == "dial_rotate_left_fast"
        or action == "dial_rotate_right_step"
        or action == "dial_rotate_right_slow"
        or action == "dial_rotate_right_fast") then
        gDial:handleAction(action)
    else
        local buttonActions = {
            ["button_1_press"] = gButtons[1],
            ["button_1_press_release"] = gButtons[1],
            ["button_1_hold"] = gButtons[1],
            ["button_1_hold_release"] = gButtons[1],

            ["button_2_press"] = gButtons[2],
            ["button_2_press_release"] = gButtons[2],
            ["button_2_hold"] = gButtons[2],
            ["button_2_hold_release"] = gButtons[2],

            ["button_3_press"] = gButtons[3],
            ["button_3_press_release"] = gButtons[3],
            ["button_3_hold"] = gButtons[3],
            ["button_3_hold_release"] = gButtons[3],

            ["button_4_press"] = gButtons[4],
            ["button_4_press_release"] = gButtons[4],
            ["button_4_hold"] = gButtons[4],
            ["button_4_hold_release"] = gButtons[4],
        }

        local buttonHandler = buttonActions[action]

        if buttonHandler then
            local normalizedAction = NormalizeAction(action)
            buttonHandler:handleAction(normalizedAction)
        end
    end
end

function NormalizeAction(action)
    local firstUnderscorePos = string.find(action, "_")
    if not firstUnderscorePos then return action end

    -- Find the position after the first underscore
    local secondUnderscorePos = string.find(action, "_", firstUnderscorePos + 1)

    if secondUnderscorePos then
        return string.sub(action, secondUnderscorePos + 1)
    else
        return action
    end
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
