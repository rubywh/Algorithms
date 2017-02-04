data = xlsread('traces_test3.csv');
    %Extract the data from the file
    time = data(:,1);
    xReading = data(:,2);
    yReading = data(:,3);
    zReading = data(:,4);
    format long;
   
    tstart = 44210000000;
    tend =95080000000;
    
    
    sz = length(xReading);
    timeVsAcceleration = zeros(sz, 2);

    %set the values for acceleration m agnitude
    for i=1:sz 
        timeVsAcceleration(i, 1) = time(i);
        timeVsAcceleration(i, 2) = sqrt((xReading(i)*xReading(i)) + (yReading(i)*yReading(i)) + (zReading(i)*zReading(i)));
    end
    
     
goal = 84;
j = 1;   

%Set window sizes
%0.31 seconds
MovAvrWin = 310000000;
%0.59 seconds
PeakWin = 590000000;

%smooth the data once
cmmResult = myCMovingMean(timeVsAcceleration, MovAvrWin);

clen = length(cmmResult);

prev = 0;
k = 1;

firstTime = 0;
%get rid of duplicates 
for i = 1:clen
    if ~isnan(cmmResult(i,2))
        if cmmResult(i,1) ~= prev
                wpdInput(k,1)= cmmResult(i,1);
                wpdInput(k,2)= cmmResult(i,2);
                prev = cmmResult(i,1);
                k = k + 1;
        end
    end
end

%Remove rows before tstart and after tend
wpdInput(:,1) = wpdInput(:,1) - wpdInput(1,1);
wpdInput(wpdInput(:, 1)<tstart, :) = [];
wpdInput(wpdInput(:, 1)>tend, :) = [];

idx=1;
bestSoFar = 100;

testThresh = 10.5

%Get the total steps counted 
totalSteps = myWpd(wpdInput, PeakWin, testThresh, 1);
%find difference from goal steps
thisDifference = abs(goal - totalSteps);



