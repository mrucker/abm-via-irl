
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
%     25 limo state
%     suppose the agent has probability of 70% to take the right action,
%     and 30 % to take the wrong actions.

    if (s0 == 1)
        neighbor = {[(s1 == s0) && (a0 == 1), s1 == (s0 + 1) && (a0 == 1)], s1 == 25 && (a0 ~= 1)};
        prob = {[0.35, 0.35]',0.3};
        p = neighbor{1} * prob{1} + neighbor{2} * prob{2};
    elseif (s0 == 2)
        neighbor = {[s1 == (s0 + 4) && (a0 == 3), s1 == (s0 + 6) && (a0 == 3)], s1 == 25 && (a0 ~= 3)};
        prob = {[0.35, 0.35]', 0.3};
        p = neighbor{1} * prob{1} + neighbor{2} * prob{2};
    elseif (s0 == 6) 
        neighbor = [s1 == (s0 + 4) && (a0 == 4), s1 == 25 && (a0 ~= 4)];
        prob = [0.7, 0.3]';
        p = neighbor * prob;
    elseif (s0 == 10) 
        neighbor = {[s1 == 1 && (a0 == 1), s1 == 2 && (a0 == 1)], s1 == 25 && (a0 ~= 1)};
        prob = {[0.35, 0.35]', 0.3};
        p = neighbor{1} * prob{1} + neighbor{2} * prob{2};
    elseif (s0 == 2) 
        neighbor = {[s1 == (s0 + 6) && (a0 == 3), s1 == (s0 + 4) && (a0 == 3)], s1 == 25 && (a0 ~= 3)};
        prob = {[0.35, 0.35]', 0.3};
        p = neighbor{1} * prob{1} + neighbor{2} * prob{2};
    elseif (s0 == 8) 
        neighbor = [s1 == (s0 + 4) && (a0 == 4), s1 == 25 && (a0 ~= 4)];
        prob = [0.7, 0.3]';
        p = neighbor * prob;
    elseif (s0 == 12) 
        neighbor = [s1 == (s0 + 4) && (a0 == 4), s1 == 25 && (a0 ~= 4)];
        prob = [0.7, 0.3]';
        p = neighbor * prob;
    elseif (s0 == 16) 
        neighbor = [s1 == (s0 + 4) && (a0 == 4), s1 == 25 && (a0 ~= 4)];
        prob = [0.7, 0.3]';
        p = neighbor * prob;
    elseif (s0 == 20) && (a0 == 4)
        neighbor = [s1 == (s0 + 4) && (a0 == 4), s1 == 25 && (a0 ~= 4)];
        prob = [0.7, 0.3]';
        p = neighbor * prob;
    elseif (s0 == 24) 
        neighbor = {[s1 == 3 && (a0 == 2) , s1 == 4 && (a0 == 2)], s1 == 25 && (a0 == 2)};
        prob = {[0.35, 0.35]', 0.3};
        p = neighbor{1} * prob{1} + neighbor{2} * prob{2};
    elseif (s0 == 3)
        neighbor = {[s1 == s0 && (a0 == 2), s1 == (s0 + 1) && (a0 == 2)], s1 == 25 && (a0 ~= 2)};
        prob = {[0.35, 0.35]', 0.3};
        p = neighbor{1} * prob{1} + neighbor{2} * prob{2};
    elseif (s0 == 4) 
        neighbor = {[s1 == (s0 + 2) && (a0 == 3), s1 == (s0 + 4) && (a0 == 3)], s1 == 25 && (a0 ~= 3)};
        prob = {[0.35, 0.35]', 0.3};
        p = neighbor{1} * prob{1} + neighbor{2} * prob{2};
    elseif (s0 == 25)
        neighbor = [s1 == 25, s1 ~= 25];
        prob = [1, 0]';
        p = neighbor * prob;
    end       
end


