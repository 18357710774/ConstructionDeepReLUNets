function N1_value = N1_func_multiCenter(x, xi, N, tau)
% x: mxd matrix, and each row is a sample
% xi: nxd matrix, and each row is a cube center
% N: side length of a cube is 1/N
[m, d] = size(x);
n = size(xi,1);
N1_value = zeros(m,n);
if m > n
    for i = 1:n
        for k = 1:d
            a = xi(i,k)-1/(2*N);
            b = xi(i,k)+1/(2*N);
            N1_value(:,i) = N1_value(:,i) +  Ttauab_func(x(:,k), tau, a, b);
        end
    end
else
    for j = 1:m
        for k = 1:d
            a = xi(:,k)-1/(2*N);
            b = xi(:,k)+1/(2*N);
            N1_value(j,:) = N1_value(j,:) +  (Ttauab_func(x(j,k), tau, a, b))';
        end
    end
end
N1_value = N1_value-(d-1);
N1_value = pos(N1_value); 
N1_value(N1_value<1e-14) = 0;