function B = issimilar(input1, input2, epsilon)


% issimilar evaluate two agents is similar or not
% Argument--------------------------------------------
% input1 = input from agent 1, vector
% input2 = input from agent 2, vector
% epsilon = upper than 0, optional (default : 0.0001)
% Evalution---------------------------------------------
% B = boolean result indicates whether these two agents are the same or not

% check arguments
if epsilon <= 0 
    disp('--------------------------------------------------------')
    disp('ERROR: epsilon must be greater than 0')
    disp('--------------------------------------------------------')
elseif nargin < 2
    disp('--------------------------------------------------------')
    disp('ERROR: 2 or more arguments needed ')
    disp('--------------------------------------------------------')
elseif (~isvector(input1)) | (~isvector(input2))
    disp('--------------------------------------------------------')
    disp('ERROR: inputs should be vector in mode 0 or mode 1')
    disp('--------------------------------------------------------')
elseif size(input1) ~= size(input2)
    disp('--------------------------------------------------------')
    disp('ERROR: Two input vectors should have the same size')
    disp('--------------------------------------------------------')    
end
    

% initialization of optional argument
if nargin < 4; epsilon = 0.0001; end


dis = sqrt(sum((input1 - input2) ^ 2)); 
if dis > epsilon
    B = 0;
else
    B = 1;
end




    
