% Stochastic backpropagation for deep neural network training
% Edited by Jinshan Zeng (Jiangxi Normal University, Email: jsh.zeng@gmail.com)
function [W,b,Error_tr,Error_te,Grad_norm,t_tr,out_te] ...
    = StochBackProp(Xtr,Ytr,Xte,Yte,W,b,L,loss_type,act_type,BatchSize,NumEpoch,lr)
% Input:
% Xtr -- input of training data (d1*Ntr, Ntr: number of training samples; d0: input dimension)
% Ytr -- output of training data (dL*Ntr, Ntr: number of training samples; dL: output dimension)
% Xte -- input of testing data (d1*Ntr, Ntr: number of testing samples; d0: input dimension)
% Yte -- output of testing data (dL*Ntr, Ntr: number of testing samples; dL: output dimension)
% W -- current update of weights (W.W(i): weight matrix of the i-th layer)
% b -- current update of bias vectors (b.b(i): bias vector of the i-th layer)
% loss_type -- loss function, 1: square; 2: cross-entropy; 3: logistic
% act_type -- activation function, 1:sigmoid; 2: ReLU; 3: leaky ReLU
% L -- number of layers (including L-2 hidden layers)
% BatchSize -- minibatch size
% NumEpoch -- number of epochs
% lr -- learning rate

% Output:
% W -- weight matrix after training
% b -- bias vectors after training
% Error_tr -- mean square error of training
% Error_te -- mean square error of testing
% Grad_norm -- norm of gradient for each layer

n = size(Xtr,2); % sample size
Error_tr = zeros(NumEpoch,1);
Error_te = zeros(NumEpoch,1);
Grad_norm = zeros(NumEpoch,L-1);
inner_iter = floor(n/BatchSize); % number of inner iteration
t_tr = zeros(NumEpoch,1);

for k=1:NumEpoch
    out_tr = NN_output(Xtr,W,b,L,act_type); % calculate the output of neural networks model    
%     Error_tr(k) = norm(Ytr-out_tr); % record the training mse
    Error_tr(k) = sqrt(mse(Ytr-out_tr)); % record the training rmse
    
    out_te = NN_output(Xte,W,b,L,act_type); % calculate the output of neural networks model
%     Error_te(k) = norm(Yte-out_te); % record the training mse
    Error_te(k) = sqrt(mse(Yte-out_te)); % record the test rmse
    
    tic;
    for i=1:inner_iter
%         tempIndex = randperm(n);
%         x = Xtr(:,tempIndex(1:BatchSize));
%         y = Ytr(:,tempIndex(1:BatchSize));

        x = Xtr(:,(i-1)*BatchSize+1:i*BatchSize);
        y = Ytr(:,(i-1)*BatchSize+1:i*BatchSize);
        
        [dW,db] = BackProp(x,y,W,b,L,loss_type,act_type);
        
        % update weight and bias
        for layer=1:L-1
            W(layer).W = W(layer).W - lr(k)/n*dW(layer).dW;
            b(layer).b = b(layer).b - lr(k)/n*db(layer).db;
        end
    end
    
    % norm of gradient for each layer
    for layer=1:L-1
        Grad_norm(k,layer) = sqrt(sum(sum((dW(layer).dW).^2,1),2)+sum((db(layer).db).^2));        
    end
    t_tr(k) = toc;
    if mod(k,100) == 0
        disp(['eprochs = ' num2str(k) '    Error_te = ' num2str(Error_te(k))])
    end
end
t_tr = cumsum(t_tr);