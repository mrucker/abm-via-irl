addpath(genpath(fullfile(fileparts(which(mfilename)),'../_dependencies/')));
addpath(genpath(fullfile(fileparts(which(mfilename)),'../_utilities/')));

discount = 0.99;
epsilon  = .5;

[state_space, state_action_space] = Spaces();

num_actions       = size(state_action_space,2);
num_states        = size(state_space,1);
num_state_actions = size(state_action_space,1);
num_features      = num_state_actions;

num_samples = 100; % Number of samples to use in feature expectations
num_steps   = 100; % Number of steps to use in each sample

% Sample trajectories from expert policy.
expert_trajectories = ReadSampleTrajectories_tsne('SampleTrajectories_lda.csv');
expert_lbls         = containers.Map(expert_trajectories{1}, expert_trajectories{7});
expert_trajectories = horzcat(expert_trajectories{1}, expert_trajectories{2}, expert_trajectories{3}, expert_trajectories{4}, expert_trajectories{5}, expert_trajectories{6});

agentIds = unique(expert_trajectories(:,1))';
episodes = unique(expert_trajectories(:,2))';

num_agents = length(agentIds);

m = zeros(num_agents,num_features);
o = zeros(num_agents,num_features);
r = zeros(num_agents,num_features);
l = repmat({''},num_agents,1);

tic

%rnd_agents = randperm(700, 400)-1;
%ind_agents = arrayfun(@(rnd_agent) (0:99)' + find(expert_trajectories(:,1) == rnd_agent, 1), rnd_agents, 'UniformOutput', false);
%ind_agents = cell2mat(ind_agents');
%P = T_lda(expert_trajectories(ind_agents, [6 3 4 5]), num_actions, num_states, state_space);

%delete(gcp('nocreate'));
%parpool(3);
for agent_idx = 1:num_agents

%    try
        phis = eye(num_features);

        sa_expert = [];
        D         = zeros(num_states,1);
        mu_expert = zeros(num_features,1);
        mu        = zeros(num_features, 0);
        mu_est    = zeros(num_features, 0);
        w         = zeros(num_features, 0);
        t         = zeros(0,1);
        R         = zeros(num_states,num_actions);
        episode_n = 0;
        Pol       = cell(0,1);
        agentId   = agentIds(agent_idx);

        agent_trajectories = expert_trajectories(expert_trajectories(:,1) == agentId, 2:6);

        %(KL) Abbel and Ng 2004 suggests 10 - 100 samples is ideal for this algorithm we have 21 currently
        for episode = episodes
            sa_episode  = find(agent_trajectories(:,1) == episode);

            if(length(sa_episode) < num_steps)
                continue;
            end

            episode_n = episode_n + 1;

            sa_episode = agent_trajectories(sa_episode(1:num_steps), [2 3 4 5]);
            sa_expert  = [sa_expert; sa_episode];

            sa_start    = sa_episode(1,[1 2 3]);
            sa_start    = find(all(state_space' == sa_start'));
            D(sa_start) = D(sa_start) + 1;
        end

        D  = D./sum(D);
        P = T_lda(sa_expert(:, [4 1 2 3]), num_actions, num_states, state_space);

        for e = (0:episode_n-1)*num_steps
            for t = 1:num_steps
                [~, state_action_ix] = ismember(sa_expert(e + t, :), state_action_space, 'rows');
                mu_expert = mu_expert + discount^(t-1) * phis(state_action_ix,:)';
            end
        end

        mu_expert = mu_expert./episode_n;

        assert(abs(sum(mu_expert) - 63.39) < 1, 'As long as num_steps == 100 and norm(phis,1) == 1 then mu_expert should sum to 63.39')        

        % Projection algorithm
        % 1.
        Pol{1}  = Init_Policy(P);
        mu(:,1) = feature_expectations_2(P, discount, D, Pol{1}, num_samples, num_steps, num_features, phis);
        i = 2;

        % 2.
        while 1
            if i > 2
                a = (mu(:,i-1) - mu_est(:,i-2))' * (mu_expert - mu_est(:,i-2)); 
                b = (mu(:,i-1) - mu_est(:,i-2))' * (mu(:,i-1) - mu_est(:,i-2));

                mu_est(:,i - 1) = mu_est(:,i - 2) + (a / b) * (mu(:,i - 1) - mu_est(:,i - 2));
            else
                mu_est(:,1) = mu(:,1);
            end
            w(:,i) = mu_expert - mu_est(:,i - 1);
            t(i)   = norm(w(:,i), 2);
            w(:,i) = w(:,i) / t(i);

            %fprintf('t(%d) = %6.4f\n', i, t(i));

            % 3.
            %(KL) for experiment, I added additional terminate conditions
            if i > 30 && (t(i) <= epsilon || (t(i-1)-t(i)<0.00001))
            %if t(i) <= epsilon 
                break;
            end

            % 4.
            %(KL) reshape w into S*A
            R = reshape(w(:,i), [num_actions, num_states])';
            [V, Pol{i}] = Value_Iteration(P, R, discount);

            % 5.
            mu(:,i) = feature_expectations_2(P, discount, D, Pol{i}, num_samples, num_steps, num_features, phis);

            % 6.
            i = i + 1;
        end

        %fprintf('Selecting feature expectations closest to expert...\n');
        distances = bsxfun(@minus, mu, mu_expert);
        distances = sqrt(sum(distances .^ 2));
        [min_distance, selected] = min(distances);
        %fprintf('Distance: %6.4f\n\n', min_distance);
        
        w_last = w(:,i);

        %(KL) mixing together policies according to the mixture weights lambda
    %     fprintf('Calculating combination of mu...\n');
    %     cvx_begin
    %         variable lambda(i-1)
    %         minimize( norm( mu*lambda - mu_expert, 2 ) )
    %         subject to
    %             sum(lambda) == 1;
    %             lambda >= 0;
    %     cvx_end
    %     [~,idx] = max(lambda);
    %     mu_mixed = mu*lambda;

    %     stochastic_policy = zeros(num_states, num_actions);
    %     for i=1:length(lambda)
    %         pol_idx = (Pol{i}-1)*num_states + (0:num_states-1)' + 1;
    %         stochastic_policy(pol_idx) = stochastic_policy(pol_idx) + lambda(i);
    %     end

    m(agent_idx, :) = horzcat(mu_expert');    %expect
    o(agent_idx, :) = horzcat(w(:,selected)');%weight
    r(agent_idx, :) = horzcat(w(:,selected)');%reward
    l{agent_idx}    = expert_lbls(agentId);

    fprintf('%d Done t(%d) = %6.4f\n', agent_idx, i-1, t(i-1));

%     catch ME
%         fprintf('%d Failed (%s)\n', agent_idx, ME.message);
%     end
end
toc

non_failures = ~strcmp(l, '');

m = m(non_failures,:);
o = o(non_failures,:);
r = r(non_failures,:);
l = l(non_failures);

plot_3d(tsne(m,[], 3, min(30,size(m,1)), 30), l, 'mu');
plot_3d(tsne(r,[], 3, min(30,size(r,1)), 30), l, 'reward');

function [V, policy] = Value_Iteration(P, R, discount)    
    [V, policy, ~, ~] = mdp_value_iteration (P, R, discount);
end

function [state_space, state_action_space] = Spaces()
    conversation_length = 0:5;
    similar_partner_yn  = 0:1;
    people_around_yn    = 0:1;
    action              = 1:4;

    state_space = sortrows(cartesian(conversation_length, similar_partner_yn, people_around_yn), 1:3);

    state_action_space = horzcat(sortrows(repmat(state_space,4,1), 1:3), repmat(action', 24,1));
end

function Pol = Init_Policy(P)
    num_states = size(P{1},1);
    num_actions = size(P,1);
    
    actions = 1:num_actions;
    states = 1:num_states;
    
    Pol = zeros(num_states,1);
    
    for s = states
        valid_for_state         = arrayfun(@(a) sum(P{a}(s,:)) ~= 0, actions);
        actions_valid_for_state = actions(valid_for_state);
        
        if isempty(actions_valid_for_state)
            Pol(s) = 0; %because we have no transition probabilities for this state that means it is impossible to reach using P so we don't need an action defined.
        else
            Pol(s) = actions_valid_for_state(randperm(length(actions_valid_for_state),1));
        end
    end
end