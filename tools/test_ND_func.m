d = 2;
N = 5;
tau = 0.1;

xD1 = [0.45 0.45
       0.55 0.45
       0.45 0.55
       0.55 0.55
       0.51 0.51
       0.47 0.47];
xD2 = [0.35 0.65
       0.35 0.5
       0.35 0.35
       0.5 0.35
       0.65 0.35
       0.65 0.5
       0.65 0.65
       0.5 0.65];
xD3 = [0.1 0.7
       0.5 0.9
       0.9 0.9
       0.9 0.5];
   
yD1 = [0.5 0.7 -0.3 0.5 -0.7 0.9]';
yD2 = [0.3 -0.4 -0.7 -0.2 0.9 0.1 0.3 -0.2]';
yD3 = [0.7 0.3 -0.2 -0.8]';


plot(0.5, 0.5, 'ro');
hold on;
plot(xD1(:,1), xD1(:,2), 'b.');
hold on;
plot(xD2(:,1), xD2(:,2), 'g.');
hold on;
plot(xD3(:,1), xD3(:,2), 'k.');

xD = [xD1; xD2; xD3];
yD = [yD1; yD2; yD3];

x = [0.63 0.66];
tic;
ND_value = ND_func(x, xD, yD, N, tau);
t1 = toc;

N1_value = N1_func(xD, [0.5 0.5], N, tau);

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
