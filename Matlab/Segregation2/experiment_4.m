addpath(genpath(fullfile(fileparts(which(mfilename)),'../_dependencies/')));

discount = 0.99;
epsilon  = .8;

[state_space, state_action_space] = Spaces();

num_actions       = size(state_action_space,2);
num_states        = size(state_space,1);
num_state_actions = size(state_action_space,1);
num_features      = num_state_actions;

num_samples = 100; % Number of samples to use in feature expectations
num_steps   = 100; % Number of steps in each sample to use in feature expectations
num_traj_steps = 50;  % Number of steps needed in an expert's trajectory

phis = eye(num_features);

% Sample trajectories from expert policy.
expert_trajectories = ReadSampleTrajectories_2('SampleTrajectories_3.csv');
expert_trajectories = horzcat(expert_trajectories{1}, expert_trajectories{2}, expert_trajectories{3}, expert_trajectories{4}, expert_trajectories{5}, expert_trajectories{6});

agentId_list = unique(expert_trajectories(:,1))';
episode_list = unique(expert_trajectories(:,2))';

% Calulate empirical estimates of feature expectations for all agents
mu_expert = zeros(num_features, length(agentId_list));
for agent_idx = 1:length(agentId_list)
    episodes = cell(0,1);
    num_valid_episode = 0; % number of valid episodes
    agentId   = agentId_list(agent_idx);
    agent_trajectories = expert_trajectories(expert_trajectories(:,1) == agentId, 2:6);

    % look for valid episodes
    for e = episode_list
        sa_step_ix  = find(agent_trajectories(:,1) == e);
        if(length(sa_step_ix) < num_traj_steps)
            continue;
        end
        num_valid_episode = num_valid_episode + 1;
        episodes{num_valid_episode} = agent_trajectories(sa_step_ix(1:num_traj_steps), [2 3 4 5]);
    end

    % calculate mu_expert in each valid episode and add them
    for ve = 1:num_valid_episode
        for t = 1:num_traj_steps
            [~, state_action_ix] = ismember(episodes{ve}(t,:), state_action_space, 'rows');
            mu_expert(:,agent_idx) = mu_expert(:,agent_idx) + discount^(t-1) * phis(state_action_ix,:)';
        end
    end
    
    % get average mu_expert
    mu_expert(:,agent_idx) = mu_expert(:,agent_idx)/num_valid_episode;
end

%(KL) it seems odd...

%plot(elbowCalulation(mu_expert, 5))




%(KL) trying Hierarchical Clustering
dist = pdist(mu_expert', 'euclidean');
clustTree = linkage(dist, 'average');
dendrogram(clustTree, 0);

%(KL) 3 clusters looks reasonable
num_clusters = 3;
group_idx = cell(num_clusters,1);
[~, T] = dendrogram(clustTree, num_clusters);
for i=1:num_clusters
    group_idx{i} = find(T==i);
end













for i=1:num_clusters
    % Projection algorithm 
    
    
    
    
    
end









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