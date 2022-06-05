function RademacherRV = RademacherRandomVariable(num)
a = rand(num, 1);
ind1 = (a>=0) & (a<0.5);
ind2 = (a>=0.5) & (a<=1);

RademacherRV = zeros(num,1);

RademacherRV(ind1) = -1;
RademacherRV(ind2) = 1;