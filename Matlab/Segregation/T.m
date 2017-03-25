
function p = T(s0, a0, s1)

%     action 1, move 0.5; action 2, move 2.5; action 3 start conv;
%     action 4, continue conv;
%     Here are our state space:
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
    if (s0 == 1) && (a0 == 1)
        neighbor = [s0, s0+1];
        p = [0.5, 0.5];
    elseif (s0 == 2) && (a0 == 3)
        neighbor = [s0 + 4, s0 + 6];
        p = [0.5, 0.5];
    elseif (s0 == 6) && (a0 == 4)
        neighbor = s0 + 4;
        p = 1;
    elseif (s0 == 10) && (a0 == 1)
        neighbor = [1, 2];
        p = [0.5, 0.5];
    elseif (s0 == 2) && (a0 == 3)
        neighbor = [s0 + 6, s0 + 4];
        p = [0.5, 0.5];
    elseif (s0 == 8) && (a0 == 4)
        neighbor = 12;
        p = 1;
    elseif (s0 == 12) && (a0 == 4)
        neighbor = 16;
        p = 1;
    elseif (s0 == 16) && (a0 == 4)
        neighbor = 20;
        p = 1;
    elseif (s0 == 20) && (a0 == 4)
        neighbor = 24;
        p = 1;
    elseif (s0 == 24) && (a0 == 2)
        neighbor = [3, 4];
        p = [0.5, 0.5];
    elseif (s0 == 3) && (a0 == 2)
        neighbor = [3, 4];
        p = [0.5, 0.5];
    elseif (s0 == 4) && (a0 == 3)
        neighbor = [6, 8];
        p = [0.5, 0.5];
    end
    
    if isvector(neighbor)
        if any(find(neighbor == s1))
            p = 0;
        else
            p = p(find(neigbor == s1));
        end
    else
        if neighbor == s1
            p = 1;
        else
            p = 0;
        end
    end
        
        
        
        
        
end


