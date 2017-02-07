%{
This script takes the data from the trace and calculates acceleration. It then
extracts the readings that lie within the ground truth walk period and
passes these as input to the Thresholding algorithm
'thresholding_script.m'.
%}

data = xlsread('traces_test2.csv');
    %Extract the data from the file
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
    %}

    %tracestest 2 
    tstart = 33340000000;
    tend = 81890000000;
  
        
%%% Setup %%%
    %Set threshold acceleration magnitude
    accMagThresh = 10.5;
    
    %Set threshold energy and define the energy window length
    enerWalkingThresh = 0.04;
    enerWinSize = 1000000000;
    
      
    %Set threshold standard deviation and define the sd window length
    sdWinSize = 800000000;
    sdWalkingThresh = 0.6;
    
    %set up vector with time and acceleration data
    sz = length(xReading);
    timeVsAcceleration = zeros(sz, 2);

    %set the values for acceleration magnitude
    for i=1:sz  
        timeVsAcceleration(i, 1) = time(i);
        timeVsAcceleration(i, 2) = sqrt((xReading(i)*xReading(i)) + (yReading(i)*yReading(i)) + (zReading(i)*zReading(i)));
    end
    
    len = length(timeVsAcceleration);

    
   % timeVsAcceleration(timeVsAcceleration(:, 2)==0, :) = [];
    
     %Take from each timestamp, the timestamp of the first reading 
    %The first column now corresponds to time elapsed and starts at 0
    timeVsAcceleration(:, 1) = (timeVsAcceleration(:, 1) - timeVsAcceleration(1,1));

     %Eliminate those readings outside ground truth period for this trace
    timeVsAcceleration(timeVsAcceleration(:, 1)<=tstart, :) = [];
    timeVsAcceleration(timeVsAcceleration(:, 1)>=tend, :) = [];

    
    %Shift again so that time elapsed starts at 0
    timeVsAcceleration(:, 1) = (timeVsAcceleration(:, 1) - timeVsAcceleration(1,1));

    
%Perform thresholding
thresholding_script(timeVsAcceleration, accMagThresh, enerWalkingThresh, enerWinSize, sdWinSize, sdWalkingThresh);
    
    