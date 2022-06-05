function X = UniballData(N,d)
% 由于3维正方体与其内切球体的体积之比为1：（0.5pi/3）= 1.91;
% 因此为了能够生成足够多的均匀分布在球体内的点，我们将生成2.5倍数目的均匀分布在[-0.5,0.5]的点，
% 然后在这些点中找出满足模长小于0.5的点来。
% 对于d维空间的超正方体与超球来说，单位边长的超正方体体积为1，其内切超球的体积为V=pi^(d/2)*(1/2)^d/Gamma(d/2+1)

NumTimes = gamma(d/2+1)/(pi^(d/2)*0.5^d);
NumTimes = NumTimes*1.4;
M = ceil(NumTimes*N);
X1 = rand(M,d)-0.5; % 生成均匀分布在[-0.5,0.5]立方体内的点
X1 = X1 -  repmat(mean(X1,1),M,1);
X1norm = sqrt(sum(X1.^2,2));

while ~isempty(find(X1norm>0.5, 1)) && length(X1norm)>N    
    IndSel = find(X1norm<=0.5);
    X1 = X1(IndSel,:);
    X1 = X1 -  repmat(mean(X1,1),size(X1,1),1);
    X1norm = sqrt(sum(X1.^2,2));
end
Num = length(IndSel);
IndRand = randperm(Num);
X = X1(IndRand(1:N),:);

