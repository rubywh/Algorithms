M = xlsread('walkTest.csv');

time = M(:,1);
X = M(:,2);
Y = M(:,3);
Z = M(:,4);
format long;
sz = size(X);
acceleration = zeros(sz);

acceleration (:,1) = time;

%set the values for acceleration magnitude
for i=1:sz 
    acceleration(i,2) = sqrt((X(i)*X(i)) + (Y(i)*Y(i)) + (Z(i)*Z(i)));
end

stft= STFT(acceleration, 20, 10, 10000, 0);
