function T = Ttauab_func(t, tau, a, b)
T = pos(t-a+tau) - pos(t-a) - pos(t-b) + pos(t-b-tau);
T = T/tau;