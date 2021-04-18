ap_enabled = createGlobalPropertyi("simpleap/enabled", 0, false, true, false)
override = globalProperty("sim/operation/override/override_flightcontrol")
elevator = globalProperty("sim/cockpit2/controls/yoke_pitch_ratio")
aileron = globalProperty("sim/cockpit2/controls/yoke_roll_ratio")
rudder = globalProperty("sim/cockpit2/controls/total_heading_ratio")
throttle = globalProperty("sim/cockpit2/engine/actuators/throttle_beta_rev_ratio_all")

pitch = globalProperty("sim/cockpit2/gauges/indicators/pitch_AHARS_deg_pilot")
roll = globalProperty("sim/cockpit2/gauges/indicators/roll_AHARS_deg_pilot")
yaw = globalProperty("sim/cockpit2/gauges/indicators/slip_deg")

DELTA_TIME = globalProperty("sim/operation/misc/frame_rate_period")

target_pitch = createGlobalPropertyf("simpleap/target_pitch", 0, false, true, false)
target_roll = createGlobalPropertyf("simpleap/target_roll", 0, false, true, false)
target_heading = createGlobalPropertyi("simpleap/target_heading", 0, false, true, false)
target_altitude = createGlobalPropertyi("simpleap/target_altitude", 10, false, true, false)
target_speed = createGlobalPropertyf("simpleap/target_speed", 250, false, true, false)


airspeed = globalProperty("sim/cockpit2/gauges/indicators/airspeed_kts_pilot")
ground_speed = globalProperty("sim/flightmodel/position/groundspeed")
alpha = globalProperty("sim/flightmodel/position/alpha")
alt = globalProperty("sim/cockpit2/gauges/indicators/altitude_ft_pilot")
vvi = globalProperty("sim/cockpit2/gauges/indicators/vvi_fpm_copilot")
hdg = globalProperty("sim/cockpit2/gauges/indicators/heading_AHARS_deg_mag_pilot")

vs_enabled = createGlobalPropertyi("simpleap/vs_enabled", 0, false, true, false)


function Math_clamp(val, min, max)
    if min > max then LogWarning("Min is larger than Max invalid") end
    if val < min then
        return min
    elseif val > max then
        return max
    elseif val <= max and val >= min then
        return val
    end
end

function Math_clamp_lower(val, min)
    if val < min then
        return min
    elseif val >= min then
        return val
    end
end

function Math_clamp_higer(val, max)
    if val > max then
        return max
    elseif val <= max then
        return val
    end
end

function Table_interpolate(tab, x)
    local a = 1
    local b = #tab
    assert(b > 1)

    -- Simple cases
    if x <= tab[a][1] then
        return tab[a][2]
    end
    if x >= tab[b][1] then
        return tab[b][2]
    end

    local middle = 1

    while b-a > 1 do
        middle = math.floor((b+a)/2)
        local val = tab[middle][1]
        if val == x then
            break
        elseif val < x then
            a = middle
        else
            b = middle
        end
    end

    if x == tab[middle][1] then
        -- Found a perfect value
        return tab[middle][2]
    else
        -- (y-y0) / (y1-y0) = (x-x0) / (x1-x0)
        return tab[a][2] + ((x-tab[a][1])*(tab[b][2]-tab[a][2]))/(tab[b][1]-tab[a][1])
    end
end

function Table_extrapolate(tab, x)  -- This works like Table_interpolate, but it estimates the values
    -- even if x < minimum value of x > maximum value according to the
    -- last segment available

local a = 1
local b = #tab

assert(b > 1)

if x < tab[a][1] then
return Math_rescale_no_lim(tab[a][1], tab[a][2], tab[a+1][1], tab[a+1][2], x) 
end
if x > tab[b][1] then
return Math_rescale_no_lim(tab[b][1], tab[b][2], tab[b-1][1], tab[b-1][2], x) 
end

return Table_interpolate(tab, x)

end

function Set_anim_value(current_value, target, min, max, speed)

    if target >= (max - 0.001) and current_value >= (max - 0.01) then
        return max
    elseif target <= (min + 0.001) and current_value <= (min + 0.01) then
        return min
    else
        return current_value + ((target - current_value) * (speed * get(DELTA_TIME)))
    end

end

function Set_anim_value_no_lim(current_value, target, speed)
    return current_value + ((target - current_value) * (speed * get(DELTA_TIME)))
end

function Round(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

function drawTextCentered(font, x, y, string, size, isbold, isitalic, alignment, colour)
    sasl.gl.drawText (font, x, y - (size/3),string, size, isbold, isitalic, alignment, colour)
end