# Orbital Strike Cannon - Wired Network Setup Guide

## What You Need

### Computers:
- **1x Portable Computer** (with wireless modem) - Your fire control terminal
- **1x Advanced Computer** (with 1 wireless + 1 wired modem) - Relay at the cannon
- **65x Basic Computers** (with wired modems) - One per button (can be basic, cheaper!)

### Modems:
- **2x Wireless Modems** (portable computer + relay computer)
- **66x Wired Modems** (relay computer + 65 button controllers)

### Cables:
- **Networking Cable** to connect all 65 button controllers + relay in a network

### Redstone:
- Wire from each button controller to its corresponding button on the cannon control panel

---

## Installation Steps

### Step 1: Set Up the Portable Computer (Fire Control)

```lua
edit OSC_STRIKECALC.lua
-- [Paste the fire control code]
-- [Save]
```

Attach wireless modem to any side (default: back)

### Step 2: Set Up the Relay Computer (At Cannon)

```lua
edit OSC_RELAY_WIRED.lua
-- [Paste the relay code]
-- [Save]

-- Configure modem sides if different:
-- WIRELESS_MODEM_SIDE = "top"  (receives from portable)
-- WIRED_MODEM_SIDE = "back"    (connects to button network)
```

Attach:
- Wireless modem on one side (default: top)
- Wired modem on another side (default: back)
- Optional: Direct redstone output for strike button (default: right)

### Step 3: Set Up Button Controllers (65 total)

**Easy Method - Use the setup helper:**

```lua
-- On each button controller computer:
pastebin get YOURCODE OSC_SETUP.lua
OSC_SETUP

-- It will ask you:
-- - What cell? (e.g., B7)
-- - Which side is the button on? (e.g., bottom)
-- - Which side is the modem on? (e.g., back)
-- Then auto-generates and saves the script!
```

**Manual Method:**

```lua
edit startup.lua
-- [Paste OSC_BUTTON.lua code]
-- Change line: local MY_SIGNAL = 27  (to your button's signal)
-- Change line: local REDSTONE_SIDE = "bottom"  (to your setup)
-- [Save]
reboot
```

### Step 4: Wire the Network

Connect all computers with networking cable:
```
[Relay Computer (wired modem)] ─┬─ Networking Cable ─┬─ [Button B7]
                                 ├──────────────────────┼─ [Button C7]
                                 ├──────────────────────┼─ [Button D7]
                                 └──────────────────────┴─ [Button N11]
```

All 66 wired modems must be connected in one network.

### Step 5: Connect Redstone

Each button controller outputs redstone to activate one button:
- Button controller computer → redstone wire → button on cannon control panel

---

## Signal Number Reference

Use this to configure each button controller:

### Row 7:
- B7 = 27, C7 = 37, D7 = 47, E7 = 57, F7 = 67, G7 = 77, H7 = 87
- I7 = 97, J7 = 107, K7 = 117, L7 = 127, M7 = 137, N7 = 147

### Row 8:
- B8 = 28, C8 = 38, D8 = 48, E8 = 58, F8 = 68, G8 = 78, H8 = 88
- I8 = 98, J8 = 108, K8 = 118, L8 = 128, M8 = 138, N8 = 148

### Row 9:
- B9 = 29, C9 = 39, D9 = 49, E9 = 59, F9 = 69, G9 = 79, H9 = 89
- I9 = 99, J9 = 109, K9 = 119, L9 = 129, M9 = 139, N9 = 149

### Row 10:
- B10 = 210, C10 = 310, D10 = 410, E10 = 510, F10 = 610, G10 = 710, H10 = 810
- I10 = 910, J10 = 1010, K10 = 1110, L10 = 1210, M10 = 1310, N10 = 1410

### Row 11:
- B11 = 211, C11 = 311, D11 = 411, E11 = 511, F11 = 611, G11 = 711, H11 = 811
- I11 = 911, J11 = 1011, K11 = 1111, L11 = 1211, M11 = 1311, N11 = 1411

---

## Starting the System

### Start Order:

1. **Start all button controllers first** (they auto-start if using startup.lua)
   - Each should show: "Button X (Signal Y) - Ready"

2. **Start the relay:**
   ```lua
   OSC_RELAY_WIRED
   ```
   - Should show: "Relay active!"

3. **Start fire control on portable:**
   ```lua
   OSC_STRIKECALC
   ```

---

## Testing

### Test Single Button:

On your portable computer:
1. Run OSC_STRIKECALC
2. Choose **Option 6: Test Single Signal**
3. Enter a cell (e.g., "B7")
4. Watch the relay and button controller activate!

### Test Full Sequence:

1. Choose **Option 1: Dummy Mode**
2. Verify which buttons should activate
3. Choose **Option 2: Fire Mode** (programs without executing strike)
4. Watch all buttons activate in sequence!

---

## Labeling Computers (Recommended!)

Label each computer so you know which is which:

```lua
-- On each button controller after setup:
os.setComputerLabel("OSC_B7")   -- for button B7
os.setComputerLabel("OSC_M10")  -- for button M10
-- etc.

-- On relay:
os.setComputerLabel("OSC_RELAY")

-- On portable:
os.setComputerLabel("OSC_FIRE_CONTROL")
```

---

## Troubleshooting

**"No modem found"**
- Check modem is attached to the correct side
- Make sure wired modems are on button controllers and relay
- Make sure wireless modem is on portable and relay

**Button not activating**
- Check the signal number is correct for that cell
- Verify wired network is connected (all modems linked with cable)
- Check redstone output side on button controller
- Use test mode to verify

**Relay not receiving from portable**
- Verify both use channel 1000
- Check wireless modems are in range
- Make sure relay's wireless modem is on the correct side

**Multiple buttons activating**
- Two button controllers probably have the same signal number
- Re-check each controller's MY_SIGNAL value

---

## Cost Summary (Survival)

### For full 65-button automation:
- **67 Computers** (1 portable, 1 advanced, 65 basic)
  - Portable: 7 gold + redstone + stone + glass
  - Advanced: 7 gold + redstone + stone  
  - Basic ×65: 455 gold + 65 redstone + 65 stone
  - **TOTAL: ~469 gold ingots + materials**

- **68 Modems**
  - 2 wireless: 2 ender pearls + materials
  - 66 wired: 66 stone + materials

- **Networking Cable** (varies based on layout)

### To reduce cost:
- Use **basic computers** for all button controllers (already in plan)
- Share computers between multiple buttons using more complex logic (not recommended)
- Only automate buttons that are frequently used (~30 buttons = ~220 gold)

---

## File Summary

- **OSC_STRIKECALC.lua** - Fire control (portable computer)
- **OSC_RELAY_WIRED.lua** - Network relay (stationary at cannon)
- **OSC_BUTTON.lua** - Button controller (×65, one per button)
- **OSC_SETUP.lua** - Setup helper (makes configuration easier)

---

## Tips

1. **Build in stages** - Set up 10 buttons first, test, then expand
2. **Use signs** - Label physical buttons with their cell coordinates
3. **Keep spares** - Have extra basic computers and modems on hand
4. **Test early** - Use dummy mode and single signal test frequently
5. **Organize cables** - Color-code or route networking cables neatly
6. **Power management** - Button controllers can run on their own (no shared power needed)

Good luck with your orbital cannon! 🚀
