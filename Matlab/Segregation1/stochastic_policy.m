function [P, cpu_time]=stochastic_policy(P, R, discount, policy0, maxiter, stochasitc)
% 
% stochastic_policy Resolution of discounted MDP 
%                       with (stochasitc) policy iteration algorithm
% 
% Arguments ---------------------------------------------------------------
% Let S = number of states, A = number of actions
%   P(SxSxA) = transition matrix 
%              P could be an array with 3 dimensions or 
%              a cell array (1xA), each cell containing a matrix (SxS) possibly sparse
%   R(SxSxA) or (SxA) = reward matrix
%              R could be an array with 3 dimensions (SxSxA) or 
%              a cell array (1xA), each cell containing a sparse matrix (SxS) or
%              a 2D array(SxA) possibly sparse  
%   discount = discount rate, in ]0, 1[
%   policy0(S) = starting policy, optional 
%   max_iter = maximum number of iteration to be done, upper than 0, 
%              optional (default 1000)
%Evaluation ---------------------------------------------------------------
%   policy(S) = stochastic policy or optimal policy
%   cputime = used CPU Time
%
% initialization of optional arguments
cpu_time = cputime;
if margin < 6; stochastic = 1; end
[V, P, ~, ~] = mdp_policy_iteration(P, R, discount, policy0, maxiter, 1);
num_states = size(P, 1);
num_actions = size(P, 3);


if stochastic
    Q = zeros(num_states, num_actions);
    for i = 1 : num_states
        for j = 1 : num_actions
            p = P{j}(i,:);
            Q(i, j) = p*(reward + discount*V);
        end
    end
    Q = Q - max(Q, [], 2);
    Q = exp(Q)/sum(exp(Q), [], 2); 
    P = Q;
end

cpu_time = cputime - cpu_time;






