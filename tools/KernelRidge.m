function hat_y = KernelRidge(in_data,out_data,test_data,lambda, KerPara)
%
% This function performs the kernel ridge regression using the Gaussian Kernel. 
%
% in_data - Input to the functio to be regressed.  N (points) x D (dimensional)
% out_data - Ouput of the function to be regressed. N x 1 (points)
% test_data - Input of testing set. n (points) x D (dimensions) 
% lamda - Regularization Parameter. (Carefully choose this)
% hat_y - Output for the testing set test_data (those that were not in training) n x 1 (points)  

% 如果lambda输入是一个向量，即表示要计算lambda的参数选择

if nargin < 4
    lambda = 1; % 
end
if nargin < 5
    KerPara.Type = 4;
    KerPara.para = 1;
end

lambdaNum = length(lambda);
hat_y = zeros(size(test_data,1),lambdaNum);

if size(in_data,1) ~= size(out_data,1)
    fprintf('\nTotal number of points for function input and output are unequal');
    fprintf('\n Exitting program');
    return
elseif size(test_data,2) ~= size(in_data,2)
    fprintf('\nTest data and Input data are of unequal dimensions');
    fprintf('\nExitting program')
    return
else    
    N = size(in_data,1);
    %% Compute K(x,x') on training set  
    Ktr = KernelComputation(in_data, in_data, KerPara);
    Ktr = (Ktr+Ktr')/2;
    %% Compute K(x, x') on training and testing set
    Ktetr = KernelComputation(test_data,in_data, KerPara);
    %% Compute the coefficients alpha and the estimated values hat_y
    % 运用-1次方的形式较快
    for k = 1:lambdaNum
        lambdac = lambda(k);
        hat_y(:,k) = Ktetr*((Ktr + lambdac*eye(N)*N)^(-1)*out_data); 
    end 
    % 运用SVD分解的方式似乎比较慢
%     [U, S] = svd(Ktr,'econ'); % Ktr = U*S*U'
%     diagS = diag(S);
%     for k = 1:lambdaNum
%         lambdac = lambda(k);
%         KlambdaInv = U*diag(1./(diagS+N*lambdac))*U';
%         alpha = KlambdaInv*out_data;
%         %% Compute hat_y
%         hat_y(:,k) = Ktetr*alpha;
%     end
end

