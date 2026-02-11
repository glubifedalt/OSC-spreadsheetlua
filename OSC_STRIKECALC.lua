-------------------------------------------------
-- Excel-equivalent math helpers
-------------------------------------------------

local function FLOOR(x)
    return math.floor(x)
end

local function ROUND(x)
    if x >= 0 then
        return math.floor(x + 0.5)
    else
        return math.ceil(x - 0.5)
    end
end

local function MOD(a,b)
    return a % b
end

-------------------------------------------------
-- Bit extraction (Excel method)
-- MOD(FLOOR(value / 2^n),2)
-------------------------------------------------

local function get_bit(value, power)
    return MOD(FLOOR(value / (2^power)), 2)
end

local function get_inv_bit(value, power)
    return 1 - get_bit(value, power)
end

-------------------------------------------------
-- Main Fire Control Function
-------------------------------------------------

function compute_fire_solution(input)

    -------------------------------------------------
    -- INPUTS
    -------------------------------------------------

    local origin_x = input.origin_x
    local origin_y = input.origin_y
    local origin_z = input.origin_z

    local target_x = input.target_x
    local target_y = input.target_y
    local target_z = input.target_z

    local nuke_size  = input.nuke_size
    local stab_depth = input.stab_depth
    local weapon_type = input.type
    local MPS = input.MPS
    local passcode = input.passcode

    -------------------------------------------------
    -- PASSCODE CHECK (replace with Excel logic if exists)
    -------------------------------------------------

    if passcode ~= input.correct_passcode then
        return {} -- deny firing
    end

    -------------------------------------------------
    -- DELTA CALCULATIONS (matches I4 style logic)
    -------------------------------------------------

    local dx = target_x - origin_x
    local dy = target_y - origin_y
    local dz = target_z - origin_z

    local distance = math.sqrt(dx*dx + dz*dz)

    -------------------------------------------------
    -- INSERT EXACT EXCEL BALLISTIC FORMULAS HERE
    -------------------------------------------------
    -- These must match L2, L3, L4 equations exactly
    -- Replace the placeholder math below
    -------------------------------------------------

    -- Placeholder ballistic model
    -- YOU MUST REPLACE THIS WITH YOUR EXACT XLSX FORMULAS

    local L2 = math.abs(dx) + nuke_size * 10
    local L3 = stab_depth + weapon_type
    local L4 = math.abs(dz) + MPS

    -------------------------------------------------
    -- SPLIT INTEGER / DECIMAL (Excel exact)
    -------------------------------------------------

    local M2 = FLOOR(L2)
    local N2 = ROUND(10*(L2 - M2))

    local M3 = FLOOR(L3)
    local N3 = ROUND(10*(L3 - M3))

    local M4 = FLOOR(L4)
    local N4 = ROUND(10*(L4 - M4))

    -------------------------------------------------
    -- SAFETY INTERLOCK (Excel-style limits)
    -------------------------------------------------

    if L2 >= 32767.999 then return {} end
    if L4 >= 32767.999 then return {} end
    if L3 >= 31.999 then return {} end
    if distance < 64 then return {} end

    -------------------------------------------------
    -- BUTTON OUTPUT ARRAY
    -------------------------------------------------

    local pressed = {}

    local function press(name, state)
        if state == 1 then
            table.insert(pressed, name)
        end
    end

    -------------------------------------------------
    -- Encode M4 (15 bits)
    -------------------------------------------------

    for power = 0,14 do
        press("M4_bit_"..power, get_bit(M4, power))
    end

    -------------------------------------------------
    -- Encode M3 (5 bits)
    -------------------------------------------------

    for power = 0,4 do
        press("M3_bit_"..power, get_bit(M3, power))
    end

    -------------------------------------------------
    -- Encode M2 (15 bits)
    -------------------------------------------------

    for power = 0,14 do
        press("M2_bit_"..power, get_bit(M2, power))
    end

    -------------------------------------------------
    -- Decimal digits (inverted like sheet)
    -------------------------------------------------

    for power = 0,3 do
        press("N4_bit_"..power, get_inv_bit(N4, power))
        press("N3_bit_"..power, get_inv_bit(N3, power))
        press("N2_bit_"..power, get_inv_bit(N2, power))
    end

    -------------------------------------------------
    -- SIGN INDICATORS
    -------------------------------------------------

    if dx < 0 then press("X_negative",1) end
    if dz < 0 then press("Z_negative",1) end

    -------------------------------------------------
    return pressed
end
