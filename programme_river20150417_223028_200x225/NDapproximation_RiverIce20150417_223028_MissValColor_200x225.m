clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));

if ~exist('results\RadarResults','dir')
	mkdir('results\RadarResults');
end

tau = 0.0001;

N_starCross = 5:5:400;
ExNum = 20;
c = 0.8;
name = 'RiverIce20150417_223028_color';
load([cd '\RadarData\' name '.mat'], 'I_200x225_normal');
[height, width, channel] = size(I_200x225_normal);

 % Generate All samples
x1 = (1/(2*width)):(1/width):1;
x2 = (1/(2*height)):(1/height):1;
[xx1, xx2] = meshgrid(x1, x2);
all_x = [xx1(:) xx2(:)];
all_x_3channel = repmat(all_x, 3, 1);
all_y_3channel = I_200x225_normal(:);

N_samples = length(all_y_3channel);
Ntr = ceil(N_samples*c);


mse_ND_3channel = zeros(channel, length(N_starCross), ExNum);
t_ND_3channel = zeros(channel, length(N_starCross), ExNum);

mse_ND_all = zeros(ExNum, length(N_starCross));
t_ND_all = zeros(ExNum, length(N_starCross));

train_x_cell = cell(3, ExNum);
train_y_cell = cell(3, ExNum);
test_x_cell = cell(3, ExNum);
test_y_cell = cell(3, ExNum);

for i = 1:ExNum   
    rng(i);
    ind_rand_3channel = randperm(N_samples);
    train_ind_3channel = ind_rand_3channel(1:Ntr);
    test_ind_3channel = ind_rand_3channel(Ntr+1:end);
    
    for j = 1:channel
        begin_ind = (j-1)*height*width;
        end_ind = j*height*width;
        train_ind_channel_j = train_ind_3channel(train_ind_3channel>begin_ind & train_ind_3channel<=end_ind);
        test_ind_channel_j = test_ind_3channel(test_ind_3channel>begin_ind & test_ind_3channel<=end_ind);
        
        % Generate training samples
        train_x_cell{j,i} = all_x_3channel(train_ind_channel_j, :);
        train_y_cell{j,i} = all_y_3channel(train_ind_channel_j, :);

        % Generating Test Set
        test_x_cell{j,i} = all_x_3channel(test_ind_channel_j, :);
        test_y_cell{j,i} = all_y_3channel(test_ind_channel_j, :);
    end
       
    uu = 0;
    for N_star = N_starCross
        uu = uu+1;
        hat_y = cell(channel,1);
        for j = 1:channel
            tic;
            hat_y{j} = ND_func_mod(test_x_cell{j,i}, train_x_cell{j,i}, train_y_cell{j,i}, N_star, tau);
            t_ND_3channel(j, uu, i) = toc;
            mse_ND_3channel(j, uu, i) = mse(test_y_cell{j,i}-hat_y{j});
        end
        t_ND_all(i,uu) = sum(t_ND_3channel(:, uu, i));
        mse_ND_all(i,uu) = mse(cell2mat(hat_y)-cell2mat(test_y_cell(:,i)));
        clear hat_y;

        fprintf(['Ex ' num2str(i) '--N_star#' num2str(N_star) ': mse is ' num2str(mse_ND_all(i,uu)) ...
            '   time cost is ' num2str(t_ND_all(i,uu)) '\n']); 
    end
    save([cd '\results\RadarResults\ND_' name '_200x225_TrPer' num2str(c*100)  '.mat'], ...
            'mse_ND_all', 't_ND_all', 'N_starCross', 'mse_ND_3channel', 't_ND_3channel', 'tau',...
             'train_x_cell', 'train_y_cell', 'test_x_cell', 'test_y_cell');
end
t_ND_3channel_mean = mean(t_ND_3channel,3);
mse_ND_3channel_mean = mean(mse_ND_3channel,3);
t_ND_all_mean = mean(t_ND_all,1);
mse_ND_all_mean = mean(mse_ND_all,1);
save([cd '\results\RadarResults\ND_' name '_200x225_TrPer' num2str(c*100)  '.mat'], ...
            'mse_ND_all', 't_ND_all', 'N_starCross', 'mse_ND_3channel', 't_ND_3channel', 'tau',...
             'train_x_cell', 'train_y_cell', 'test_x_cell', 'test_y_cell',...
             't_ND_3channel_mean','mse_ND_3channel_mean','t_ND_all_mean','mse_ND_all_mean');