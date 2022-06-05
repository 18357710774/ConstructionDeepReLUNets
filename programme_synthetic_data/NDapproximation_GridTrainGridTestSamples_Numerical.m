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

GridNum_train = 200; % 500; % 1000
GridNum_test = 100;
N_starCross = 5:5:200;
ExNum = 20;

x1 = (1/GridNum_train):(1/GridNum_train):1;
x2 = x1;
[xx1, xx2] = meshgrid(x1, x2);
train_x = [xx1(:) xx2(:)];

m = size(train_x,1);
U = ceil((m*s/(N^d))^(1/(2*r+d))); 

mse_ND = zeros(ExNum, length(N_starCross));
t_ND = zeros(ExNum, length(N_starCross));
vv = 0;
for Ex = 1:ExNum
    vv = vv+1;
    rng(Ex);
    IndRand = randperm(N^d);
    Ind_S = IndRand(1:s);
    RadeRV = RademacherRandomVariable(U^d);

    train_y = f_func(train_x, N, Ind_S, RadeRV);
    e = 1/10*max(abs(train_y))*randn(m,1);
    train_y = train_y+e;

    % Generating Test Set
    y1 = (0.5/GridNum_train):(1/GridNum_test):1;
    y2 = y1;
    [yy1, yy2] = meshgrid(y1, y2);
    test_x = [yy1(:) yy2(:)];
    test_y = f_func(test_x, N, Ind_S, RadeRV);

    uu = 0;
    for N_star = N_starCross
        uu = uu+1;
        tic;
        hat_y = ND_func_mod(test_x, train_x, train_y, N_star, tau);
        t_ND(vv, uu) = toc;
        mse_ND(vv, uu) = mse(test_y-hat_y);
        
        figure(1);
        imagesc(reshape(hat_y,GridNum_test,GridNum_test));
        title('predict\_y');
        colormap(jet);
        saveas(1, [cd '\results\simulation3\figs\ND_GridTrainGridTestEx' num2str(Ex) 'N_star' num2str(N_star) '.png'])
        close;
        
        fprintf(['Ex#' num2str(Ex) 'N_star#' num2str(N_star) ': mse is ' num2str(mse_ND(vv,uu)) ...
            '   time cost is ' num2str(t_ND(vv,uu)) '\n']); 
    end
    save([cd '\results\simulation3\NDGridTrainGridTestSamplesNumericalReusltsEx' num2str(Ex) 'GridNum' num2str(GridNum_train) '.mat'], ...
        'd','GridNum_test','GridNum_train','Ind_S', 'm', 'mse_ND', 't_ND', 'N_starCross', 'r', 'RadeRV', 's', 'tau','U');
end