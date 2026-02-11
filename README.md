Readme · MD
# Orbital Strike Cannon Fire Control System v6.1

## Installation (wget method)

### Quick Install
```lua
-- On Fire Control Computer:
pastebin get YOURCODE1 OSC_STRIKECALC.lua

-- On Relay Computer:
pastebin get YOURCODE2 OSC_RELAY.lua

-- Or use wget if you host on GitHub:
wget https://raw.githubusercontent.com/USERNAME/REPO/main/OSC_STRIKECALC.lua
wget https://raw.githubusercontent.com/USERNAME/REPO/main/OSC_RELAY.lua
```

### Manual Install
Copy and paste the code into files using `edit filename.lua`

## Compatibility

**YES** - This will work in base ComputerCraft!

Requirements:
- ComputerCraft (or CC:Tweaked)
- Wireless modems
- Bundled cable (RedPower/Project Red/etc) OR regular redstone

All the code uses standard CC APIs - no special dependencies needed.

## Bug Fix

**Original Error:** `attempt to perform arithmetic on local 'weapon_type' (a string value)`

**Cause:** The original code tried to do math operations on the `weapon_type` variable which was a string ("nuke"), not a number.

**Solution:** Changed the logic to properly check if weapon_type equals "nuke" as a string comparison, not arithmetic:
```lua
-- WRONG (caused error):
local L3 = stab_depth + weapon_type  -- Can't add string to number!

-- CORRECT:
if weapon_data.weapon_type == "nuke" then
    button_matrix[5][11] = true  -- Set L11 for nuke type
end
```

## Features Added

### 1. Dummy Mode
- Prints the complete button matrix to screen
- Shows which buttons need to be pressed
- Displays cell coordinates and signal numbers
- No actual redstone signals sent (safe for testing)

### 2. Redstone Integration
- Uses ComputerCraft modems for wireless signal transmission
- Signal format: Column index + Row number (e.g., E5 = 55, M10 = 1310)
- Supports bundled cable with color-coded outputs
- Separate relay receiver script for redstone control

### 3. Interactive Menu System
- Configure target coordinates
- Set passcode
- Test individual signals
- Full fire sequence execution with confirmation

### 4. Strike Execution & Timer (NEW!)
- Execute the actual strike/fire button after programming
- Calculate distance-based impact time
- Live countdown timer showing time to impact
- Customizable projectile speed for accurate timing
- Separate mode for just programming vs full strike

## File Structure

```
OSC_STRIKECALC.lua  - Main fire control computer (calculates and sends signals)
OSC_RELAY.lua       - Relay computer (receives signals and controls redstone)
```

## Signal Format

Cell coordinates are converted to numeric signals:
- **Column:** Letter position in alphabet (A=1, B=2, C=3, ..., N=14)
- **Row:** Row number
- **Signal:** Column_index concatenated with row (no math, just string concat)

Examples:
- B7 → 27 (column B=2, row 7)
- E5 → 55 (column E=5, row 5)
- M10 → 1310 (column M=13, row 10)
- N11 → 1411 (column N=14, row 11)

## Setup Instructions

### Hardware Requirements

1. **Fire Control Computer:**
   - 1x Advanced Computer
   - 1x Wireless Modem (attached to back)

2. **Relay Computer:**
   - 1x Advanced Computer  
   - 1x Wireless Modem (attached to back)
   - 5x Bundled Cable outputs (one per side: left, right, top, bottom, front)
   - Redstone Integrators or other devices to interface with your OSC buttons

### Installation

1. **On Fire Control Computer:**
   ```
   edit OSC_STRIKECALC.lua
   [Paste the code]
   [Save with Ctrl]
   ```

2. **On Relay Computer:**
   ```
   edit OSC_RELAY.lua
   [Paste the code]
   [Save with Ctrl]
   ```

3. **Configure Modem Sides:**
   Edit both files if your modems are on different sides:
   ```lua
   local MODEM_SIDE = "back"  -- Change to your modem side
   ```

4. **Configure Redstone Mapping:**
   Edit `OSC_RELAY.lua` in the `initializeMapping()` function to match your physical setup.
   Map each signal number to the correct bundled cable side and color.

## Usage

### Starting the System

1. **Start Relay First:**
   ```
   OSC_RELAY
   ```
   You should see: "OSC REDSTONE RELAY ACTIVE"

2. **Start Fire Control:**
   ```
   OSC_STRIKECALC
   ```

### Menu Options

**1. Dummy Mode (Print Matrix)**
- Calculates button states
- Prints visual matrix
- Lists all cells to activate with signal numbers
- Does NOT send any redstone signals
- Use this to verify calculations before firing

**2. Fire Mode (Send Signals)**
- Calculates button states
- Shows matrix preview
- Sends redstone signals to relay
- Programs the cannon but does NOT execute strike
- Good for setting up without firing

**3. Full Strike (Signals + Execute)** ⭐ NEW
- Does everything Fire Mode does
- Then asks if you want to execute the strike button
- Calculates time to impact
- Shows live countdown timer
- Full automated strike sequence

**4. Configure Target**
- Set X, Y, Z coordinates
- Updates target location for strike

**5. Configure Passcode**
- Set the security passcode (0-1023)
- Encoded into button matrix

**6. Test Single Signal**
- Send one signal manually
- Enter cell coordinate (e.g., "E5")
- Useful for testing wiring

**7. Calculate Strike Time** ⭐ NEW
- Shows distance to target
- Estimates impact time
- Helpful for planning

**8. Exit**
- Closes the program

### Example Workflow

1. Start relay computer: `OSC_RELAY`
2. Start fire control: `OSC_STRIKECALC`
3. Choose option 3 - Configure target
4. Enter coordinates: X=1000, Y=64, Z=1000
5. Choose option 1 - Dummy mode (verify matrix)
6. Choose option 2 - Fire mode
7. Confirm firing sequence
8. Watch as signals are sent!

## Customization

### Strike Execution Button
In `OSC_STRIKECALC.lua`:
```lua
local STRIKE_BUTTON_SIDE = "top"  -- Side where fire button is
local STRIKE_BUTTON_COLOR = colors.red  -- Bundled cable color
local USE_BUNDLED_FOR_STRIKE = true  -- false for regular redstone
```

### Strike Timer Settings
Adjust these for accurate countdown:
```lua
local PROJECTILE_SPEED = 100  -- blocks per second (tune to your mod)
local LAUNCH_DELAY = 5  -- seconds for launch sequence
```

### Changing Channel
Both files must use the same channel:
```lua
local RELAY_CHANNEL = 1000  -- Change in both files
```

### Signal Timing
In `OSC_STRIKECALC.lua`:
```lua
executeFireSequence(0.75)  -- Delay between signals (seconds)
sendRedstoneSignal(cell, 0.5)  -- Pulse duration (seconds)
```

### Bundled Cable Colors
In `OSC_RELAY.lua`, change color assignments:
```lua
REDSTONE_MAPPING[27] = {side = "left", color = colors.white}
REDSTONE_MAPPING[37] = {side = "left", color = colors.orange}
-- etc...
```

## Advanced Features to Implement

The current version has simplified button calculation. For full Excel parity, you would need to implement:

1. **Distance calculations** (dV formulas)
2. **Coarse/Fine encoding** (M/N columns for coordinates)
3. **Binary encoding** for all parameters
4. **Error checking** (alignment, range limits, etc.)
5. **Multi-shot support** with saved configurations

The structure is in place - just expand the `calculateButtons()` function with the full Excel formulas.

## Troubleshooting

**"No modem found"**
- Check modem is attached to correct side
- Verify `MODEM_SIDE` in code

**"No mapping for signal"**
- Signal not configured in relay
- Check `initializeMapping()` function
- Verify signal calculation is correct

**Buttons not activating**
- Check bundled cable connections
- Verify color assignments match physical wiring
- Test with option 5 (Test Single Signal)

**Wrong buttons activate**
- Review redstone mapping
- Ensure signal format is correct (column + row)
- Check Excel column letters match code

## Credits

Based on OSC_6_0_Fire_Control.xlsx
Enhanced for ComputerCraft integration with redstone relay system
Version 6.1 - Bug fixed and features added
