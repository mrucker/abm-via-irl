addpath(fullfile(fileparts(which(mfilename)),'../MDPtoolbox/'));

%%
% Make parameters availabe in functions
global n m num_macrocells num_states num_actions;

n = 32; % nxn gridworld
m = 4; % mxm macrocells

discount = 0.99;
epsilon = 1;

num_macrocells = (n / m) ^ 2;
num_states = n ^ 2;
num_actions = 4; % North, East, South, West

num_samples = 100; % Number of samples to take to approximate feature expectations
num_steps = 100; % Number of steps for each sample

% Initial uniform state distribution
D = ones(num_states, 1) / num_states;

% True reward function
mask = rand(num_macrocells, 1) > 0.9;
r = rand(num_macrocells,1) .* mask;
r = r ./ sum(r);
R = kron(reshape(r,(n/m),(n/m)), ones(m,m));
R = repmat(R(:), 1, num_actions); 

% Transition probabilities
for a = 1:num_actions
    P{a} = sparse([],[],[],num_states,num_states,num_states * (num_actions + 1));
    for from = 1:num_states
        
        P{a}(from, from) = T(from,a,from);
        
        if from > n && from <= num_states - n 
            P{a}(from, from - 1) = T(from,a,from - 1);
            P{a}(from, from + n) = T(from,a,from + n);
            P{a}(from, from + 1) = T(from,a,from + 1);
            P{a}(from, from - n) = T(from,a,from - n);
        elseif from == 1 % Top-left corner
            P{a}(from, from + n) = T(from,a,from + n);
            P{a}(from, from + 1) = T(from,a,from + 1);
        elseif from <= n % Left column
            P{a}(from, from - 1) = T(from,a,from - 1);
            P{a}(from, from + n) = T(from,a,from + n);
            P{a}(from, from + 1) = T(from,a,from + 1);
        elseif from == num_states % Bottom-right corner
            P{a}(from, from - 1) = T(from,a,from - 1);
            P{a}(from, from - n) = T(from,a,from - n);
        elseif from > num_states - n % Right column
            P{a}(from, from - 1) = T(from,a,from - 1);
            P{a}(from, from + 1) = T(from,a,from + 1);
            P{a}(from, from - n) = T(from,a,from - n);
        end
    end
end

% Solve MDP with value iteration
[V, policy, iter, cpu_time] = mdp_value_iteration (P, R, discount);
