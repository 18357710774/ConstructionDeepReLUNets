clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));

if ~exist('results\RadarResults','dir')
	mkdir('results\RadarResults');
end

N_starCross = 2:2:300;
tau = 0.0001;
name = '20201009135112_mse';
c = 0.8;
ExNum = 20;

load([cd '\RadarData\' name '.mat'], 'I_334x450_normal', 'I_167x225_normal');
[height, width] = size(I_167x225_normal);

 % Generate All samples
x1 = (1/(2*width)):(1/width):1;
x2 = (1/(2*height)):(1/height):1;
[xx1, xx2] = meshgrid(x1, x2);
all_x = [xx1(:) xx2(:)];
all_y = I_167x225_normal(:);

N_samples = length(all_y);
Ntr = ceil(N_samples*c);

mse_ND = zeros(ExNum, length(N_starCross));
t_ND = zeros(ExNum, length(N_starCross));

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
    for N_star = N_starCross
        uu = uu+1;
        tic;
        hat_y = ND_func_mod(test_x, train_x, train_y, N_star, tau);
        t_ND(i, uu) = toc;
        mse_ND(i, uu) = mse(test_y-hat_y);
        fprintf(['Ex' num2str(i) '--N_star#' num2str(N_star)  ': mse is ' num2str(mse_ND(i,uu)) ...
            '   time cost is ' num2str(t_ND(i,uu)) '\n']); 
    end
    save([cd '\results\RadarResults\ND_' name '_167x225_TrPer' num2str(c*100) '.mat'], ...
          'mse_ND', 't_ND', 'N_starCross', 'tau', 'train_x_cell',...
        'train_y_cell', 'test_x_cell', 'test_y_cell');
end
mse_ND_mean = mean(mse_ND,1);
t_ND_mean = mean(t_ND, 1);
save([cd '\results\RadarResults\ND_' name '_167x225_TrPer' num2str(c*100) '.mat'], ...
          'mse_ND', 't_ND', 'N_starCross', 'tau', 'train_x_cell',...
        'train_y_cell', 'test_x_cell', 'test_y_cell', 'mse_ND_mean', 't_ND_mean');