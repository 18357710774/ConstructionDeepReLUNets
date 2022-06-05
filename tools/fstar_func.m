function f_value = fstar_func(x, N, s, m, r)
[xNum, d] = size(x);
U = ceil((m*s/(N^d))^(1/(2*r+d)));

BlocksNum = U^d;
tau_k = Center_func(d, U);
RadeRV = RademacherRandomVariable(BlocksNum);

gk_value = zeros(xNum, BlocksNum);
for k = 1:BlocksNum
    xtmp = (x-ones(xNum,1)*tau_k(k,:))*U;
    gk_value(:,k) = g_func(xtmp)/U;
end

IndRand = randperm(N^d);
Ind_S = IndRand(1:s);  % randomly choose s sub-cubes

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
