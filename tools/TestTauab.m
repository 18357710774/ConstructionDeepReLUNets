t = 0:0.01:1;
a = 0.2;
b = 0.4;
tau = 0.1;
T = Ttauab_func(t, tau, a, b);

plot(t, T)