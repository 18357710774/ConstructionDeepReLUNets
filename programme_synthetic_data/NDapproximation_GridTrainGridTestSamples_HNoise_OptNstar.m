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

tau = 0.0001;

% % GridNum_train = 500的最优参数
% GridNum_train = 500;
% GridNum_test = 100;
% N_star_Opt = 30;

% % GridNum_train = 1000的最优参数
% GridNum_train = 1000;
% GridNum_test = 100;
% N_star_Opt = 60;

% GridNum_train = 2000的最优参数
GridNum_train = 2000;
GridNum_test = 100;
N_star_Opt = 90;

ExNum = 20;

x1 = (1/GridNum_train):(1/GridNum_train):1;
x2 = x1;
[xx1, xx2] = meshgrid(x1, x2);
train_x = [xx1(:) xx2(:)];

m = size(train_x,1);
U = ceil((m*s/(N^d))^(1/(2*r+d))); 

mse_ND = zeros(ExNum, 1);
t_ND = zeros(ExNum, 1);
predict_y_ND = zeros(GridNum_test^2,ExNum);
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

    tic;
    hat_y = ND_func_mod(test_x, train_x, train_y, N_star_Opt, tau);
    t_ND(vv) = toc;
    mse_ND(vv) = mse(test_y-hat_y);
    predict_y_ND(:,vv) = hat_y;

    fprintf(['Ex#' num2str(Ex) ': mse is ' num2str(mse_ND(vv)) ...
        '   time cost is ' num2str(t_ND(vv)) '\n']);      
end
save([cd '\results\simulation3\NDGridTrainSamplesHNoiseNumericalReusltsGridNum' num2str(GridNum_train) 'OptNstar.mat'],...
        'd','GridNum_test','GridNum_train','Ind_S', 'IndRand', 'm', 'mse_ND', 't_ND', 'N_star_Opt',...
        'predict_y_ND', 'r', 'RadeRV', 's', 'tau',  'U');