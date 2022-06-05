clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));
addpath(genpath('libsvm-3.24\windows'));
addpath(genpath('SGD_tools'));

if ~exist('results\RadarResults','dir')
	mkdir('results\RadarResults');
end

name = 'RiverIce20150417_223028_color';

load([cd '\RadarData\' name '.mat'], 'I_400x450_normal', 'I_200x225_normal');
[height, width, channel] = size(I_200x225_normal);

 % Generating Train Set
x1 = (1/(2*width)):(1/width):1;
x2 = (1/(2*height)):(1/height):1;
[xx1, xx2] = meshgrid(x1, x2);
train_x = [xx1(:) xx2(:)];
train_y = cell(1,channel);
for i = 1:channel
    tmp = I_200x225_normal(:, :, i);
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
    tmp = I_400x450_normal(:, :, i);
    test_y{i} = tmp(:);
end

% 11中BP方法的最优参数
BPMethodCross = {'traingdm','traingda','traingdx',...
                'trainrp','traincgf','traincgp','traincgb',...
                'trainscg','trainbfg','trainoss','trainlm'};
            
nBP_3channel_opt = [10 30 130 190 170 150 200 190 180 200 200;
                    10 80 140 200 200 190 190 190 190 190 190;
                    10 70 170 200 200 200 180 180 200 180 200];
epochsBP_3channel_opt = [10000 10000 10000 10000 3000 4000 5000 5000 4000 5000 3000;
                         10000 10000 10000 8000 3000 3000 5000 5000 5000 5000 3000;
                         6000 8000 10000 10000 5000 4000 4000 4000 5000 5000 4000];


% SVReps方法的最优参数
% ------------------SVR optimal parameters 1 -------------------
% SVR_eps_3channel_opt = [0.001;0.001;0.001];
% SVR_gamma_3channel_opt = [10000;10000;10000];
% SVR_C_3channel_opt = [100;100;100];
% libsvm_options_3channel = {['-s 3 -t 2 -h 0 -g ' num2str(SVR_gamma_3channel_opt(1))  ' -c ' num2str(SVR_C_3channel_opt(1)) ' -p ' num2str( SVR_eps_3channel_opt(1))],...
%                            ['-s 3 -t 2 -h 0 -g ' num2str(SVR_gamma_3channel_opt(2))  ' -c ' num2str(SVR_C_3channel_opt(2)) ' -p ' num2str( SVR_eps_3channel_opt(2))],...
%                            ['-s 3 -t 2 -h 0 -g ' num2str(SVR_gamma_3channel_opt(3))  ' -c ' num2str(SVR_C_3channel_opt(3)) ' -p ' num2str( SVR_eps_3channel_opt(3))]};

% ------------------SVR optimal parameters 2 -------------------
SVR_eps_3channel_opt = [0.01;0.01;0.01];
SVR_gamma_3channel_opt = [1000;1000;1000];
SVR_C_3channel_opt = [1000;1000;1000];
libsvm_options_3channel = {['-s 3 -t 2 -h 0 -g ' num2str(SVR_gamma_3channel_opt(1))  ' -c ' num2str(SVR_C_3channel_opt(1)) ' -p ' num2str( SVR_eps_3channel_opt(1))],...
                           ['-s 3 -t 2 -h 0 -g ' num2str(SVR_gamma_3channel_opt(2))  ' -c ' num2str(SVR_C_3channel_opt(2)) ' -p ' num2str( SVR_eps_3channel_opt(2))],...
                           ['-s 3 -t 2 -h 0 -g ' num2str(SVR_gamma_3channel_opt(3))  ' -c ' num2str(SVR_C_3channel_opt(3)) ' -p ' num2str( SVR_eps_3channel_opt(3))]};
  

% ND_method的最优参数
tau = 0.0001;
N_star_3channel_opt = [200;200;150];

t_BP_3channel = zeros(3, length(BPMethodCross));  % 11中Matlab自带的BP算法
mse_BP_3channel = zeros(3, length(BPMethodCross));
predict_y_BP_3channel = cell(3,length(BPMethodCross));
predict_yTensor_BP_3channel = cell(1,length(BPMethodCross));

t_SVR_3channel = zeros(3, 1);
mse_SVR_3channel = zeros(3, 1);
predict_y_SVR_3channel = cell(3, 1);
predict_yTenosr_SVR_3channel = zeros(size(I_400x450_normal));

t_ND_3channel = zeros(3, 1);
mse_ND_3channel = zeros(3, 1);
predict_y_ND_3channel = cell(3, 1);
predict_yTensor_ND_3channel = zeros(size(I_400x450_normal));

% BP methods
for uu = 1:length(BPMethodCross)
    method = BPMethodCross{uu};   
    Itmp = zeros(size(I_400x450_normal));
    for  ii = 1:3
        epochsBP = epochsBP_3channel_opt(ii,uu);
        nBP = nBP_3channel_opt(ii,uu);

        tic;
        net = newff(train_x',train_y{ii}',nBP,{'tansig', 'purelin'}, method); 
        net.trainParam.goal = 1e-5;
        net.trainParam.epochs = epochsBP;
        net.trainParam.lr = 0.05;
        net.trainParam.showWindow = false;
        net.divideFcn = '';
        net = train(net,train_x',train_y{ii}');
        t_BP_3channel(ii, uu) = toc;

        predict_y_BP_3channel{ii,uu} = sim(net,test_x');
        mse_BP_3channel(ii, uu) = mse(test_y{ii}'-predict_y_BP_3channel{ii,uu});
        Itmp(:,:,ii) = reshape(predict_y_BP_3channel{ii,uu},GridNum_test_height,GridNum_test_width);
        fprintf([ ' BPmethod#' method '  nBP ' num2str(nBP) ' epoch ' num2str(epochsBP) ...
        ': mse is ' num2str(mse_BP_3channel(ii, uu)) '   time cost is ' num2str(t_BP_3channel(ii, uu)) '\n']);   
    end
    predict_yTensor_BP_3channel{uu} = Itmp;   
end

% SVReps方法
for ii = 1:channel
    tic;
    model = libsvmtrain(train_y{ii}, train_x, libsvm_options_3channel{ii});
    t_SVR_3channel(ii) = toc;
    [predict_y_SVR_3channel{ii}, tmse, ~] = libsvmpredict(test_y{ii}, test_x, model);
    % tmse(1) 分类准确率，分类问题中用到的参数指标, 回归问题中没有实质意义；
    % tmse(2) 平均平方误差（ mean squared error,MSE），回归问题中用到的参数指标；
    % tmse(3) 平方相关系数（ squared correlation coefficient ，r2），回归问题中用到的参数指标。                   
    mse_SVR_3channel(ii) = tmse(2);
    predict_yTenosr_SVR_3channel(:,:,ii) = reshape(predict_y_SVR_3channel{ii},GridNum_test_height,GridNum_test_width);
    fprintf([ libsvm_options_3channel{ii} ...
        ':  mse is ' num2str(mse_SVR_3channel(ii)) '   time cost is ' num2str(t_SVR_3channel(ii))  '\n']);
end          

% ND方法   
for ii = 1:channel
    tic;
    predict_y_ND_3channel{ii} = ND_func_mod(test_x, train_x, train_y{ii}, N_star_3channel_opt(ii), tau);
    t_ND_3channel(ii) = toc;
    mse_ND_3channel(ii) = mse(test_y{ii}-predict_y_ND_3channel{ii});
    predict_yTensor_ND_3channel(:,:,ii) = reshape(predict_y_ND_3channel{ii},GridNum_test_height,GridNum_test_width);
    fprintf([' ND  N_star#' num2str(N_star_3channel_opt(ii)) ': mse is ' num2str(mse_ND_3channel(ii)) ...
    '   time cost is ' num2str(t_ND_3channel(ii)) '\n']);  
end
    
save([cd '\results\simulation3\Contrast_RiverIce20150417_223028_2ResColor_200x225_Numerical.mat'],...
        'BPMethodCross', 'nBP_3channel_opt', 'epochsBP_3channel_opt', 'SVR_eps_3channel_opt',...
        'SVR_gamma_3channel_opt', 'SVR_C_3channel_opt', 'libsvm_options_3channel', 'tau',...
        'N_star_3channel_opt', 't_BP_3channel', 'mse_BP_3channel', 'predict_y_BP_3channel',...
        'predict_yTensor_BP_3channel', 't_SVR_3channel', 'mse_SVR_3channel',...
        'predict_y_SVR_3channel', 'predict_yTenosr_SVR_3channel','t_ND_3channel','mse_ND_3channel',... 
        'predict_y_ND_3channel', 'predict_yTensor_ND_3channel', 'I_400x450_normal', 'I_200x225_normal',...
        'train_x', 'train_y', 'test_x', 'test_y');    
