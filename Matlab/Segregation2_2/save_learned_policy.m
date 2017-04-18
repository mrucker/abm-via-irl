function save_learned_policy(output_file, num_clusters, group_idx, state_space, determ_pol, stoch_pol, which_pol)

    new_file(output_file);
    
    [num_states, num_state_variables] = size(state_space);
    state_space = horzcat((1:num_states)', state_space);
    
    head = 'number of states';
    write_head(output_file, head);
    dlmwrite(output_file, num_states, '-append'); 
    
    head = 'number of state variables';
    write_head(output_file, head);
    dlmwrite(output_file, num_state_variables, '-append'); 
    
    head = 'state space';
    write_head(output_file, head);
    dlmwrite(output_file, state_space, '-append'); 

    head = 'number of clusters';
    write_head(output_file, head);
    dlmwrite(output_file, num_clusters, '-append'); 
    
    head = 'number of agents in each cluster';
    write_head(output_file, head);
    num_agents = zeros(1, num_clusters);
    for i=1:num_clusters
        num_agents(i) = length(group_idx{i});
    end
    dlmwrite(output_file, num_agents, '-append');
    
    for i=1:num_clusters
        if (which_pol(i) == 1)
            head = ['deterministic policy for cluster',num2str(i)];
            write_head(output_file, head);
            dlmwrite(output_file, round(determ_pol{i},4), '-append');
        end
        if (which_pol(i) == 2)
            head = ['stochastic policy for cluster',num2str(i)];
            write_head(output_file, head);
            dlmwrite(output_file, round(stoch_pol{i},4), '-append');
        end
    end
%     
%     for i=1:num_clusters
%         fprintf(fid, '\nstochastic policy for cluster%d\n', i);
%         dlmwrite(output_file, policies{i}, '-append'); 
%     end
%     
    
    
    
    
end

function new_file(output_file)
    [fid, message] = fopen(output_file, 'w');
    if fid < 0; disp(message); end
    fprintf(fid, 'Stochastic policy for each cluster\r\n');
    fclose(fid);
end

function write_head(output_file, head)
    fid = fopen(output_file, 'a');
    fprintf(fid, '\r\n%s\r\n', head);
    fclose(fid);
end