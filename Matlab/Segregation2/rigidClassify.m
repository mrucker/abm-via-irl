function idx = rigidClassify(input, epsilon)

% Argument----------------------------------------
% input = matrix or vector of features
% epsilon = default is 0.0001
% Evaluation----------------------------------------
% idx = a vector to indicate the category

% check argument
if nargin < 1
    disp('--------------------------------------------------------')
    disp('ERROR: input number should be more than 2')
    disp('--------------------------------------------------------')
elseif epsilon <= 0
    disp('--------------------------------------------------------')
    disp(' ERROR: epsilon should be greater than 0')
    disp('--------------------------------------------------------')
end

% argument initialization
if nargin == 1; epsilon = 0.0001; end


num_agent = size(input, 1);
idx = zeros(num_agent);
cluster_id = 1;
for i = 1:num_agent
    if i == 0
        idx(i) = cluster_id;
        for j = i:num_agent
            if idx(j) == 0
                if issimilar(input(i), input(j), epsilon) 
                    idx(j) = cluster_id;
                end
            end
        end
        cluster_id = cluster_id + 1;
    end
end
    
        
    