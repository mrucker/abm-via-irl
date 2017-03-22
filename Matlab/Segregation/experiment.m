addpath(fullfile(fileparts(which(mfilename)),'../MDPtoolbox/'));

Run();

function Run()

    discount = 0.99;
    epsilon  = 1;
    
    state_space = [...
        horzcat(ones(4, 1)*0, [0;0;1;1], [0;1;0;1]);...
        horzcat(ones(4, 1)*1, [0;0;1;1], [0;1;0;1]);...
        horzcat(ones(4, 1)*2, [0;0;1;1], [0;1;0;1]);...
        horzcat(ones(4, 1)*3, [0;0;1;1], [0;1;0;1]);...
        horzcat(ones(4, 1)*4, [0;0;1;1], [0;1;0;1]);...
        horzcat(ones(4, 1)*5, [0;0;1;1], [0;1;0;1]);...
    ];
        
    num_actions  = 4;
    num_states   = size(state_space,1); %|{0 1 2 3 4 5}| * |{0 1}| * |{0 1}|
    num_features = 3;
    
    num_samples = 100; % Number of samples to use in feature expectations
    num_steps   = 100; % Number of steps to use in each sample

    % Initial uniform state distribution
    D = ones(num_states, 1) / num_states;
    P = cell(num_actions, 1);
    
    % Transition probabilities
    for a = 1:num_actions
        for from = 1:num_states
            for to = 1:num_states
                P{a}(from, to) = T(from, a, to);
            end
        end
    end
    
    % Sample trajectories from expert policy.
    expert_trajectories = ReadSampleTrajectories('SampleTrajectories.csv');
    expert_trajectories = horzcat(expert_trajectories{2}, expert_trajectories{3}, expert_trajectories{4});
    
    mu_expert = zeros(num_features,1);
    for t = 1:numel(expert_trajectories)
        mu_expert = mu_expert + discount^(t-1) * phi(expert_trajectories(t));
    end

    mu     = zeros(num_features, 0);
    mu_est = zeros(num_features, 0);
    w      = zeros(num_features, 0);
    t      = zeros(0,1);
    R      = zeros(num_states,1);

    % Projection algorithm
    % 1.
    Pol{1}  = ceil(rand(num_states,1) * num_actions);
    mu(:,1) = feature_expectations(P, discount, D, Pol{1}, num_samples, num_steps);
    i = 2;

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

        fprintf('t(%d) = %6.4f\n', i, t(i));

        % 3.
        if t(i) <= epsilon
            fprintf('Terminate...\n\n');
            break;
        end

        % 4. We need to finish this
        for j = 1:num_states
            R(j) =  phi(state_space(j, :)) * w(:,i);
        end
        
        [~, Pol{i}] = Value_Iteration(P, R, discount);

        % 5.
        mu(:,i) = feature_expectations(P, discount, D, Pol{i}, num_samples, num_steps);

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

    fprintf('Comparison between performance of expert and apprentice on found reward function:\n');
    fprintf('V(Apprentice): %6.4f\n', w(:,selected)' * mu(:, selected));
    %fprintf('V(Mixed): %6.4f\n', w(:,selected)' * mu_mixed);
    fprintf('V(Expert): %6.4f\n\n', w(:,selected)' * mu_expert);

    fprintf('Comparison between performance of expert and apprentice on found reward function:\n');
    fprintf('V(Apprentice): %6.4f\n', w_last' * mu(:, selected));
    %fprintf('V(Mixed): %6.4f\n', w_last' * mu_mixed);
    fprintf('V(Expert): %6.4f\n\n', w_last' * mu_expert);


    fprintf('Comparison between performance of expert and apprentice on true reward function:\n');
    fprintf('V(Apprentice): %6.4f\n', r' * mu(:, selected));
    %fprintf('V(Mixed): %6.4f\n', r' * mu_mixed);
    fprintf('V(Expert): %6.4f\n\n', r' * mu_expert);

    fprintf('Done\n');
end

function [V, policy] = Value_Iteration(P, R, discount)
    [V, policy, ~, ~] = mdp_value_iteration (P, R, discount);
end