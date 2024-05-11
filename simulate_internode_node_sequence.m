function [output, time] = simulate_internode_node_sequence(sequence_array, myelin_thickness, demyelinated_nodes)
    max_time = 100;
    time_step = 0.01;
    number_of_demyelinated = 0;

    % tmy = 250 nm 
    neuron = Neuron(max_time, time_step);
    n = myelin_thickness_to_wraps(myelin_thickness);

    % create the axon sequence
    for i = 1:length(sequence_array)
        noise = 0;
        snr = -1;
        
        if sequence_array(i) == 0
            neuron.add_segment("NODE", [noise, snr]);
        else
            neuron.add_segment("INTERNODE", [noise, snr, n]);
        end
    end

    if nargin > 2
        % identify segments that are internodes and store in internode_indices
        internode_indices = [];

        for i = 1:length(sequence_array)
            if number_of_demyelinated == demyelinated_nodes
                break
            end
            if sequence_array(i) == 1
                neuron.n_params(i) = 0.5;
                number_of_demyelinated = number_of_demyelinated + 1;
            end
        end        
    end
    
    % Define I(t)
    input = current_injection(max_time, time_step, 1, 75);

    % Simulate the neuron
    [output, time] = neuron.simulate(input);
end