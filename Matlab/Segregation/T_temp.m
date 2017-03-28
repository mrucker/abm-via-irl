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
    
    
%     %get default transitions and then overwrite them
%     default = T_2_1(num_actions, num_states);
%     
%     for a = 1:num_actions
%         for s = 1:num_states
%             if(sum(P{a}(s,:)) > 0)
%                 default{a}(s,:) = P{a}(s,:);
%             end
%         end
%     end
end