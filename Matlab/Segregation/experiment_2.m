addpath(fullfile(fileparts(which(mfilename)),'../MDPtoolbox/'));
addpath(fullfile(fileparts(which(mfilename)),'../Sandbox/'));


%(KL) I uncommented the function line in order to access the result variables after running this script
%Run();

%function learned_policy = Run()

    %(KL) for use in feature_expectations
    global num_features;

    tts = 0;
    tt = tic();
    
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
    state_space = vertcat(state_space, [9,9,9]); %(KL) limbo state
        
    num_actions  = 4;
    num_states   = size(state_space,1); %|{0 1 2 3 4 5}| * |{0 1}| * |{0 1}|
    %num_features = 3;
    %(KL) our number of features is equal to the number of states for now
    num_features = num_states; 
    
    num_samples = 100; % Number of samples to use in feature expectations
    num_steps   = 100; % Number of steps to use in each sample
        
    % Sample trajectories from expert policy.
    expert_trajectories = ReadSampleTrajectories('SampleTrajectories.csv');
    expert_StateActions = horzcat(expert_trajectories{5}, expert_trajectories{2}, expert_trajectories{3}, expert_trajectories{4});
    expert_States       = horzcat(expert_trajectories{2}, expert_trajectories{3}, expert_trajectories{4});
    
    D = ones(num_states, 1) / num_states;
    P = T_SA(expert_StateActions, num_actions, num_states);
    
    mu_expert = zeros(num_features,1);
    for t = 1:100000%size(expert_States,1)
        %mu_expert = mu_expert + discount^(t-1) * phi(expert_trajectories(t, :))';
        
        %(KL) I added phi_2 function, which is my understanding for Phi
        [~, state_ix] = ismember(expert_States(t, :), state_space, 'rows');
        mu_expert = mu_expert + discount^(t-1) * phi_2(state_ix);
    end
    %(KL) I guess we need more than one trajectory for empirical estimate for mu_expert

    mu     = zeros(num_features, 0);
    mu_est = zeros(num_features, 0);
    w      = zeros(num_features, 0);
    t      = zeros(0,1);
    R      = zeros(num_states,num_actions);

    % Projection algorithm
    % 1.
    Pol{1}  = ceil(rand(num_states,1) * num_actions);
    mu(:,1) = feature_expectations_2(P, discount, D, Pol{1}, num_samples, num_steps);
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

        if(i == 1 || ceil(t(i)) ~= ceil(t(i-1)))
            tts(end+1) = toc(tt);
            disp(['Elapsed time is ' num2str(tts(end)) ' seconds']);
            fprintf('t(%d) = %6.4f\n', i, t(i));
            tt = tic();
        end        

        % 3.
        %(KL) for experiment, I added additional terminate conditions
        %if t(i) <= epsilon || (i>20 && t(i-5)-t(i)<0.001)
        %    fprintf('Terminate...\n\n');
        %    break;
        %end

        % 4.
%         for j = 1:num_states
%             R(j, :) =  repmat(phi_2(state_space(j, :)) * w(:,i), 1,4);
%         end

        %(KL) For now, our R is this because the features are equal to the states
        R = repmat(w(:,i), 1, num_actions);
        [V, Pol{i}, iter, cpu_time] = mdp_value_iteration(P, R, discount);

        % 5.
        mu(:,i) = feature_expectations_2(P, discount, D, Pol{i}, num_samples, num_steps);

        % 6.
        i = i + 1;
    end
    toc

    fprintf('Selecting feature expectations closest to expert...\n');
    distances = bsxfun(@minus, mu, mu_expert);
    distances = sqrt(sum(distances .^ 2));
    [min_distance, selected] = min(distances);
    fprintf('Distance: %6.4f\n\n', min_distance);
    
    %(KL) set output
    learned_policy = Pol{selected};
    
    
    w_last = w(:,i);

    fprintf('Comparison between performance of expert and apprentice on found reward function:\n');
    fprintf('V(Apprentice): %6.4f\n', w(:,selected)' * mu(:, selected));
    %fprintf('V(Mixed): %6.4f\n', w(:,selected)' * mu_mixed);
    fprintf('V(Expert): %6.4f\n\n', w(:,selected)' * mu_expert);

    fprintf('Comparison between performance of expert and apprentice on found reward function:\n');
    fprintf('V(Apprentice): %6.4f\n', w_last' * mu(:, selected));
    %fprintf('V(Mixed): %6.4f\n', w_last' * mu_mixed);
    fprintf('V(Expert): %6.4f\n\n', w_last' * mu_expert);


    %fprintf('Comparison between performance of expert and apprentice on true reward function:\n');
    %fprintf('V(Apprentice): %6.4f\n', r' * mu(:, selected));
    %fprintf('V(Mixed): %6.4f\n', r' * mu_mixed);
    %fprintf('V(Expert): %6.4f\n\n', r' * mu_expert);

    fprintf('Done\n');
    
    tts(end+1) = toc(tt);
    disp(['Elapsed time is ' num2str(sum(tts)) ' seconds']);
%end

function [V, policy] = Value_Iteration(P, R, discount)
    [V, policy, ~, ~] = mdp_value_iteration (P, R, discount);
end