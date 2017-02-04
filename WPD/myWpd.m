
%perform Windowed Peak Detection with params
function totalSteps = myWpd(wpdInput, wpdWinSize, thresh, show)

%cmmResult is the vector of results from centred moving mean calculation
%These give a smoothed version of the wave over time

%extract centred moving mean an d time columns
wpdTime = wpdInput(:,1);
wpdValues = wpdInput(:,2);

totalSteps = 0;
clen = length(wpdValues);

j = 1;

%get the time for the first entry in the final window
%lastTime = wpdTime(clen) - wpdWinSize;
%i=1;
%for each centred moving mean

for i = wpdTime(1):wpdWinSize:wpdTime(clen)
    timeLimit = i + wpdWinSize;
    %+ wpdWinSize
    mIdx = find(wpdTime>i,1);
    start = mIdx-1;
    nIdx = find(wpdTime>timeLimit,1);
    windowTimes= wpdTime(start:nIdx-1);
    windowVals = wpdValues(start:nIdx-1);
    windowCount = length(windowVals);
    
    %get the max val and index of that val in the window
    [maxVal, maxIdx] = max(windowVals);
    thisTime = windowTimes(maxIdx);
    thisVal = windowVals(maxIdx);
    %check maximum in window is greater than threshold
    if maxVal > thresh
         if show == 1
           steps(j,1) = thisTime;
           steps(j,2) = thisVal;
         end
            totalSteps = totalSteps +1;
            j=j+1;     
    end
end



%{
while i<clen
    %if we have hit the final window
    if wpdTime(i) == lastTime
        %stop the loop
        break;
    end
    
    %initialise empty arrays for window values
    windowVals = [];
    windowTimes = [];
    
    %time for which the window cannot go past
    timeLimit = wpdTime(i) + wpdWinSize;
    %+ wpdWinSize
    
    %fill the window
    idx = find(wpdTime>timeLimit,1);
    windowTimes(:,1)= wpdTime(i:idx-1);
    windowVals(:,1) = wpdValues(i:idx-1);
    windowCount = length(windowVals);
    
    %get the max val and index of that val in the window
    [maxVal, maxIdx] = max(windowVals);
    thisTime = windowTimes(maxIdx);
    thisVal = windowVals(maxIdx);
    %check maximum in window is greater than threshold
    if maxVal > thresh
         if show == 1
           steps(j,1) = thisTime;
           steps(j,2) = thisVal;
         end
            totalSteps = totalSteps +1;
            j=j+1;     
    end
    i=i+windowCount;
end
%}

if show == 1
    %extract times at which steps occur
    stepTimes = steps(:,1);
    stepVals = steps(:,2);

    %plot my results with peaks marked as circles
    figure
    plot(wpdTime, wpdValues)
    hold on
    scatter(stepTimes, stepVals, 'filled')
    title('My WPD Results, steps circled');
    xlabel('Time (ms)');
    ylabel('Smoothed Acceleration (m/s^2)');

    %{
    test against findpeaks function
    figure
    findpeaks(cmm, wpdTime, 'MinPeakDistance', minTimeElapsedSincePeak, 'MinPeakHeight', thresh);
    title('Matlab FindPeaks function results');
    xlabel('Time (ms)');
    ylabel('Smoothed Acceleration (m/s^2)');
    %}
end 
end