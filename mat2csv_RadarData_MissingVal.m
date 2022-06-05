ExNum = 20;
c = 0.8;

% name = '20201009135112_mse';
% load([cd '\RadarData\' name '.mat'], 'I_334x450_normal', 'I_167x225_normal');
% [height, width] = size(I_167x225_normal);

name = '20201009135029_mse';
load([cd '\RadarData\' name '.mat'], 'I_280x340_normal', 'I_140x170_normal');
[height, width] = size(I_140x170_normal);

% name = '20201010101543_mse';
% load([cd '\RadarData\' name '.mat'], 'I_460x500_normal', 'I_230x250_normal');
% [height, width] = size(I_230x250_normal);

% Generate All samples
x1 = (1/(2*width)):(1/width):1;
x2 = (1/(2*height)):(1/height):1;
[xx1, xx2] = meshgrid(x1, x2);
all_x = [xx1(:) xx2(:)];

% all_y = I_167x225_normal(:);
all_y = I_140x170_normal(:);
% all_y = I_230x250_normal(:);

N_samples = length(all_y);
Ntr = ceil(N_samples*c);

for i = 1:ExNum
    rng(i);
    ind_rand = randperm(N_samples);
    train_ind = ind_rand(1:Ntr);
    test_ind = ind_rand(Ntr+1:end);

    % Generate training samples
    train_x = all_x(train_ind, :);
    train_y = all_y(train_ind, :);

    % Generating Test Set
    test_x = all_x(test_ind, :);
    test_y = all_y(test_ind, :);
    

    dataPath = [cd '\RadarData\'];

    path1 = [dataPath 'train_x' num2str(i) '.csv'];
    csvwrite(path1, train_x)

    path2 = [dataPath 'train_y' num2str(i) '.csv'];
    csvwrite(path2, train_y)

    path3 = [dataPath 'test_x' num2str(i) '.csv'];
    csvwrite(path3, test_x)

    path4 = [dataPath 'test_y' num2str(i) '.csv'];
    csvwrite(path4, test_y)
end