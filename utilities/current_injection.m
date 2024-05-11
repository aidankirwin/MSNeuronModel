function current = current_injection(max_time, time_step, pulse_start, pulse_width, pulse_magnitude)
    % current injection function pulse function
    % produces a pulse of current (uA) given a start time and pulse width

    % Inputs:
    % max_time: the maximum time value that the pulse function should use
    % as an input
    % time_step: the time step between time values that the pulse function
    % will use as an input
    % pulse_start: the time at which the pulse will begin
    % pulse_width: how long the pulse will last (s)
    
    % Output:
    % current: injection current I(t), array of current values corresponding 
    % to time values in the calculated time array (time_arr)

    current_injection = [];
    time_arr = 0:time_step:max_time;

    if nargin < 5
        pulse_magnitude = -30;
    end

    for i = 1:length(time_arr)
        if (pulse_start < time_arr(i)) && (time_arr(i) < pulse_start + pulse_width)
            current_injection = [current_injection, pulse_magnitude];
        else
            current_injection = [current_injection, 0];
        end
    end

    current = current_injection;
end

