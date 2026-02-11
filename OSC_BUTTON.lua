-- Orbital Strike Cannon - Button Controller
-- This runs on each individual button computer (65 total)
-- One computer per button on the control panel

-- CONFIGURATION - CHANGE THIS FOR EACH BUTTON!
local MY_SIGNAL = 27  -- Change this! (e.g., B7=27, C7=37, E5=55, M10=1310, etc.)
local REDSTONE_SIDE = "bottom"  -- Side where button/relay is connected

-- Network configuration
local MODEM_SIDE = "back"  -- Side where wired modem is attached

-- Initialize
print("=================================")
print("  OSC Button Controller")
print("=================================")
print("My Signal: " .. MY_SIGNAL)
print("Output Side: " .. REDSTONE_SIDE)
print("")

-- Find and wrap the modem
local modem = peripheral.find("modem") or peripheral.wrap(MODEM_SIDE)
if not modem then
    error("No modem found! Attach a wired modem.")
end

-- Make sure it's open for network messages
if modem.isWireless() then
    error("This needs a WIRED modem, not wireless!")
end

print("Wired modem found!")
print("Waiting for commands...")
print("")

-- Main loop - listen for commands
while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    
    -- Check if message is for us
    if type(message) == "table" and message.signal == MY_SIGNAL then
        local command = message.command
        
        if command == "activate" then
            print("[" .. os.date("%H:%M:%S") .. "] ACTIVATE")
            rs.setOutput(REDSTONE_SIDE, true)
            
        elseif command == "deactivate" then
            print("[" .. os.date("%H:%M:%S") .. "] Deactivate")
            rs.setOutput(REDSTONE_SIDE, false)
            
        elseif command == "ping" then
            -- Respond to ping for testing
            modem.transmit(channel, replyChannel, {
                signal = MY_SIGNAL,
                status = "online"
            })
            print("[" .. os.date("%H:%M:%S") .. "] Ping received")
        end
    end
end
