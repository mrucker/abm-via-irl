addpath(genpath(fullfile(fileparts(which(mfilename)),'../_dependencies/')));

global state_space;

%(KL) I uncommented the function line in order to access the result variables after running this script
%Run();

%function learned_policy = Run()
    
    discount = 0.99;
    epsilon  = .7;

    conversation_length = 0:5;
    similar_partner_yn = 0:1;
    people_around_yn = 0:1;
    action = 1:4;
    state_space = sortrows(combvec(conversation_length, similar_partner_yn, people_around_yn)', 1:3);
    state_space = vertcat(state_space, [9,9,9]); %limbo state
    state_action_space = horzcat(sortrows(repmat(state_space,4,1), 1:3), repmat(action', 25,1));
        
    num_actions = length(action);
    num_states = size(state_space,1);
    num_state_actions = size(state_action_space,1);
    %(KL) our number of features is equal to the number of states for now
    num_features = num_state_actions; 
    
    phis = zeros(num_state_actions, num_features);
    for i = 1:num_state_actions
        phis(i,i) = 1;
    end
    
    num_samples = 100; % Number of samples to use in feature expectations
    num_steps   = 100; % Number of steps to use in each sample

        
    % Sample trajectories from expert policy.
    expert_trajectories = ReadSampleTrajectories_2('SampleTrajectories_2.csv');
    expert_trajectories = horzcat(expert_trajectories{1}, expert_trajectories{2}, expert_trajectories{3}, expert_trajectories{4}, expert_trajectories{5}, expert_trajectories{6});
    
    agentIds = unique(expert_trajectories(:,1))';
    episodes = unique(expert_trajectories(:,2))';    
    
    for agentId = agentIds
        
        sa_expert = [];        
        D         = zeros(num_states,1);
        mu_expert = zeros(num_features,1);
        mu        = zeros(num_features, 0);
        mu_est    = zeros(num_features, 0);
        w         = zeros(num_features, 0);
        t         = zeros(0,1);
        R         = zeros(num_states,num_actions);
        
        %(KL) Abbel and Ng 2004 suggests 10 - 100 samples is ideal for this algorithm we have 21 currently
        for episode = episodes
            sa_episode  = find(all(expert_trajectories(:,1:2)' == [agentId;episode]));
            
            if(length(sa_episode) < num_steps)
                episodes = episodes(episodes ~= episode);
                continue; 
            end
            
            sa_episode = expert_trajectories(sa_episode(1:num_steps), [3 4 5 6]);
            sa_expert  = [sa_expert; sa_episode];
        
            sa_start = sa_episode(1,[1 2 3]);
            sa_start = find(all(state_space' == sa_start'));
            D(sa_start) = D(sa_start) + 1;
        end
        
        D = D./sum(D);
        P = T_SA(sa_expert(:, [4 1 2 3]), num_actions, num_states);

        for e = (0:length(episodes)-1)*num_steps
            for t = 1:num_steps
                [~, state_action_ix] = ismember(sa_expert(e + t, :), state_action_space, 'rows');
                mu_expert = mu_expert + discount^(t-1) * phis(state_action_ix,:)';
            end
        end                

        mu_expert = mu_expert./length(episodes);

        assert(abs(sum(mu_expert) - 63.39) < 1, 'As long as num_steps == 100 and norm(phis,1) == 1 then mu_expert should sum to 63.39')
        
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
                a = (mu(:,i-1) - mu_est(:,i-2))' * (mu_expert - mu_est(:,i-2)); 
                b = (mu(:,i-1) - mu_est(:,i-2))' * (mu(:,i-1) - mu_est(:,i-2));

                mu_est(:,i - 1) = mu_est(:,i - 2) + (a / b) * (mu(:,i - 1) - mu_est(:,i - 2));
            else
                mu_est(:,1) = mu(:,1);
            end
            w(:,i) = mu_expert - mu_est(:,i - 1);
            t(i)   = norm(w(:,i), 2);
            w(:,i) = w(:,i) / t(i);

            %if(i == 1 || ceil(t(i)) ~= ceil(t(i-1)))
                %tts(end+1) = toc(tt);
                %disp(['Elapsed time is ' num2str(tts(end)) ' seconds']);
                %fprintf('t(%d) = %3.0f\n', i, ceil(t(i)));
                fprintf('t(%d) = %6.4f\n', i, t(i));
            %    tt = tic();
            %end        

            % 3.
            %(KL) for experiment, I added additional terminate conditions
            %if t(i) <= epsilon || (i>20 && t(i-1)-t(i)<0.0001)
            if t(i) <= epsilon 
                fprintf('Terminate...\n\n');
                break;
            end

            % 4.
            %(KL) reshape w into S*A
            R = reshape(w(:,i), [num_actions, num_states])';
            [V, Pol{i}, iter, cpu_time] = mdp_value_iteration(P, R, discount);

            % 5.
            mu(:,i) = feature_expectations_2(P, discount, D, Pol{i}, num_samples, num_steps, num_features, phis);

            % 6.
            i = i + 1;
        end
        toc

        fprintf('Selecting feature expectations closest to expert...\n');
        distances = bsxfun(@minus, mu, mu_expert);
        distances = sqrt(sum(distances .^ 2));
        [min_distance, selected] = min(distances);
        fprintf('Distance: %6.4f\n\n', min_distance);

        w_last = w(:,i);

        %(KL) mixing together policies according to the mixture weights lambda
        fprintf('Calculating combination of mu...\n');
        cvx_begin
            variable lambda(i-1)
            minimize( norm( mu*lambda - mu_expert, 2 ) )
            subject to
                sum(lambda) == 1;
                lambda >= 0;
        cvx_end
        [~,idx] = max(lambda);
        mu_mixed = mu*lambda;

        stochastic_policy = zeros(num_states, num_actions);
        for i=1:length(lambda)
            pol_idx = (Pol{i}-1)*num_states + (0:num_states-1)' + 1;
            stochastic_policy(pol_idx) = stochastic_policy(pol_idx) + lambda(i);
        end

        fprintf('Comparison between performance of expert and apprentice on found reward function:\n');
        fprintf('V(Apprentice): %6.4f\n', w(:,selected)' * mu(:, selected));
        %fprintf('V(Mixed): %6.4f\n', w(:,selected)' * mu_mixed);
        fprintf('V(Expert): %6.4f\n\n', w(:,selected)' * mu_expert);

        fprintf('Comparison between performance of expert and apprentice on found reward function:\n');
        fprintf('V(Apprentice): %6.4f\n', w_last' * mu(:, selected));
        %fprintf('V(Mixed): %6.4f\n', w_last' * mu_mixed);
        fprintf('V(Expert): %6.4f\n\n', w_last' * mu_expert);


        fprintf('Done\n');

        tts(end+1) = toc(tt);
        disp(['Elapsed time is ' num2str(sum(tts)) ' seconds']);
    end
%end

function [V, policy] = Value_Iteration(P, R, discount)
    %[V, policy, ~, ~] = mar_value_iteration2 (P, R, discount);
    [V, policy, ~, ~] = mdp_value_iteration (P, R, discount);
end