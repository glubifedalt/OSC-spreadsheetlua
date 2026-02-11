-- Orbital Strike Cannon - Wired Network Relay
-- This script runs on the stationary computer at the cannon
-- It receives wireless signals and relays them to button controllers via wired network
-- wget run https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/OSC_RELAY_WIRED.lua

-- Configuration
local WIRELESS_MODEM_SIDE = "top"  -- Side with wireless modem (receives from portable)
local WIRED_MODEM_SIDE = "back"    -- Side with wired modem (connects to button controllers)
local RELAY_CHANNEL = 1000         -- Must match fire control system

-- For strike button (if not on network, can be direct redstone)
local STRIKE_BUTTON_SIDE = "right"  -- Direct redstone output for strike button
local USE_DIRECT_STRIKE = true      -- true = direct redstone, false = network command

print("=================================")
print("  OSC WIRED NETWORK RELAY")
print("=================================")

-- Find modems
local wirelessModem = peripheral.wrap(WIRELESS_MODEM_SIDE)
local wiredModem = peripheral.wrap(WIRED_MODEM_SIDE)

if not wirelessModem then
    error("No wireless modem found on side: " .. WIRELESS_MODEM_SIDE)
end

if not wiredModem then
    error("No wired modem found on side: " .. WIRED_MODEM_SIDE)
end

if wirelessModem.isWireless() == false then
    error(WIRELESS_MODEM_SIDE .. " has a wired modem, need wireless!")
end

if wiredModem.isWireless() == true then
    error(WIRED_MODEM_SIDE .. " has a wireless modem, need wired!")
end

-- Open wireless channel for receiving from portable computer
wirelessModem.open(RELAY_CHANNEL)

print("Wireless listening on channel: " .. RELAY_CHANNEL)
print("Wired network ready")
print("Strike button side: " .. STRIKE_BUTTON_SIDE)
print("")
print("Relay active! Press Ctrl+T to stop")
print("")

-- Statistics
local messages_relayed = 0
local strike_executions = 0

-- Handle strike button (direct redstone)
local function handleStrike(activate)
    if USE_DIRECT_STRIKE then
        rs.setOutput(STRIKE_BUTTON_SIDE, activate)
        if activate then
            print(">>> STRIKE BUTTON ACTIVATED <<<")
            strike_executions = strike_executions + 1
        else
            print("Strike button released")
        end
    else
        -- Send to network if strike button also on network
        wiredModem.transmit(RELAY_CHANNEL, RELAY_CHANNEL, {
            signal = 9999,  -- Special signal for strike
            command = activate and "activate" or "deactivate"
        })
    end
end

-- Main relay loop
while true do
    local event, modemSide, senderChannel, replyChannel, message, senderDistance = os.pullEvent("modem_message")
    
    -- Only process messages from wireless modem on our channel
    if modemSide == WIRELESS_MODEM_SIDE and senderChannel == RELAY_CHANNEL then
        
        if type(message) ~= "table" then
            print("WARNING: Invalid message format")
        else
            local command = message.command
            local signal = message.signal
            local cell = message.cell or "?"
            
            -- Handle strike button commands
            if command == "strike" then
                handleStrike(true)
                
            elseif command == "strike_release" then
                handleStrike(false)
                
            -- Handle normal button signals
            elseif command == "activate" or command == "deactivate" then
                if signal then
                    -- Relay to wired network
                    wiredModem.transmit(RELAY_CHANNEL, RELAY_CHANNEL, {
                        signal = signal,
                        command = command,
                        cell = cell
                    })
                    
                    messages_relayed = messages_relayed + 1
                    
                    local action = command == "activate" and "ON " or "OFF"
                    print(string.format("[%s] %s -> Signal %d (%s)", 
                        os.date("%H:%M:%S"), action, signal, cell))
                else
                    print("WARNING: No signal in message")
                end
            else
                print("WARNING: Unknown command: " .. tostring(command))
            end
        end
    end
end
