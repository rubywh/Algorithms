
%nasc v1

data = xlsread('traces_test5.csv');

 idx = data(:,2) == 1;
    time = data(idx,1);
    xReading = data(idx,2);
    yReading = data(idx,3);
    zReading = data(idx,4);
    format long;
       
    sz = length(xReading);
    timeVsAcceleration = zeros(sz, 2);
    
    j = 1;   
   
    %set the values for acceleration magnitude
    for i=1:sz 
        timeVsAcceleration(i, 1) = time(i);
        timeVsAcceleration(i, 2) = sqrt((xReading(i).^2) + (yReading(i).^2) + (zReading(i).^2));
    end
    
     
    %traces test 
    tstart = 44210000000;
    tend =95080000000;
    goal = 85; 
    
   
    
    timeVsAcceleration(:, 1) = (timeVsAcceleration(:, 1) - timeVsAcceleration(1,1));
    timeVsAcceleration(timeVsAcceleration(:, 1)<=tstart, :) = [];
    timeVsAcceleration(timeVsAcceleration(:, 1)>=tend, :) = [];
    timeVsAcceleration(:, 1) = (timeVsAcceleration(:, 1) - timeVsAcceleration(1,1));
    
    figure
    plot(timeVsAcceleration(:,1), timeVsAcceleration(:,2));
    title('Raw Data');
    xlabel('Time');
    ylabel('Acceleration (m/s^2)');
                
        
sdWindow = 900000000;
sdWalkingThresh = 0.6;

RThresh = 0.4;
tmin = 400000000;
nascWindowSize = 2000000000;
tmax = 1500000000;

time = timeVsAcceleration(:,1);
acc = timeVsAcceleration(:,2);

clen = length(time);

walking = zeros(clen, 1);

z = 1;
for p = 1:clen
        sdData = std(acc);
        if sdData < sdWalkingThresh
            continue;
        end
        %do Nasc on all in window
        [tOpt, nascResult] = nascv1(timeVsAcceleration,p, tmax, tmin);
                
        if nascResult > RThresh
            walking(p, 1) = 1;
            toptResults(z, 1) = tOpt;
            toptResults(z, 2) = nascResult;
            z=z+1;
        else
            walking(p, 1) = 0;
        end
end

firstTime = timeVsAcceleration(1,1);
lastTime = timeVsAcceleration(clen,1);
timeWalking = lastTime - firstTime; 
%{
meanTOpt = mean(toptResults(:,1));
stepsTaken = timeWalking./(meanTOpt./2);
%}

[maxVal, maxIdx] = max(toptResults(:,2));
maxTOpt = toptResults(maxIdx, 1);
stepsTaken = timeWalking./(maxTOpt/2);
