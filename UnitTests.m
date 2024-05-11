%% Define Main Function
%it always has the same structure.
% THe name of the main function corresponds
% to the name of your test file and should
% start or end with the word 'test', which is case insensitive.

function tests = UnitTests %you can only change the name 
    %do not change this
    tests = functiontests(localfunctions);
end

%% Define Local Test Functions
% test function names must begin or end with
% the case-insensitive word 'test'

function testConstructorWithStartingNodeTrue(testCase)
    
    % create HH object
    input = 5; % set a random injection current (mV)
    starting_node = true;
    max_time = 10; 
    noise_perc = 0.1; 

    obj = HodgkinHuxley(input, starting_node, max_time, noise_perc); % create instance of HH class
            
    % confirm variables are correctly assigned
    verifyEqual(testCase, obj.I, input);
    verifyEqual(testCase, obj.starting_node, true);
    verifyEqual(testCase, obj.max_time, max_time);
end
        
function testConstructorWithStartingNodeFalse(testCase)
    
    input = 5; 
    starting_node = false;
    max_time = 10; 
    noise_perc = 0.1; 

    obj = HodgkinHuxley(input, starting_node, max_time, noise_perc);
    
    % confirm variables are correctly assigned
    verifyEqual(testCase, obj.V, input);
    verifyEqual(testCase, obj.starting_node, false);
    verifyEqual(testCase, obj.max_time, max_time);
end

function testConstructorInternode(testCase)
    
    input = 5; 
    n = 1;
    max_time = 10; 
    noise_perc = 0.1; 

    obj = Internode(input, n, max_time, noise_perc);
    
    % confirm variables are correctly assigned
    verifyEqual(testCase, obj.Vm, input);
    verifyEqual(testCase, obj.max_time, max_time);
end

function testAddSegment(testCase)
    % Test that neuron segments are correctly creating when passing the
    % segment type (i.e. passing "NODE" vs "INTERNODE")
    
    % create Neuron object
    max_time = 10; 
    time_step = 0.1;
    neuron = Neuron(max_time, time_step);

    % define segment parameters
    node_params = [0.1, -1, 15];
    internode_params = [0.15, -1, 23];

    neuron.add_segment("NODE", node_params);  % add "NODE" segment
    neuron.add_segment("INTER", internode_params); % add "INTERNODE" segment

    % confirm "NODE" segment parameters
    verifyEqual(testCase, neuron.neuron_segments(1), 0);
    verifyEqual(testCase, neuron.noise_params(1), node_params(1));
    verifyEqual(testCase, neuron.snr_params(1), node_params(2));
    verifyEqual(testCase, neuron.n_params(1), 0); % confirm that even when passing 
    % an n_param value in the node_params, it still returns 0

    % confirm "INTERNODE" segment parameters
    verifyEqual(testCase, neuron.neuron_segments(2), 1);
    verifyEqual(testCase, neuron.noise_params(2), internode_params(1));
    verifyEqual(testCase, neuron.snr_params(2), internode_params(2));
    verifyEqual(testCase, neuron.n_params(2), internode_params(3));
end

function testConductionVelocity(testCase)
    % Set Up   
    neuron_sequence = [0 1 0];
    voltage = [1 -1 -1; -1 -1 -1; -1 -1 1];
    time = [0 1 2];
    axon_length = 1;
    expected_velocity = [1.5, 0.5];

    % Run
    [conduction_velocity_node, conduction_velocity_true] = conduction_velocity(neuron_sequence, voltage, time, axon_length);
    conduction_velocity_value = [conduction_velocity_node, conduction_velocity_true];

    % Validate
    verifyEqual(testCase, expected_velocity, conduction_velocity_value);    
end

function testFiringRate(testCase)
    % Set Up

    % We will use a triangle wave with a frequency of 50Hz to test
    T = 10*(1/50);    
    fs = 1000;
    t = 0:1/fs:T-1/fs;
    
    x = sawtooth(2*pi*50*t,1/2);
    test_output = 100000 * x;
    test_time = t;

    % Expected Results
    expected_firing_rate = 50;

    % Run
    [computed_firing_rate, pks, locs] = get_firing_rate(test_output, test_time);

    plot(test_time, test_output, locs, pks, 'o');

    % Validate
    verifyEqual(testCase, computed_firing_rate, expected_firing_rate);
end
    