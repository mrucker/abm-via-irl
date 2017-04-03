function [idx, C, disD, D] = cluster(input, k)

% cluster classify all agents use unsupervised learning
% Argument----------------------------------------
% input = matrix or vector of features
% k = number of clusters
% Evaluation----------------------------------------
% idx = a vector to indicate the cluster
% C = matrix of the k cluster centroid locations
% dis = within-cluster sums of point-to-centroid distances

% check argument
if nargin < 2
    disp('--------------------------------------------------------')
    disp('ERROR: input number should be more than 2')
    disp('--------------------------------------------------------')
elseif (~isinteger(k)) | k < 2
    disp('--------------------------------------------------------')
    disp(' ERROR: k should be an integer greater or equal to 2')
    disp('--------------------------------------------------------')
end
    
    
[idx, C, disD, D] = kmeans(input, k);




    



