%% Simulation 1
clear
clc

sim1_vary_myelin(10, 7.5, 202.5);

%% Simulation 2
clear
clc

sim2_demyelinated_internode(10);

%% Simulation 3
clear
clc

sim3_internode_to_node(10);

%% Optimization
clear
clc

param = 1;
begin_val = 6;
end_val = 10;

optimization(param, 6, 10, "HH");