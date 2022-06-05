clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));

name = '20201009135112_167x225';
load([cd '\results\RadarResults\Contrast_RadarData20201009135112_MissingVal_167x225_Numerical.mat'])
load([cd '\results\RadarResults\ImgRecovery_Ada_167x225.mat'])
[m, n] = size(I_167x225_normal);

% %% ------------对存在负像素的结果做归一化处理--------------------------
% % -----------BP methods---------------
% BPMethodCross = {'traingdx','trainrp','traincgf','traincgb',...
%                  'trainscg','trainbfg','trainoss','trainlm'};
% 
% SelExInd = 8; 
% for i = 1:8
%     method = BPMethodCross{i};
%     Itmp = ImgRecovery_BP{SelExInd,i};  
%     figure(1);
%     if min(min(Itmp)) < 0
%         I = ImgStandard(Itmp);
%         imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
%     else
%         I = Itmp;
%         imshow(I,[],'DisplayRange',[0 max(max(I))],'Border','tight')
%     end 
%     saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_' method '.fig'])
%     close;
% end
% 
% % -----------SVR method----------------
% Itmp = ImgRecovery_SVR{SelExInd};   
% figure(1);
% if min(min(Itmp)) < 0
%     I = ImgStandard(Itmp);
%     imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
% else
%     I = Itmp;
%     imshow(I,[],'DisplayRange',[0 max(max(I))],'Border','tight')
% end 
% saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_SVR.fig'])
% close;
% 
% % ----------ND method--------------------
% Itmp = ImgRecovery_ND{SelExInd};  
% figure(1);
% if min(min(Itmp)) < 0
%     I = ImgStandard(Itmp);
%     imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
% else
%     I = Itmp;
%     imshow(I,[],'DisplayRange',[0 max(max(I))],'Border','tight')
% end 
% saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_ND.fig'])
% close;
% 
% % % ---------Adaboost----------------------
% Itmp = ImgRecovery_Ada;    
% figure(1);
% if min(min(Itmp)) < 0
%     I = ImgStandard(Itmp);
%     imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
% else
%     I = Itmp;
%     imshow(I,[],'DisplayRange',[0 max(max(I))],'Border','tight')
% end 
% saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_Adaboost.fig'])
% close;
% 
% % % ---------GroundTruth------------------
% % tmp = test_y;
% % Itmp = reshape(tmp,m,n);    
% % I = ImgStandard(Itmp);
% % figure(1);
% % imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
% % saveas(1, [cd '\results\RadarResults\figs\' name '_Groudtruth.fig'])
% % imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_Groudtruth.png'])
% % close;
% 
% % ---------TrainImage------------------
% tmp = zeros(m, n);
% tmp(train_ind_cell{SelExInd}) = train_y_cell{SelExInd};
% Itmp = reshape(tmp,m,n);    
% figure(1);
% if min(min(Itmp)) < 0
%     I = ImgStandard(Itmp);
%     imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
% else
%     I = Itmp;
%     imshow(I,[],'DisplayRange',[0 max(max(I))],'Border','tight')
% end
% saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_TrainImg.fig'])
% close;

%% ------------对存在负像素的结果做归零处理--------------------------

% -----------BP methods---------------
BPMethodCross = {'traingdx','trainrp','traincgf','traincgb',...
                 'trainscg','trainbfg','trainoss','trainlm'};

SelExInd = 8; 
for i = 1:8
    method = BPMethodCross{i};
    Itmp = ImgRecovery_BP{SelExInd,i};  
    figure(1);    
    I = Itmp;
    I(I<0) = 0;
    imshow(I,[],'DisplayRange',[0 max(max(I))],'Border','tight')
    saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_' method '.fig'])
    close;
end

% -----------SVR method----------------
Itmp = ImgRecovery_SVR{SelExInd};   
figure(1);    
I = Itmp;
I(I<0) = 0;
imshow(I,[],'DisplayRange',[0 max(max(I))],'Border','tight') 
saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_SVR.fig'])
close;

% ----------ND method--------------------
Itmp = ImgRecovery_ND{SelExInd};  
figure(1);    
I = Itmp;
I(I<0) = 0;
imshow(I,[],'DisplayRange',[0 max(max(I))],'Border','tight') 
saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_ND.fig'])
close;

% % ---------Adaboost----------------------
Itmp = ImgRecovery_Ada;    
figure(1);    
I = Itmp;
I(I<0) = 0;
imshow(I,[],'DisplayRange',[0 max(max(I))],'Border','tight')
saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_Adaboost.fig'])
close;

% % ---------GroundTruth------------------
% tmp = test_y;
% Itmp = reshape(tmp,m,n);    
% I = ImgStandard(Itmp);
% figure(1);
% imshow(uint8(I),[],'DisplayRange',[0 max(max(I))],'Border','tight')
% saveas(1, [cd '\results\RadarResults\figs\' name '_Groudtruth.fig'])
% imwrite(uint8(I), [cd '\results\RadarResults\figs\' name '_Groudtruth.png'])
% close;

% ---------TrainImage------------------
tmp = zeros(m, n);
tmp(train_ind_cell{SelExInd}) = train_y_cell{SelExInd};
Itmp = reshape(tmp,m,n);    
figure(1);    
I = Itmp;
I(I<0) = 0;
imshow(I,[],'DisplayRange',[0 max(max(I))],'Border','tight')
saveas(1, [cd '\results\RadarResults\figs\' name '_MissVal_TrainImg.fig'])
close;