function [firing_rate, pks, locs] = get_firing_rate(output, time)
    
    [rows, cols] = size(output);

    % make sure that voltage array has same number of cols as there are
    % time points in time array
    if length(time) ~= cols
        disp("ERROR IN conduction_velocity: STATE ARRAY MUST MATCH TIME ARRAY");
        firing_rate = -1;
        return
    end
    
    % extract voltage sequence at last node from output matrix
    voltage_at_last_node = output(rows, :);

    % find AP spikes
    [AP_spikes, AP_times] = findpeaks(voltage_at_last_node, time, MinPeakHeight=10);

    firing_rate = (length(AP_spikes) - 1) / (AP_times(end) - AP_times(1));
    
    pks = AP_spikes;
    locs = AP_times;
end