

local reset_flag
local smooth_alpha = 0
local heading_error = 0

local PRtable = {pitch_rate = 0, previous_pitch = 0, current_pitch = 0}

local function pitch_rate(PR_array)
    PR_array.current_pitch = get(pitch)
    PR_array.pitch_rate = PR_array.current_pitch - PR_array.previous_pitch
    PR_array.previous_pitch = PR_array.current_pitch
    return PR_array.pitch_rate / get(DELTA_TIME)
end


local function smooth_the_alpha()
    smooth_alpha = Set_anim_value_no_lim(smooth_alpha, get(alpha), 5)
end


local function roll_pid(array, setpoint, current)
    local error = setpoint - current
    local output = 
    --Proportional Component
    array.P * error
    --Integral Component
    +array.I * array.Isum
    --Derivative Component
    + array.D * (error - array.Eprior)/get(DELTA_TIME)


    array.Isum = Math_clamp(array.Isum + error * get(DELTA_TIME), -array.Imax, array.Imax)
    array.Eprior = error

    --print(array.Isum)
    return output
end

local function pid_bp(array, setpoint, current, control_error)
    local error = setpoint - current
    local output = 
    --Proportional Component
    array.P * error
    --Integral Component
    +array.I * array.Isum
    --Derivative Component
    + array.D * (error - array.Eprior)/get(DELTA_TIME)


    array.Isum = array.Isum + error * get(DELTA_TIME) - array.BP * (output - current) * get(DELTA_TIME)
    array.Eprior = error

    --print(array.Isum)
    return output
end


local output_1 = 0
local output_2 = 0
local output_2_smooth = 0
local output_3 = 0
local target_vs_smooth = 0


Aileron_array = {P=0.5, I=0.3, D=0.4, BP = 0.7, Isum=0, Imax = 1, Eprior = 0}
Pitch_rate_array = {P=0.4, I=0.2, D=0.000, BP = 0,Isum=0, Eprior = 0}
Cascade_array = {P=0.4, I=0, D=0.0, BP = 0, Isum=0, Imax = 0, Eprior = 0}
Cascade2_array = {P=0.01, I=0.00121*1.0, D=0.026, BP = 0.004*1.3, Isum=0, Imax = 1, Eprior = 0}
Rudder_array = {P=1, I=0.0, D=0.005, Isum=0, Imax = 1, Eprior = 0}
Throttle_array = {P=0.25, I=0.2, D=0.1, BP = 0, Isum=0, Imax = 1, Eprior = 0}

local elevator_gain_scheduling = {
    {-999,0.5},
    {-1,0.3},
    {0,0.1},
    {1,0.3},
    {999,0.5},
}

function update()
    smooth_the_alpha()
    if get(ap_enabled) == 1 then
        set(aileron, pid_bp(Aileron_array, get(target_roll)/3.3, get(roll)))
        --set(elevator, Set_anim_value_no_lim(get(elevator), roll_pid(Elevator_array, get(target_pitch), get(pitch)), 10))

        if get(vs_enabled) == 1 then
            target_vs_smooth = Set_anim_value_no_lim( target_vs_smooth, get(target_pitch), 0.25)
            output_1 = pid_bp(Cascade2_array, target_vs_smooth, get(vvi))
            output_2 = pid_bp(Cascade_array, output_1, get(pitch))
            output_3 = pid_bp(Pitch_rate_array, Math_clamp(output_2,-1,1), pitch_rate(PRtable))
            set(elevator, output_3  )
        end

        set(throttle, math.max(roll_pid(Throttle_array, get(target_speed), get(airspeed)), 0))
        
        --print(Round(output_2,2))
        --print(Round(Pitch_rate_array.Isum, 2))

        reset_flag = false


    elseif reset_flag == false and get(ap_enabled) == 0 then
        Aileron_array.Isum = 0
        Pitch_rate_array.Isum = 0
        Cascade_array.Isum = 0
        Cascade2_array.Isum = 0
        set(aileron, 0)
        set(elevator, 0)
        reset_flag = true
    end
end

























--local function compute_gradient(vs, smooth_alpha, smooth_gradient)
--
--    smooth_alpha = Set_anim_value_no_lim(smooth_alpha, get(alpha), 20)
--
--    print(Set_anim_value_no_lim(smooth_alpha, get(alpha), 5))
--
--    local gradient = math.atan( ( vs/(get(ground_speed)*197) ) ) / 0.01745 + Math_clamp(smooth_alpha, -5, 5) + Math_clamp ( ( vs - get(vvi) ), -200, 200) * 1 --( vs - get(vvi) ) * get(DELTA_TIME) * 1.2  
--    --local smooth_gradient = Set_anim_value_no_lim(get(pitch), gradient, 0.8)
--
--    smooth_gradient = Set_anim_value_no_lim(smooth_gradient, gradient, 0.4)
--
--    return Math_clamp( smooth_gradient, -10, 10) * 1.4
--end