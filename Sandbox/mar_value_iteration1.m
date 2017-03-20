function [V, policy, iter, cpu_time] = mar_value_iteration1(P, R, discount, epsilon, max_iter, V0)

    iter = 0;

    S_N = size(R,1);
    A_N = size(R,2);
    
    Q = zeros(S_N, A_N);

    if(nargin < 4)
        epsilon = .01;
    end

    if(nargin < 5)
        max_iter = 100;
    end

    if(nargin < 6)
        V = zeros(S_N, 001);
    else
        V = V0;
    end

%     if nargin < 5
%         if discount ~= 1
%             max_iter = mdp_value_iteration_bound_iter(P, R, discount, epsilon, V);            
%         else
%             max_iter = 1000;
%         end;
%     end

    if discount ~= 1
        epsilon = epsilon * (1-discount)/discount;
    end;

    done = false;

    while ~done

        v    = V;
        iter = iter + 1;

        for a_i = 1:A_N
            Q(:, a_i) = R(:,a_i) + P{a_i}*discount*V;
        end

        [V, policy] = max(Q, [], 2);

        done = max(V-v) < epsilon | iter == max_iter;
    end

    cpu_time = 0;
end