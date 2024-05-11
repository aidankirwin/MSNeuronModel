function [node_over_time, length_over_time] = conduction_velocity(sequence, voltage, time, axon_length)
    % calculate conduction velocity of a neuron

    % Inputs:
    % sequence: sequence array of neuron, e.g., [0 1 0 1 0]
    % voltage: output array of n x t where n = number of segments, and t =
    % number of assessed time points
    % time: time array
    % axon_length: length of axon in mm

    % Outputs:
    % nodes_over_time = conduction velocity in terms of nodes/time
    % length_over_time = conduction velocity in terms of axon lenght/time

    [rows, cols] = size(voltage);

    % make sure that voltage array has same number of rows as
    % there are nodes/internodes in neuron
    if length(sequence) ~= rows
        disp("ERROR IN conduction_velocity: STATE ARRAY MUST MATCH SEQUENCE");
        node_over_time = -1;
        length_over_time = -1;
        return
    end

    % make sure that voltage array has same number of cols as there are
    % time points in time array
    if length(time) ~= cols
        disp("ERROR IN conduction_velocity: STATE ARRAY MUST MATCH TIME ARRAY");
        node_over_time = -1;
        length_over_time = -1;
        return
    end

    first_node = voltage(1, :);
    last_node = voltage(length(sequence), :);

    voltage_threshold = 0; % a spike will be considered a voltage > 0, this isn't the best method

    for i = 1:length(time)
        % get first node peak
        if first_node(i) > voltage_threshold
            start_time = time(i);
            break % peak found, don't accidentally grab time of next peak
        end
    end

    for i = 1:length(time)
        % get last node peak
        if last_node(i) > voltage_threshold
            end_time = time(i);
            break % peak found, don't accidentally grab time of next peak
        end
    end

    node_over_time = length(sequence) / (end_time - start_time);
    
    % optional argument: length of axon in mm
    if nargin == 4
        length_over_time = axon_length / (end_time - start_time);
    else
        % if no length is passed, then set to 0
        length_over_time = 0;
    end
end