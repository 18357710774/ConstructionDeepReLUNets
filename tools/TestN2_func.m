x = -1:0.01:1;
x = x';
y = g_func(x);
plot(x,y)

eta = [1 1; 3 4];
feta_value = N2_func(@fmy, eta);