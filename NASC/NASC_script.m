M = xlsread('testaccelerometer1.dat.csv');

%get columns from file
time = M(:,1);
X = M(:,2);
Y = M(:,3);
Z = M(:,4);
format long;

acc = thresh_accMag(time, X, Y, Z);
acctimes = acc(:,1);
acceleration = acc(:,2);


signal(:,1) = acctimes;
signal(:,2) = acceleration;

sdWindow = 6;
sdWalkingThresh = 0.02;

%calculate the standard deviations 
sd = thresh_sd(acceleration, time, sdWindow);

%perform thresholding on the standard deviations
sdWalking = thresholding(sd, sdWalkingThresh);

RThresh = 0.7;
tmin = 40;
t = 2;
tmax = 100;
nascWindow = 20;

for len = 1:length(sdWalking)%minus something here
    if sdWalking(len) == 1;
       %Get Topt and its corresponding NASC value
           Topt= nasc(len, signal, tmin, tmax);
           
           if Topt > RThresh
              walking(len,1) = sd(len, 1);%time walking
              walking(len, 2) = 1;
           else
              walking(len,1) = sd(len, 1);%time not walking
              walking(len,2) = 0;
           end
   
    else
       %not walking as sd below sdthresh
       walking(len,1) = sd(len, 1);%time not walking
       walking(len,2) = 0;
    end
end    
