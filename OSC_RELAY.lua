-- Orbital Strike Cannon - Redstone Relay Receiver
-- This script runs on the computer controlling the redstone integrators
-- It receives signals and activates the corresponding redstone outputs
-- wget run https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/OSC_RELAY.lua
-- (Or save this file as OSC_RELAY.lua)

-- Configuration
local MODEM_SIDE = "back"  -- Side where modem is attached
local RELAY_CHANNEL = 1000  -- Must match the fire control system
local REDSTONE_MAPPING = {}  -- Maps signal numbers to redstone sides/bundled colors

-- Initialize redstone mapping
-- Format: [signal] = {side = "left", color = colors.white}
-- Signal format: column_index + row_number (e.g., E5 = 55)
local function initializeMapping()
    -- Example mapping for rows 7-11, columns B-N (col 2-14)
    -- You'll need to configure this based on your actual setup
    
    -- Row 7 (index 7)
    REDSTONE_MAPPING[27] = {side = "left", color = colors.white}    -- B7
    REDSTONE_MAPPING[37] = {side = "left", color = colors.orange}   -- C7
    REDSTONE_MAPPING[47] = {side = "left", color = colors.magenta}  -- D7
    REDSTONE_MAPPING[57] = {side = "left", color = colors.lightBlue} -- E7
    REDSTONE_MAPPING[67] = {side = "left", color = colors.yellow}   -- F7
    REDSTONE_MAPPING[77] = {side = "left", color = colors.lime}     -- G7
    REDSTONE_MAPPING[87] = {side = "left", color = colors.pink}     -- H7
    REDSTONE_MAPPING[97] = {side = "left", color = colors.gray}     -- I7
    REDSTONE_MAPPING[107] = {side = "left", color = colors.lightGray} -- J7
    REDSTONE_MAPPING[117] = {side = "left", color = colors.cyan}    -- K7
    REDSTONE_MAPPING[127] = {side = "left", color = colors.purple}  -- L7
    REDSTONE_MAPPING[137] = {side = "left", color = colors.blue}    -- M7
    REDSTONE_MAPPING[147] = {side = "left", color = colors.brown}   -- N7
    
    -- Row 8 (index 8)
    REDSTONE_MAPPING[28] = {side = "right", color = colors.white}   -- B8
    REDSTONE_MAPPING[38] = {side = "right", color = colors.orange}  -- C8
    REDSTONE_MAPPING[48] = {side = "right", color = colors.magenta} -- D8
    REDSTONE_MAPPING[58] = {side = "right", color = colors.lightBlue} -- E8
    REDSTONE_MAPPING[68] = {side = "right", color = colors.yellow}  -- F8
    REDSTONE_MAPPING[78] = {side = "right", color = colors.lime}    -- G8
    REDSTONE_MAPPING[88] = {side = "right", color = colors.pink}    -- H8
    REDSTONE_MAPPING[98] = {side = "right", color = colors.gray}    -- I8
    REDSTONE_MAPPING[108] = {side = "right", color = colors.lightGray} -- J8
    REDSTONE_MAPPING[118] = {side = "right", color = colors.cyan}   -- K8
    REDSTONE_MAPPING[128] = {side = "right", color = colors.purple} -- L8
    REDSTONE_MAPPING[138] = {side = "right", color = colors.blue}   -- M8
    REDSTONE_MAPPING[148] = {side = "right", color = colors.brown}  -- N8
    
    -- Row 9 (index 9) - using "top" side
    REDSTONE_MAPPING[29] = {side = "top", color = colors.white}     -- B9
    REDSTONE_MAPPING[39] = {side = "top", color = colors.orange}    -- C9
    REDSTONE_MAPPING[49] = {side = "top", color = colors.magenta}   -- D9
    REDSTONE_MAPPING[59] = {side = "top", color = colors.lightBlue} -- E9
    REDSTONE_MAPPING[69] = {side = "top", color = colors.yellow}    -- F9
    REDSTONE_MAPPING[79] = {side = "top", color = colors.lime}      -- G9
    REDSTONE_MAPPING[89] = {side = "top", color = colors.pink}      -- H9
    REDSTONE_MAPPING[99] = {side = "top", color = colors.gray}      -- I9
    REDSTONE_MAPPING[109] = {side = "top", color = colors.lightGray} -- J9
    REDSTONE_MAPPING[119] = {side = "top", color = colors.cyan}     -- K9
    REDSTONE_MAPPING[129] = {side = "top", color = colors.purple}   -- L9
    REDSTONE_MAPPING[139] = {side = "top", color = colors.blue}     -- M9
    REDSTONE_MAPPING[149] = {side = "top", color = colors.brown}    -- N9
    
    -- Row 10 (index 10) - using "bottom" side
    REDSTONE_MAPPING[210] = {side = "bottom", color = colors.white}     -- B10
    REDSTONE_MAPPING[310] = {side = "bottom", color = colors.orange}    -- C10
    REDSTONE_MAPPING[410] = {side = "bottom", color = colors.magenta}   -- D10
    REDSTONE_MAPPING[510] = {side = "bottom", color = colors.lightBlue} -- E10
    REDSTONE_MAPPING[610] = {side = "bottom", color = colors.yellow}    -- F10
    REDSTONE_MAPPING[710] = {side = "bottom", color = colors.lime}      -- G10
    REDSTONE_MAPPING[810] = {side = "bottom", color = colors.pink}      -- H10
    REDSTONE_MAPPING[910] = {side = "bottom", color = colors.gray}      -- I10
    REDSTONE_MAPPING[1010] = {side = "bottom", color = colors.lightGray} -- J10
    REDSTONE_MAPPING[1110] = {side = "bottom", color = colors.cyan}     -- K10
    REDSTONE_MAPPING[1210] = {side = "bottom", color = colors.purple}   -- L10
    REDSTONE_MAPPING[1310] = {side = "bottom", color = colors.blue}     -- M10
    REDSTONE_MAPPING[1410] = {side = "bottom", color = colors.brown}    -- N10
    
    -- Row 11 (index 11) - using "front" side
    REDSTONE_MAPPING[211] = {side = "front", color = colors.white}     -- B11
    REDSTONE_MAPPING[311] = {side = "front", color = colors.orange}    -- C11
    REDSTONE_MAPPING[411] = {side = "front", color = colors.magenta}   -- D11
    REDSTONE_MAPPING[511] = {side = "front", color = colors.lightBlue} -- E11
    REDSTONE_MAPPING[611] = {side = "front", color = colors.yellow}    -- F11
    REDSTONE_MAPPING[711] = {side = "front", color = colors.lime}      -- G11
    REDSTONE_MAPPING[811] = {side = "front", color = colors.pink}      -- H11
    REDSTONE_MAPPING[911] = {side = "front", color = colors.gray}      -- I11
    REDSTONE_MAPPING[1011] = {side = "front", color = colors.lightGray} -- J11
    REDSTONE_MAPPING[1111] = {side = "front", color = colors.cyan}     -- K11
    REDSTONE_MAPPING[1211] = {side = "front", color = colors.purple}   -- L11
    REDSTONE_MAPPING[1311] = {side = "front", color = colors.blue}     -- M11
    REDSTONE_MAPPING[1411] = {side = "front", color = colors.brown}    -- N11
end

-- Activate a bundled cable color
local function activateBundled(side, color)
    local current = rs.getBundledOutput(side)
    rs.setBundledOutput(side, colors.combine(current, color))
end

-- Deactivate a bundled cable color
local function deactivateBundled(side, color)
    local current = rs.getBundledOutput(side)
    rs.setBundledOutput(side, colors.subtract(current, color))
end

-- Handle incoming signal
local function handleSignal(message)
    if type(message) ~= "table" then
        return
    end
    
    local signal = message.signal
    local command = message.command
    local cell = message.cell or "unknown"
    
    -- Handle strike button command
    if command == "strike" then
        local side = message.side
        local color = message.color
        local bundled = message.bundled
        
        print(">>> EXECUTING STRIKE BUTTON <<<")
        if bundled then
            activateBundled(side, color)
        else
            rs.setOutput(side, true)
        end
        return
    elseif command == "strike_release" then
        local side = message.side
        local color = message.color
        local bundled = message.bundled
        
        print("Strike button released")
        if bundled then
            deactivateBundled(side, color)
        else
            rs.setOutput(side, false)
        end
        return
    end
    
    -- Handle normal cell signals
    local mapping = REDSTONE_MAPPING[signal]
    if not mapping then
        print("WARNING: No mapping for signal " .. signal .. " (cell " .. cell .. ")")
        return
    end
    
    if command == "activate" then
        print("Activating: " .. cell .. " (signal " .. signal .. ") -> " .. mapping.side)
        activateBundled(mapping.side, mapping.color)
    elseif command == "deactivate" then
        print("Deactivating: " .. cell .. " (signal " .. signal .. ") -> " .. mapping.side)
        deactivateBundled(mapping.side, mapping.color)
    else
        print("Unknown command: " .. tostring(command))
    end
end

-- Main relay loop
local function relayLoop()
    local modem = peripheral.wrap(MODEM_SIDE)
    if not modem then
        error("No modem found on side: " .. MODEM_SIDE)
    end
    
    -- Open channel
    modem.open(RELAY_CHANNEL)
    print("=================================")
    print("  OSC REDSTONE RELAY ACTIVE")
    print("=================================")
    print("Listening on channel: " .. RELAY_CHANNEL)
    print("Modem side: " .. MODEM_SIDE)
    print("\nPress Ctrl+T to terminate\n")
    
    -- Clear all outputs on startup
    local sides = {"left", "right", "top", "bottom", "front"}
    for _, side in ipairs(sides) do
        rs.setBundledOutput(side, 0)
    end
    
    -- Event loop
    while true do
        local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
        
        if senderChannel == RELAY_CHANNEL then
            handleSignal(message)
        end
    end
end

-- Initialize and start
initializeMapping()
relayLoop()
