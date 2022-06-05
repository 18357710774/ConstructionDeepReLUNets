clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));
addpath(genpath('libsvm-3.24\windows'));
addpath(genpath('SGD_tools'));

if ~exist('results\RadarResults','dir')
	mkdir('results\RadarResults');
end

c = 0.8;
ExNum = 20;

name = 'RiverIce20200513_013745_color';

load([cd '\RadarData\' name '.mat'],  'I_400x300_normal', 'I_200x150_normal');
[height, width, channel] = size(I_200x150_normal);

% Generate All samples
x1 = (1/(2*width)):(1/width):1;
x2 = (1/(2*height)):(1/height):1;
[xx1, xx2] = meshgrid(x1, x2);
all_x = [xx1(:) xx2(:)];
all_x_3channel = repmat(all_x, 3, 1);
all_y_3channel = I_200x150_normal(:);

N_samples = length(all_y_3channel);
Ntr = ceil(N_samples*c);


% 8中BP方法的最优参数
BPMethodCross = {'traingdx','trainrp','traincgf','traincgb',...
                'trainscg','trainbfg','trainoss','trainlm'};
            
nBP_3channel_opt = [70  140 200 190 200 200 200 200;
                    100 170 200 180 200 200 200 200
                    130 200 200 200 200 200 200 200];
epochsBP_3channel_opt = [8000  10000 5000 3000 5000 5000 5000 3000;
                         10000 10000 4000 4000 5000 5000 4000 5000;
                         10000 10000 5000 5000 5000 5000 5000 4000];

% SVReps方法的最优参数
SVR_eps_3channel_opt = [0.01;0.01;0.01];
SVR_gamma_3channel_opt = [1000;1000;1000];
SVR_C_3channel_opt = [1000;1000;1000];

libsvm_options_3channel = {['-s 3 -t 2 -h 0 -g ' num2str(SVR_gamma_3channel_opt(1))  ' -c ' num2str(SVR_C_3channel_opt(1)) ' -p ' num2str( SVR_eps_3channel_opt(1))],...
                           ['-s 3 -t 2 -h 0 -g ' num2str(SVR_gamma_3channel_opt(2))  ' -c ' num2str(SVR_C_3channel_opt(2)) ' -p ' num2str( SVR_eps_3channel_opt(2))],...
                           ['-s 3 -t 2 -h 0 -g ' num2str(SVR_gamma_3channel_opt(3))  ' -c ' num2str(SVR_C_3channel_opt(3)) ' -p ' num2str( SVR_eps_3channel_opt(3))]};
  
% ND_method的最优参数
tau = 0.0001;
N_star_3channel_opt = [44;52;74];

t_BP_3channel = zeros(3, length(BPMethodCross), ExNum);  % 8中Matlab自带的BP算法
mse_BP_3channel = zeros(3, length(BPMethodCross), ExNum);
predict_y_BP_3channel = cell(3,length(BPMethodCross), ExNum);
ImgRecovery_BP = cell(ExNum,length(BPMethodCross));

t_SVR_3channel = zeros(3, ExNum);
mse_SVR_3channel = zeros(3, ExNum);
predict_y_SVR_3channel = cell(3, ExNum);
ImgRecovery_SVR = cell(ExNum, 1);

t_ND_3channel = zeros(3, ExNum);
mse_ND_3channel = zeros(3, ExNum);
predict_y_ND_3channel = cell(3, ExNum);
ImgRecovery_ND = cell(ExNum, 1);

train_x_cell = cell(3, ExNum);
train_y_cell = cell(3, ExNum);
test_x_cell = cell(3, ExNum);
test_y_cell = cell(3, ExNum);
train_ind_cell = cell(3, ExNum);
test_ind_cell = cell(3, ExNum);

for ii = 1:ExNum
    rng(ii);
    ind_rand_3channel = randperm(N_samples);
    train_ind_3channel = ind_rand_3channel(1:Ntr);
    test_ind_3channel = ind_rand_3channel(Ntr+1:end);
    
    ImgRecoveryVec = all_y_3channel;
    ImgRecoveryVec(test_ind_3channel) = 0;

    
    for jj = 1:channel
        begin_ind = (jj-1)*height*width;
        end_ind = jj*height*width;
        train_ind_channel_j = train_ind_3channel(train_ind_3channel>begin_ind & train_ind_3channel<=end_ind);
        test_ind_channel_j = test_ind_3channel(test_ind_3channel>begin_ind & test_ind_3channel<=end_ind);
        
        % Generate training samples
        train_x_cell{jj,ii} = all_x_3channel(train_ind_channel_j, :);
        train_y_cell{jj,ii} = all_y_3channel(train_ind_channel_j, :);

        % Generating Test Set
        test_x_cell{jj,ii} = all_x_3channel(test_ind_channel_j, :);
        test_y_cell{jj,ii} = all_y_3channel(test_ind_channel_j, :);
        
        train_ind_cell{jj,ii} = train_ind_channel_j;
        test_ind_cell{jj,ii} = test_ind_channel_j;
    end
    
    % BP methods
    for uu = 1:length(BPMethodCross)
        ImgRecoveryVecTmp = ImgRecoveryVec;
        method = BPMethodCross{uu};   
         for  jj = 1:channel
            epochsBP = epochsBP_3channel_opt(jj,uu);
            nBP = nBP_3channel_opt(jj,uu);

            tic;
            net = newff(train_x_cell{jj,ii}',train_y_cell{jj,ii}',nBP,{'tansig', 'purelin'}, method); 
            net.trainParam.goal = 1e-5;
            net.trainParam.epochs = epochsBP;
            net.trainParam.lr = 0.05;
            net.trainParam.showWindow = false;
            net.divideFcn = '';
            net = train(net,train_x_cell{jj,ii}',train_y_cell{jj,ii}');
            t_BP_3channel(jj, uu, ii) = toc;

            predict_y_BP_3channel{jj,uu,ii} = sim(net,test_x_cell{jj,ii}');
            mse_BP_3channel(jj, uu, ii) = mse(test_y_cell{jj,ii}'-predict_y_BP_3channel{jj,uu,ii});
            ImgRecoveryVecTmp(test_ind_cell{jj,ii}) = predict_y_BP_3channel{jj,uu,ii};
            
            fprintf(['Ex' num2str(ii)  '--BPmethod#' method '--channel ' num2str(jj) '  nBP ' num2str(nBP) ' epoch ' num2str(epochsBP) ...
            ': mse is ' num2str(mse_BP_3channel(jj, uu, ii)) '   time cost is ' num2str(t_BP_3channel(jj, uu, ii)) '\n']);   
         end
        Itmp = reshape(ImgRecoveryVecTmp,[height,width,3]);
        clear ImgRecoveryVecTmp
        ImgRecovery_BP{ii,uu} = Itmp;   
        clear Itmp
    end

    % SVReps方法
    ImgRecoveryVecTmp = ImgRecoveryVec;
    for jj = 1:channel
        tic;
        model = libsvmtrain(train_y_cell{jj,ii}, train_x_cell{jj,ii}, libsvm_options_3channel{jj});
        t_SVR_3channel(jj,ii) = toc;
        [predict_y_SVR_3channel{jj,ii}, tmse, ~] = libsvmpredict(test_y_cell{jj,ii}, test_x_cell{jj,ii}, model);
        % tmse(1) 分类准确率，分类问题中用到的参数指标, 回归问题中没有实质意义；
        % tmse(2) 平均平方误差（ mean squared error,MSE），回归问题中用到的参数指标；
        % tmse(3) 平方相关系数（ squared correlation coefficient ，r2），回归问题中用到的参数指标。                   
        mse_SVR_3channel(jj,ii) = tmse(2);
        ImgRecoveryVecTmp(test_ind_cell{jj,ii}) = predict_y_SVR_3channel{jj,ii};
        fprintf(['Ex' num2str(ii)  '--SVR--channel ' num2str(jj) libsvm_options_3channel{jj} ...
            ':  mse is ' num2str(mse_SVR_3channel(jj,ii)) '   time cost is ' num2str(t_SVR_3channel(jj,ii))  '\n']);
    end     
    Itmp = reshape(ImgRecoveryVecTmp,[height,width,3]);
    clear ImgRecoveryVecTmp
    ImgRecovery_SVR{ii} = Itmp;   
    clear Itmp

    % ND方法
    ImgRecoveryVecTmp = ImgRecoveryVec;
    for jj = 1:channel
        tic;
        predict_y_ND_3channel{jj,ii} = ND_func_mod(test_x_cell{jj,ii}, train_x_cell{jj,ii}, train_y_cell{jj,ii}, N_star_3channel_opt(jj), tau);
        t_ND_3channel(jj,ii) = toc;
        mse_ND_3channel(jj,ii) = mse(test_y_cell{jj,ii}-predict_y_ND_3channel{jj,ii});
        ImgRecoveryVecTmp(test_ind_cell{jj,ii}) = predict_y_ND_3channel{jj,ii};
        fprintf(['Ex' num2str(ii) '--ND  N_star#' num2str(N_star_3channel_opt(jj)) ': mse is ' num2str(mse_ND_3channel(jj,ii)) ...
        '   time cost is ' num2str(t_ND_3channel(jj,ii)) '\n']);  
    end 
    Itmp = reshape(ImgRecoveryVecTmp,[height,width,3]);
    clear ImgRecoveryVecTmp
    ImgRecovery_ND{ii} = Itmp;   
    clear Itmp
    
    save([cd '\results\RadarResults\Contrast_RiverIce20200513_013745_MissValColor_200x150_Numerical.mat'],...
            'BPMethodCross', 'nBP_3channel_opt', 'epochsBP_3channel_opt', 'SVR_eps_3channel_opt',...
            'SVR_gamma_3channel_opt', 'SVR_C_3channel_opt', 'libsvm_options_3channel', 'tau',...
            'N_star_3channel_opt', 'ExNum','c', 't_BP_3channel', 'mse_BP_3channel', 'predict_y_BP_3channel',...
            'ImgRecovery_BP', 't_SVR_3channel', 'mse_SVR_3channel',...
            'predict_y_SVR_3channel', 'ImgRecovery_SVR','t_ND_3channel','mse_ND_3channel',... 
            'predict_y_ND_3channel', 'ImgRecovery_ND', 'I_400x300_normal', 'I_200x150_normal',...
            'train_x_cell', 'train_y_cell', 'test_x_cell', 'test_y_cell',...
            'all_x_3channel', 'all_y_3channel', 'train_ind_cell', 'test_ind_cell' );       
end  
