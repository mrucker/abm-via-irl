function P = T_5(SA, num_actions, num_states, state_space)
%%    actions
%     action 1, move short distance
%     action 2, move long distance
%     action 3, start conversation
%     action 4, continue conversation
%
%%    state space
%	   id/conv/recent/previous/near
%      1     0     0     0     0
%      2     0     0     1     0
%      3     0     1     0     0
%      4     0     1     1     0
%      5     0     0     0     1
%      6     1     0     0     1
%      7     2     0     0     1
%      8     3     0     0     1
%      9     4     0     0     1
%     10     5     0     0     1
%     11     6     0     0     1
%     12     7     0     0     1
%     13     8     0     0     1
%     14     9     0     0     1
%     15     0     1     0     1
%     16     1     1     0     1
%     17     2     1     0     1
%     18     3     1     0     1
%     19     4     1     0     1
%     20     5     1     0     1
%     21     6     1     0     1
%     22     7     1     0     1
%     23     8     1     0     1
%     24     9     1     0     1
%     25     0     0     1     1
%     26     1     0     1     1
%     27     2     0     1     1
%     28     3     0     1     1
%     29     4     0     1     1
%     30     5     0     1     1
%     31     6     0     1     1
%     32     7     0     1     1
%     33     8     0     1     1
%     34     9     0     1     1
%     35     0     1     1     1
%     36     1     1     1     1
%     37     2     1     1     1
%     38     3     1     1     1
%     39     4     1     1     1
%     40     5     1     1     1
%     41     6     1     1     1
%     42     7     1     1     1
%     43     8     1     1     1
%     44     9     1     1     1
%     45     limbo

    P = Initialize(num_actions, num_states);
    
    % calculate transition probabilities using SA (observed state-action trajectoies)
    P = Count(P, SA, state_space);
    P = Normalize(P);
    
    % project the calculated transition probabilities onto the non-observed but structurally same state-actions
    % and assign transition probabilities for illegal actions and unreachable states
    P = Assign(P, num_actions, num_states, state_space);
    
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

function p = Assign(P, num_actions, num_states, state_space)

%     % model probability: action 2 in state(0,0,0,0)
%     P = Copy_Identical(P, [[2,state(0,0,0,0)]; [2,state(0,0,0,1)]; [2,state(1,0,0,1)]; [2,state(2,0,0,1)]; [2,state(3,0,0,1)]; [2,state(4,0,0,1)]; [2,state(5,0,0,1)]; [2,state(6,0,0,1)]; [2,state(7,0,0,1)]; [2,state(8,0,0,1)]; [2,state(9,0,0,1)];...
%                            [1,state(0,0,0,0)]; [1,state(0,0,0,1)]; [1,state(1,0,0,1)]; [1,state(2,0,0,1)]; [1,state(3,0,0,1)]; [1,state(4,0,0,1)]; [1,state(5,0,0,1)]; [1,state(6,0,0,1)]; [1,state(7,0,0,1)]; [1,state(8,0,0,1)]; [1,state(9,0,0,1)]]);
%     
%     % model probability: action 2 in state(0,0,1,0)
%     P = Copy_Identical(P, [[2,state(0,0,1,0)]; [2,state(0,0,1,1)]; [2,state(1,0,1,1)]; [2,state(2,0,1,1)]; [2,state(3,0,1,1)]; [2,state(4,0,1,1)]; [2,state(5,0,1,1)]; [2,state(6,0,1,1)]; [2,state(7,0,1,1)]; [2,state(8,0,1,1)]; [2,state(9,0,1,1)];...
%                            [1,state(0,0,1,0)]; [1,state(0,0,1,1)]; [1,state(1,0,1,1)]; [1,state(2,0,1,1)]; [1,state(3,0,1,1)]; [1,state(4,0,1,1)]; [1,state(5,0,1,1)]; [1,state(6,0,1,1)]; [1,state(7,0,1,1)]; [1,state(8,0,1,1)]; [1,state(9,0,1,1)]]);
%     
%     % model probability: action 1 in state(0,1,0,0)
%     P = Copy_Identical(P, [[1,state(0,1,0,0)]; [1,state(0,1,0,1)]; [1,state(1,1,0,1)]; [1,state(2,1,0,1)]; [1,state(3,1,0,1)]; [1,state(4,1,0,1)]; [1,state(5,1,0,1)]; [1,state(6,1,0,1)]; [1,state(7,1,0,1)]; [1,state(8,1,0,1)]; [1,state(9,1,0,1)];...
%                            [2,state(0,1,0,0)]; [2,state(0,1,0,1)]; [2,state(1,1,0,1)]; [2,state(2,1,0,1)]; [2,state(3,1,0,1)]; [2,state(4,1,0,1)]; [2,state(5,1,0,1)]; [2,state(6,1,0,1)]; [2,state(7,1,0,1)]; [2,state(8,1,0,1)]; [2,state(9,1,0,1)]]);
%     
%     % model probability: action 1 in state(0,1,1,0)
%     P = Copy_Identical(P, [[1,state(0,1,1,0)]; [1,state(0,1,1,1)]; [1,state(1,1,1,1)]; [1,state(2,1,1,1)]; [1,state(3,1,1,1)]; [1,state(4,1,1,1)]; [1,state(5,1,1,1)]; [1,state(6,1,1,1)]; [1,state(7,1,1,1)]; [1,state(8,1,1,1)]; [1,state(9,1,1,1)];...
%                            [2,state(0,1,1,0)]; [2,state(0,1,1,1)]; [2,state(1,1,1,1)]; [2,state(2,1,1,1)]; [2,state(3,1,1,1)]; [2,state(4,1,1,1)]; [2,state(5,1,1,1)]; [2,state(6,1,1,1)]; [2,state(7,1,1,1)]; [2,state(8,1,1,1)]; [2,state(9,1,1,1)]]);
%     

    % model probability: action 2 in state(0,0,0,0)
    P = Copy_Identical(P, [[2,1]; [2,5]; [2,6]; [2,7]; [2,8]; [2,9]; [2,10]; [2,11]; [2,12]; [2,13]; [2,14];...
                           [1,1]; [1,5]; [1,6]; [1,7]; [1,8]; [1,9]; [1,10]; [1,11]; [1,12]; [1,13]; [1,14]]);
    
    % model probability: action 2 in state(0,0,1,0)
    P = Copy_Identical(P, [[2,2]; [2,15]; [2,26]; [2,27]; [2,28]; [2,29]; [2,30]; [2,31]; [2,32]; [2,33]; [2,34];...
                           [1,2]; [1,15]; [1,26]; [1,27]; [1,28]; [1,29]; [1,30]; [1,31]; [1,32]; [1,33]; [1,34]]);
    
    % model probability: action 1 in state(0,1,0,0)
    P = Copy_Identical(P, [[1,3]; [1,25]; [1,16]; [1,17]; [1,18]; [1,19]; [1,20]; [1,21]; [1,22]; [1,23]; [1,24];...
                           [2,3]; [2,25]; [2,16]; [2,17]; [2,18]; [2,19]; [2,20]; [2,21]; [2,22]; [2,23]; [2,24]]);
    
    % model probability: action 1 in state(0,1,1,0)
    P = Copy_Identical(P, [[1,4]; [1,35]; [1,36]; [1,37]; [1,38]; [1,39]; [1,40]; [1,41]; [1,42]; [1,43]; [1,44];...
                           [2,4]; [2,35]; [2,36]; [2,37]; [2,38]; [2,39]; [2,40]; [2,41]; [2,42]; [2,43]; [2,44]]);
                      
    % assign probability for definite actions
    for rp=0:1
        for pp=0:1
            for t=1:8
                [~,from]    = ismember([t,	rp,	pp, 1], state_space, 'rows');
                [~,to]      = ismember([t+1,rp,	pp, 1], state_space, 'rows');
                P{4}(from, :) = 0;
                P{4}(from, to) = 1;
            end
        end
    end

    % any remaining, undefined transitions send to the limbo state
    for s=1:num_states
        for a=1:num_actions
            if sum(P{a}(s, :)) == 0
                P{a}(s,45) = 1;
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

% function state_ix = state(conv, recent, previous, near)
%     [~, state_ix] = ismember([conv,	recent,	previous, near], state_space, 'rows');
% end
