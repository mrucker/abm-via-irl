addpath(fullfile(fileparts(which(mfilename)),'../MDPtoolbox/'));

global C;

PW = 0.2;
PL = 1-PW;
C  = 5000;
S  = 0:C;
A  = 0:floor(C/2);

S_N = numel(S);
A_N = numel(A);

R = sparse([1 S_N], [1 1], [0 0], S_N, A_N);
P = cell(A_N,1);

d        = 1;
e        = .1;
V0       = zeros(S_N,1);
V0(end)  = 1;
max_iter = 1000;

P{1} = sparse([1 S_N],[1 S_N],[1 1], S_N, S_N);

for a = A(2:end)
    s1 = [(1+a):(S_N-a)           , (1+a):(S_N-a)           ];
    s2 = [((1+a):(S_N-a))-a       , ((1+a):(S_N-a))+a       ];
    wl = [repmat(PL, 1, S_N-(a*2)), repmat(PW, 1, S_N-(a*2))];

    P{a+1} = sparse(s1, s2, wl, S_N, S_N);
end

loop = 1;

tstart = tic;
for i = 1:loop
   [v1, policy1, ~, ~]  = mar_value_iteration2(P, R, d, e, max_iter, V0);
end
disp(['v1' ' ' num2str(toc(tstart) / loop)]);

tstart = tic;
for i = 1:loop
    %[v2, policy2, ~, ~] = mdp_value_iteration (P, R, d, e, max_iter, V0);
    [v2, policy2, ~, ~] = mar_value_iteration1(P, R, d, e, max_iter, V0);
end
disp(['v2' ' ' num2str(toc(tstart) / loop)]);

figure('Name', 'From Mark')
Plot(v1);

figure('Name', 'From Online')
Plot(v2);

% h = horzcat(v1, v2, abs(v1 - v2));
% disp(h(h(:,3) > .01, :));
% 
% h = horzcat(policy1, policy2, (1:S_N).');
% disp(h( h(:,1) ~= h(:,2), :));

function Plot(vs); global C;
    plot(0:C, vs);
    axis([0 C 0 1])
    xlabel('s')
    ylabel('v')
end
