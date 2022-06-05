clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));
if ~exist('results\RadarResults','dir')
	mkdir('results\RadarResults');
end

method = 'trainoss';
nBP_Cross = 10:10:130;
epoches_Cross = 1000:1000:5000;
resolution = 2;
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

t_BPOSS_3channel = zeros(channel, length(nBP_Cross)*length(epoches_Cross));
mse_BPOSS_3channel = zeros(channel, length(nBP_Cross)*length(epoches_Cross));

mse_BPOSS_all = zeros(1, length(nBP_Cross)*length(epoches_Cross));
t_BPOSS_all = zeros(1, length(nBP_Cross)*length(epoches_Cross));

para = zeros(2, length(nBP_Cross)*length(epoches_Cross));

uu = 0;
for nBP = nBP_Cross
    for epochs = epoches_Cross
        uu = uu+1;
        para(:,uu) = [nBP; epochs];
        I = zeros(size(I_400x450_normal));
        hat_y = cell(1,channel);
        for ii = 1:channel
            tic;
            net = newff(train_x',train_y{ii}',nBP,{'tansig', 'purelin'}, method); 
            net.trainParam.goal = 1e-5;
            net.trainParam.epochs = epochs;
            net.trainParam.lr = 0.05;
            net.trainParam.showWindow = false;
            net.divideFcn = '';
            net = train(net,train_x',train_y{ii}');
            t_BPOSS_3channel(ii, uu) = toc;

            hat_y{ii} = sim(net,test_x');
            mse_BPOSS_3channel(ii, uu) = mse(test_y{ii}'-hat_y{ii});
            I(:,:,ii) = reshape(hat_y{ii},GridNum_test_height,GridNum_test_width);
        end
        t_BPOSS_all(:,uu) = sum(t_BPOSS_3channel(:, uu));
        hat_y_tmp = cell2mat(hat_y);
        hat_y_tmp = hat_y_tmp(:);
        test_y_tmp = cell2mat(test_y);
        test_y_tmp = test_y_tmp(:);
        mse_BPOSS_all(:,uu) = mse(hat_y_tmp-test_y_tmp);
        
        min_hat_y_tmp = min(hat_y_tmp);
        max_hat_y_tmp = max(hat_y_tmp);
        I = uint8(((I-min_hat_y_tmp)/max_hat_y_tmp) * 255);
        
        imwrite(I,[cd '\results\RadarResults\BPOSS_' name '_200x225_2ResColor_nBP ' num2str(nBP) 'epo' num2str(epochs) '.jpg'],'jpg')

        fprintf([method '-- nBP ' num2str(nBP) ' epoch ' num2str(epochs)...
           ': mse is ' num2str(mse_BPOSS_all(:,uu)) ...
            '   time cost is ' num2str(t_BPOSS_all(:,uu)) '\n']);   
    end
end
save([cd '\results\RadarResults\BPOSS_' name '_200x225_2ResColor_1.mat'],...
    'GridNum_test_height','GridNum_test_width', 't_BPOSS_all', 'mse_BPOSS_all',...
    'mse_BPOSS_3channel', 't_BPOSS_3channel', 'epoches_Cross', 'nBP_Cross',...
    'I_400x450_normal','I_200x225_normal', 'para');