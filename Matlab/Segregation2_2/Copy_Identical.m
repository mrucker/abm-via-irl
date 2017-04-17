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