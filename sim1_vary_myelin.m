%% simulation 1: vary myelination of internodes

function sim1_vary_myelin(number_of_internodes, starting_myelin, end_myelin, step_size)
    % use the neuron class
    % plot conduction velocity vs myelin thickness
    % plot firing rate vs myelin thickness

    % constant amount of internodes
    % start at x myelin thickness and decrement by fixed amount until reaching zero
    % At each myelin thickness we need to make note of firing rate, and
    % output velocity  

    if nargin < 4
        step_size = 7.5;
    end

    % Constants
    internode_length = 1; % in mm;
    node_length = 2 / 1000; % in mm;

    % Initialize Output Arrays
    conduction_node_velocities = [];
    conduction_true_velocities = [];
    firing_rates = [];

    % Set up the sequence array based on the number_of_internodes
    sequence_array = zeros(1, 2*number_of_internodes + 1);
    sequence_array(2:2:end-1) = 1;

    % Calculate axon length
    number_of_nodes = length(sequence_array) - number_of_internodes;
    axon_length = number_of_internodes * internode_length + number_of_nodes * node_length;

    % Generate the array of myelin thicknesses
    myelin_values = starting_myelin:step_size:end_myelin;

    % Simulate for each thickness and add to the velocity and firing rates

    for i = 1:length(myelin_values)
        % Access and print the current myelin value
        myelin_value = myelin_values(i);

        [output, time] = simulate_internode_node_sequence(sequence_array, myelin_value);
        [conduction_velocity_node, conduction_velocity_true] = conduction_velocity(sequence_array, output, time, axon_length);
        conduction_node_velocities = [conduction_node_velocities, conduction_velocity_node];
        conduction_true_velocities = [conduction_true_velocities, conduction_velocity_true];
        firing_rates = [firing_rates, get_firing_rate(output,time)];
    end
    
     % PLOTTING CODE HERE

    figure()
    FontSize = 12;
    LineWidth = 1.5;

    % Your plotting code should be here
    plot(myelin_values, conduction_node_velocities, 'LineWidth', LineWidth)
    hold on;
    plot(myelin_values, conduction_true_velocities, 'LineWidth', LineWidth)
    hold off;
    
    legend('Node Velocity (node/ms)', 'True Velocity (m/s)') % note the order here
    xlabel('Myelin Thickness (nm)')
    ylabel('Velocity')
    set(gca, 'FontSize', FontSize)

    figure()
    plot(myelin_values, firing_rates, 'LineWidth', LineWidth)

    xlabel('Myelin Thickness (nm)')
    ylabel('Firing Rate (Hz)')
    set(gca, 'FontSize', FontSize)

    figure()
    plot(conduction_true_velocities, firing_rates, 'LineWidth', LineWidth)

    xlabel('True Conduction Velocity (m/s)')
    ylabel('Firing Rate (Hz)')
    set(gca, 'FontSize', FontSize)

    disp(myelin_values);
end