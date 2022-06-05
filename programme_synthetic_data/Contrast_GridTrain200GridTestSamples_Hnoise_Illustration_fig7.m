clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
if ~exist('results\simulation3','dir')
	mkdir('results\simulation3');
end

addpath(genpath('tools'));
addpath(genpath('libsvm-3.24\windows'));
addpath(genpath('SGD_tools'));

SelExNum = 17;
GridNum_test = 100;
GridNum_train = 200;
% 11中BP方法的最优参数
BPMethodCross = {'traingdm','traingda','traingdx',...
                'trainrp','traincgf','traincgp','traincgb',...
                'trainscg','trainbfg','trainoss','trainlm'};
            
nBP_opt = [20 20 50 50 190 190 180 180 130 190 40];
epochsBP_opt = [10000 10000 10000 10000 3000 3000 5000 5000 4000 5000 1000];

% 关于随机梯度下降的参数设置
% SGD方法的最优参数
nBPSGD_opt = 10;
epochsBPSGD_opt = 10000;
% SGD方法的固定参数
L = 3; % 层数
loss_type = 1; % loss function
act_type = 5; % 隐藏层运用tan-sigmoid激活函数
BatchSize = 50;
lr = 0.05;
actfunc = cell(1,L-1);
for ii = 1:L-2
    actfunc{ii} = 'tansig';
end
actfunc{L-1} = 'purelin';   


% SVReps方法的最优参数
SVR_eps_opt = 0.001;
SVR_gamma_opt = 100;
SVR_C_opt = 1000;
libsvm_options = ['-s 3 -t 2 -h 0 -g ' num2str(SVR_gamma_opt)  ' -c ' num2str(SVR_C_opt) ' -p ' num2str(SVR_eps_opt)];

% ND_method的最优参数
tau = 0.0001;
N_star_opt = 20;

t_BP = zeros(1, length(BPMethodCross));  % 11中Matlab自带的BP算法
mse_BP = zeros(1, length(BPMethodCross));
predict_y_BP = cell(1,length(BPMethodCross));

load([cd '\SyntheticData\GridTrainGridTestSamplesHnoise40000.mat']);
train_x_cell = train_x;
train_y_cell = train_y;
test_x_cell = test_x;
test_y_cell = test_y;
clear train_x train_y  test_x test_y

train_x = train_x_cell{SelExNum};
train_y = train_y_cell{SelExNum};
test_x = test_x_cell{SelExNum};
test_y = test_y_cell{SelExNum};

% BP methods
for uu = 1:length(BPMethodCross)
    method = BPMethodCross{uu};
    epochsBP = epochsBP_opt(uu);
    nBP = nBP_opt(uu);

    tic;
    net = newff(train_x',train_y',nBP,{'tansig', 'purelin'}, method); 
    net.trainParam.goal = 1e-5;
    net.trainParam.epochs = epochsBP;
    net.trainParam.lr = 0.05;
    net.trainParam.showWindow = false;
    net.divideFcn = '';
    net = train(net,train_x',train_y');
    t_BP(uu) = toc;

    predict_y_BP{uu} = sim(net,test_x');
    mse_BP(uu) = mse(test_y'-predict_y_BP{uu});
    
    figure(1);
    imagesc(reshape(predict_y_BP{uu},GridNum_test,GridNum_test));
    colormap(jet);
    saveas(1, [cd '\results\simulation3\figs\' method '_GridTrainGridTestHnoiseEx' num2str(SelExNum) '.fig'])
    close;

    fprintf(['BPmethod#' method '  nBP ' num2str(nBP) ' epoch ' num2str(epochsBP) ...
        ': mse is ' num2str(mse_BP(uu)) '   time cost is ' num2str(t_BP(uu)) '\n']);   
end

% BP-SGD methods
net = newff(train_x',train_y',nBPSGD_opt*ones(1,L-2),actfunc); % 初始化神经网络 
W(1).W = net.IW{1};
b(1).b = net.b{1};
for i = 2:L-1
    W(i).W = net.LW{i,i-1}; 
    b(i).b = net.b{i};  
end
lrvec = lr*ones(1,epochsBPSGD_opt);
[~, ~, ~, Error_te, ~, t_tr, predict_y_BPSGD] = StochBackProp(train_x', train_y', test_x', test_y',...
                                W, b, L, loss_type, act_type, BatchSize, epochsBPSGD_opt, lrvec);
mse_BPSGD = Error_te(epochsBPSGD_opt).^2;
t_BPSGD = t_tr(epochsBPSGD_opt);

figure(1);
imagesc(reshape(predict_y_BPSGD,GridNum_test,GridNum_test));
colormap(jet);
saveas(1, [cd '\results\simulation3\figs\BPSGD_GridTrainGridTestHnoiseEx' num2str(SelExNum) '.fig'])
close;
fprintf(['BPmethod#SGD  nBP ' num2str(nBPSGD_opt) ' epoch ' num2str(epochsBPSGD_opt) ...
    ':  mse is ' num2str(mse_BPSGD) '   time cost is ' num2str( t_BPSGD)  '\n']);


% SVReps方法
tic;
model = libsvmtrain(train_y, train_x, libsvm_options);
t_SVR = toc;
[predict_y_SVR, tmse, ~] = libsvmpredict(test_y, test_x, model);
% tmse(1) 分类准确率，分类问题中用到的参数指标, 回归问题中没有实质意义；
% tmse(2) 平均平方误差（ mean squared error,MSE），回归问题中用到的参数指标；
% tmse(3) 平方相关系数（ squared correlation coefficient ，r2），回归问题中用到的参数指标。   
mse_SVR = tmse(2);

figure(1);
imagesc(reshape(predict_y_SVR,GridNum_test,GridNum_test));
colormap(jet);
saveas(1, [cd '\results\simulation3\figs\SVR_GridTrainGridTestHnoiseEx' num2str(SelExNum) '.fig'])
close;
    
fprintf(['SVR eps ' num2str(SVR_eps_opt) ' gamma ' num2str(SVR_gamma_opt) ' C ' num2str(SVR_C_opt) ...
    ':  mse is ' num2str(mse_SVR) '   time cost is ' num2str(t_SVR)  '\n']);

% ND方法   
tic;
predict_y_ND = ND_func_mod(test_x, train_x, train_y, N_star_opt, tau);
t_ND = toc;
mse_ND = mse(test_y-predict_y_ND);

figure(1);
imagesc(reshape(predict_y_ND,GridNum_test,GridNum_test));
colormap(jet);
saveas(1, [cd '\results\simulation3\figs\ND_GridTrainGridTestHnoiseEx' num2str(SelExNum) '.fig'])
close;

fprintf(['ND  N_star#' num2str(N_star_opt) ': mse is ' num2str(mse_ND) ...
'   time cost is ' num2str(t_ND) '\n']);    

save([cd '\results\simulation3\Contrast_GridTrainGridTestHnoiseIllustrationSelExNum17TrainNum40000.mat'],...
    'SelExNum','BPMethodCross', 'nBP_opt', 'epochsBP_opt', 'nBPSGD_opt', 'epochsBPSGD_opt', 'GridNum_test',...
    'L', 'loss_type', 'act_type', 'BatchSize', 'lr', 'actfunc', 'SVR_eps_opt', 'SVR_gamma_opt', 'GridNum_train',...
    'SVR_C_opt', 'libsvm_options','tau','N_star_opt',... 
    't_BP', 'mse_BP', 't_BPSGD', 'mse_BPSGD', 't_SVR', 'mse_SVR', 't_ND', 'mse_ND',...
    'predict_y_BP', 'predict_y_BPSGD', 'predict_y_SVR', 'predict_y_ND');    

