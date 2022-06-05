clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));
if ~exist('results\RadarResults','dir')
	mkdir('results\RadarResults');
end

method = 'trainscg';
nBP_Cross = 10:10:200;
epoches_Cross = 1000:1000:5000;

c = 0.8;
ExNum = 20;

name = 'RiverIce20200513_013745_color';
load([cd '\RadarData\' name '.mat'],'I_200x150_normal');
[height, width, channel] = size(I_200x150_normal);

 % Generate All samples
x1 = (1/(2*width)):(1/width):1;
x2 = (1/(2*height)):(1/height):1;
[xx1, xx2] = meshgrid(x1, x2);
all_x = [xx1(:) xx2(:)];
all_x_3channel = repmat(all_x, 3, 1);
all_y_3channel = I_200x150_normal(:);

N_samples = length(all_y_3channel);
Ntr = ceil(N_samples*c);

mse_BPSCG_3channel = zeros(channel, length(nBP_Cross)*length(epoches_Cross), ExNum);
t_BPSCG_3channel = zeros(channel, length(nBP_Cross)*length(epoches_Cross), ExNum);

mse_BPSCG_all = zeros(ExNum, length(nBP_Cross)*length(epoches_Cross));
t_BPSCG_all = zeros(ExNum, length(nBP_Cross)*length(epoches_Cross));

para = zeros(2, length(nBP_Cross)*length(epoches_Cross));
uu = 0;
for nBP = nBP_Cross
    for epochs = epoches_Cross
        uu = uu+1;
        para(:,uu) = [nBP; epochs];
    end
end

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
    for nBP = nBP_Cross
        for epochs = epoches_Cross
            uu = uu+1;
            hat_y = cell(channel,1);
            for j = 1:channel
                tic;
                net = newff(train_x_cell{j,i}',train_y_cell{j,i}',nBP,{'tansig', 'purelin'}, method); 
                net.trainParam.goal = 1e-5;
                net.trainParam.epochs = epochs;
                net.trainParam.lr = 0.05;
                net.trainParam.showWindow = false;
                net.divideFcn = '';
                net = train(net,train_x_cell{j,i}',train_y_cell{j,i}');
                t_BPSCG_3channel(j, uu, i) = toc;

                hat_y_tmp = sim(net,test_x_cell{j,i}');
                mse_BPSCG_3channel(j, uu, i) = mse(test_y_cell{j,i}'-hat_y_tmp);
                hat_y{j} = hat_y_tmp';

                fprintf(['Ex' num2str(i) '--Channel' num2str(j) '--' method '-- nBP ' num2str(nBP) ...
                    ' epoch ' num2str(epochs) ': mse is ' num2str(mse_BPSCG_3channel(j, uu, i)) ...
                    '   time cost is ' num2str(t_BPSCG_3channel(j, uu, i)) '\n']);   
            end
            t_BPSCG_all(i,uu) = sum(t_BPSCG_3channel(:, uu, i));
            mse_BPSCG_all(i,uu) = mse(cell2mat(hat_y)-cell2mat(test_y_cell(:,i)));
            clear hat_y;
            
        end
    end
    save([cd '\results\RadarResults\BPSCG_' name '_200x150_TrPer' num2str(c*100) '.mat'],...
        't_BPSCG_3channel', 'mse_BPSCG_3channel', 't_BPSCG_all','mse_BPSCG_all',...
        'epoches_Cross', 'nBP_Cross', 'para', 'train_x_cell',...
        'train_y_cell', 'test_x_cell', 'test_y_cell');
end
t_BPSCG_3channel_mean = mean(t_BPSCG_3channel,3);
mse_BPSCG_3channel_mean = mean(mse_BPSCG_3channel,3);
t_BPSCG_all_mean = mean(t_BPSCG_all,1);
mse_BPSCG_all_mean = mean(mse_BPSCG_all,1);
save([cd '\results\RadarResults\BPSCG_' name '_200x150_TrPer' num2str(c*100) '.mat'],...
        't_BPSCG_3channel', 'mse_BPSCG_3channel', 't_BPSCG_all','mse_BPSCG_all',...
        't_BPSCG_3channel_mean','mse_BPSCG_3channel_mean','t_BPSCG_all_mean',...
        'mse_BPSCG_all_mean', 'epoches_Cross', 'nBP_Cross', 'para', ...
        'train_x_cell', 'train_y_cell', 'test_x_cell', 'test_y_cell');