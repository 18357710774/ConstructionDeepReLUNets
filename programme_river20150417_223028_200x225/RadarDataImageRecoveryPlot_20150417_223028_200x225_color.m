clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));

name = '20150417_223028_200x225_color';

load([cd '\results\RadarResults\Contrast_RiverIce20150417_223028_2ResColor_200x225_Numerical.mat'])
load([cd '\results\RadarResults\Adaboost_Yhat_20150417_223028_200x225_Color.mat'])
[m, n, channel] = size(I_400x450_normal);


% -----------BP methods---------------
BPMethodCross = {'traingdm','traingda','traingdx',...
                'trainrp','traincgf','traincgp','traincgb',...
                'trainscg','trainbfg','trainoss','trainlm'};

for i = 1:11
    method = BPMethodCross{i};   
    I = ImgStandard_3channel(predict_yTensor_BP_3channel{i});
    figure(2);
    imshow(uint8(I),[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
    saveas(2, [cd '\results\RadarResults\figs\' name '_' method '.fig'])
    imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_' method '.png'])    
    close;
end

% -----------SVR method---------------- 
I = ImgStandard_3channel(predict_yTenosr_SVR_3channel);
figure(1);
imshow(uint8(I),[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
saveas(1, [cd '\results\RadarResults\figs\' name '_SVR.fig'])
imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_SVR.png'])
close;

% ----------ND method-------------------- 
I = ImgStandard_3channel(predict_yTensor_ND_3channel);
figure(1);
imshow(uint8(I),[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
saveas(1, [cd '\results\RadarResults\figs\' name '_ND.fig'])
imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_ND.png'])
close;

% ---------Adaboost----------------------
tmp = Yhat_3channel;
Itmp = zeros(m, n, channel);
for i = 1:channel
    Itmp(:,:,i) = reshape(tmp(:,i),m,n); 
end
I = ImgStandard_3channel(Itmp);
figure(1);
imshow(uint8(I),[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
saveas(1, [cd '\results\RadarResults\figs\' name '_Adaboost.fig'])
imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_Adaboost.png'])
close;

% ---------GroundTruth------------------
test_y_Tensor_3channel = zeros(m, n, channel);
for j = 1:channel
    tmp = test_y{j};
    Itmp = reshape(tmp,m,n); 
    test_y_Tensor_3channel(:,:,j) = Itmp;
end
I = ImgStandard_3channel(test_y_Tensor_3channel);
figure(1);
imshow(uint8(I),[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
saveas(1, [cd '\results\RadarResults\figs\' name '_Groudtruth.fig'])
imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_Groudtruth.png'])
close;
    
   
% ---------TrainImage------------------
train_y_Tensor_3channel = zeros(m/2, n/2, channel);
for j = 1:channel
    tmp = train_y{j};
    Itmp = reshape(tmp,m/2,n/2); 
    train_y_Tensor_3channel(:,:,j) = Itmp;
end
I = ImgStandard_3channel(train_y_Tensor_3channel);
figure(1);
imshow(uint8(I),[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
saveas(1, [cd '\results\RadarResults\figs\' name '_TrainImg.fig'])
imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_TrainImg.png'])
close;