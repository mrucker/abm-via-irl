function P = T_SA(SA, num_actions, num_states, state_space)
%%    actions
%     action 1, move short distance
%     action 2, move long distance
%     action 3, start conversation
%     action 4, continue conversation
%
%%    state space
%      id  convo  like  near
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
    P = Assign(P, num_actions, num_states);
    
    Validate(P, num_actions, num_states);
end

function P = Initialize(num_actions, num_states)
    P = cell(num_actions,1);

    for a = 1:num_actions
        P{a} = sparse(num_states,num_states);
    end
end

function p = Count(P, SA, state_space)
    for i = 2:size(SA,1)
        last_a = SA(i-1,1);
        last_s = find(all(state_space' == SA(i-1,2:end)'));
        this_s = find(all(state_space' == SA(i-0,2:end)'));

        P{last_a}(last_s,this_s) = P{last_a}(last_s, this_s) + 1;
    end
    
    p = P;
end

function p = Normalize(P)
   for a = 1:size(P,1)
       P{a} = diag(1./sum(P{a},2))*P{a};
   end
   
   p = P;
end

function p = Assign(P, num_actions, num_states)

    P = Copy_Identical(P, [[1,1]; [2,1]]);
    P = Copy_Identical(P, [[1,3]; [2,3]; [1,4]; [2,4]]);    
    P = Copy_Identical(P, [[1,24]; [1,8]; [2,8]; [1,12]; [2,12]; [1,16]; [2,16]; [1,20]; [2,20]; [2,24]; [4,24]]);
    P = Copy_Identical(P, [[2,1]; [1,1]; [1,2]; [2,2]]);
    P = Copy_Identical(P, [[2,10]; [1,6]; [2,6]; [1,10]; [1,14]; [2,14]; [1,18]; [2,18]; [1,22]; [2,22]; [4,22]]);
    P = Copy_Identical(P, [[4,6]; [4,10]; [4,14]; [4,18]]);   
        
    % assign probability for illegal actions    
    P{1}([5,7,9,11,13,15,17,19,21,23,25], 25) = 1;
    P{2}([5,7,9,11,13,15,17,19,21,23,25], 25) = 1;
    P{3}([1,3,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25], 25) = 1;
    P{4}([1,2,3,4,5,9,11,13,15,17,19,21,23,25], 25) = 1;

    % any remaining, undefined transitions send to the limbo state
    for s=1:num_states
        for a=1:num_actions
            if sum(P{a}(s, :)) == 0
                P{a}(s,25) = 1;
            end
        end
    end
    
    p = P;
end

function p = Copy_Identical(P, actions_states)

    copy = 0;

    %find first non-zero state-action transitions
    for as = actions_states'
        a = as(1);
        s = as(2);
        
        if abs(sum(P{a}(s,:)) - 1) < .001
            copy = P{a}(s,:);
            break;
        end
    end
    
    %copy the found transitions to all other state actions
    for as = actions_states'
        a = as(1);
        s = as(2);

        P{a}(s,:) = copy;
    end
    
    p = P;
end

function Validate(P, num_actions, num_states)
    for i=1:num_states
        for a=1:num_actions
            assert(abs(sum(P{a}(i, :)) - 1) < .000001, sprintf('probability for state %d, action %d is wrong\n', i, a));
        end
    end
end
