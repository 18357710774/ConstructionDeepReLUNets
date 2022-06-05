function Xi = Center_func(d, N)
% Xi: N^d*d matrix, in which each row represents a coordinate of a center of sub-cubes

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

