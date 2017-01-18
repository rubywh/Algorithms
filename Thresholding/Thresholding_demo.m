 data = xlsread('testaccelerometer1.dat.csv');
    %Extract the data from the file
    time = data(:,1);
    xReading = data(:,2);
    yReading = data(:,3);
    zReading = data(:,4);
    format long;
    
    %initialisation
    accMagThresh = 10;
    enerWalkingThresh = 300;
    enerWinSize = 6;
    sdWinSize = 6;
    sdWalkingThresh = 0.02;
    
     %set up vector with time and acceleration data
    sz = length(xReading);
    timeVsAcceleration = zeros(sz, 2);

    %set the values for acceleration magnitude
    for i=1:sz 
        timeVsAcceleration(i, 1) = time(i);
        timeVsAcceleration(i, 2) = sqrt((xReading(i)*xReading(i)) + (yReading(i)*yReading(i)) + (zReading(i)*zReading(i)));
    end

    thresholding_script(timeVsAcceleration, accMagThresh, enerWalkingThresh, enerWinSize, sdWinSize, sdWalkingThresh);
    
    