
%{
This script takes the data from the trace, calculates acceleration and then
calls the centred moving mean function in order to smooth the data. It then
extracts the readings that lie within the ground truth walk period and
passes these as input to the Windowed Peak Detection algorithm 'myWpd.m',
testing a number of thresholds for that closest to the ground truth goal
for total steps.
%}

%%% Extract data from the file
    data = xlsread('traces_test2.csv');
    time = data(:,1);
    xReading = data(:,2);
    yReading = data(:,3);
    zReading = data(:,4);
    format long;
   
    
%%% Indicate ground truths per trace %%%
    
    %{
    %traces test 1
    tstart = 61230000000;
    tend =110920000000;
     goal = 79;
    %}
    
    %traces test 2 
    tstart = 33340000000;
    tend =81890000000;
    goal = 79;
    
%%% Setup %%%
   
    sz = length(xReading);
    timeVsAcceleration = zeros(sz, 2);
  
    j = 1;   
    %set the values for acceleration magnitude
    for i=1:sz 
        timeVsAcceleration(i, 1) = time(i);
        timeVsAcceleration(i, 2) = sqrt((xReading(i).^2) + (yReading(i).^2) + (zReading(i).^2));
    end
    
    %Set window sizes
    %0.31 seconds
    MovAvrWin = 310000000;
    %0.59 seconds
    PeakWin =590000000;
     
%%% Functionality %%%

    %smooth the data once
    wpdInput = myCMovingMean(timeVsAcceleration, MovAvrWin);

    %Remove those with CMM = 0
    wpdInput(wpdInput(:, 2)==0, :) = [];

    %Take from each timestamp, the timestamp of the first reading 
    %The first column now corresponds to time elapsed and starts at 0
    wpdInput(:, 1) = (wpdInput(:, 1) - wpdInput(1,1));

    %Eliminate those readings outside ground truth period for this trace
    wpdInput(wpdInput(:, 1)<=tstart, :) = [];
    wpdInput(wpdInput(:, 1)>=tend, :) = [];

    %Shift again so that time elapsed starts at 0
    wpdInput(:, 1) = (wpdInput(:, 1) - wpdInput(1,1));

    bestSoFar = 100;
    %Try a range of test thresholds and record the one that achieves the 
    %closest result to the ground truth goal
    for testThresh=8.0:0.1:9.0
        totalSteps = myWpd(wpdInput, PeakWin, testThresh, 1);
        %find difference from goal steps
        thisDifference = abs(goal - totalSteps);
        if thisDifference<bestSoFar
            bestSoFar = thisDifference;
            bestThresh = testThresh;
        end
    end

