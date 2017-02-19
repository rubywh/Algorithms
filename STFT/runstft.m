M = xlsread('traces_test2.csv');

time = M(:,1);
X = M(:,2);
Y = M(:,3);
Z = M(:,4);
format long;
sz = size(X);
acceleration = zeros(sz);

acceleration (:,1) = time;

windowSize = 700000000;

%!!
overlap = 1;

FFTLength = 10;

threshold = 20;

%set the values for acceleration magnitude
for i=1:sz 
    acceleration(i,2) = sqrt((X(i)*X(i)) + (Y(i)*Y(i)) + (Z(i)*Z(i)));
end



[T, F, Stft]= STFT(acceleration, overlap, FFTLength, windowSize, threshold, 0);
