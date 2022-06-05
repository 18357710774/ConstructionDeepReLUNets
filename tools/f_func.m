function f_value = f_func(x, N, Ind_S, RadeRV)
[xNum, d] = size(x);

BlocksNum = length(RadeRV);
U = round(BlocksNum^(1/d));
tau_k = Center_func(d, U);

gk_value = zeros(xNum, BlocksNum);
for k = 1:BlocksNum
    xtmp = (x-ones(xNum,1)*tau_k(k,:))*U;
    gk_value(:,k) = g_func(xtmp)/U;
end

[~, B] = CenterBound_func(d, N, 0.001); % �������0.001����Ϊ����ֻ�õ�������xi_k�Լ���Ӧ��B_k�����½磬û���õ�B_{k,tau}�����½�
Ind_xInS = zeros(xNum,1);
for k = Ind_S
    indtmp = ones(xNum,1);
    for j = 1:d    
        indtmp1 = x(:,j)>=B.lowBound(k,j) & x(:,j)<=B.upBound(k,j);
        indtmp = indtmp & indtmp1;
    end
    Ind_xInS = Ind_xInS | indtmp;
end

f_value = zeros(xNum, 1);
f_value(Ind_xInS) = gk_value(Ind_xInS, :)*RadeRV;
