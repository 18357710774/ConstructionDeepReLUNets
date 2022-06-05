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

method = 'traincgp';
nBP_Cross = 10:10:200;
epoches_Cross = 1000:1000:5000;

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

t_BPCGP = zeros(ExNum, length(nBP_Cross)*length(epoches_Cross));
mse_BPCGP = zeros(ExNum, length(nBP_Cross)*length(epoches_Cross));
para = zeros(2, length(nBP_Cross)*length(epoches_Cross));

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
    for nBP = nBP_Cross
        for epochs = epoches_Cross
            uu = uu+1;
            para(:,uu) = [nBP; epochs];
            tic;
            net = newff(train_x',train_y',nBP,{'tansig', 'purelin'}, method); 
            net.trainParam.goal = 1e-5;
            net.trainParam.epochs = epochs;
            net.trainParam.lr = 0.05;
            net.trainParam.showWindow = false;
            net.divideFcn = '';
            net = train(net,train_x',train_y');
            t_BPCGP(vv, uu) = toc;

            predict_y = sim(net,test_x');
            mse_BPCGP(vv, uu) = mse(test_y'-predict_y);

            fprintf(['Ex#' num2str(Ex) 'nBP ' num2str(nBP) ' epoch ' num2str(epochs)...
               ': mse is ' num2str(mse_BPCGP(vv,uu)) ...
                '   time cost is ' num2str(t_BPCGP(vv,uu)) '\n']);   
        end
    end
    save([cd '\results\simulation3\BPCGPGridTrainGridTestSamplesHnoiseNumericalEx' num2str(Ex) 'TrainNum' num2str(m_train) '.mat'],...
        'd','m_test','GridNum_test','Ind_S', 'IndRand', 'm_train','GridNum_train', 'mse_BPCGP', 't_BPCGP', 'epoches_Cross', 'ExNum',...
        'nBP_Cross','r', 'RadeRV', 's', 'U', 'N', 'para');
end