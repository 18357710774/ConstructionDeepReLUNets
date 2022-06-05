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
gammaCross = [1 10 100 1000 10000];
cCross = [1 10 100 1000 10000];
resolution = 2;
name = 'RiverIce20200513_013745_color';

load([cd '\RadarData\' name '.mat'], 'I_400x300_normal', 'I_200x150_normal');
[height, width, channel] = size(I_200x150_normal);

 % Generating Train Set
x1 = (1/(2*width)):(1/width):1;
x2 = (1/(2*height)):(1/height):1;
[xx1, xx2] = meshgrid(x1, x2);
train_x = [xx1(:) xx2(:)];
train_y = cell(1,channel);
for i = 1:channel
    tmp = I_200x150_normal(:, :, i);
    train_y{i} = tmp(:);
end

% Generating Test Set
y1 = (1/(4*width)):(1/(2*width)):1;
y2 = (1/(4*height)):(1/(2*height)):1;
[yy1, yy2] = meshgrid(y1, y2);
test_x = [yy1(:) yy2(:)];
GridNum_test_height = 2*height;
GridNum_test_width = 2*width;
test_y = cell(1,channel);
for i = 1:channel
    tmp = I_400x300_normal(:, :, i);
    test_y{i} = tmp(:);
end

t_SVRepsRBF_3channel = zeros(channel, length(gammaCross)*length(cCross)*length(epsilonCross));
mse_SVRepsRBF_3channel = zeros(channel, length(gammaCross)*length(cCross)*length(epsilonCross));

t_SVRepsRBF_all = zeros(1, length(gammaCross)*length(cCross)*length(epsilonCross));
mse_SVRepsRBF_all = zeros(1, length(gammaCross)*length(cCross)*length(epsilonCross));

para = zeros(3, length(gammaCross)*length(cCross)*length(epsilonCross));

uu = 0;
for epsilon = epsilonCross
    for gamma = gammaCross
        for c = cCross
            uu = uu+1;
            para(:,uu) = [epsilon; gamma; c];
            libsvm_options = [libsvm_options1 ' -g ' num2str(gamma)...
                ' -c ' num2str(c) ' -p ' num2str(epsilon)];
            I = zeros(size(I_400x300_normal));
            hat_y = cell(1,channel);
            for ii = 1:channel
                tic;
                model = libsvmtrain(train_y{ii}, train_x, libsvm_options);
                t_SVRepsRBF_3channel(ii, uu) = toc;
                [hat_y{ii}, tmse, ~] = libsvmpredict(test_y{ii}, test_x, model);
                % tmse(1) 分类准确率，分类问题中用到的参数指标, 回归问题中没有实质意义；
                % tmse(2) 平均平方误差（ mean squared error,MSE），回归问题中用到的参数指标；
                % tmse(3) 平方相关系数（ squared correlation coefficient ，r2），回归问题中用到的参数指标。                   
                mse_SVRepsRBF_3channel(ii, uu) = tmse(2);
                I(:,:,ii) = reshape(hat_y{ii},GridNum_test_height,GridNum_test_width);
            end          
            t_SVRepsRBF_all(:,uu) = sum(t_SVRepsRBF_3channel(:, uu));
            hat_y_tmp = cell2mat(hat_y);
            hat_y_tmp = hat_y_tmp(:);
            test_y_tmp = cell2mat(test_y);
            test_y_tmp = test_y_tmp(:);
            mse_SVRepsRBF_all(:,uu) = mse(hat_y_tmp-test_y_tmp);
            
            min_hat_y_tmp = min(hat_y_tmp);
            max_hat_y_tmp = max(hat_y_tmp);
            I = uint8(((I-min_hat_y_tmp)/max_hat_y_tmp) * 255);
            
            imwrite(I,[cd '\results\RadarResults\SVRepsRBF_' name '_200x150_2ResColor_eps ' num2str(epsilon) 'gamma' num2str(gamma) 'c' num2str(c) '.jpg'],'jpg')

            fprintf(['libsvmSVR--epsilon ' num2str(epsilon) ' gamma ' num2str(gamma)...
                ' c ' num2str(c) ': mse is ' num2str(mse_SVRepsRBF_all(:,uu)) ...
                '   time cost is ' num2str(t_SVRepsRBF_all(:,uu)) '\n']);   
        end
    end
end
save([cd '\results\RadarResults\SVRepsRBF' name '_200x150_2ResColor' num2str(resolution) '.mat'],...
        'GridNum_test_height','GridNum_test_width', 't_SVRepsRBF_all', 'mse_SVRepsRBF_all', ...
        't_SVRepsRBF_3channel','mse_SVRepsRBF_3channel','epsilonCross', 'gammaCross', 'cCross',...,
        'I_400x300_normal','I_200x150_normal','para');