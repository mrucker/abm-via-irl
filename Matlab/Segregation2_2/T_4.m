function P = T_4(SA, skip_line, num_actions, num_states, state_space, overall_P)
%%    actions
%     action 1, move short distance
%     action 2, move long distance
%     action 3, start conversation
%     action 4, continue conversation
%
%%    state space
%      id convo recent partner familiar 
%      1     0     0     0     0
%      2     0     0     1     0
%      3     0     0     0     1
%      4     0     0     1     1
%      5     0     1     0     0
%      6     0     1     1     0
%      7     0     1     0     1
%      8     0     1     1     1
%      9     1     0     1     1
%     10     2     0     1     1
%     11     3     0     1     1
%     12     4     0     1     1
%     13     5     0     1     1
%     14     6     0     1     1
%     15     7     0     1     1
%     16     8     0     1     1
%     17     9     0     1     1
%     18    10     0     1     1
%     19     1     1     1     1
%     20     2     1     1     1
%     21     3     1     1     1
%     22     4     1     1     1
%     23     5     1     1     1
%     24     6     1     1     1
%     25     7     1     1     1
%     26     8     1     1     1
%     27     9     1     1     1
%     28    10     1     1     1
%     29    10    10    10    10 (limbo)

    P = Initialize(num_actions, num_states);
    
    % calculate transition probabilities using SA (observed state-action trajectoies)
    Cnt = Count(P, SA, skip_line, state_space);
    
    P = Normalize(Cnt);
    
    % project the calculated transition probabilities onto the non-observed but structurally same state-actions
    % and assign transition probabilities for illegal actions and unreachable states
    if ~exist('overall_P', 'var')
        P = Assign(P, Cnt, num_actions, num_states, state_space);
    else
        P = Assign(P, Cnt, num_actions, num_states, state_space, overall_P);
    end 
    
    Validate(P, num_actions, num_states);
end

function P = Initialize(num_actions, num_states)
    P = cell(num_actions,1);

    for a = 1:num_actions
        P{a} = zeros(num_states,num_states);
    end
end

function p = Count(P, SA, skip_line, state_space)
    for i = 2:size(SA,1)
        if(ismember(i, skip_line))
            continue;
        end
        
        last_a = SA(i-1,1);
        last_s = find(all(state_space' == SA(i-1,2:end)'));
        this_s = find(all(state_space' == SA(i-0,2:end)'));
        P{last_a}(last_s,this_s) = P{last_a}(last_s, this_s) + 1;
    end
    
    p = P;
end


function p = Normalize(P)
   for a = 1:size(P,1)
       %P{a} = diag(1./sum(P{a},2))*P{a};
       P{a} = P{a}./sum(P{a},2);
   end
   
   p = P;
end

function p = Assign(P, Cnt, num_actions, num_states, state_space, overall_P)
    
    % model probability: action 1 in state(0,0,0,0)
    P = Copy_Identical(P, [[1,1]; [1,2]]);
    % model probability: action 1 in state(0,0,0,1)
    P = Copy_Identical(P, [[1,3]; [1,4]]);
    % model probability: action 1 in state(0,1,0,0)
    P = Copy_Identical(P, [[1,5]; [1,6]]);
    % model probability: action 1 in state(0,1,0,1)
    P = Copy_Identical(P, [[1,7]; [1,8]]);
    % model probability: action 1 in state(1,0,1,1)
    P = Copy_Identical(P, [[1,9]; [1,10]; [1,11]; [1,12]; [1,13]; [1,14]; [1,15]; [1,16]; [1,17]; [1,18]]);
    % model probability: action 1 in state(5,1,1,1)
    P = Copy_Identical(P, [[1,23]; [1,19]; [1,20]; [1,21]; [1,22]; [1,24]; [1,25]; [1,26]; [1,27]; [1,28]]);
    
    % model probability: action 2 in state(0,0,0,0)
    P = Copy_Identical(P, [[2,1]; [2,2]]);
    % model probability: action 2 in state(0,0,0,1)
    P = Copy_Identical(P, [[2,3]; [2,4]]);
    % model probability: action 2 in state(0,1,0,0)
    P = Copy_Identical(P, [[2,5]; [2,6]]);
    % model probability: action 2 in state(0,1,0,1)
    P = Copy_Identical(P, [[2,7]; [2,8]]);
    % model probability: action 2 in state(2,0,1,1)
    P = Copy_Identical(P, [[2,10]; [2,9]; [2,11]; [2,12]; [2,13]; [2,14]; [2,15]; [2,16]; [2,17]; [2,18]]);
    % model probability: action 2 in state(1,1,1,1)
    P = Copy_Identical(P, [[2,19]; [2,20]; [2,21]; [2,22]; [2,23]; [2,24]; [2,25]; [2,26]; [2,27]; [2,28]]);

    
    % assign probability for illegal actions    
    % 1. continue conversation while not having a conversation
    P{4}(find(state_space(:,1) == 0), :) = 0;
    P{4}(find(state_space(:,1) == 0), 29) = 1;
    % 2. start or continue a conversation when there's no potential partner
    P{3}(find(state_space(:,3) == 0), :) = 0;
    P{4}(find(state_space(:,3) == 0), :) = 0;
    P{3}(find(state_space(:,3) == 0), 29) = 1;
    P{4}(find(state_space(:,3) == 0), 29) = 1;
    % 3. start or continue a conversation when it reaches the maximum conversation length
    P{3}(find(state_space(:,1) == 10), :) = 0;
    P{4}(find(state_space(:,1) == 10), :) = 0;
    P{3}(find(state_space(:,1) == 10), 29) = 1;
    P{4}(find(state_space(:,1) == 10), 29) = 1;
    % 4. start a conversation when having a conversation
    P{3}(find(state_space(:,1) ~= 0), :) = 0;
    P{3}(find(state_space(:,1) ~= 0), 29) = 1;
    
    if ~exist('overall_P', 'var')
        % assign probability for definite actions
        for from = [9:17, 19:27]
            to = from + 1;
            if(sum(Cnt{4}(from, :)) < 10) % in case there are little evidence to estimate the probability
                P{4}(from, :) = P{4}(from-1, :);
                P{4}(from, to - 1) = 0;
                P{4}(from, to) = P{4}(from-1, to-1);
                %P{4}(from, :) = 0;
                %P{4}(from, to) = 1;
            end
        end

        % assign probability for limbo state
        P{1}(29, :) = 0;
        P{2}(29, :) = 0;
        P{3}(29, :) = 0;
        P{4}(29, :) = 0;
        P{1}(29, 29) = 1;
        P{2}(29, 29) = 1;
        P{3}(29, 29) = 1;
        P{4}(29, 29) = 1;
    else
        % assign overall transition probabilities for unobserved actions
        for s=1:num_states
            for a=1:num_actions
                if (abs(nansum(P{a}(s,:)) - 1) > .001)
                    P{a}(s,:) = overall_P{a}(s,:);
                end
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
            assert(abs(sum(P{a}(i, :)) - 1) < .000001, sprintf('probability for state %d, action %d is wrong (sum: %f)\n', i, a,sum(P{a}(i, :))));
        end
    end
end
