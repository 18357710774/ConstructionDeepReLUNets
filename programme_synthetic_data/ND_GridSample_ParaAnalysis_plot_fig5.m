clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录


% load([cd '\results\simulation3\NDRandomSamplesParaAnalysisEx20m40000.mat']);
% load([cd '\results\simulation3\NDRandomSamplesParaAnalysisEx20m250000.mat']);
% load([cd '\results\simulation3\NDRandomSamplesParaAnalysisEx20m1000000.mat']);
% load([cd '\results\simulation3\NDRandomSamplesHnoiseParaAnalysisEx20m40000.mat']);
% load([cd '\results\simulation3\NDRandomSamplesHnoiseParaAnalysisEx20m250000.mat']);
load([cd '\simulation3\NDRandomSamplesHnoiseParaAnalysisEx20m1000000.mat']);


tauCross = [0.0001 0.0005 0.001 0.005 0.01 0.05 0.1];
tauIndSel = 1:7; 

N_starCross = 5:5:200;
A = colormap(jet(length(tauIndSel)));

for i = 1:length(tauIndSel)
    plot(N_starCross, mse_ND_mean(tauIndSel(i),:), 'Color', A(i,:), 'Linewidth', 2);
    hold on;
end

legendstr = cell(1, length(tauIndSel));
for i = 1:length(tauIndSel)
    legendstr{i} = ['\tau = ' num2str(tauCross(tauIndSel(i)))];
end
legend(legendstr)