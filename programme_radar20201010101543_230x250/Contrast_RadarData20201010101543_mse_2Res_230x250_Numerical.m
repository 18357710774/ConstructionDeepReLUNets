clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));
addpath(genpath('libsvm-3.24\windows'));
addpath(genpath('SGD_tools'));

if ~exist('results\RadarResults','dir')
	mkdir('results\RadarResults');
end

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


% 11中BP方法的最优参数
BPMethodCross = {'traingdm','traingda','traingdx',...
                'trainrp','traincgf','traincgp','traincgb',...
                'trainscg','trainbfg','trainoss','trainlm'};
            
nBP_opt = [20 40 180 200 180 200 180 180 200 170 200];
epochsBP_opt = [8000 8000 10000 10000 5000 2000 5000 5000 5000 5000 5000];


% SVReps方法的最优参数
% ------------------SVR optimal parameters 1 -------------------
% SVR_eps_opt = 0.01;
% SVR_gamma_opt = 10000;
% SVR_C_opt = 10;
% libsvm_options = ['-s 3 -t 2 -h 0 -g ' num2str(SVR_gamma_opt)  ' -c ' num2str(SVR_C_opt) ' -p ' num2str(SVR_eps_opt)];

% ---------SVR optimal parameters 2 (used in paper) ------------
% SVReps方法的最优参数
SVR_eps_opt = 0.01;
SVR_gamma_opt = 1000;
SVR_C_opt = 100;
libsvm_options = ['-s 3 -t 2 -h 0 -g ' num2str(SVR_gamma_opt)  ' -c ' num2str(SVR_C_opt) ' -p ' num2str(SVR_eps_opt)];
 
% ND_method的最优参数
tau = 0.0001;
N_star_opt = 100;

t_BP = zeros(1, length(BPMethodCross));  % 11中Matlab自带的BP算法
mse_BP = zeros(1, length(BPMethodCross));
predict_y_BP = cell(1,length(BPMethodCross));
predict_yTensor_BP = cell(1,length(BPMethodCross));

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
    Itmp= reshape(predict_y_BP{uu},GridNum_test_height,GridNum_test_width);
    fprintf([ ' BPmethod#' method '  nBP ' num2str(nBP) ' epoch ' num2str(epochsBP) ...
    ': mse is ' num2str(mse_BP(uu)) '   time cost is ' num2str(t_BP(uu)) '\n']);   
    predict_yTensor_BP{uu} = Itmp;   
end

% SVReps方法
tic;
model = libsvmtrain(train_y, train_x, libsvm_options);
t_SVR = toc;
[predict_y_SVR, tmse, ~] = libsvmpredict(test_y, test_x, model);
% tmse(1) 分类准确率，分类问题中用到的参数指标, 回归问题中没有实质意义；
% tmse(2) 平均平方误差（ mean squared error,MSE），回归问题中用到的参数指标；
% tmse(3) 平方相关系数（ squared correlation coefficient ，r2），回归问题中用到的参数指标。                   
mse_SVR = tmse(2);
predict_yTenosr_SVR = reshape(predict_y_SVR,GridNum_test_height,GridNum_test_width);
fprintf([ libsvm_options ':  mse is ' num2str(mse_SVR) '   time cost is ' num2str(t_SVR)  '\n']);
    
% ND方法   
tic;
predict_y_ND = ND_func_mod(test_x, train_x, train_y, N_star_opt, tau);
t_ND = toc;
mse_ND = mse(test_y-predict_y_ND);
predict_yTensor_ND = reshape(predict_y_ND,GridNum_test_height,GridNum_test_width);
fprintf([' ND  N_star#' num2str(N_star_opt) ': mse is ' num2str(mse_ND) ...
'   time cost is ' num2str(t_ND) '\n']);  

save([cd '\results\simulation3\Contrast_RadarData20201010101543_mse_2Res_230x250_Numerical.mat'],...
        'BPMethodCross', 'nBP_opt', 'epochsBP_opt', 'SVR_eps_opt',...
        'SVR_gamma_opt', 'SVR_C_opt', 'libsvm_options', 'tau',...
        'N_star_opt', 't_BP', 'mse_BP', 'predict_y_BP',...
        'predict_yTensor_BP', 't_SVR', 'mse_SVR',...
        'predict_y_SVR', 'predict_yTenosr_SVR','t_ND','mse_ND',... 
        'predict_y_ND', 'predict_yTensor_ND', 'I_460x500_normal', 'I_230x250_normal',...
        'train_x', 'train_y', 'test_x', 'test_y');    
    
