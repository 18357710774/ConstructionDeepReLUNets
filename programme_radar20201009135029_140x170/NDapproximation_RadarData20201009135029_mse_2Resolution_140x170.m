clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));

if ~exist('results\RadarResults','dir')
	mkdir('results\RadarResults');
end

tau = 0.0001;
N_starCross = 2:2:300;
resolution = 2;
name = '20201009135029_mse';

load([cd '\RadarData\' name '.mat'], 'I_280x340_normal', 'I_140x170_normal');
[height, width] = size(I_140x170_normal);

 % Generating Train Set
x1 = (1/(2*width)):(1/width):1;
x2 = (1/(2*height)):(1/height):1;
[xx1, xx2] = meshgrid(x1, x2);
train_x = [xx1(:) xx2(:)];
train_y = I_140x170_normal(:);

% Generating Test Set
y1 = (1/(4*width)):(1/(2*width)):1;
y2 = (1/(4*height)):(1/(2*height)):1;
[yy1, yy2] = meshgrid(y1, y2);
test_x = [yy1(:) yy2(:)];
GridNum_test_height = 2*height;
GridNum_test_width = 2*width;
test_y = I_280x340_normal(:);

mse_ND = zeros(1, length(N_starCross));
t_ND = zeros(1, length(N_starCross));

uu = 0;
for N_star = N_starCross
    uu = uu+1;
    tic;
    hat_y = ND_func_mod(test_x, train_x, train_y, N_star, tau);
    t_ND(:, uu) = toc;
    mse_ND(:, uu) = mse(test_y-hat_y);
    
    I = uint8(reshape(hat_y,GridNum_test_height,GridNum_test_width)*255);
    imwrite(I,[cd '\results\RadarResults\ND_' name '_resolution' num2str(resolution) '_N_star' num2str(N_star) '.png'],'png')
%     figure(1);
%     imshow(I)
%     saveas(1, [cd '\results\RadarResults\ND_' name '_resolution' num2str(resolution) '_N_star' num2str(N_star) '.fig'])
%     close;
    fprintf(['N_star#' num2str(N_star)  ': mse is ' num2str(mse_ND(1,uu)) ...
        '   time cost is ' num2str(t_ND(1,uu)) '\n']); 
end
save([cd '\results\RadarResults\ND_' name '_resolution' num2str(resolution) '.mat'], ...
       'GridNum_test_height','GridNum_test_width', 'mse_ND', 't_ND', 'N_starCross', 'tau');