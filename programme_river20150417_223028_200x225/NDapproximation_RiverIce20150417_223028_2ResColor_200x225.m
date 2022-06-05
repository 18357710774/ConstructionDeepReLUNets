clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));

if ~exist('results\RadarResults','dir')
	mkdir('results\RadarResults');
end

tau = 0.0001;

N_starCross = 5:5:400;
ExNum = 20;
resolution = 2;
name = 'RiverIce20150417_223028_color';

load([cd '\RadarData\' name '.mat'],'I_400x450_normal','I_200x225_normal');

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

mse_ND_3channel = zeros(channel, length(N_starCross));
t_ND_3channel = zeros(channel, length(N_starCross));

mse_ND_all = zeros(1, length(N_starCross));
t_ND_all = zeros(1, length(N_starCross));

uu = 0;
for N_star = N_starCross
    uu = uu+1;
    I = zeros(size(I_400x450_normal));
    hat_y = cell(1,channel);
    for ii = 1:channel
        tic;
        hat_y{ii} = ND_func_mod(test_x, train_x, train_y{ii}, N_star, tau);
        t_ND_3channel(ii, uu) = toc;
        mse_ND_3channel(ii, uu) = mse(test_y{ii}-hat_y{ii});
        I(:,:,ii) = reshape(hat_y{ii},GridNum_test_height,GridNum_test_width)*255;
    end
    I = uint8(I);
    t_ND_all(:,uu) = sum(t_ND_3channel(:, uu));
    mse_ND_all(:,uu) = mse(cell2mat(hat_y)-cell2mat(test_y));
    
    imwrite(I,[cd '\results\RadarResults\ND_' name '_resolution' num2str(resolution) '_N_star' num2str(N_star) '.jpg'],'jpg')
%     figure(1);
%     imshow(I)
%     saveas(1, [cd '\results\RadarResults\ND_' name '_resolution' num2str(resolution) '_N_star' num2str(N_star) '.fig'])
%     close;
    fprintf(['N_star#' num2str(N_star) ': mse is ' num2str(mse_ND_all(1,uu)) ...
        '   time cost is ' num2str(t_ND_all(1,uu)) '\n']); 
end
save([cd '\results\RadarResults\ND_' name '_resolution' num2str(resolution) '.mat'], ...
       'GridNum_test_height','GridNum_test_width', 'mse_ND_all', 't_ND_all', 'N_starCross',...
       'I_200x225_normal','I_400x450_normal', 'mse_ND_3channel', 't_ND_3channel', 'tau');