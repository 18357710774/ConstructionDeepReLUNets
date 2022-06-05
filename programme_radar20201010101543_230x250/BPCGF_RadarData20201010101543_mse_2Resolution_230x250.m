clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));
if ~exist('results\RadarResults','dir')
	mkdir('results\RadarResults');
end

method = 'traincgf';
nBP_Cross = 10:10:200;
epoches_Cross = 1000:1000:5000;
resolution = 2;
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

t_BPCGF = zeros(1, length(nBP_Cross)*length(epoches_Cross));
mse_BPCGF = zeros(1, length(nBP_Cross)*length(epoches_Cross));
para = zeros(2, length(nBP_Cross)*length(epoches_Cross));

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
        t_BPCGF(:, uu) = toc;

        predict_y = sim(net,test_x');
        mse_BPCGF(:, uu) = mse(test_y'-predict_y);

        fprintf([method '-- nBP ' num2str(nBP) ' epoch ' num2str(epochs)...
           ': mse is ' num2str(mse_BPCGF(:,uu)) ...
            '   time cost is ' num2str(t_BPCGF(:,uu)) '\n']);   
    end
end
save([cd '\results\RadarResults\BPCGF_' name '_230x250_Res' num2str(resolution) '.mat'],...
    'GridNum_test_height','GridNum_test_width', 't_BPCGF', 'mse_BPCGF', 'epoches_Cross', 'nBP_Cross', 'para');