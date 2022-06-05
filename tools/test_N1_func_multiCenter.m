addpath(genpath('tools'));
N = 8;
d = 2;
tau = 0.05;
N1 = 256;

x = Center_func(d, N1);
xi = Center_func(d, N);

[m, d] = size(x);
n = size(xi,1);
N1_value1 = zeros(m,n);


for i = 1:n
    for k = 1:d
        a = xi(i,k)-1/(2*N);
        b = xi(i,k)+1/(2*N);
        N1_value1(:,i) = N1_value1(:,i) +  Ttauab_func(x(:,k), tau, a, b);
    end
end
N1_value1 = N1_value1-(d-1);
N1_value1 = pos(N1_value1); 
N1_value1(N1_value1<1e-14) = 0;


N1_value2 = zeros(m,n);
for j = 1:m
    for k = 1:d
        a = xi(:,k)-1/(2*N);
        b = xi(:,k)+1/(2*N);
        N1_value2(j,:) = N1_value2(j,:) +  (Ttauab_func(x(j,k), tau, a, b))';
    end
end
N1_value2 = N1_value2-(d-1);
N1_value2 = pos(N1_value2); 
N1_value2(N1_value2<1e-14) = 0;

max(max(abs(N1_value1-N1_value1),[],1))
% xik = [5/16, 9/16];
% tic;
% N1_value1 = N1_func(x, xik, N, tau);
% t1 = toc;
% tic;
% N1_value2 = N1_func_multiCenter(x, xik, N, tau);
% t2 = toc;
% max(max(abs(N1_value1-N1_value2),[],1))