
%{
This script takes the data from the trace, calculates acceleration and then
calls the centred moving mean function in order to smooth the data. It then
extracts the readings that lie within the ground truth walk period and
passes these as input to the Windowed Peak Detection algorithm 'myWpd.m',
testing a number of thresholds for that closest to the ground truth goal
for total steps.
%}
function [steps, optWin, optThresh] = bfs_wpd(src, tstart, tend, goal, establishOptWinSize, PeakWin)

%%% Extract data from the file
data = xlsread(src);
time = data(:,1);
xReading = data(:,2);
yReading = data(:,3);
zReading = data(:,4);


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

%%% Functionality %%%

%smooth the data once
wpdInput = myCMovingMean(timeVsAcceleration, MovAvrWin);

%Remove those with CMM = 0
wpdInput(wpdInput(:, 2)==0, :) = [];


%Take from each timestamp, the timestamp of the first reading
%The first column now corresponds to time elapsed and starts at 0
wpdInput(:, 1) = (wpdInput(:, 1) - wpdInput(1,1));

%Graphing raw data
timeVsAcceleration(:, 1) = (timeVsAcceleration(:, 1) - timeVsAcceleration(1,1));
timeVsAcceleration(timeVsAcceleration(:, 1)<=tstart, :) = [];
timeVsAcceleration(timeVsAcceleration(:, 1)>=tend, :) = [];
timeVsAcceleration(:, 1) = (timeVsAcceleration(:, 1) - timeVsAcceleration(1,1));

%{
figure
plot(timeVsAcceleration(:,1), timeVsAcceleration(:,2));
title('Raw Data');
xlabel('Time');
ylabel('Acceleration (m/s^2)');
%}

%Eliminate those readings outside ground truth period for this trace
wpdInput(wpdInput(:, 1)<=tstart, :) = [];
wpdInput(wpdInput(:, 1)>=tend, :) = [];

%Shift again so that time elapsed starts at 0
wpdInput(:, 1) = (wpdInput(:, 1) - wpdInput(1,1));
%{
%Graph smoothed data
figure
plot(wpdInput(:,1), wpdInput(:,2));
title('Smoothed');
xlabel('Time');
ylabel('Smoothed Acceleration (m/s^2)');

figure
plot(wpdInput(:,1), wpdInput(:,2));
title('Smoothed');
xlabel('Time');
ylabel('Smoothed Acceleration (m/s^2)');
hold on
plot(timeVsAcceleration(:,1), timeVsAcceleration(:,2));
%}

bestSoFar = 100;
thresh = 10;

if establishOptWinSize == 1
    for PeakWin = 350000000:1000000:700000000;
        totalSteps = myWpd(wpdInput, PeakWin, thresh, 0);
        %find difference from goal steps
        thisDifference = abs(goal - totalSteps);
        if thisDiff43erence<=bestSoFar
            bestSoFar = thisDifference;
            steps = totalSteps;
            optWin = PeakWin;
        end
    end
else
    steps = myWpd(wpdInput, PeakWin, thresh, 0);
    optWin = PeakWin;
end
end

