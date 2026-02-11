-- Orbital Strike Cannon Fire Control System
-- Version 6.1 - Enhanced with Redstone Integration
-- wget run https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/OSC_STRIKECALC.lua
-- (Or save this file as OSC_STRIKECALC.lua)

-- Configuration
local STRIKE_BUTTON_SIDE = "top"  -- Side where the fire/execute button is
local STRIKE_BUTTON_COLOR = colors.red  -- Color for strike execution button
local USE_BUNDLED_FOR_STRIKE = true  -- Set to false if using regular redstone
local weapon_data = {
    origin_x = 0,
    origin_y = 0,
    origin_z = 0,
    target_x = 1000,
    target_y = 0,
    target_z = 1000,
    nuke_size = 1,
    stab_depth = 1,
    weapon_type = "nuke",
    mps = 0,
    passcode = 940
}

-- Button mapping (row 7-11, columns B-N)
-- Each cell represents a button on the control panel
local button_matrix = {
    -- Row 7 (row index 1)
    {false, false, false, false, false, false, false, false, false, false, false, false, false},
    -- Row 8 (row index 2)
    {false, false, false, false, false, false, false, false, false, false, false, false, false},
    -- Row 9 (row index 3)
    {false, false, false, false, false, false, false, false, false, false, false, false, false},
    -- Row 10 (row index 4)
    {false, false, false, false, false, false, false, false, false, false, false, false, false},
    -- Row 11 (row index 5)
    {false, false, false, false, false, false, false, false, false, false, false, false, false}
}

-- Modem configuration
local MODEM_SIDE = "back"  -- Change this to match your modem placement
local RELAY_CHANNEL = 1000  -- Channel for relay communication

-- Column letter to index mapping (B=1, C=2, ..., N=13)
local function columnToIndex(letter)
    return string.byte(letter:upper()) - string.byte('A')
end

-- Convert cell coordinate to signal format (e.g., "E5" -> 55)
local function cellToSignal(cell)
    local col_letter = cell:match("^(%a+)")
    local row_num = tonumber(cell:match("(%d+)$"))
    
    if not col_letter or not row_num then
        return nil
    end
    
    local col_index = columnToIndex(col_letter)
    return tonumber(tostring(col_index) .. tostring(row_num))
end

-- Calculate button states from weapon data
local function calculateButtons()
    -- This is a simplified version - you'll need to implement the full Excel formulas
    -- For now, this creates a sample pattern
    
    -- In real implementation, you'd calculate:
    -- - M2, N2 (coarse/fine for X)
    -- - M3, N3 (coarse/fine for Y)
    -- - M4, N4 (coarse/fine for Z)
    -- - H2 (passcode encoding)
    -- - L11, K11, G11 (weapon type and sign bits)
    
    -- Example: Set some buttons based on passcode
    local passcode = weapon_data.passcode
    
    -- Reset matrix
    for row = 1, 5 do
        for col = 1, 13 do
            button_matrix[row][col] = false
        end
    end
    
    -- Encode passcode into columns M and N (rows 7-11)
    -- Column M is col 12, Column N is col 13
    for bit = 0, 4 do
        local row = bit + 1
        -- M column: higher bits
        button_matrix[row][12] = math.floor(passcode / (2^(9-bit))) % 2 == 1
        -- N column: lower bits  
        button_matrix[row][13] = math.floor(passcode / (2^(4-bit))) % 2 == 1
    end
    
    -- Set weapon type (nuke = 1 in L11)
    if weapon_data.weapon_type == "nuke" then
        button_matrix[5][11] = true  -- L11
    end
    
    return button_matrix
end

-- Print the button matrix (dummy mode)
local function printMatrix()
    print("\n=== Orbital Strike Cannon - Fire Control ===")
    print("Target: X=" .. weapon_data.target_x .. " Y=" .. weapon_data.target_y .. " Z=" .. weapon_data.target_z)
    print("Weapon: " .. weapon_data.weapon_type .. " | Size: " .. weapon_data.nuke_size)
    print("Passcode: " .. weapon_data.passcode)
    print("\n--- Button Matrix ---")
    print("     B  C  D  E  F  G  H  I  J  K  L  M  N")
    
    local row_numbers = {7, 8, 9, 10, 11}
    for row_idx = 1, 5 do
        local row_str = string.format("R%02d:", row_numbers[row_idx])
        for col = 1, 13 do
            row_str = row_str .. " " .. (button_matrix[row_idx][col] and "X" or ".")
        end
        print(row_str)
    end
    print("\n=== End Matrix ===\n")
end

-- Generate list of cells to activate
local function generateCellList()
    local cells = {}
    local col_letters = {"B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N"}
    local row_numbers = {7, 8, 9, 10, 11}
    
    for row_idx = 1, 5 do
        for col = 1, 13 do
            if button_matrix[row_idx][col] then
                local cell = col_letters[col] .. row_numbers[row_idx]
                table.insert(cells, cell)
            end
        end
    end
    
    return cells
end

-- Send redstone signal via modem/relay
local function sendRedstoneSignal(cell_coord, duration)
    duration = duration or 0.5  -- Default pulse duration
    
    local signal = cellToSignal(cell_coord)
    if not signal then
        print("ERROR: Invalid cell coordinate: " .. tostring(cell_coord))
        return false
    end
    
    -- Open modem if not already open
    local modem = peripheral.wrap(MODEM_SIDE)
    if not modem then
        print("ERROR: No modem found on side: " .. MODEM_SIDE)
        return false
    end
    
    if not modem.isOpen(RELAY_CHANNEL) then
        modem.open(RELAY_CHANNEL)
    end
    
    -- Send activation signal
    print("Sending signal " .. signal .. " for cell " .. cell_coord)
    modem.transmit(RELAY_CHANNEL, RELAY_CHANNEL, {
        command = "activate",
        signal = signal,
        cell = cell_coord
    })
    
    -- Wait for pulse duration
    os.sleep(duration)
    
    -- Send deactivation signal
    modem.transmit(RELAY_CHANNEL, RELAY_CHANNEL, {
        command = "deactivate",
        signal = signal,
        cell = cell_coord
    })
    
    return true
end

-- Execute the strike button (final confirmation)
local function executeStrike()
    print("\n>>> EXECUTING STRIKE BUTTON <<<")
    
    local modem = peripheral.wrap(MODEM_SIDE)
    if not modem then
        print("ERROR: No modem found")
        return false
    end
    
    if not modem.isOpen(RELAY_CHANNEL) then
        modem.open(RELAY_CHANNEL)
    end
    
    -- Send strike command
    modem.transmit(RELAY_CHANNEL, RELAY_CHANNEL, {
        command = "strike",
        side = STRIKE_BUTTON_SIDE,
        color = STRIKE_BUTTON_COLOR,
        bundled = USE_BUNDLED_FOR_STRIKE
    })
    
    os.sleep(1)  -- Hold for 1 second
    
    modem.transmit(RELAY_CHANNEL, RELAY_CHANNEL, {
        command = "strike_release",
        side = STRIKE_BUTTON_SIDE,
        color = STRIKE_BUTTON_COLOR,
        bundled = USE_BUNDLED_FOR_STRIKE
    })
    
    print("Strike button pressed!")
    return true
end

-- Calculate strike time based on distance
local function calculateStrikeTime()
    -- Calculate distance from origin to target
    local dx = weapon_data.target_x - weapon_data.origin_x
    local dy = weapon_data.target_y - weapon_data.origin_y
    local dz = weapon_data.target_z - weapon_data.origin_z
    
    local distance = math.sqrt(dx*dx + dy*dy + dz*dz)
    
    -- Orbital strike parameters (adjust these based on your mod/setup)
    local PROJECTILE_SPEED = 100  -- blocks per second (adjust as needed)
    local LAUNCH_DELAY = 5  -- seconds for launch sequence
    
    local flight_time = distance / PROJECTILE_SPEED
    local total_time = LAUNCH_DELAY + flight_time
    
    return total_time, distance
end

-- Countdown timer
local function countdown(seconds, message)
    for i = math.floor(seconds), 1, -1 do
        term.clear()
        term.setCursorPos(1, 1)
        print("=================================")
        print("  " .. message)
        print("=================================")
        print("")
        print("TIME TO IMPACT: " .. i .. " seconds")
        print("")
        if i <= 10 then
            print(">>> WARNING: IMPACT IMMINENT <<<")
        end
        os.sleep(1)
    end
    term.clear()
    term.setCursorPos(1, 1)
    print("=================================")
    print("  *** IMPACT ***")
    print("=================================")
end

-- Execute fire sequence with redstone
local function executeFireSequence(delay_between, execute_strike_after)
    delay_between = delay_between or 0.75  -- Default delay between signals
    
    print("\n=== EXECUTING FIRE SEQUENCE ===")
    local cells = generateCellList()
    
    if #cells == 0 then
        print("WARNING: No buttons to activate!")
        return
    end
    
    print("Total buttons to press: " .. #cells)
    print("\nSequence:")
    for i, cell in ipairs(cells) do
        print("  " .. i .. ". " .. cell .. " (signal: " .. cellToSignal(cell) .. ")")
    end
    
    if execute_strike_after then
        local strike_time, distance = calculateStrikeTime()
        print("\n--- STRIKE PROJECTION ---")
        print("Distance to target: " .. string.format("%.1f", distance) .. " blocks")
        print("Estimated impact time: " .. string.format("%.1f", strike_time) .. " seconds")
    end
    
    print("\nPress ENTER to confirm fire sequence or Q to cancel...")
    local input = read()
    if input:lower() == "q" then
        print("Fire sequence CANCELLED")
        return
    end
    
    print("\n--- FIRING ---")
    for i, cell in ipairs(cells) do
        print("Activating " .. cell .. "...")
        sendRedstoneSignal(cell, 0.5)
        if i < #cells then
            os.sleep(delay_between)
        end
    end
    
    print("\n=== FIRE SEQUENCE COMPLETE ===\n")
    
    if execute_strike_after then
        print("Execute strike button? (Y/N)")
        local confirm = read()
        if confirm:lower() == "y" then
            executeStrike()
            print("\nStrike launched! Starting countdown...")
            os.sleep(2)
            local strike_time, distance = calculateStrikeTime()
            countdown(strike_time, "ORBITAL STRIKE IN PROGRESS")
            print("\nStrike complete!")
        else
            print("Strike button NOT pressed.")
        end
    end
    
    print("\nPress ENTER to continue...")
    read()
end

-- Main menu
local function mainMenu()
    while true do
        term.clear()
        term.setCursorPos(1, 1)
        print("=================================")
        print("  ORBITAL STRIKE CANNON v6.1")
        print("=================================")
        print("\n1. Dummy Mode (Print Matrix)")
        print("2. Fire Mode (Send Signals)")
        print("3. Full Strike (Signals + Execute)")
        print("4. Configure Target")
        print("5. Configure Passcode")
        print("6. Test Single Signal")
        print("7. Calculate Strike Time")
        print("8. Exit")
        print("\nSelect option: ")
        
        local choice = read()
        
        if choice == "1" then
            -- Dummy mode
            calculateButtons()
            printMatrix()
            local cells = generateCellList()
            print("Cells to activate: ")
            for i, cell in ipairs(cells) do
                print("  " .. cell .. " -> Signal " .. cellToSignal(cell))
            end
            print("\nPress ENTER to continue...")
            read()
            
        elseif choice == "2" then
            -- Fire mode (no strike execution)
            calculateButtons()
            printMatrix()
            executeFireSequence(0.75, false)
            
        elseif choice == "3" then
            -- Full strike with execution
            calculateButtons()
            printMatrix()
            executeFireSequence(0.75, true)
            
        elseif choice == "4" then
            -- Configure target
            print("\nEnter Target X: ")
            weapon_data.target_x = tonumber(read()) or weapon_data.target_x
            print("Enter Target Y: ")
            weapon_data.target_y = tonumber(read()) or weapon_data.target_y
            print("Enter Target Z: ")
            weapon_data.target_z = tonumber(read()) or weapon_data.target_z
            print("Target updated!")
            os.sleep(1)
            
        elseif choice == "5" then
            -- Configure passcode
            print("\nEnter Passcode (0-1023): ")
            local pc = tonumber(read())
            if pc and pc >= 0 and pc <= 1023 then
                weapon_data.passcode = pc
                print("Passcode updated!")
            else
                print("Invalid passcode!")
            end
            os.sleep(1)
            
        elseif choice == "6" then
            -- Test single signal
            print("\nEnter cell coordinate (e.g., E5): ")
            local cell = read()
            sendRedstoneSignal(cell, 0.5)
            print("\nPress ENTER to continue...")
            read()
            
        elseif choice == "7" then
            -- Calculate strike time
            local strike_time, distance = calculateStrikeTime()
            print("\n=== STRIKE CALCULATIONS ===")
            print("Origin: " .. weapon_data.origin_x .. ", " .. weapon_data.origin_y .. ", " .. weapon_data.origin_z)
            print("Target: " .. weapon_data.target_x .. ", " .. weapon_data.target_y .. ", " .. weapon_data.target_z)
            print("Distance: " .. string.format("%.1f", distance) .. " blocks")
            print("Estimated time to impact: " .. string.format("%.1f", strike_time) .. " seconds")
            print("\nPress ENTER to continue...")
            read()
            
        elseif choice == "8" then
            print("Shutting down fire control system...")
            break
        end
    end
end

-- Start the program
mainMenu()
