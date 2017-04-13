function save_learned_policy(output_file, num_clusters, group_idx, policies)

    new_file(output_file);
    
    head = 'number of clusters';
    write_head(output_file, head);
    dlmwrite(output_file, num_clusters, '-append'); 
    
    head = 'number of agents in each cluster';
    write_head(output_file, head);
    data = zeros(1, num_clusters);
    for i=1:num_clusters
        data(i) = length(group_idx{i});
    end
    dlmwrite(output_file, data, '-append');
    
    for i=1:num_clusters
        head = ['stochastic policy for cluster',num2str(i)];
        write_head(output_file, head);
        dlmwrite(output_file, policies{i}, '-append');
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