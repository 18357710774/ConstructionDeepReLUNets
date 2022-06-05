clear;
clc;

cd('..');  % 返回本文件所在路径的上级目录
addpath(genpath('tools'));

N = 8;
d = 2;
tauCross = [0.2 0.1 0.05 0.01 0.005 0.001];
N1 = 256;

xData = Center_func(d, N1);
xik = [9/16, 7/16];

for tau = tauCross
    figure;
    N1_value = N1_func(xData, xik, N, tau);
    N1_value1 = reshape(N1_value, N1, N1);
    N1_value2 = N1_value1(end:-1:1,:);
    imagesc(N1_value2);
end
