function N2_value = N2_etaIsCenter_func1(x, Lipf_eta_value, eta, tau)

[BlocksNum, d] = size(eta);
N = round(BlocksNum^(1/d));

N1_value = zeros(size(x,1), BlocksNum);
for k = 1:BlocksNum
    N1_value(:,k) = N1_func(x, eta(k,:), N, tau);
end
N2_value = N1_value*Lipf_eta_value;
