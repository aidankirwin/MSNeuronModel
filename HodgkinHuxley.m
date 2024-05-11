classdef HodgkinHuxley
    
    % Circuit model of a neuronal node from A. L. Hodgkin and A. F. Huxley
    % (1952), A quantitative description of membrane current and its 
    % application to conduction and excitation in nerve, The Journal of
    % Physiology
    
    properties
        % Constant vals
        Cm  {mustBeNumeric}   % specific membrane capacitance
        vna {mustBeNumeric}   % sodium equilibrium potential
        vk  {mustBeNumeric}   % potassium equilibrium potential
        vl  {mustBeNumeric}   % equilibrium potential of leakage current
        gna {mustBeNumeric}   % maximum sodium conductance
        gk  {mustBeNumeric}   % maximum potassium conductance
        gl  {mustBeNumeric}   % nonspecific leakage conductance
        ra  {mustBeNumeric}   % specific resistance of axoplasm 

        % Non-constant vals
        I % current injection array
        V % internodal voltage array
        starting_node % boolean val; true if HH is the first node in a neuron
        max_time {mustBeNumeric}
    end

    methods
        function obj = HodgkinHuxley(input, starting_node, max_time, noise_perc, consts)
            
            %%% SET START NODE
            if starting_node == true   % is this HH the first node in a neuron 
                obj.I = input; % input is an injection current
                obj.starting_node = true;
            else
                obj.V = input; % input is the membrane voltage at the internode
                obj.starting_node = false;
            end

            %%% ADD NOISE TO CONSTANTS
            % make constant parameter vector
            % [Cm, vna, vk, vl, gna, gk, gl, ra]

            param = [1, -115, 12, -10.613, 120, 36, 0.3, 1];

            if nargin > 4
                param = consts;
            end

            param_noise = [];
            
            % noise_perc is the maximum relative noise compared to the
            % parameter

            for i = 1:length(param)
                param_noise = [param_noise, param(i) + noise_perc * param(i) * rand];
            end

            obj.Cm  = param_noise(1);
            obj.vna = param_noise(2);
            obj.vk  = param_noise(3);
            obj.vl  = param_noise(4);
            obj.gna = param_noise(5);
            obj.gk  = param_noise(6);
            obj.gl  = param_noise(7);
            obj.ra  = param_noise(8);

            % without noise:
            % obj.Cm  = 1;
            % obj.vna = -115;
            % obj.vk  = 12;
            % obj.vl  = -10.613;
            % obj.gna = 120;
            % obj.gk  = 36;
            % obj.gl  = 0.3;
            % obj.ra  = 1;

            obj.max_time = max_time; % set max time
        end

        function [t, x] = simulate(obj, time_arr)
            x0 = [0; 0.3177; 0.0529; 0.595];   % not sure where these come from
            [t, x] = ode45(@(t, x) obj.x_dot(t, x), time_arr, x0);
        end

        function [x_dot] = x_dot(obj, t, x)
            % ode45 needs a function that takes time t and state x as inputs.
            % this means we need to use the general state-space equation format
            % from class. Let's say x1 = v, x2 = n, x3 = m, and x4 = h.
            % input u can be I(t) which we can define in this function.

            v = x(1);
            n = x(2);
            m = x(3);
            h = x(4);
            
            % input function
            I_at_t = obj.input_func(t, v);
            
            % make x_dot a column vector with 4 values then fill it appropriately.
            x_dot = [0; 0; 0; 0];
            
            x_dot(1) = obj.v_dot(v, n, m, h, I_at_t);
            x_dot(2) = obj.n_dot(v, n);
            x_dot(3) = obj.m_dot(v, m);
            x_dot(4) = obj.h_dot(v, h);
        end
        
        function I_at_t = input_func(obj, t, v)
            % determines the current value given a time t.
            
            % since I(t) must be indexed as an array, but we only know t,
            % the input function is indexed approximately to keep this function as O(1)

            % Inputs:
            % t: time point in the simulation
            % v: membrane potential at the node for given time t

            % Outputs:
            % I_at_t: input current for time t

            if obj.starting_node == true
                % if this node is the first node, then we have an injection
                % current function to index.
                
                % find the approximate index for the I(t) array
                % mathematically
                time_ratio = t / obj.max_time;
                index = time_ratio * (length(obj.I) - 1) + 1;
                
                I_at_t = obj.I(round(index));
            else
                % if this node is not the first node, then we need to
                % calculate the input current given V(t), which is the
                % membrane potential over time of the previous axon segment

                % find the approximate index for the V(t) array
                % mathematically
                time_ratio = t / obj.max_time;
                index = time_ratio * (length(obj.V) - 1) + 1;
                
                V_at_t = obj.V(round(index));
                
                % calculate the input current using V(t) and v
                I_at_t = (V_at_t - v) / obj.ra;
            end
        end
        
        % note that voltage at rest is 0V here, need to offset it
        function v_dot = v_dot(obj, v, n, m, h, I)
            v_dot = 1/obj.Cm * (I + obj.gk * n^4 * (obj.vk - v) + obj.gna...
                * m^3 * h * (obj.vna - v) + obj.gl * (obj.vl - v));
        end
        
        function n_dot = n_dot(obj, v, n)
            n_dot = obj.alpha_n(v) * (1 - n) - obj.beta_n(v) * n;
        end
        
        function m_dot = m_dot(obj, v, m)
            m_dot = obj.alpha_m(v) * (1 - m) - obj.beta_m(v) * m;
        end
        
        function h_dot = h_dot(obj, v, h)
            h_dot = obj.alpha_h(v) * (1 - h) - obj.beta_h(v) * h;
        end
        
        function alpha_n = alpha_n(obj, v)
            alpha_n = 0.01 * (v + 10) / (exp((v + 10)/10) - 1);
        end
        
        function beta_n = beta_n(obj, v)
            beta_n = 0.125 * exp(v/80);
        end
        
        function alpha_m = alpha_m(obj, v)
            alpha_m = 0.1 * (v + 25) / (exp((v + 25)/10) - 1);
        end
        
        function beta_m = beta_m(obj, v)
            beta_m = 4 * exp(v/20);
        end
        
        function alpha_h = alpha_h(obj, v)
            alpha_h = 0.07 * exp(v/20);
        end
        
        function beta_h = beta_h(obj, v)
            beta_h = 1/(exp((v + 30)/10) + 1);
        end
    end
end