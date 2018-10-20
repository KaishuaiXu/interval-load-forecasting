close all; clear; clc;

%% Load samples
dist = 'euclidean';
m = 1;
number_of_cluster = 2;

path = ['../data/load_data_for_model/' dist '/' num2str(m) '_' num2str(number_of_cluster) '.mat'];
load(path);

%% Train
tic;
for j = 1 : number_of_cluster
    
    best_acc = 1;
    for iter = 1 : 10
        
    [wih, who, current_out] = iMLPMain(train(j).xu, train(j).xl, train(j).yu, train(j).yl);
    
    xC=(test(j).xl + test(j).xu)/2;
    xR=(test(j).xu - test(j).xl)/2;
    
    xC = xC';
    xR = xR';

    [ni, N]=size(xC);

    hC = tansig(current_out.wih*[xC;ones(1,N)]);
    hR = tansig(current_out.wih*[xR;ones(1,N)]);
    yCt = tansig(current_out.who*[hC;ones(1,N)]);
    yRt = (current_out.who*[hR;ones(1,N)]);
    
    F = [yCt',yRt'];
    F = iCR2Inter(F);
    O = [test(j).yl test(j).yu];
    F = descale(F, maximum(j), minimum(j));
    O = descale(O, maximum(j), minimum(j));
    current_out.F = F;
    
    acc = mean(mean(mape(O, F)));
    display = ['MAPE = ' num2str(acc)];
    disp(display);
    
    if acc < best_acc
        best_acc = acc;
        out(j) = current_out;
    end
    
    end
    break;
end
path = ['./iMLP_result/' dist '/' num2str(m) '_' num2str(number_of_cluster) '.mat'];
save(path, 'out');
    
toc;