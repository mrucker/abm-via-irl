
function P = T_2_1(num_actions, num_states)
%%    actions
%     action 1, move short distance
%     action 2, move long distance
%     action 3, start conversation
%     action 4, continue conversation
%
%%    state space
%      1     0     0     0
%      2     0     0     1
%      3     0     1     0
%      4     0     1     1
%      5     1     0     0
%      6     1     0     1
%      7     1     1     0
%      8     1     1     1
%      9     2     0     0
%     10     2     0     1
%     11     2     1     0
%     12     2     1     1
%     13     3     0     0
%     14     3     0     1
%     15     3     1     0
%     16     3     1     1
%     17     4     0     0
%     18     4     0     1
%     19     4     1     0
%     20     4     1     1
%     21     5     0     0
%     22     5     0     1
%     23     5     1     0
%     24     5     1     1
%     25     limbo

    %% initialize
    for a = 1:num_actions
        P{a}(1:num_states, 1:num_states) = 0;
    end

    %% possible actions in state 1,2,6,10
    action = 1;	from = [1,2,6,10];	to = [1];     prob = 0.1;
    P{action}(from, to) = prob;
    
    action = 1;	from = [1,2,6,10];	to = [2];     prob = 0.9;
    P{action}(from, to) = prob;

    action = 2;	from = [1,2,6,10];	to = [1];     prob = 0.1;
    P{action}(from, to) = prob;
    
    action = 2;	from = [1,2,6,10];	to = [2];     prob = 0.9;
    P{action}(from, to) = prob;

    action = 3;	from = [2];         to = [6,8];     prob = 0.5;
    P{action}(from, to) = prob;

    action = 4; from = [6];         to = [10];      prob = 1;
    P{action}(from, to) = prob;

    action = 4; from = [10];        to = [1];     prob = 0.1;
    P{action}(from, to) = prob;
    
    action = 4; from = [10];        to = [2];     prob = 0.9;
    P{action}(from, to) = prob;

    %% possible actions in state 3,4,8,12,16,20,24
    action = 1; from = [3,4,8,12,16,20,24]; to = [3]; prob = 0.1;
    P{action}(from, to) = prob;
    
    action = 1; from = [3,4,8,12,16,20,24]; to = [4]; prob = 0.9;
    P{action}(from, to) = prob;

    action = 2; from = [3,4,8,12,16,20,24]; to = [3]; prob = 0.1;
    P{action}(from, to) = prob;
    
    action = 2; from = [3,4,8,12,16,20,24]; to = [4]; prob = 0.9;
    P{action}(from, to) = prob;

    action = 3; from = [4];             to = [6,8]; prob = 0.5;
    P{action}(from, to) = prob;

    action = 4; from = [8,12,16,20];    to = [12, 16, 20, 24];  prob = 1;
    for i = 1:length(from)
        P{action}(from(i), to(i)) = prob;
    end

    action = 4; from = [24];            to = [3]; prob = 0.1;
    P{action}(from, to) = prob;
    
    action = 4; from = [24];            to = [4]; prob = 0.9;
    P{action}(from, to) = prob;

    %% impossible actions
    action = 3; from = [1,6,10,3,8,12,16,20,24];    to = [25];  prob = 1;
    P{action}(from, to) = prob;

    action = 4; from = [1,2,3,4];   to = [25];  prob = 1;
    P{action}(from, to) = prob;

    %% unreachable states
    action = [1,2,3,4]; 
    from = [5,9,13,17,21,7,11,15,19,23,14,18,22,25];   to = [25];  prob = 1;
    for a = 1:length(action)
        P{a}(from, to) = prob;
    end
    
    
    %% Validation
    for i=1:num_states
        for a=1:num_actions
            assert(sum(P{a}(i, :)) == 1, sprintf('probability for state %d, action %d is wrong\n', i, a));
        end
    end
end


