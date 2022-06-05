function y = Simf21(x)
n = size(x,1);
y = zeros(n,1);
for i = 1:n
    rnorm = norm(x(i,:));
    r = 2.2*rnorm;
    if  r <= 1
        y(i) = (1 - r)^6*(35*r^2+18*r+3);
    else
        y(i) = 0;
    end
end
