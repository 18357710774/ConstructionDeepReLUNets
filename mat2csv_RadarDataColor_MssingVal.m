ExNum = 20;
c = 0.8;

dataPath = [cd '\RadarData\'];

% name = 'RiverIce20150417_223028_color';
% load([cd '\RadarData\' name '.mat'], 'I_200x225_normal');
% [height, width, channel] = size(I_200x225_normal);

name = 'RiverIce20200513_013745_color';
load([cd '\RadarData\' name '.mat'], 'I_200x150_normal');
[height, width, channel] = size(I_200x150_normal);

% Generate All samples
x1 = (1/(2*width)):(1/width):1;
x2 = (1/(2*height)):(1/height):1;
[xx1, xx2] = meshgrid(x1, x2);
all_x = [xx1(:) xx2(:)];
all_x_3channel = repmat(all_x, 3, 1);

% all_y_3channel = I_200x225_normal(:);
all_y_3channel = I_200x150_normal(:);

N_samples = length(all_y_3channel);
Ntr = ceil(N_samples*c);

for i = 1:ExNum
    rng(i);
    ind_rand_3channel = randperm(N_samples);
    train_ind_3channel = ind_rand_3channel(1:Ntr);
    test_ind_3channel = ind_rand_3channel(Ntr+1:end);
    
    for j = 1:3
        begin_ind = (j-1)*height*width;
        end_ind = j*height*width;
        train_ind_channel_j = train_ind_3channel(train_ind_3channel>begin_ind & train_ind_3channel<=end_ind);
        test_ind_channel_j = test_ind_3channel(test_ind_3channel>begin_ind & test_ind_3channel<=end_ind);
        
        % Generate training samples
        train_x_channel_j = all_x_3channel(train_ind_channel_j, :);
        train_y_channel_j = all_y_3channel(train_ind_channel_j, :);

        % Generating Test Set
        test_x_channel_j = all_x_3channel(test_ind_channel_j, :);
        test_y_channel_j = all_y_3channel(test_ind_channel_j, :);
        
        path1 = [dataPath 'train_x' num2str(i) num2str(j) '.csv'];
        csvwrite(path1, train_x_channel_j)
        path2 = [dataPath 'train_y' num2str(i) num2str(j) '.csv'];
        csvwrite(path2, train_y_channel_j)
        path3 = [dataPath 'test_x'  num2str(i) num2str(j) '.csv'];
        csvwrite(path3, test_x_channel_j)
        path4 = [dataPath 'test_y'  num2str(i) num2str(j) '.csv'];
        csvwrite(path4, test_y_channel_j)
    end
end