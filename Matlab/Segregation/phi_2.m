function f = phi_2(state)
    global num_features;
    f = zeros(num_features, 1);
    f(state) = 1;
end

