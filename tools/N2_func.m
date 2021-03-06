function N2_value = N2_func(x, Lipf_eta_value, eta, N, tau)

[etaNum, d] = size(eta);
BlocksNum = N^d;

[Xi, B, ~] = CenterBound_func(d, N, tau);

N2_value = zeros(size(x,1),1);
for k = 1:BlocksNum
    indtmp = ones(etaNum,1);
    for j = 1:d    
        indtmp1 = eta(:,j)>=B.lowBound(k,j) & eta(:,j)<=B.upBound(k,j);
        indtmp = indtmp & indtmp1;
    end
   
    if ~isempty(find(indtmp==1, 1))
        Lipf_eta_value_k = Lipf_eta_value(indtmp);
        Lipfsum = sum(Lipf_eta_value_k);
        L = length(Lipf_eta_value_k);
        N2_value = N2_value + Lipfsum*N1_func(x, Xi(k,:), N, tau)/L;
    end   
end

