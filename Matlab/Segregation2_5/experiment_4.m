addpath(genpath(fullfile(fileparts(which(mfilename)),'../_dependencies/')));

discount = 0.99;
epsilon  = .9;

[state_space, state_action_space] = Spaces();

num_actions       = size(state_action_space,2);
num_states        = size(state_space,1);
num_state_actions = size(state_action_space,1);
num_features      = num_state_actions;

num_samples = 100; % Number of samples to use in feature expectations
num_steps   = 50; % Number of steps in each sample to use in feature expectations
num_traj_steps = 50;  % Number of steps needed in an expert's trajectory

phis = eye(num_features);

% Sample trajectories from expert policy.
expert_trajectories = ReadSampleTrajectories_2('SampleTrajectories_3.csv');
expert_trajectories = horzcat(expert_trajectories{1}, expert_trajectories{2}, expert_trajectories{3}, expert_trajectories{4}, expert_trajectories{5}, expert_trajectories{6}, expert_trajectories{7});

% get transition probabilities
fprintf('Getting transition probabilities...\n');
P = T_SA(expert_trajectories(:, [6 3 4 5]), num_actions, num_states, state_space);

% Calulate empirical estimates of feature expectations for all agents
fprintf('Calulating empirical estimates of feature expectations...\n');
agentId_list = unique(expert_trajectories(:,1))';
num_agents = length(agentId_list);
episode_list = unique(expert_trajectories(:,2))';
mu_expert = zeros(num_features, length(agentId_list));
initCount = zeros(num_states,1);
num_valid_episode = zeros(num_agents,1); % number of valid episodes
for agent_idx = 1:length(agentId_list)
    episodes = cell(0,1);
    %num_valid_episode = 0; % number of valid episodes
    agentId   = agentId_list(agent_idx);
    agent_trajectories = expert_trajectories(expert_trajectories(:,1) == agentId, 2:6);

    % look for valid episodes
    for e = episode_list
        sa_step_ix  = find(agent_trajectories(:,1) == e);
        if(length(sa_step_ix) < num_traj_steps)
            continue;
        end
        num_valid_episode(agent_idx) = num_valid_episode(agent_idx) + 1;
        episodes{num_valid_episode(agent_idx)} = agent_trajectories(sa_step_ix(1:num_traj_steps), [2 3 4 5]);
        % count initial state visit for D
        init_state = agent_trajectories(1,[2 3 4]);
        init_s_id  = find(all(state_space' == init_state'));
        initCount(init_s_id) = initCount(init_s_id) + 1;
    end
    
    % calculate mu_expert in each valid episode and add them
    for ve = 1:num_valid_episode(agent_idx)
        for t = 1:num_traj_steps
            [~, state_action_ix] = ismember(episodes{ve}(t,:), state_action_space, 'rows');
            mu_expert(:,agent_idx) = mu_expert(:,agent_idx) + discount^(t-1) * phis(state_action_ix,:)';
        end
    end
    
    % get average mu_expert
    mu_expert(:,agent_idx) = mu_expert(:,agent_idx)/num_valid_episode(agent_idx);
end

% get distribution of first state
D = initCount./sum(initCount);

%(KL) trying Hierarchical Clustering
dist = pdist(mu_expert', 'cosine');
clustTree = linkage(dist, 'average');
figure('visible', 'on');
dendrogram(clustTree, 0);

prompt = 'How many clusters seems to be there? ';
num_clusters = input(prompt);
group_idx = cell(num_clusters,1);
figure('visible', 'off');
[~, T] = dendrogram(clustTree, num_clusters);

% Calculate mu_expert for each cluster
mu_expert_cluster = cell(num_clusters, 1);
for c=1:num_clusters
    group_idx{c} = find(T==c);
    mu_expert_cluster{c} = mu_expert(:,group_idx{c})*num_valid_episode(group_idx{c})...
                          ./sum(num_valid_episode(group_idx{c})); 
end


% Initialize result variables
pol_selected = cell(num_clusters, 1);
stochastic_pol_selected = cell(num_clusters, 1);
w_last = cell(num_clusters, 1);
w_selected = cell(num_clusters, 1);

for c=1:num_clusters
    fprintf('[Cluster %d] Starting projection algorithm...\n', c);
    % initialize cluster iteration variables
    mu          = zeros(num_features, 0);
    mu_est      = zeros(num_features, 0);
    w           = zeros(num_features, 0);
    t           = zeros(0,1);
    R           = zeros(num_states,num_actions);
    
    % Projection algorithm
    % 1.
    Pol{1}  = ceil(rand(num_states,1) * num_actions);
    mu(:,1) = feature_expectations_2(P, discount, D, Pol{1}, num_samples, num_steps, num_features, phis);
    i = 2;

    tts = 0;
    tt = tic();
    
    % 2.
    tic
    while 1
        if i > 2
            a = (mu(:,i-1) - mu_est(:,i-2))' * (mu_expert_cluster{c} - mu_est(:,i-2)); 
            b = (mu(:,i-1) - mu_est(:,i-2))' * (mu(:,i-1) - mu_est(:,i-2));

            mu_est(:,i - 1) = mu_est(:,i - 2) + (a / b) * (mu(:,i - 1) - mu_est(:,i - 2));
        else
            mu_est(:,1) = mu(:,1);
        end
        w(:,i) = mu_expert_cluster{c} - mu_est(:,i - 1);
        t(i)   = norm(w(:,i), 2);
        w(:,i) = w(:,i) / t(i);

        fprintf('[Cluster %d] t(%d) = %6.4f\n', c, i, t(i));

        % 3.
        if i > 30 && (t(i) <= epsilon || (t(i-5)-t(i)<0.00001)) % condition for experiment
            fprintf('[Cluster %d] Terminate...\n\n', c);
            break;
        end

        % 4.
        R = reshape(w(:,i), [num_actions, num_states])'; %reshape w into S*A
        [V, Pol{i}, iter, cpu_time] = mdp_value_iteration(P, R, discount);

        % 5.
        mu(:,i) = feature_expectations_2(P, discount, D, Pol{i}, num_samples, num_steps, num_features, phis);

        % 6.
        i = i + 1;
    end
    toc
    
    fprintf('[Cluster %d] Selecting feature expectations closest to expert...\n', c);
    distances = bsxfun(@minus, mu, mu_expert_cluster{c});
    distances = sqrt(sum(distances .^ 2));
    [min_distance, selected] = min(distances);
    fprintf('[Cluster %d] Distance: %6.4f\n\n', min_distance, c);
    
    w_last{c} = w(:,i);
    w_selected{c} = w(:,selected);
    pol_selected{c} = Pol{selected};
    
    %(KL) mixing together policies according to the mixture weights lambda
    fprintf('[Cluster %d] Calculating combination of mu...\n', c);
    cvx_begin
        variable lambda(i-1)
        minimize( norm( mu*lambda - mu_expert_cluster{c}, 2 ) )
        subject to
            sum(lambda) == 1;
            lambda >= 0;
    cvx_end
    [~,idx] = max(lambda);
    mu_mixed = mu*lambda;
    
    stochastic_pol_selected{c} = zeros(num_states, num_actions);
    for i=1:length(lambda)
        pol_idx = (Pol{i}-1)*num_states + (0:num_states-1)' + 1;
        stochastic_pol_selected{c}(pol_idx) = stochastic_pol_selected{c}(pol_idx) + lambda(i);
    end
    
    fprintf('[Cluster %d] Done\n', c);
    tts(end+1) = toc(tt);
    fprintf('[Cluster %d] Elapsed time is %s seconds\n', c, num2str(sum(tts)));
    
end

%% output values
% pol_selected{1}
% pol_selected{2}
% pol_selected{3}
% 
% stochastic_pol_selected{1}
% stochastic_pol_selected{2}
% stochastic_pol_selected{3}
% 
% w_last{1}
% w_last{2}
% w_last{3}
% 
% w_selected{1}
% w_selected{2}
% w_selected{3}

% Save environment information and stochastic policies to csv file
file_name = 'Segregation2_learned_policies.csv';
save_learned_policy(file_name, num_clusters, group_idx, stochastic_pol_selected);











%% Local functions

function [V, policy] = Value_Iteration(P, R, discount)    
    [V, policy, ~, ~] = mdp_value_iteration (P, R, discount);
end


function [state_space, state_action_space] = Spaces()
    conversation_length = 0:5;
    similar_partner_yn  = 0:1;
    people_around_yn    = 0:1;
    action              = 1:4;

    state_space = sortrows(combvec(conversation_length, similar_partner_yn, people_around_yn)', 1:3);
    state_space = vertcat(state_space, [9,9,9]); %limbo state

    state_action_space = horzcat(sortrows(repmat(state_space,4,1), 1:3), repmat(action', 25,1));
end