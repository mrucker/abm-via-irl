%FEATURE_EXPECTATIONS Expected features.
%   FEATURE_EXPECTATIONS produces the expected accumulated feature counts
%   if the given POLICY is followed.
function mu = feature_expectations_2(P, discount, D, policy, num_samples, num_steps, num_features, phis)
    
    Mu = zeros(num_samples, num_features);

    for i = 1:num_samples
        %get the first state
        cumprob = cumsum(D);
        r = rand();
        s = find(cumprob > r, 1);

        %initialize Mu
        Mu(i,:) = zeros(num_features, 1)';

        for t = 1:num_steps
            a = policy(s);
            cumprob = cumsum(P{a}(s,:));
            r = rand();
            s_next = find(cumprob > r, 1);
            
            %calculate state_action_space index
            as_ix = (s-1)*4 + a;

            Mu(i,:) = Mu(i,:) + discount^(t-1) * phis(as_ix,:);

            s = s_next;
        end
    end
    
    mu = mean(Mu)';
end

