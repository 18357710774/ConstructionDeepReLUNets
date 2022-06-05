clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));

name = '20201009135029_140x170';
load([cd '\results\RadarResults\Contrast_RadarData20201009135029_mse_2Res_140x170_Numerical.mat'])
load([cd '\results\RadarResults\Adaboost_Yhat_20201009135029_140x170.mat'])
[m, n] = size(I_280x340_normal);


% -----------BP methods---------------
BPMethodCross = {'traingdm','traingda','traingdx',...
                'trainrp','traincgf','traincgp','traincgb',...
                'trainscg','trainbfg','trainoss','trainlm'};

for i = 1:11
    method = BPMethodCross{i};
    tmp = predict_y_BP{i};
    Itmp = reshape(tmp,m,n);    
    I = ImgStandard(Itmp);
    figure(1);
    imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
    saveas(1, [cd '\results\RadarResults\figs\' name '_' method '.fig'])
    imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_' method '.png'])
    close;
end

% -----------SVR method----------------
tmp = predict_y_SVR;
Itmp = reshape(tmp,m,n);    
I = ImgStandard(Itmp);
figure(1);
imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
saveas(1, [cd '\results\RadarResults\figs\' name '_SVR.fig'])
imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_SVR.png'])
close;

% ----------ND method--------------------
tmp = predict_y_ND;
Itmp = reshape(tmp,m,n);    
I = ImgStandard(Itmp);
figure(1);
imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
saveas(1, [cd '\results\RadarResults\figs\' name '_ND.fig'])
imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_ND.png'])
close;

% ---------Adaboost----------------------
tmp = Yhat;
Itmp = reshape(tmp,m,n);    
I = ImgStandard(Itmp);
figure(1);
imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
saveas(1, [cd '\results\RadarResults\figs\' name '_Adaboost.fig'])
imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_Adaboost.png'])
close;

% ---------GroundTruth------------------
tmp = test_y;
Itmp = reshape(tmp,m,n);    
I = ImgStandard(Itmp);
figure(1);
imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
saveas(1, [cd '\results\RadarResults\figs\' name '_Groudtruth.fig'])
imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_Groudtruth.png'])
close;

% ---------TrainImage------------------
tmp = train_y;
Itmp = reshape(tmp,m/2,n/2);    
I = ImgStandard(Itmp);
figure(1);
imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
saveas(1, [cd '\results\RadarResults\figs\' name '_TrainImg.fig'])
imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_TrainImg.png'])
close;