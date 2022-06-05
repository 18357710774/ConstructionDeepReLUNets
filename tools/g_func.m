function y = g_func(x)
[xNum, d] = size(x);
e = ones(d,1);
t = x*e;

y = zeros(xNum,1);

ind1 = (t>=-0.5) & (t<=0);
ind2 = (t>0) & (t<=0.5);
y(ind1) = t(ind1)+0.5;
y(ind2) = 0.5-t(ind2);