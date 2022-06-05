d = 3;
N = 5;
tau = 0.3;
xDNum = 100000;
xD = rand(xDNum,d);
BlocksNum = N^d;
[Xi, B, B_wave] = CenterBound_func(d, N, tau);

for k = 1:BlocksNum
    plot3(Xi(k,1), Xi(k,2), Xi(k,3),'ro', 'Markersize',10, 'Linewidth', 4);
    hold on;
    indtmp = ones(xDNum,1);
    for j = 1:d    
        indtmp1 = xD(:,j)>=B_wave.lowBound(k,j) & xD(:,j)<=B_wave.upBound(k,j);
        indtmp = indtmp & indtmp1;
    end
    plot3(xD(indtmp,1), xD(indtmp,2), xD(indtmp,3), 'b.');
%     hold on;
%     pause(1);
    close;
end        
