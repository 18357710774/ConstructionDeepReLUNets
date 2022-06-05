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
% epsilonCross = [0.001 0.01 0.1];
% gammaCross = [0.01 0.1 1 10 100 1000];
% cCross = [0.01 0.1 1 10 100 1000];
epsilonCross = [0.001 0.01 0.1];
gammaCross = 10000;
cCross = [0.01 0.1 1 10 100 1000 10000];
resolution = 2;
name = '20201010101543_mse';

load([cd '\RadarData\' name '.mat'], 'I_460x500_normal', 'I_230x250_normal');
[height, width] = size(I_230x250_normal);

 % Generating Train Set
x1 = (1/(2*width)):(1/width):1;
x2 = (1/(2*height)):(1/height):1;
[xx1, xx2] = meshgrid(x1, x2);
train_x = [xx1(:) xx2(:)];
train_y = I_230x250_normal(:);

% Generating Test Set
y1 = (1/(4*width)):(1/(2*width)):1;
y2 = (1/(4*height)):(1/(2*height)):1;
[yy1, yy2] = meshgrid(y1, y2);
test_x = [yy1(:) yy2(:)];
GridNum_test_height = 2*height;
GridNum_test_width = 2*width;
test_y = I_460x500_normal(:); 

t_SVRepsRBF = zeros(1, length(gammaCross)*length(cCross)*length(epsilonCross));
mse_SVRepsRBF = zeros(1, length(gammaCross)*length(cCross)*length(epsilonCross));
para = zeros(3, length(gammaCross)*length(cCross)*length(epsilonCross));

uu = 0;
for epsilon = epsilonCross
    for gamma = gammaCross
        for c = cCross
            uu = uu+1;
            para(:,uu) = [epsilon; gamma; c];
            libsvm_options = [libsvm_options1 ' -g ' num2str(gamma)...
                ' -c ' num2str(c) ' -p ' num2str(epsilon)];
            tic;
            model = libsvmtrain(train_y, train_x, libsvm_options);
            [hat_y, tmse, ~] = libsvmpredict(test_y, test_x, model);
            % tmse(1) 分类准确率，分类问题中用到的参数指标, 回归问题中没有实质意义；
            % tmse(2) 平均平方误差（ mean squared error,MSE），回归问题中用到的参数指标；
            % tmse(3) 平方相关系数（ squared correlation coefficient ，r2），回归问题中用到的参数指标。   
            t_SVRepsRBF(:, uu) = toc;
            mse_SVRepsRBF(:, uu) = tmse(2);
%                 mse_SVRepsRBF1(vv, uu) = mse(test_y-hat_y);

            fprintf(['libsvmSVR--epsilon ' num2str(epsilon) ' gamma ' num2str(gamma)...
                ' c ' num2str(c) ': mse is ' num2str(mse_SVRepsRBF(:,uu)) ...
                '   time cost is ' num2str(t_SVRepsRBF(:,uu)) '\n']);   
        end
    end
end
    save([cd '\results\RadarResults\SVRepsRBF' name '_230x250_Res' num2str(resolution) '_2.mat'],...
        'GridNum_test_height','GridNum_test_width', 't_SVRepsRBF', 'mse_SVRepsRBF', 'epsilonCross', 'gammaCross', 'cCross', 'para');