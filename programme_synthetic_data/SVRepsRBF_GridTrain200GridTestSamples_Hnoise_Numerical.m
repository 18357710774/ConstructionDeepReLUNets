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
if ~exist('results\simulation3','dir')
	mkdir('results\simulation3');
end

% f函数的相关参数值
r = 1;
N = 10;
s = 4;
d = 2;

libsvm_options1 = '-s 3 -t 2 -h 0';
epsilonCross = [0.001 0.01];
gammaCross = [10 100 1000 10000];
cCross = [10 100 1000 10000];
GridNum_train = 200;
GridNum_test = 100;

x1 = (1/GridNum_train):(1/GridNum_train):1;
x2 = x1;
[xx1, xx2] = meshgrid(x1, x2);
train_x = [xx1(:) xx2(:)];

ExNum = 20;
m_train = GridNum_train^d;
m_test = GridNum_test^d;

U = ceil((m_train*s/(N^d))^(1/(2*r+d))); 

t_SVRepsRBF = zeros(ExNum, length(gammaCross)*length(cCross)*length(epsilonCross));
mse_SVRepsRBF = zeros(ExNum, length(gammaCross)*length(cCross)*length(epsilonCross));
para = zeros(3, length(gammaCross)*length(cCross)*length(epsilonCross));

vv = 0;
for Ex = 1:ExNum
    vv = vv+1;
    rng(Ex);
    IndRand = randperm(N^d);
    Ind_S = IndRand(1:s);
    RadeRV = RademacherRandomVariable(U^d);

    train_y = f_func(train_x, N, Ind_S, RadeRV);
    indysel = find(train_y~=0);
    train_y(indysel) = train_y(indysel)+1/sqrt(10)*randn(length(indysel),1);

    % Generating Test Set
    y1 = (0.5/GridNum_train):(1/GridNum_test):1;
    y2 = y1;
    [yy1, yy2] = meshgrid(y1, y2);
    test_x = [yy1(:) yy2(:)];
    test_y = f_func(test_x, N, Ind_S, RadeRV);
    
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
                t_SVRepsRBF(vv, uu) = toc;
                mse_SVRepsRBF(vv, uu) = tmse(2);
%                 mse_SVRepsRBF1(vv, uu) = mse(test_y-hat_y);

                fprintf(['Ex#' num2str(Ex) 'epsilon ' num2str(epsilon) ' gamma ' num2str(gamma)...
                    ' c ' num2str(c) ': mse is ' num2str(mse_SVRepsRBF(vv,uu)) ...
                    '   time cost is ' num2str(t_SVRepsRBF(vv,uu)) '\n']);   
            end
        end
    end
    save([cd '\results\simulation3\SVRepsRBFGridTrainGridTestSamplesHNoiseNumericalEx' num2str(Ex) 'TrainNum' num2str(m_train) '.mat'],...
        'd','m_test','GridNum_test','Ind_S', 'IndRand', 'm_train', 'GridNum_train','t_SVRepsRBF', 'mse_SVRepsRBF', 'epsilonCross', 'ExNum',...
        'gammaCross', 'cCross', 'r', 'RadeRV', 's', 'U', 'N', 'para');
end