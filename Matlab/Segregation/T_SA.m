function P = T_SA(SA, num_actions, num_states)
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
    P = Count(P, SA);
    P = Normalize(P);
    P = Defaults(P);
    
    Validate(P, num_actions, num_states);
end

function P = Initialize(num_actions, num_states)
    P = cell(num_actions,1);

    for a = 1:num_actions
        P{a} = sparse(num_states,num_states);
    end
end

function count = Count(P, SA); global state_space;
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

function default = Defaults(P)
    num_actions = size(P,1);
    num_states  = size(P{1},1);
    
    %get default transitions and then overwrite them
    default = T_2_1(num_actions, num_states);
    
    for a = 1:num_actions
        for s = 1:num_states
            if(sum(P{a}(s,:)) > 0)
                default{a}(s,:) = P{a}(s,:);
            end
        end
    end
end

function Validate(P, num_actions, num_states)
    for i=1:num_states
        for a=1:num_actions
            assert(abs(sum(P{a}(i, :)) - 1) < .000001, sprintf('probability for state %d, action %d is wrong\n', i, a));
        end
    end
end
