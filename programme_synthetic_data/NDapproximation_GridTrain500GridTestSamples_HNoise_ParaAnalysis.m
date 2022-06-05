clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));
if ~exist('results\simulation3','dir')
	mkdir('results\simulation3');
end

% f函数的相关参数值
r = 1;
N = 10;
s = 4;
d = 2;

tauCross = [0.0001 0.0005 0.001 0.005 0.01 0.05 0.1];

GridNum_train = 500;
GridNum_test = 100;
N_starCross = 5:5:200;
ExNum = 20;


x1 = (1/GridNum_train):(1/GridNum_train):1;
x2 = x1;
[xx1, xx2] = meshgrid(x1, x2);
train_x = [xx1(:) xx2(:)];

m = size(train_x,1);
U = ceil((m*s/(N^d))^(1/(2*r+d))); 

mse_ND = zeros(length(tauCross), length(N_starCross), ExNum);
t_ND = zeros(length(tauCross), length(N_starCross), ExNum);

for Ex = 1:ExNum
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
    
    vv = 0;
    for tau = tauCross
        vv = vv+1;
        uu = 0;
        for N_star = N_starCross
            uu = uu+1;
            tic;
            hat_y = ND_func_mod(test_x, train_x, train_y, N_star, tau);
            t_ND(vv, uu, Ex) = toc;
            mse_ND(vv, uu, Ex) = mse(test_y-hat_y);

            fprintf(['Ex#' num2str(Ex) '  tau#' num2str(tau) '  N_star#' num2str(N_star) ': mse is ' num2str(mse_ND(vv, uu, Ex)) ...
                '   time cost is ' num2str(t_ND(vv, uu, Ex)) '\n']);      
        end
    end
    save([cd '\results\simulation3\NDGridTrainSamplesHNoiseParaAnalysisEx' num2str(Ex) 'GridNum' num2str(GridNum_train) '.mat'],...
            'd','GridNum_test','GridNum_train','Ind_S', 'IndRand', 'm', 'mse_ND', 't_ND', 'tauCross', 'N_starCross', 'r', 'RadeRV', 's', 'tau',  'U');
end
mse_ND_mean = mean(mse_ND, 3);
t_ND_mean = mean(mse_ND, 3);
save([cd '\results\simulation3\NDGridTrainSamplesHNoiseParaAnalysisEx' num2str(Ex) 'GridNum' num2str(GridNum_train) '.mat'],...
            'd','GridNum_test','GridNum_train','Ind_S', 'IndRand', 'm', 'mse_ND', 't_ND',  'mse_ND_mean', 't_ND_mean', ...
            'tauCross', 'N_starCross', 'r', 'RadeRV', 's', 'tau',  'U');