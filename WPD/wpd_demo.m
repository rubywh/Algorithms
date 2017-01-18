function totalSteps = wpd_demo 
    data = xlsread('walkTest.csv');
    %Extract the data from the file
    time = data(:,1);
    xReading = data(:,2);
    yReading = data(:,3);
    zReading = data(:,4);
    format long;

    %initialisation
    thresh = 10;
    cmmWinSize = 300;
    minTimeBetweenPeaks = 300;
    wpdWinSize = 500;

    %set up vector with time and acceleration data
    sz = length(xReading);
    timeVsAcceleration = zeros(sz, 2);

    %set the values for acceleration magnitude
    for i=1:sz 
        timeVsAcceleration(i, 1) = time(i);
        timeVsAcceleration(i, 2) = sqrt((xReading(i)*xReading(i)) + (yReading(i)*yReading(i)) + (zReading(i)*zReading(i)));
    end

    totalSteps = wpdAlgorithm(timeVsAcceleration, thresh, cmmWinSize, minTimeBetweenPeaks, wpdWinSize);
end