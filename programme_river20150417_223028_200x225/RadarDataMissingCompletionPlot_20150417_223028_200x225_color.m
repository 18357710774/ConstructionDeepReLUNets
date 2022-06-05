clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));

name = '20150417_223028_200x225_color';
load([cd '\results\RadarResults\Contrast_RiverIce20150417_223028_MissValColor_200x225_Numerical.mat'])
load([cd '\results\RadarResults\ImgRecovery_Ada_200x225x3.mat'])
[m, n, channel] = size(I_200x225_normal);

%% ------------对存在负像素的结果做归一化处理--------------------------
% % -----------BP methods---------------
% BPMethodCross = {'traingdx','trainrp','traincgf','traincgb',...
%                  'trainscg','trainbfg','trainoss','trainlm'};
% 
% SelExInd = 10; 
% for i = 1:8
%     method = BPMethodCross{i};
%     Itmp = ImgRecovery_BP{SelExInd,i};  
%     figure(1);
%     if min(min(min(Itmp))) < 0
%         I = ImgStandard_3channel(Itmp);
%         imshow(uint8(I),[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
%     else
%         I = Itmp;
%         imshow(I,[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
%     end  
%     saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_' method '.fig'])
%     close;
% end
% 
% % -----------SVR method----------------
% Itmp = ImgRecovery_SVR{SelExInd};   
% figure(1);
% if min(min(min(Itmp))) < 0
%     I = ImgStandard_3channel(Itmp);
%     imshow(uint8(I),[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
% else
%     I = Itmp;
%     imshow(I,[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
% end  
% saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_SVR.fig'])
% close;
% 
% % ----------ND method--------------------
% Itmp = ImgRecovery_ND{SelExInd};  
% figure(1);
% if min(min(min(Itmp))) < 0
%     I = ImgStandard_3channel(Itmp);
%     imshow(uint8(I),[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
% else
%     I = Itmp;
%     imshow(I,[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
% end
% saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_ND.fig'])
% close;
% 
% % % ---------Adaboost----------------------
% Itmp = ImgRecovery_Ada;    
% figure(1);
% if min(min(min(Itmp))) < 0
%     I = ImgStandard_3channel(Itmp);
%     imshow(uint8(I),[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
% else
%     I = Itmp;
%     imshow(I,[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
% end
% saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_Adaboost.fig'])
% close;
% 
% % ---------GroundTruth------------------
% tmp = test_y;
% Itmp = reshape(tmp,m,n);    
% I = ImgStandard(Itmp);
% figure(1);
% imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
% saveas(1, [cd '\results\RadarResults\figs\' name '_Groudtruth.fig'])
% imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_Groudtruth.png'])
% close;
% 
% % ---------TrainImage------------------
% tmp = zeros(m*n*channel,1);
% for ii = 1:channel
%     tmp(train_ind_cell{ii, SelExInd}) = train_y_cell{ii, SelExInd};
% end
% Itmp = reshape(tmp,m,n,channel);    
% figure(1);
% if min(min(min(Itmp))) < 0
%     I = ImgStandard_3channel(Itmp);
%     imshow(uint8(I),[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
% else
%     I = Itmp;
%     imshow(I,[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
% end
% saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_TrainImg.fig'])
% close;


%% ------------对存在负像素的结果做归零处理--------------------------
% -----------BP methods---------------
BPMethodCross = {'traingdx','trainrp','traincgf','traincgb',...
                 'trainscg','trainbfg','trainoss','trainlm'};

SelExInd = 10; 
for i = 1:8
    method = BPMethodCross{i};
    Itmp = ImgRecovery_BP{SelExInd,i};  
    figure(1);    
    I = Itmp;
    I(I<0) = 0;
    imshow(I,[],'DisplayRange',[0 max(max(max(I)))],'Border','tight')
    saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_' method '.fig'])
    close;
end

% -----------SVR method----------------
Itmp = ImgRecovery_SVR{SelExInd};   
figure(1);    
I = Itmp;
I(I<0) = 0;
imshow(I,[],'DisplayRange',[0 max(max(max(I)))],'Border','tight') 
saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_SVR.fig'])
close;

% ----------ND method--------------------
Itmp = ImgRecovery_ND{SelExInd};  
figure(1);    
I = Itmp;
I(I<0) = 0;
imshow(I,[],'DisplayRange',[0 max(max(max(I)))],'Border','tight') 
saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_ND.fig'])
close;

% % ---------Adaboost----------------------
Itmp = ImgRecovery_Ada;    
figure(1);    
I = Itmp;
I(I<0) = 0;
imshow(I,[],'DisplayRange',[0 max(max(max(I)))],'Border','tight') 
saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_Adaboost.fig'])
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
tmp = zeros(m*n*channel,1);
for ii = 1:channel
    tmp(train_ind_cell{ii, SelExInd}) = train_y_cell{ii, SelExInd};
end
Itmp = reshape(tmp,m,n,channel);    
figure(1);    
I = Itmp;
I(I<0) = 0;
imshow(I,[],'DisplayRange',[0 max(max(max(I)))],'Border','tight') 
saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_TrainImg.fig'])
close;