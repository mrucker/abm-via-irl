function P = T_SA(SA, num_actions, num_states, state_space)
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

    P = Initialize(num_actions, num_states);
    
    % calculate transition probabilities using SA (observed state-action trajectoies)
    P = Count(P, SA, state_space);
    P = Normalize(P);
    
    % project the calculated transition probabilities onto the non-observed but structurally same state-actions
    % and assign transition probabilities for illegal actions and unreachable states
    P = Assign(P);
    
    Validate(P, num_actions, num_states);
end

function P = Initialize(num_actions, num_states)
    P = cell(num_actions,1);

    for a = 1:num_actions
        P{a} = sparse(num_states,num_states);
    end
end

function count = Count(P, SA, state_space)
    for i = 2:size(SA,1)
        last_a = SA(i-1,1);
        last_s = find(all(state_space' == SA(i-1,2:end)'));
        this_s = find(all(state_space' == SA(i-0,2:end)'));

        P{last_a}(last_s,this_s) = P{last_a}(last_s, this_s) + 1;
    end
    
    count = P;
end

function normal = Normalize(P)
   for a = 1:size(P,1)
       P{a} = diag(1./sum(P{a},2))*P{a};
   end
   
   normal = P;
end

function projection = Assign(P)
    num_actions = size(P,1);
    num_states  = size(P{1},1);
    
    % model probability: action 1 in state 3
    % -> assign to [action, state] = [2,3] [1,4] [2,4]
    a_in_s = [[2,3]; [1,4]; [2,4]];
    for i=1:size(a_in_s, 1)
        [a, s] = deal(a_in_s(i,1), a_in_s(i,2));
        P{a}(s,:) = P{1}(3,:);
    end
    
    % model probability: action 1 in state 24
    % -> assign to [action, state] = [1,8] [2,8] [1,12] [2,12] [1,16] [2,16] [1,20] [2,20] [2,24] [4,24]
    a_in_s = [[1,8]; [2,8]; [1,12]; [2,12]; [1,16]; [2,16]; [1,20]; [2,20]; [2,24]; [4,24]];
    for i=1:size(a_in_s, 1)
        [a, s] = deal(a_in_s(i,1), a_in_s(i,2));
        P{a}(s,:) = P{1}(24,:);
    end
    
    % model probability: action 2 in state 1
    % -> assign to [action, state] = [1,1] [1,2] [2,2]
    a_in_s = [[1,1]; [1,2]; [2,2]];
    for i=1:size(a_in_s, 1)
        [a, s] = deal(a_in_s(i,1), a_in_s(i,2));
        P{a}(s,:) = P{2}(1,:);
    end
    
    % model probability: action 2 in state 10
    % -> assign to [action, state] = [1,6] [2,6] [1,10] [1,14] [2,14] [1,18] [2,18] [1,22] [2,22] [4 22]
    a_in_s = [[1,6]; [2,6]; [1,10]; [1,14]; [2,14]; [1,18]; [2,18]; [1,22]; [2,22]; [4 22]];
    for i=1:size(a_in_s, 1)
        [a, s] = deal(a_in_s(i,1), a_in_s(i,2));
        P{a}(s,:) = P{2}(10,:);
    end
    
    % model probability: action 4 in state 6
    % -> assign to [action, state] = [4,10] [4,14] [4,18]
    a_in_s = [[4,10]; [4,14]; [4,18]];
    for i=1:size(a_in_s, 1)
        [a, s] = deal(a_in_s(i,1), a_in_s(i,2));
        P{a}(s,:) = P{4}(6,:);
    end
    
    % assign probability for illegal actions
    action = 3; from = [1,6,10,14,18,22,3,8,12,16,20,24];    to = [25];  prob = 1;
    P{action}(from, to) = prob;

    action = 4; from = [1,2,3,4];   to = [25];  prob = 1;
    P{action}(from, to) = prob;

    % assign probability for unreachable state
    action = [1,2,3,4]; 
    from = [5,9,13,17,21,7,11,15,19,23,25];   to = [25];  prob = 1;
    for a = 1:length(action)
        P{a}(from, to) = prob;
    end
    
    projection = P;
end

function Validate(P, num_actions, num_states)
    for i=1:num_states
        for a=1:num_actions
            assert(abs(sum(P{a}(i, :)) - 1) < .000001, sprintf('probability for state %d, action %d is wrong\n', i, a));
        end
    end
end
