function SAF = state_action_frequency(num_clusters, expert_trajectories, group_idx, agentId_list, num_states, num_actions, state_space)
    SAF = cell(num_clusters,1);
    
    for c = 1:num_clusters
        SAF{c} = zeros(num_states, num_actions);
    
        steps_of_group = find(ismember(expert_trajectories(:,1),agentId_list(group_idx{c}),'rows'));
        [~, states_no] = ismember(expert_trajectories(steps_of_group, [3,4,5]), state_space,'rows');
        actions = expert_trajectories(steps_of_group, 6);
        states_actions = horzcat(states_no, actions);

        for i=1:length(states_actions)
            SAF{c}(states_actions(i,1), states_actions(i,2)) = SAF{c}(states_actions(i,1), states_actions(i,2)) + 1;
        end
        SAF{c} = SAF{c}./sum(SAF{c}, 2);
    end

end