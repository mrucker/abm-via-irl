function P = elbowCalulation(input, k)

% elbowCalulation calculation the percentage of variance explained by each k
% Argument----------------------------------------
% input = matrix or vector of features
% k = range of number of clusters, 1:k
% Evaluation----------------------------------------
% P = k by 1 vector, indicating the percentage of variance explained by each k

% check argument
if nargin ~= 2
    disp('--------------------------------------------------------')
    disp('ERROR: input number should be exactly 2')
    disp('--------------------------------------------------------')
elseif (~isinteger(k)) | k < 2
    disp('--------------------------------------------------------')
    disp(' ERROR: k should be an integer greater or equal to 2')
    disp('--------------------------------------------------------')
end

% calculate the P
P = zeros(k, 1);
for i = 1:k
    [idx, C, dis, D] = cluster(input, k);
    k_num = zeros(k, 1);
    for j = 1:k
        k_num(j) = sum(idx == j);
    end
% calculate the mean distance of each centroids
    total_num = size(idx, 1);
    k_mean = bsxfun(@rdivide, dis, k_num);
    
    
    k_v = zeros(k,1);
% calculate the within group variances
    D = min(D, [], 2);
    for n = 1:k
        k_v(n) = sum((D(find(idx == i)) - k_mean(n)) .^ 2);
    end
    e_v = sum(k_v);
        
% calculate the grand variance
    grand_v = sum((D - mean(D)) .^ 2);

% calculate the percentage of variances explained
    P(i) = e_v / grand_v;
end
end


    
    
