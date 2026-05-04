local mod       = peripheral.wrap("bottom")
local rocket1   = peripheral.wrap("rocket_engine_1")
local rocket2   = peripheral.wrap("rocket_engine_2")
local rocket3   = peripheral.wrap("rocket_engine_3")
local rocket4   = peripheral.wrap("rocket_engine_4")
local rocket5   = peripheral.wrap("rocket_engine_5")
local rocket6   = peripheral.wrap("rocket_engine_6")
local rocket7   = peripheral.wrap("rocket_engine_7")
local rocket8   = peripheral.wrap("rocket_engine_8")
local mon       = peripheral.find("monitor")
local altSensor = peripheral.find("altitude_sensor")
local baseThrust = 0
local running   = true
local Kp        = 2.0
local Ki        = 0.05
local Kd        = 4.0

local function setMultThrust(thrust)
    rocket1.setThrust(thrust)
    rocket2.setThrust(thrust)
    rocket3.setThrust(thrust)
    rocket4.setThrust(thrust)
    rocket5.setThrust(thrust)
    rocket6.setThrust(thrust)
    rocket7.setThrust(thrust)
    rocket8.setThrust(thrust)
end

local function getMultThrust()
    local totalThrust = 0
    totalThrust = totalThrust + rocket1.getThrust()
    totalThrust = totalThrust + rocket2.getThrust()
    totalThrust = totalThrust + rocket3.getThrust()
    totalThrust = totalThrust + rocket4.getThrust()
    totalThrust = totalThrust + rocket5.getThrust()
    totalThrust = totalThrust + rocket6.getThrust()
    totalThrust = totalThrust + rocket7.getThrust()
    totalThrust = totalThrust + rocket8.getThrust()
    return totalThrust / 8
end

local function editTuning()
    mon.clear()
    mon.setCursorPos(1, 1)
    mon.write("Edit tuning? (y/n)")
    local choice = io.read()

    if choice == "y" then
        mon.setCursorPos(1, 2)
        mon.write("Kp (" .. tostring(Kp) .. "):")
        local kpInput = io.read()
        if kpInput ~= "" then Kp = tonumber(kpInput) end

        mon.setCursorPos(1, 3)
        mon.write("Ki (" .. tostring(Ki) .. "):")
        local kiInput = io.read()
        if kiInput ~= "" then Ki = tonumber(kiInput) end

        mon.setCursorPos(1, 4)
        mon.write("Kd (" .. tostring(Kd) .. "):")
        local kdInput = io.read()
        if kdInput ~= "" then Kd = tonumber(kdInput) end

        mon.setCursorPos(1, 5)
        mon.write("Saved: Kp=" .. Kp .. " Ki=" .. Ki .. " Kd=" .. Kd)
        sleep(2)
    end
end

local function hoverCalibration()
    mon.clear()
    mon.setCursorPos(1, 1)
    mon.write("Calibrating...")

    baseThrust = 0
    local stableCount = 0

    setMultThrust(0)

    while baseThrust == 0 do
        local previousAlt = altSensor.getHeight()
        setMultThrust(getMultThrust() + 1)
        sleep(0.1)

        local altChange = altSensor.getHeight() - previousAlt

        if altChange > 1 then
            stableCount = stableCount + 1
            if stableCount >= 5 then
                baseThrust = getMultThrust()
                mon.setCursorPos(1, 2)
                mon.write("Calibrated! Base thrust: " .. tostring(baseThrust))
                sleep(3)
                break
            end
        else
            stableCount = 0
        end
    end
end

local function feedbackLoop(target)
    local previousError = target - altSensor.getHeight()
    local integral      = 0.0

    while running do
        local currentAlt = altSensor.getHeight()
        local error      = target - currentAlt

        integral = integral + (error * 0.1)
        integral = math.max(-100, math.min(100, integral))

        local derivative = (error - previousError) / 0.1

        local correction = 0
        if math.abs(error) > 0.5 then
            correction = (Kp * error) + (Ki * integral) + (Kd * derivative)
        end

        local newtons = math.max(0, math.min(256, math.floor(baseThrust + correction + 0.5)))

        setMultThrust(newtons)

        mon.clear()
        mon.setCursorPos(1, 1)
        mon.write("Height:     " .. tostring(currentAlt))
        mon.setCursorPos(1, 2)
        mon.write("Target:     " .. tostring(target))
        mon.setCursorPos(1, 3)
        mon.write("Error:      " .. tostring(error))
        mon.setCursorPos(1, 4)
        mon.write("Correction: " .. tostring(correction))
        mon.setCursorPos(1, 5)
        mon.write("Newtons:    " .. tostring(newtons))

        previousError = error
        sleep(0.1)
    end
end

local function listenForStop()
    print("Press Q to stop")
    while true do
        local event, key = os.pullEvent("key")
        if key == keys.q then
            running = false
            break
        end
    end
end

local function main()
    mon.clear()
    mon.setCursorPos(1, 1)
    mon.write("Enter base thrust or blank to calibrate:")
    local userChoice = io.read()

    if userChoice ~= "" then
        baseThrust = tonumber(userChoice)
    else
        hoverCalibration()
    end

    sleep(1)
    mon.clear()
    mon.setCursorPos(1, 1)
    mon.write("Choose target height:")
    local targetHeight = tonumber(io.read())

    mon.clear()
    mon.setCursorPos(1, 1)
    mon.write("Enter offset (0 for none):")
    mon.setCursorPos(1, 2)
    mon.write("(compensates for quantization drift)")
    local offset = tonumber(io.read()) or 0
    local adjustedTarget = targetHeight + offset

    mon.clear()
    mon.setCursorPos(1, 1)
    mon.write("Target:   " .. tostring(targetHeight))
    mon.setCursorPos(1, 2)
    mon.write("Offset:   " .. tostring(offset))
    mon.setCursorPos(1, 3)
    mon.write("Adjusted: " .. tostring(adjustedTarget))
    sleep(2)

    running = true
    parallel.waitForAny(
        function() feedbackLoop(adjustedTarget) end,
        listenForStop
    )

    setMultThrust(0)
    editTuning()
    mon.clear()
    mon.setCursorPos(1, 1)
    mon.write("Restarting...")
    sleep(3)
    main()
end

main()
