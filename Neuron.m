classdef Neuron < handle
    % Contains all segments (HH or Internodes) for a single neuron
    % Individual segments are encoded as a binary value and a set of
    % parameters; each parameter is stored in a corresponding parameter
    % array

    % A single neuron can be simulated in full
    
    properties
        neuron_segments % array of nodes and internodes; 0 = node, 1 = internode 
        noise_params % noise parameter array; affects amount of noise on a single segments consts
        snr_params % signal-to-noise (S/N) ratio on the output of a segment
        n_params % myelin wrap count (n) parameter array

        node_consts % constants for HH model if varied
        internode_consts % constants for internode model if varied

        output % output matrix of entire neuron

        max_time  {mustBeNumeric} % const max time for all segment simulations
        time_step {mustBeNumeric} % const time step for all segment simulations
        time_arr  {mustBeNumeric} % all time points simulation will run for
    end
    
    methods
        function obj = Neuron(max_time, time_step)
            obj.max_time = max_time;
            obj.time_step = time_step;
            obj.time_arr = 0:time_step:max_time;

            obj.neuron_segments = [];
            obj.noise_params = [];
            obj.snr_params = [];
            obj.n_params = [];

            obj.node_consts = [];
            obj.internode_consts = [];

            obj.output = [];
        end
        
        function add_segment(obj, segment_type, segment_params)
            % add a segment of neuron

            % Inputs:
            % segment_type: node or internode
            % segment_params: array of doubles, order matters
                % segment_params(1) = noise percentage for segment consts
                % segment_params(2) = signal-to-noise ratio for segment output
                % segment_params(3) = myelin thickness of internode

            if segment_type == "NODE"
                % add 0 to neuron segment array
                obj.neuron_segments = [obj.neuron_segments, 0];
                
                % add noise percentage to parameter array
                obj.noise_params = [obj.noise_params, segment_params(1)];

                % add signal-to-noise ratio to parameter array
                obj.snr_params = [obj.snr_params, segment_params(2)];

                % set myelin wraps to 0 (not relevant to HH segment)
                obj.n_params = [obj.n_params, 0];
            else
                % add 1 to neuron segment array
                obj.neuron_segments = [obj.neuron_segments, 1];
                
                % add noise percentage to noise param array
                obj.noise_params = [obj.noise_params, segment_params(1)];

                % add signal-to-noise ratio to parameter array
                obj.snr_params = [obj.snr_params, segment_params(2)];

                % add myelin wraps to myelin param array
                obj.n_params = [obj.n_params, segment_params(3)];
            end
        end

        function [out, t] = simulate(obj, init_input, offset)
            % simulate the membrane potential of EACH segment in a SINGLE
            % neuron wrt time

            % Inputs:
            % init_input: the injection current to the first HH node in the
            % neuron (representing the soma)

            % Outputs:
            % out: a matrix with n rows and t cols, where n = number of
            % neuron segments and t = number of voltage samples (this will
            % equal the number of time points)
            % t: an array with each time point the simulation runs for

            if isempty(obj.neuron_segments)
                disp("ERROR IN Neuron.simulate: SEGMENT ARRAY IS EMPTY.");
                out = -1;
                t = -1;
                return
            end

            if nargin < 3
                offset = -70;
            end

            % initialize output matrix
            obj.output = zeros(length(obj.neuron_segments), length(obj.time_arr));
            
            for i = 1:length(obj.neuron_segments)
                disp('Running simulation of neuron segment:');
                disp(i);

                if obj.neuron_segments(i) == 0  % this segment is an HH node

                    if i == 1  % this segment is the first HH node
                        % get noise parameter
                        noise_perc = obj.noise_params(i);

                        if isempty(obj.node_consts)
                            % generate HH model
                            HH_model = HodgkinHuxley(init_input, true,...
                                obj.max_time, noise_perc);
                        else
                            % generate HH model
                            HH_model = HodgkinHuxley(init_input, true,...
                                obj.max_time, noise_perc, obj.node_consts);
                        end
                    else
                        % get the previous segments output voltage
                        Vin = obj.output(i - 1, :);

                        % get noise parameter
                        noise_perc = obj.noise_params(i);

                        if isempty(obj.node_consts)
                            % generate HH model
                            HH_model = HodgkinHuxley(Vin, false, obj.max_time, ...
                                noise_perc);    
                        else
                            % generate HH model
                            HH_model = HodgkinHuxley(Vin, false, obj.max_time, ...
                                noise_perc, obj.node_consts);  
                        end
                    end

                    % run HH simulation
                    [time, state] = HH_model.simulate(obj.time_arr);

                    % get snr parameter
                    snr = obj.snr_params(i);

                    % add white gaussian noise
                    if snr ~= -1
                        state = awgn(state, snr);
                    end
            
                    % add Vm(t) to output matrix                    
                    for k = 1:length(state(:, 1))
                        obj.output(i, k) = state(k, 1);
                    end

                else  % this segment is an internode

                    % probably need error check here in case neuron[] starts with
                    % internode
                    Vin = obj.output(i - 1, :);

                    % get noise parameter
                    noise_perc = obj.noise_params(i);

                    % get myelin thickness
                    tmy = obj.n_params(i);

                    if isempty(obj.internode_consts)
                        % generate internode model
                        internode_model = Internode(Vin, tmy, obj.max_time, ...
                            noise_perc);
                    else
                        % generate internode model
                        internode_model = Internode(Vin, tmy, obj.max_time, ...
                            noise_perc, obj.internode_consts);
                    end

                    % run internode simulation
                    [time, state] = internode_model.simulate(obj.time_arr);

                    % get snr parameter
                    snr = obj.snr_params(i);

                    % add white gaussian noise
                    if snr ~= -1
                        state = awgn(state, snr);
                    end
            
                    % add Vm(t) to output matrix
                    for k = 1:length(state)
                        obj.output(i, k) = state(k);
                    end

                end
            end
            
            obj.output = -obj.output + offset; % adjust outputs

            out = obj.output;
            t = time;
        end

        function modify_consts(obj, node_consts, internode_consts)
            obj.node_consts = node_consts;
            obj.internode_consts = internode_consts;
        end
    end
end