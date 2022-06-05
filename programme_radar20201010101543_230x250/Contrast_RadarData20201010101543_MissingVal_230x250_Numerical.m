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
c = 0.8;
ExNum = 20;

load([cd '\RadarData\' name '.mat'], 'I_460x500_normal', 'I_230x250_normal');
[height, width] = size(I_230x250_normal);

 % Generate All samples
x1 = (1/(2*width)):(1/width):1;
x2 = (1/(2*height)):(1/height):1;
[xx1, xx2] = meshgrid(x1, x2);
all_x = [xx1(:) xx2(:)];
all_y = I_230x250_normal(:);

N_samples = length(all_y);
Ntr = ceil(N_samples*c);

% 8中BP方法的最优参数
BPMethodCross = {'traingdx','trainrp','traincgf','traincgb',...
                'trainscg','trainbfg','trainoss','trainlm'};
            
nBP_opt = [140 180 200 200 200 200 200 200];
epochsBP_opt = [10000 10000 4000 5000 5000 5000 5000 5000];

% SVReps方法的最优参数
SVR_eps_opt = 0.01;
SVR_gamma_opt = 1000;
SVR_C_opt = 10;
libsvm_options = ['-s 3 -t 2 -h 0 -g ' num2str(SVR_gamma_opt)  ' -c ' num2str(SVR_C_opt) ' -p ' num2str(SVR_eps_opt)];
                          
% ND_method的最优参数
tau = 0.0001;
N_star_opt = 66;

t_BP = zeros(ExNum, length(BPMethodCross));  % 8种Matlab自带的BP算法
mse_BP = zeros(ExNum, length(BPMethodCross));
predict_y_BP = cell(ExNum,length(BPMethodCross));
ImgRecovery_BP = cell(ExNum,length(BPMethodCross));

t_SVR = zeros(ExNum, 1);
mse_SVR = zeros(ExNum, 1);
predict_y_SVR = cell(ExNum, 1);
ImgRecovery_SVR = cell(ExNum, 1);

t_ND = zeros(ExNum, 1);
mse_ND = zeros(ExNum, 1);
predict_y_ND = cell(ExNum, 1);
ImgRecovery_ND = cell(ExNum, 1);

train_x_cell = cell(1, ExNum);
train_y_cell = cell(1, ExNum);
test_x_cell = cell(1, ExNum);
test_y_cell = cell(1, ExNum);
train_ind_cell = cell(1, ExNum);
test_ind_cell = cell(1, ExNum);

for ii = 1:ExNum
    rng(ii);
    ind_rand = randperm(N_samples);
    train_ind = ind_rand(1:Ntr);
    test_ind = ind_rand(Ntr+1:end);
    
    train_ind_cell{ii} = train_ind;
    test_ind_cell{ii} = test_ind;
    
    ImgRecoveryVec = all_y;
    ImgRecoveryVec(test_ind) = 0;
    
    % Generate training samples
    train_x = all_x(train_ind, :);
    train_y = all_y(train_ind, :);

    % Generating Test Set
    test_x = all_x(test_ind, :);
    test_y = all_y(test_ind, :);
    
    train_x_cell{ii} = train_x;
    train_y_cell{ii} = train_y;
    test_x_cell{ii} = test_x;
    test_y_cell{ii} = test_y;
    
    % BP methods
    for uu = 1:length(BPMethodCross)
        ImgRecoveryVecTmp = ImgRecoveryVec;
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
        t_BP(ii,uu) = toc;

        predict_y_BP{ii,uu} = sim(net,test_x');
        mse_BP(ii,uu) = mse(test_y'-predict_y_BP{ii,uu});
        ImgRecoveryVecTmp(test_ind) = predict_y_BP{ii,uu};      
        Itmp= reshape(ImgRecoveryVecTmp,height,width);
        clear ImgRecoveryVecTmp
        ImgRecovery_BP{ii,uu} = Itmp;   
        clear Itmp
        fprintf(['Ex' num2str(ii) '--' ' BPmethod#' method '  nBP ' num2str(nBP) ' epoch ' num2str(epochsBP) ...
        ': mse is ' num2str(mse_BP(ii,uu)) '   time cost is ' num2str(t_BP(ii,uu)) '\n']);   
        
    end

    % SVReps方法
    ImgRecoveryVecTmp = ImgRecoveryVec;
    tic;
    model = libsvmtrain(train_y, train_x, libsvm_options);
    t_SVR(ii) = toc;
    [predict_y_SVR{ii}, tmse, ~] = libsvmpredict(test_y, test_x, model);
    % tmse(1) 分类准确率，分类问题中用到的参数指标, 回归问题中没有实质意义；
    % tmse(2) 平均平方误差（ mean squared error,MSE），回归问题中用到的参数指标；
    % tmse(3) 平方相关系数（ squared correlation coefficient ，r2），回归问题中用到的参数指标。                   
    mse_SVR(ii) = tmse(2);
    ImgRecoveryVecTmp(test_ind) = predict_y_SVR{ii};
    Itmp = reshape(ImgRecoveryVecTmp,height,width);
    clear ImgRecoveryVecTmp        
    ImgRecovery_SVR{ii} = Itmp;
    clear Itmp;
    fprintf(['Ex' num2str(ii) '--SVR ' libsvm_options ':  mse is ' num2str(mse_SVR(ii)) '   time cost is ' num2str(t_SVR(ii))  '\n']);

    % ND方法  
    ImgRecoveryVecTmp = ImgRecoveryVec;
    tic;
    predict_y_ND{ii} = ND_func_mod(test_x, train_x, train_y, N_star_opt, tau);
    t_ND(ii) = toc;
    mse_ND(ii) = mse(test_y-predict_y_ND{ii});
    ImgRecoveryVecTmp(test_ind) = predict_y_ND{ii};
    Itmp = reshape(ImgRecoveryVecTmp,height,width);
    clear ImgRecoveryVecTmp        
    ImgRecovery_ND{ii} = Itmp;
    clear Itmp;
    fprintf(['Ex' num2str(ii) '--ND  N_star#' num2str(N_star_opt) ': mse is ' num2str(mse_ND(ii)) ...
    '   time cost is ' num2str(t_ND(ii)) '\n']);  

    save([cd '\results\RadarResults\Contrast_RadarData20201010101543_MissingVal_230x250_Numerical.mat'],...
        'BPMethodCross', 'nBP_opt', 'epochsBP_opt', 'SVR_eps_opt',...
        'SVR_gamma_opt', 'SVR_C_opt', 'libsvm_options', 'tau',...
        'N_star_opt','c', 'ExNum', 't_BP', 'mse_BP', 'predict_y_BP',...
        'ImgRecovery_BP', 't_SVR', 'mse_SVR',...
        'predict_y_SVR', 'ImgRecovery_SVR','t_ND','mse_ND',... 
        'predict_y_ND', 'ImgRecovery_ND', 'I_460x500_normal', 'I_230x250_normal',...
        'all_x','all_y','train_x_cell', 'train_y_cell', 'test_x_cell',...
        'test_y_cell', 'train_ind_cell', 'test_ind_cell');    
end