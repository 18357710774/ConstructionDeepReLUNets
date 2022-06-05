function X = UniballData(N,d)
% ����3ά����������������������֮��Ϊ1����0.5pi/3��= 1.91;
% ���Ϊ���ܹ������㹻��ľ��ȷֲ��������ڵĵ㣬���ǽ�����2.5����Ŀ�ľ��ȷֲ���[-0.5,0.5]�ĵ㣬
% Ȼ������Щ�����ҳ�����ģ��С��0.5�ĵ�����
% ����dά�ռ�ĳ��������볬����˵����λ�߳��ĳ����������Ϊ1�������г�������ΪV=pi^(d/2)*(1/2)^d/Gamma(d/2+1)

NumTimes = gamma(d/2+1)/(pi^(d/2)*0.5^d);
NumTimes = NumTimes*1.4;
M = ceil(NumTimes*N);
X1 = rand(M,d)-0.5; % ���ɾ��ȷֲ���[-0.5,0.5]�������ڵĵ�
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

