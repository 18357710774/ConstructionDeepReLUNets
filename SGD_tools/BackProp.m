% back propagation for neural network training
% Edited by Jinshan Zeng (Jiangxi Normal University, Email:jsh.zeng@gmail.com)
% Date: June 03, 2019
function [dW,db] = BackProp(X,Y,W,b,L,loss_type,act_type)
% X -- input of training data (d1*N, N: number of samples; d0: input dimension)
% Y -- output of training data (dL*N, N: number of samples; dL: output dimension)
% W -- current update of weights (W.W(i): weight matrix of the i-th layer)
% b -- current update of bias vectors (b.b(i): bias vector of the i-th layer)
% loss_type -- loss function, 1: square; 2: cross-entropy; 3: logistic
% act_type -- activation function, 1:sigmoid; 2: ReLU
% L -- number of layers (including L-2 hidden layers)

% forward propagation
n = size(X,2); % sample size
a(1).a = X;
for i=1:L-2
   Z(i).Z = W(i).W * a(i).a + repmat(b(i).b,1,n);
   a(i+1).a = act_fun(Z(i).Z,act_type);
end
Z(L-1).Z = W(L-1).W * a(L-1).a + repmat(b(L-1).b,1,n); % use linear activation at the last layer

% error backward propagation
%delta(L-1).delta = loss_Grad(a(L).a,Y,loss_type).*act_fun_Grad(Z(L-1).Z,act_type);
delta(L-1).delta = loss_Grad(Z(L-1).Z,Y,loss_type); % using linear activation at the last layer
for j=L-2:-1:1
    delta(j).delta = ((W(j+1).W).'*(delta(j+1).delta)).*act_fun_Grad(Z(j).Z,act_type);  
end

for k=1:L-1
   dW(k).dW = (delta(k).delta)*(a(k).a)';
   db(k).db = sum(delta(k).delta,2);
end
end


% gradient of loss function
function f = loss_Grad(a,y,loss_type)
% a -- output of the final layer
% y -- output of data
% loss_type -- loss function, 1: square; 2: cross entropy

switch loss_type
    case 1 % square
        f = a - y;
    case 2 % cross entropy
        n = size(y,1); % number of samples
        f = (y./a - (1-y)./(1-a))./n;        
end

end
 
