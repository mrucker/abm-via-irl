function p = T(s0, a0, s1)
%T Transition probability.
%   T returns the probability that the agent will land in state S1 if in 
%   state S0 action A0 is taken.
    global n;

    success = 0.7;
    fail = 1 - 0.7;
    
    col = ceil(s0 / n); 
	row = mod(s0,n);
    if row == 0
        row = n;
    end
    
    %initalize a neighbor vector to find the neighbors of initial state s0
    neighbor = zeros(4,1);
    neighbor(1) = (s0 - 1) == s1 & row > 1;         %neighbor(1) = 1 indicate the agent moves left, otherwise 0
    neighbor(2) = (s0 + n) == s1 & col < n;         %neighbor(2) = 1, the agent moves down
    neighbor(3) = (s0 + 1) == s1 & row < n;         %neighbor(3) = 1, the agent moves right
    neighbor(4) = (s0 - n) == s1 & col > 1;         %neighbor(4) = 4, the agent moves up
    
    prob = zeros(4,1);      %prob defines the action space. The agent has probability of 0.7 taking action 0
    prob(:) = fail / 3;
    prob(a0) = success;
    
    edge = zeros(4,1);      %edge indicates which edge the agent is on.
    edge(1) = row == 1;     %upper edge
    edge(2) = col == n;     %right edge
    edge(3) = row == n;     %lower edge
    edge(4) = col == 1;     %left edge
    
    if s0 == s1
        p = prob' * edge;
    elseif sum(neighbor) == 1   %if not in edge
        p = prob' * neighbor;
    else
        p = 0;
    end
end

