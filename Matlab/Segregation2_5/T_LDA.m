function P = T_LDA(AS, num_actions, num_states, state_space)
%%    actions
%     action 1, move short distance
%     action 2, move long distance
%     action 3, start conversation
%     action 4, continue conversation
%
%%    state space
%      id  convo  like  near
%      1     0     0     0
%      2     0     0     1
%      3     0     1     0
%      4     0     1     1
%      5     1     0     0
%      6     1     0     1
%      7     1     1     0
%      8     1     1     1
%      9     2     0     0
%     10     2     0     1
%     11     2     1     0
%     12     2     1     1
%     13     3     0     0
%     14     3     0     1
%     15     3     1     0
%     16     3     1     1
%     17     4     0     0
%     18     4     0     1
%     19     4     1     0
%     20     4     1     1
%     21     5     0     0
%     22     5     0     1
%     23     5     1     0
%     24     5     1     1
%     25     limbo

    AS = double(AS);

    dlt_predictors = PredictorDeltas(AS);
    cls_predictors = PredictorClasses(dlt_predictors);
    fit_predictors = PredictorFits(AS, dlt_predictors);
    
    P = Initialize(num_actions, num_states);
    P = Predict(P, num_actions, state_space, fit_predictors, cls_predictors);
    P = Normalize(P); %We normalize because some predicted transitions go to illegal states cause less than 1 probabilities.
    P = Validate(P, num_actions, num_states);
end

function dlt_predictors = PredictorDeltas(AS)
    dlt_predictors = AS(2:end, 2:end) - AS(1:end-1, 2:end);
    lt0_1_predictors = dlt_predictors(:,1) <= 0;
    nt0_2_predictors = dlt_predictors(:,2) ~= 0;
    nt0_3_predictors = dlt_predictors(:,3) ~= 0;
    
    dlt_predictors(lt0_1_predictors, 1) = -100;
    dlt_predictors(nt0_2_predictors, 2) = 1; 
    dlt_predictors(nt0_3_predictors, 3) = 1; 
end

function cls_predictors = PredictorClasses(dlt_predictors)
    num_predictors = size(dlt_predictors, 2);
    cls_predictors = cell(1, num_predictors);
    
    for i = 1:num_predictors
        cls_predictors{i} = unique(dlt_predictors(:,i));
    end
end

function fit_predictors = PredictorFits(AS, dlt_predictors)
    num_predicotrs = size(dlt_predictors,2);    
    fit_predictors = cell(1,num_predicotrs);

    for i = 1:num_predicotrs
        fit_predictors{i} = LDA(AS(1:end-1, :), dlt_predictors(:,i));
    end
end

function ts = Transitions(a, s, fit_predictors, cls_predictors)
    ts = cartesian(1, cls_predictors{:});

    for i = 1:numel(s)
        for c = fit_predictors{i}([a, s'])                    
            ts(ts(:,i+1) == c(1), 1) = ts(ts(:,i+1) == c(1), 1) * c(2);
        end
    end

    for r = 1:size(ts,1)
        for c = 2:size(ts,2)
            ts(r,c) = Change(c-1, s(c-1), ts(r,c));
        end
    end
    
%     ts(:, 2:end) = ts(:, 2:end) + s';
% 
%     ts(ts(:,2) > 5, 2) = 5;
%     ts(ts(:,2) < 0, 2) = 0;

end

function P = Initialize(num_actions, num_states)
    P = cell(num_actions,1);

    for a = 1:num_actions
        P{a} = sparse(num_states,num_states);
    end
end

function P = Predict(p, num_actions, state_space, fit_predictors, cls_predictors)
    for a = 1:num_actions 
        for s = state_space'
            
            ts = Transitions(a, s, fit_predictors, cls_predictors);            
            
            for t = ts'
                
                this_s_i = all(state_space' == s);
                next_s_i = all(state_space' == t(2:end));
                
                p{a}(this_s_i, next_s_i) = p{a}(this_s_i, next_s_i) + round(t(1),1);
                
            end
            
            if ~all(s==9)
                %assert(abs(sum(p{a}(this_s_i, :)) -1) < .3, sprintf('probability for state %d, action %d is wrong', find(this_s_i), a));
            end
        end
    end
    
    P = p;
end

function P = Normalize(p)
   for a = 1:size(p,1)
       p{a} = diag(1./sum(p{a},2))*p{a};
   end
   
   P = p;
end

function P = Validate(p, num_actions, num_states)
    for i=1:(num_states-1)
        for a=1:num_actions
            assert(abs(sum(p{a}(i, :)) - 1) < .000001, sprintf('probability for state %d, action %d is wrong', i, a));
        end
    end
    
    P = p;
end

function lda = LDA(training, responses)
    fit = fitcdiscr(training, responses);
    lda = @(predictors) Prediction(fit, predictors);
end

function prediction = Prediction(fit, predictors)
    [~, score, ~] = predict(fit, predictors);
    prediction = vertcat(fit.ClassNames', score);
end

function change = Change(predictor_i, predictor_v, class)
    if predictor_i == 1 && class == -100
        change = 0;
    elseif predictor_i == 1 && class == 1 && predictor_v == 5
        change = 5;     
    elseif ismember(predictor_i, [2 3]) && class == 1
        change = abs(predictor_v - 1);
    else
        change = predictor_v + class;
    end
end