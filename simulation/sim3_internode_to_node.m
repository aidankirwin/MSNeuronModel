%% simulation 3: replace internodes with HH nodes
   
function sim3_internode_to_node(number_of_internodes)
    % use the neuron class
    % plot conduction velocity vs # of internodes
    % plot firing rate vs # of internodes
    % neuron length is constant
    
    % in this experiment internodes will be replaced with HH nodes one at a
    % time. the total number of segments is kept constant. the amount of
    % myelin in remaining internodes should be kept constant, with some
    % level of random noise.
    
    % Set Constants
    internode_length = 1; % in mm;
    node_length = 2 / 1000; % in mm;
    myelin_thickness = 500; % in nm
    
    % Initialize number_of_internodes array
    number_of_internodes_plot = [];
    conduction_node_velocities = [];
    conduction_true_velocities = [];
    firing_rates = [];
    for i = number_of_internodes:-1:0
        number_of_internodes_plot = [number_of_internodes_plot, i];
    end
    
    % Initialize the array with alternating 1s and 0s, starting and ending with 0
    initial_array = zeros(1, 2*number_of_internodes + 1);
    initial_array(2:2:end-1) = 1;
    flipped_array = initial_array;
    
    % Set axonal length    
    number_of_nodes = length(initial_array) - number_of_internodes;
    axonal_length = number_of_internodes * internode_length + number_of_nodes * node_length;
    
    %Initial Array Code
    [output, time] = simulate_internode_node_sequence(initial_array, myelin_thickness);

    % Get the conduction velocity and firing rate
    [conduction_velocity_node, conduction_velocity_true] = get_conduction_velocity(number_of_internodes, initial_array, output, time);
    conduction_node_velocities = [conduction_node_velocities, conduction_velocity_node];
    conduction_true_velocities = [conduction_true_velocities, conduction_velocity_true];
    firing_rates = [firing_rates, get_firing_rate(output,time)];
    
    % Flip each 1 to a 0 sequentially
    for i = 2:2:length(flipped_array)-1
        flipped_array(i) = 0;
        number_of_internodes = number_of_internodes - 1;

        % Work With AdjustedArray
        [output, time] = simulate_internode_node_sequence(flipped_array, myelin_thickness);

        % Get the conduction velocity and the firing rate
        [conduction_velocity_node, conduction_velocity_true] = get_conduction_velocity(number_of_internodes, initial_array, output, time);
        conduction_node_velocities = [conduction_node_velocities, conduction_velocity_node];
        conduction_true_velocities = [conduction_true_velocities, conduction_velocity_true];
        firing_rates = [firing_rates, get_firing_rate(output,time)];
    end

    function [node_velocity, true_velocity] = get_conduction_velocity(internodes, sequence_array, neuron_output, neuron_time)
        % dynamic length below
        dynamic_length = internodes * internode_length + number_of_nodes * node_length;

        % Use sequence array for dynamic calculation
        [node_velocity, true_velocity] = conduction_velocity(initial_array, neuron_output, neuron_time, axonal_length);
    end

    % PLOTTING CODE HERE

    figure()
    FontSize = 12;
    LineWidth = 1.5;

    % Your plotting code should be here
    plot(number_of_internodes_plot, conduction_node_velocities, 'LineWidth', LineWidth)
    hold on;
    plot(number_of_internodes_plot, conduction_true_velocities, 'LineWidth', LineWidth)
    hold off;
    
    legend('Node Velocity (node/ms)', 'True Velocity (m/s)') % note the order here
    xlabel('Number of Internodes')
    ylabel('Velocity')
    set(gca, 'FontSize', FontSize)

    figure()
    plot(number_of_internodes_plot, firing_rates, 'LineWidth', LineWidth)

    xlabel('Number of Internodes')
    ylabel('Firing Rate (Hz)')
    set(gca, 'FontSize', FontSize)

    figure()
    plot(conduction_true_velocities, firing_rates, 'LineWidth', LineWidth)

    xlabel('True Conduction Velocity (m/s)')
    ylabel('Firing Rate (Hz)')
    set(gca, 'FontSize', FontSize)
end