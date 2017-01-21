%A script to plot acceleration over time

M = xlsread('210120171500_accelerometer.csv');
time = M(:,1);
X = M(:,2);
Y = M(:,3);
Z = M(:,4);

sz = size(X);
acceleration = zeros(sz);

%set the values for acceleration magnitude
for i=1:sz 
    acceleration(i) = sqrt((X(i)*X(i)) + (Y(i)*Y(i)) + (Z(i)*Z(i)));
end

figure
plot(time, acceleration)
xlabel('Time');
ylabel('Acceleration')