clc;
clear;

dataname = 'flickr';

load(['data/' dataname '.mat']);

num_period = 10;

%% parameter setting
k = 90;
beta = 1;
eta = 1;

Z = full(user_side);
H = full(user_item);

HR_list = [];
for period = 1:num_period
    index_hist = train(period, :) + 1;
    index_test = test(period, :) + 1;
    
    H_train = H(index_hist, :);
    H_test = H(index_test, :);
    H_train = H_train';
    H_test = H_test';
    
    Z_hist = Z(index_hist, :);
    Z_test = Z(index_test, :);
    Z_hist = Z_hist';
    Z_test = Z_test';
    
    X2 = [Z_hist, Z_test];
    H0 = zeros(size(H_train, 1), size(Z_test, 2));
    X = [H_train, H0; Z_hist, Z_test];
    
    [Ms, Mt, Mst, Mts] = constructMMD(size(H_train, 2), size(X, 2));
    
    Ts = H_train * Ms * H_train';
    Tt = X2 * Mt * X2';
    Tst = H_train * Mst * X2';
    Tts = X2 * Mts * H_train';
    
    U = [Ts, Tst; Tts, Tt];
    
    B_0 = X * X';
    C_0 = H_train * H_train';
    C_1 = Z_hist * Z_hist';
    C_2 = Z_hist * H_train';

    
    fprintf('running %s, period:%d -----> ', dataname, period);
    
    B = eta * U - B_0;
    C11 = beta * C_0;
    C22 = beta * C_1;
    C12 = zeros(size(C11, 1), size(C22, 2));
    C21 = -2 * beta * C_2;
    C = [C11, C12; C21, C22];
    A = B + C;
    
    
    % learn P
    [P, ~] = eigs(A + eps, k, 'sr');
    
    % prediction
    tildeX = P * P' * X;
    score = sigmoid(tildeX(1 : size(H_train, 1), size(H_train, 2) + 1 : size(X, 2)));
    score = score';
    count = 0;
    for s = 1:size(score)
        s_user = score(s, :);
        [~, idx] = sort(s_user, 'descend');
        
        rec_item = idx(1:20);
        true_item = find(H_test(:, s) == 1);
        count = count + length(intersect(rec_item, true_item));
    end
    
    hr20 = count/sum(sum(H_test));
    HR_list = [HR_list; hr20];
    fprintf('HR@20: %.4f \n', hr20);
    
    score_list{period} = score;
    test_list{period} = H_test;
end

fprintf('Average HR@20: %.4f (%.4f) \n', mean(HR_list), std(HR_list));






