% epsilon-SVR with RBF kernel: exp(-gamma*|u-v|^2)
% options:
% -s svm_type : set type of SVM (default 0)
% 	0 -- C-SVC
% 	1 -- nu-SVC
% 	2 -- one-class SVM
% 	3 -- epsilon-SVR
% 	4 -- nu-SVR
% -t kernel_type : set type of kernel function (default 2)
% 	0 -- linear: u'*v
% 	1 -- polynomial: (gamma*u'*v + coef0)^degree
% 	2 -- radial basis function: exp(-gamma*|u-v|^2)
% 	3 -- sigmoid: tanh(gamma*u'*v + coef0)
% -g gamma : set gamma in kernel function (default 1/num_features)
% -c cost : set the parameter C of C-SVC, epsilon-SVR, and nu-SVR (default 1)
% -p epsilon : set the epsilon in loss function of epsilon-SVR (default 0.1)
% -e epsilon : set tolerance of termination criterion (default 0.001)
% -h shrinking: whether to use the shrinking heuristics, 0 or 1 (default 1)

clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));
addpath(genpath('libsvm-3.24\windows'));

if ~exist('results\RadarResults','dir')
	mkdir('results\RadarResults');
end

libsvm_options1 = '-s 3 -t 2 -h 0';
epsilonCross = [0.001 0.01];
gammaCross = [100 1000];
cCross = [100 1000];
Ratio = 0.8;
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
Ntr = ceil(N_samples*Ratio);

t_SVRepsRBF_3channel = zeros(channel, length(gammaCross)*length(cCross)*length(epsilonCross), ExNum);
mse_SVRepsRBF_3channel = zeros(channel, length(gammaCross)*length(cCross)*length(epsilonCross), ExNum);

mse_SVRepsRBF_all = zeros(ExNum, length(gammaCross)*length(cCross)*length(epsilonCross));
t_SVRepsRBF_all = zeros(ExNum, length(gammaCross)*length(cCross)*length(epsilonCross));

para = zeros(3, length(gammaCross)*length(cCross)*length(epsilonCross));
uu = 0;
for epsilon = epsilonCross
    for gamma = gammaCross
        for c = cCross
            uu = uu+1;
            para(:,uu) = [epsilon; gamma; c];
        end
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
    for epsilon = epsilonCross
        for gamma = gammaCross
            for c = cCross
                uu = uu+1;
                libsvm_options = [libsvm_options1 ' -g ' num2str(gamma)...
                    ' -c ' num2str(c) ' -p ' num2str(epsilon)];
                hat_y = cell(channel,1);
                for j = 1:channel
                    tic;
                    model = libsvmtrain(train_y_cell{j,i}, train_x_cell{j,i}, libsvm_options);
                    t_SVRepsRBF_3channel(j, uu, i) = toc;
                    [hat_y{j}, tmse, ~] = libsvmpredict(test_y_cell{j,i}, test_x_cell{j,i}, model);
                    % tmse(1) 分类准确率，分类问题中用到的参数指标, 回归问题中没有实质意义；
                    % tmse(2) 平均平方误差（ mean squared error,MSE），回归问题中用到的参数指标；
                    % tmse(3) 平方相关系数（ squared correlation coefficient ，r2），回归问题中用到的参数指标。                       
                    mse_SVRepsRBF_3channel(j, uu, i) = tmse(2);

                    fprintf(['Ex' num2str(i) '--Channel' num2str(j) '--libsvmSVR--epsilon '...
                             num2str(epsilon) ' gamma ' num2str(gamma)...
                            ' c ' num2str(c) ': mse is ' num2str(mse_SVRepsRBF_3channel(j, uu, i)) ...
                            '   time cost is ' num2str(t_SVRepsRBF_3channel(j, uu, i)) '\n']);   
                end
                t_SVRepsRBF_all(i,uu) = sum(t_SVRepsRBF_3channel(:, uu, i));
                mse_SVRepsRBF_all(i,uu) = mse(cell2mat(hat_y)-cell2mat(test_y_cell(:,i)));
                clear hat_y;               
            end
        end
    end
    save([cd '\results\RadarResults\SVRepsRBF' name '_200x150_TrPer' num2str(Ratio*100) '.mat'],...
          't_SVRepsRBF_3channel', 'mse_SVRepsRBF_3channel', 't_SVRepsRBF_all', 'mse_SVRepsRBF_all',...
          'epsilonCross', 'gammaCross', 'cCross', 'para',...
           'train_x_cell', 'train_y_cell', 'test_x_cell', 'test_y_cell');
end

t_SVRepsRBF_3channel_mean = mean(t_SVRepsRBF_3channel,3);
mse_SVRepsRBF_3channel_mean = mean(mse_SVRepsRBF_3channel,3);
t_SVRepsRBF_all_mean = mean(t_SVRepsRBF_all,1);
mse_SVRepsRBF_all_mean = mean(mse_SVRepsRBF_all,1);

save([cd '\results\RadarResults\SVRepsRBF' name '_200x150_TrPer' num2str(Ratio*100) '.mat'],...
          't_SVRepsRBF_3channel', 'mse_SVRepsRBF_3channel', 't_SVRepsRBF_all', 'mse_SVRepsRBF_all',...
          'epsilonCross', 'gammaCross', 'cCross', 'para',...
           'train_x_cell', 'train_y_cell', 'test_x_cell', 'test_y_cell',...
           't_SVRepsRBF_3channel_mean','mse_SVRepsRBF_3channel_mean',...
           't_SVRepsRBF_all_mean','mse_SVRepsRBF_all_mean');