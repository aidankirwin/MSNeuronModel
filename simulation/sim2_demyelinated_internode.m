%% simulation 2: remove myelin from internodes

function sim2_demyelinated_internode(number_of_internodes)
    % use the neuron class
    % plot conduction velocity vs # of demyelinated internodes
    % plot firing rate vs # of demyelinated internodes
    % neuron length is constant

    % in this experiment myelin will be "removed" from one internode at a
    % time. the number of nodes and internodes are kept constant.
    % myelin wraps (n) will be set to 0.5 for all (which is approx 4nm of myelin)

    % Constants
    internode_length = 1; % in mm;
    node_length = 2 / 1000; % in mm;
    myelin_thickness = 250; % in nm

    % Initialize Output Arrays
    conduction_node_velocities = [];
    conduction_true_velocities = [];
    firing_rates = [];
    demyelinated_node_array = [];

    % Set up the sequence array based on the number_of_internodes
    sequence_array = zeros(1, 2*number_of_internodes + 1);
    sequence_array(2:2:end-1) = 1;

    % Calculate axon length
    number_of_nodes = length(sequence_array) - number_of_internodes;
    axon_length = number_of_internodes * internode_length + number_of_nodes * node_length;

    % Demyelinate and add to the arrays

    for i = 0:number_of_internodes
        [output, time] = simulate_internode_node_sequence(sequence_array, myelin_thickness, i);
        [conduction_velocity_node, conduction_velocity_true] = conduction_velocity(sequence_array, output, time, axon_length);
        conduction_node_velocities = [conduction_node_velocities, conduction_velocity_node];
        conduction_true_velocities = [conduction_true_velocities, conduction_velocity_true];
        firing_rates = [firing_rates, get_firing_rate(output,time)];

        demyelinated_node_array = [demyelinated_node_array, i];
    end

     % PLOTTING CODE HERE
    figure()
    FontSize = 12;
    LineWidth = 1.5;

    % Your plotting code should be here
    plot(demyelinated_node_array, conduction_node_velocities, 'LineWidth', LineWidth)
    hold on;
    plot(demyelinated_node_array, conduction_true_velocities, 'LineWidth', LineWidth)
    hold off;
    
    legend('Node Velocity (node/ms)', 'True Velocity (m/s)') % note the order here
    xlabel('Demyelinated Nodes (nm)')
    ylabel('Velocity')
    set(gca, 'FontSize', FontSize)

    figure()
    plot(demyelinated_node_array, firing_rates, 'LineWidth', LineWidth)

    xlabel('Demyelinated Nodes (nm)')
    ylabel('Firing Rate (Hz)')
    set(gca, 'FontSize', FontSize)

    figure()
    plot(conduction_true_velocities, firing_rates, 'LineWidth', LineWidth)

    xlabel('True Conduction Velocity (m/s)')
    ylabel('Firing Rate (Hz)')
    set(gca, 'FontSize', FontSize)

end