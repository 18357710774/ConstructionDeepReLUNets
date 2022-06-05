function [Xi, B, B_wave] = CenterBound_func(d, N, tau)
% Xi: N^d*d matrix, in which each row represents a coordinate of a center of sub-cubes
% B.upBound: N^d*d matrix, in which each row represents the upper bounds of the corresponding sub-cube
% B.lowBound: N^d*d matrix, in which each row represents the lower bounds of the corresponding sub-cube
% B_wave.upBound: N^d*d matrix, in which each row represents the extended upper bounds of the corresponding sub-cube
% B_wave.lowBound: N^d*d matrix, in which each row represents the extended lower bounds of the corresponding sub-cube

epsilon = 1e-15;  % 引入epsilon的目的是，在进行上下界的数值计算时会有大约1e-16级别的误差，
                  % 因此会出现类似当B_wave.upBound(k,j)的理论值是0.9时，0.9<=B_wave.upBound(k,j)
                  % 为false的情况，这是因为在计算时B_wave.upBound(k,j)有大约1e-16级别的精度误差。

a = 1/(2*N);
b = 1/N;
BlocksNum = N^d;
if BlocksNum > 1e10
    fprintf('caution: too large number of blocks');
    return;
end
Xi = zeros(BlocksNum, d);
x = a:b:1;
x = x';
for k = 1:d
    Xi(:,k) = repmat(kron(x, ones(N^(d-k),1)), N^(k-1), 1);
end

B.upBound = Xi+a+epsilon;
B.lowBound = Xi-a-epsilon;

B_wave.upBound = min(Xi+a+tau, 1)+epsilon;
B_wave.lowBound = max(Xi-a-tau, 0)-epsilon;
