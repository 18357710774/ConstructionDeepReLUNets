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
name = '20201009135112_mse';
Ratio = 0.8;
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
Ntr = ceil(N_samples*Ratio);

t_SVRepsRBF = zeros(ExNum, length(gammaCross)*length(cCross)*length(epsilonCross));
mse_SVRepsRBF = zeros(ExNum, length(gammaCross)*length(cCross)*length(epsilonCross));
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
    for epsilon = epsilonCross
        for gamma = gammaCross
            for c = cCross
                uu = uu+1;
                libsvm_options = [libsvm_options1 ' -g ' num2str(gamma)...
                    ' -c ' num2str(c) ' -p ' num2str(epsilon)];
                tic;
                model = libsvmtrain(train_y, train_x, libsvm_options);
                [hat_y, tmse, ~] = libsvmpredict(test_y, test_x, model);
                % tmse(1) 分类准确率，分类问题中用到的参数指标, 回归问题中没有实质意义；
                % tmse(2) 平均平方误差（ mean squared error,MSE），回归问题中用到的参数指标；
                % tmse(3) 平方相关系数（ squared correlation coefficient ，r2），回归问题中用到的参数指标。   
                t_SVRepsRBF(i, uu) = toc;
                mse_SVRepsRBF(i, uu) = tmse(2);

                fprintf(['Ex' num2str(i) '--libsvmSVR--epsilon ' num2str(epsilon) ' gamma ' num2str(gamma)...
                    ' c ' num2str(c) ': mse is ' num2str(mse_SVRepsRBF(i,uu)) ...
                    '   time cost is ' num2str(t_SVRepsRBF(i,uu)) '\n']);   
            end
        end
    end
    save([cd '\results\RadarResults\SVRepsRBF' name '_167x225_TrPer' num2str(Ratio*100) '.mat'],...
          't_SVRepsRBF', 'mse_SVRepsRBF', 'epsilonCross', 'gammaCross', 'cCross', 'para',...
           'train_x_cell', 'train_y_cell', 'test_x_cell', 'test_y_cell');
end
t_SVRepsRBF_mean = mean(t_SVRepsRBF,1);
mse_SVRepsRBF_mean = mean(mse_SVRepsRBF,1);
save([cd '\results\RadarResults\SVRepsRBF' name '_167x225_TrPer' num2str(Ratio*100) '.mat'],...
          't_SVRepsRBF', 'mse_SVRepsRBF', 'epsilonCross', 'gammaCross', 'cCross', 'para',...
           'train_x_cell', 'train_y_cell', 'test_x_cell', 'test_y_cell', 't_SVRepsRBF_mean', 'mse_SVRepsRBF_mean');