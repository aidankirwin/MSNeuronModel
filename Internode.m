classdef Internode
    
    % Circuit model of an internode
    
    properties
        % Constant vals
        Cm  {mustBeNumeric}  % specific membrane capacitance
        ra  {mustBeNumeric}  % specific resistance of axoplasm
        rl  {mustBeNumeric}  % resistance of internodal segment
        rmy {mustBeNumeric}  % resistance of the myelin sheath
        Cmy {mustBeNumeric}  % capacitance of the myelin sheath

        % Non-constant vals
        Vm % membrane voltage array
        max_time {mustBeNumeric}
    end

    methods
        function obj = Internode(Vm, n, max_time, noise_perc, consts)
            % Inputs
            % Vm: array of membrane voltage outputted from previous
            % node/internode
            % n: number of myelin wraps

            obj.Vm = Vm;

            %%% ADD NOISE TO CONSTANTS
            % make constant parameter vector
            % [Cm, ra, rl]
            param = [1, 1, 1/0.3];

            if nargin > 4
                param = consts;
            end

            param_noise = [];

            for i = 1:length(param)
                param_noise = [param_noise, param(i) + noise_perc * param(i) * rand];
            end

            obj.Cm = param_noise(1);
            obj.ra = param_noise(2); % this is assumed to be 1
            obj.rl = param_noise(3); % calculated from leakage conductance

            % without noise:
            % obj.Cm = 1;
            % obj.ra = 1;
            % obj.rl = 1 / 0.3;
            
            obj.rmy = (2*n) * obj.rl;
            obj.Cmy = obj.Cm / (2*n); % calculate from the membrane capacitance

            obj.max_time = max_time;
        end

        function [t, x] = simulate(obj, time_arr)
            x0 = 0;
            [t, x] = ode45(@(t, x) obj.x_dot(t, x), time_arr, x0);
        end

        function x_dot = x_dot(obj, t, x)
            % ode45 needs a function that takes time t and state as inputs.
            % input u is Vm(t)

            % x1 = v0
            v0 = x;
            
            % input function
            Vm_at_t = obj.input_func(t);
            
            a = -(1/(obj.ra*obj.Cmy) + 1/(obj.rmy*obj.Cmy));
            b = 1/(obj.ra*obj.Cmy);

            x_dot = a*v0 + b*Vm_at_t;
        end
        
        function Vm_at_t = input_func(obj, t)
            % determines the current value given a time t.
            
            % since Vm(t) must be indexed as an array, but we only know t,
            % the input function is indexed approximately to keep this function as O(1)

            % Inputs:
            % t: time point in the simulation

            % Outputs:
            % Vm_at_t: membrane voltage of the previous axon segment for time t

            time_ratio = t / obj.max_time;
            index = time_ratio * (length(obj.Vm) - 1) + 1;

            Vm_at_t = obj.Vm(round(index));
        end
    end
end