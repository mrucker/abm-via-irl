
function p1 = T(s0, a0, s1)

%     action 1, continue talk; action 2, start talk; action 3, go 0.5 range;
%     action 4, go 2.5 range;
%     Suppose people talk 7 sec with people they don't like, talk 14 sec with people they like
%     There would be 45 * 45 states in total, I code s0 from 1 to 45
%     (0~7, 0, 0), (0~7, 0, 1), (1~14, 1, 0), (0~14, 1, 1)
      
      if (1 < s0) && (s0 < 8) && (a0 == 1) 
          neighbor = {s0 + 1, s0 + 9};
          p = {0.5, 0.5}; 
      elseif (s0 == 1) && (a0 == 3 || a0 == 4)
          neighbor = {s0 + 30, s0 + 8, s0};
          p{1} = {0.42, 0.28, 0.3};
          p{2} = {0.36, 0.24, 0.4};
      elseif s0 == 8 && (a0 == 3)
          neighbor = {1, 9};
          p = {0.5, 0.5};  
      elseif (9 <= s0) && (s0 < 16) && (a0 == 1)
          neighbor = {s0 - 7, s0 + 1};
          p = {0.5, 0.5};
      elseif s0 == 16 && (a0 == 3)
          neighbor = {1, 9};
          p = {0.5, 0.5};
      elseif (s0 >= 17) && (s0 < 30) && (a0 == 1)
          neighbor = {s0 + 1, s0 + 16};
          p = {0.5, 0.5};
      elseif s0 == 30 && (a0 == 4)`
          neighbor = {1, 9};
          p = {0.5, 0.5};
      elseif (s0 >= 31) && ( s0 < 46)
          neighbor = {s0 - 14, s0 + 1};
          p = {0.5, 0.5};
      elseif s0 == 45
          neighbor = {1, 9};
          p = {0.5, 0.5};
      end
      
      if iscell(p) == 0
          if ismember(s1, neighbor) == 1
              p1 = p(find(neighbor == s1));
          else
              p1 = 0;
          end
      else
          if (a0 == 3) && (ismember(s1, neigbhor) == 1)
              p1 = p{1}(find(neighbor == s1));
          elseif (a0 == 3) && (ismember(s1, neighbor) == 0)
              p1 = 0;
          elseif (a0 == 4) && (ismember(s1, neigbhor) == 1)
              p1 = p{2}(find(neighbor == s1));
          elseif (a0 == 4) && (ismember(s1, neigbhor) == 0)
              p1 = 0;
          end     
      end      
end

