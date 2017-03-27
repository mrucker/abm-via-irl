%FEATURE_EXPECTATIONS Expected features.
%   FEATURE_EXPECTATIONS produces the expected accumulated feature counts
%   if the given POLICY is followed.
function mu = feature_expectations_2(P, discount, D, policy, num_samples, num_steps)

    global num_features;
    
    Mu = zeros(num_samples, num_features);

    for i = 1:num_samples
        trajectory = zeros(num_steps,1);

        cumprob = cumsum(D);
        r = rand();
        s = find(cumprob > r, 1);
        trajectory(1) = s;
        Mu(i,:) = phi_2(s)';

        for t = 2:num_steps
            a = policy(s);
            cumprob = cumsum(P{a}(s,:));
            r = rand();
            
            s = find(cumprob > r, 1);

            trajectory(t) = s;
            
            Mu(i,:) = Mu(i,:) + discount ^ (t-1) * phi_2(s)';
        end
    end
    
    mu = mean(Mu)';
end

