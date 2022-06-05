function N1_value = N1_func(x, xi, N, tau)
% x: mxd matrix, and each row is a sample
% xi: a cube center
% N: side length of a cube is 1/N
[m, d] = size(x);
N1_value = zeros(m,1);
for k = 1:d
    a = xi(k)-1/(2*N);
    b = xi(k)+1/(2*N);
    N1_value = N1_value +  Ttauab_func(x(:,k), tau, a, b);
end
N1_value = N1_value-(d-1);
N1_value = pos(N1_value); 
N1_value(N1_value<1e-14) = 0;