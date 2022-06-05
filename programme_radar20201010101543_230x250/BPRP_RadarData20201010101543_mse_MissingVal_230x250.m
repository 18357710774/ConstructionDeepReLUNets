clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));
if ~exist('results\RadarResults','dir')
	mkdir('results\RadarResults');
end

method = 'trainrp';
nBP_Cross = 10:10:200;
epoches_Cross = 2000:2000:10000;
name = '20201010101543_mse';
c = 0.8;
ExNum = 20;

load([cd '\RadarData\' name '.mat'], 'I_460x500_normal', 'I_230x250_normal');
[height, width] = size(I_230x250_normal);

% Generate All samples
x1 = (1/(2*width)):(1/width):1;
x2 = (1/(2*height)):(1/height):1;
[xx1, xx2] = meshgrid(x1, x2);
all_x = [xx1(:) xx2(:)];
all_y = I_230x250_normal(:);

N_samples = length(all_y);
Ntr = ceil(N_samples*c);

t_BPRP = zeros(ExNum, length(nBP_Cross)*length(epoches_Cross));
mse_BPRP = zeros(ExNum, length(nBP_Cross)*length(epoches_Cross));
para = zeros(2, length(nBP_Cross)*length(epoches_Cross));
uu = 0;
for nBP = nBP_Cross
    for epochs = epoches_Cross
        uu = uu+1;
        para(:,uu) = [nBP; epochs];
    end
end
train_x_cell = cell(1, ExNum);
train_y_cell = cell(1, ExNum);
test_x_cell = cell(1, ExNum);
test_y_cell = cell(1, ExNum);

for i = 1:ExNum
    rng(i);
    ind_rand = randperm(N_samples);
    train_ind = ind_rand(1:Ntr);
    test_ind = ind_rand(Ntr+1:end);

    % Generate training samples
    train_x = all_x(train_ind, :);
    train_y = all_y(train_ind, :);

    % Generating Test Set
    test_x = all_x(test_ind, :);
    test_y = all_y(test_ind, :);
    
    train_x_cell{i} = train_x;
    train_y_cell{i} = train_y;
    test_x_cell{i} = test_x;
    test_y_cell{i} = test_y;
    
    uu = 0;
    for nBP = nBP_Cross
        for epochs = epoches_Cross
            uu = uu+1;
            tic;
            net = newff(train_x',train_y',nBP,{'tansig', 'purelin'}, method); 
            net.trainParam.goal = 1e-5;
            net.trainParam.epochs = epochs;
            net.trainParam.lr = 0.05;
            net.trainParam.showWindow = false;
            net.divideFcn = '';
            net = train(net,train_x',train_y');
            t_BPRP(i, uu) = toc;

            predict_y = sim(net,test_x');
            mse_BPRP(i, uu) = mse(test_y'-predict_y);

            fprintf(['Ex' num2str(i) '--' method '-- nBP ' num2str(nBP) ' epoch ' num2str(epochs)...
               ': mse is ' num2str(mse_BPRP(i,uu)) ...
                '   time cost is ' num2str(t_BPRP(i,uu)) '\n']);   
        end
    end
    save([cd '\results\RadarResults\BPRP_' name '_230x250_TrPer' num2str(c*100) '.mat'],...
        't_BPRP', 'mse_BPRP', 'epoches_Cross', 'nBP_Cross', 'para', 'train_x_cell',...
        'train_y_cell', 'test_x_cell', 'test_y_cell');
end
mse_BPRP_mean = mean(mse_BPRP,1);
t_BPRP_mean = mean(t_BPRP, 1);
save([cd '\results\RadarResults\BPRP_' name '_230x250_TrPer' num2str(c*100) '.mat'],...
        't_BPRP', 'mse_BPRP', 'epoches_Cross', 'nBP_Cross', 'para', 'train_x_cell',...
        'train_y_cell', 'test_x_cell', 'test_y_cell','mse_BPRP_mean','t_BPRP_mean');