%% Generating Data
clear;
clc;
addpath(genpath('tools'));

% f函数的相关参数值
r = 1;
N = 10;
s = 4;
d = 2;
ExNum = 20;

% GridNum_train = 500;
% GridNum_test = 100;

% GridNum_train = 1000;
% GridNum_test = 100;

GridNum_train = 2000;
GridNum_test = 100;


x1 = (1/GridNum_train):(1/GridNum_train):1;
x2 = x1;
[xx1, xx2] = meshgrid(x1, x2);
train_x = [xx1(:) xx2(:)];

m = size(train_x,1);
U = ceil((m*s/(N^d))^(1/(2*r+d))); 

train_x_cell = cell(1,ExNum);
train_y_cell = cell(1,ExNum);
test_x_cell = cell(1,ExNum);
test_y_cell = cell(1,ExNum);

vv = 0;
for Ex = 1:ExNum
    vv = vv+1;
    rng(Ex);
    IndRand = randperm(N^d);
    Ind_S = IndRand(1:s);
    RadeRV = RademacherRandomVariable(U^d);

    train_x_cell{vv} = train_x;
    train_y = f_func(train_x, N, Ind_S, RadeRV);
    e = 1/10*max(abs(train_y))*randn(m,1);
    train_y = train_y+e;
    train_y_cell{vv} = train_y;

    % Generating Test Set
    y1 = (0.5/GridNum_train):(1/GridNum_test):1;
    y2 = y1;
    [yy1, yy2] = meshgrid(y1, y2);
    test_x = [yy1(:) yy2(:)];
    test_x_cell{vv} = test_x;
    test_y = f_func(test_x, N, Ind_S, RadeRV);
    test_y_cell{vv} = test_y;
 
end