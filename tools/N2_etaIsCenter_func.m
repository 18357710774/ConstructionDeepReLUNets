function N2_value = N2_etaIsCenter_func(x, Lipf_eta_value, eta, tau)

[BlocksNum, d] = size(eta);
N = round(BlocksNum^(1/d));

N1_value = N1_func_multiCenter(x, eta, N, tau);
N2_value = N1_value*Lipf_eta_value;
