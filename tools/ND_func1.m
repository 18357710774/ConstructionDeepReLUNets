function ND_value = ND_func1(x, xD, yD, N, tau)
[xDNum, d] = size(xD);
BlocksNum = N^d;

[Xi, B, B_wave] = CenterBound_func(d, N, tau);

xNum = size(x,1);
xN1_value = zeros(xNum, BlocksNum);
for k = 1:BlocksNum
    xN1_value(:,k) = N1_func(x, Xi(k,:), N, tau);
end

ND_value = zeros(size(x,1),1);
for i = 1:xNum
    indtmpi = find(xN1_value(i,:) ~=0);
    for k = indtmpi
        indtmp1 = ones(xDNum,1);
        for j = 1:d    
            indtmp11 = xD(:,j)>=B.lowBound(k,j) & xD(:,j)<=B.upBound(k,j);
            indtmp1 = indtmp1 & indtmp11;
        end
        if ~isempty(find(indtmp1==1, 1))
            yDsum = sum(yD(indtmp1));
            indtmp2 = ones(xDNum,1);
            for j = 1:d    
                indtmp22 = xD(:,j)>=B_wave.lowBound(k,j) & xD(:,j)<=B_wave.upBound(k,j);
                indtmp2 = indtmp2 & indtmp22;
            end
            ND_value(i) = ND_value(i) + yDsum*N1_func(x(i,:), Xi(k,:), N, tau)/length(find(indtmp2==1));
        end
    end
end