function ND_value = ND_func(x, xD, yD, N, tau)
[xDNum, d] = size(xD);
BlocksNum = N^d;

[Xi, B, B_wave] = CenterBound_func(d, N, tau);

ND_value = zeros(size(x,1),1);
for k = 1:BlocksNum
    if mod(k, 500) == 0
        fprintf(['Block proceeding: ' num2str(k) '/' num2str(length(BlocksNum))  '\n']);
    end
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
        ND_value = ND_value + yDsum*N1_func(x, Xi(k,:), N, tau)/length(find(indtmp2==1));
    end
    
end

