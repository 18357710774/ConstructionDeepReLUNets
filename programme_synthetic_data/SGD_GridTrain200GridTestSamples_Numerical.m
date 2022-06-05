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

nBP_Cross = 10:10:100;
NumEpoch = 10000; 

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

mse_BPSGD = zeros(NumEpoch, length(nBP_Cross), ExNum);
t_BPSGD = zeros(NumEpoch, length(nBP_Cross), ExNum);
para = nBP_Cross;

% 关于随机梯度下降的参数设置
L = 3; % 层数
loss_type = 1; % loss function
act_type = 5; % 隐藏层运用tan-sigmoid激活函数
BatchSize = 50;
lr = 0.05;
stri = cell(1,L-1);
for ii = 1:L-2
    stri{ii} = 'tansig';
end
stri{L-1} = 'purelin';   

for Ex = 1:ExNum
    rng(Ex);
    IndRand = randperm(N^d);
    Ind_S = IndRand(1:s);
    RadeRV = RademacherRandomVariable(U^d);

    train_y = f_func(train_x, N, Ind_S, RadeRV);
    e = 1/10*max(abs(train_y))*randn(m_train,1);
    train_y = train_y+e;

    % Generating Test Set
    y1 = (0.5/GridNum_train):(1/GridNum_test):1;
    y2 = y1;
    [yy1, yy2] = meshgrid(y1, y2);
    test_x = [yy1(:) yy2(:)];
    test_y = f_func(test_x, N, Ind_S, RadeRV);
    
    uu = 0;
    for nBP = nBP_Cross
        uu = uu+1;

        net = newff(train_x',train_y',nBP*ones(1,L-2),stri); % 初始化神经网络 
        W(1).W = net.IW{1};
        b(1).b = net.b{1};
        for i = 2:L-1
            W(i).W = net.LW{i,i-1}; 
            b(i).b = net.b{i};  
        end
        lrvec = lr*ones(1,NumEpoch);
        [W, b, Error_tr, Error_te, Grad_norm, t_tr] = StochBackProp(train_x', train_y', test_x', test_y',...
                                            W, b, L, loss_type, act_type, BatchSize, NumEpoch, lrvec);

        mse_BPSGD(:,uu,Ex) = Error_te.^2;
        t_BPSGD(:,uu,Ex) = t_tr;
        fprintf(['Ex# ' num2str(Ex) '  nBP ' num2str(nBP) ...
            ':  mse_min = ' num2str(min(mse_BPSGD(:,uu,Ex))) '\n']);
    end 
    save([cd '\results\simulation3\BPBSGDridTrainGridTestSamplesNumericalEx' num2str(Ex) 'TrainNum' num2str(m_train) '.mat'],...
        'd','m_test','GridNum_test','Ind_S', 'IndRand', 'm_train','GridNum_train', 't_BPSGD', 'mse_BPSGD', 'NumEpoch', 'ExNum',...
        'nBP_Cross','r', 'RadeRV', 's', 'U', 'N', 'para');
end
