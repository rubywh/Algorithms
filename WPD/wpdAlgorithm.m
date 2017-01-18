function totalSteps = wpd_script(timeVsAcceleration, thresh, wsize, minTime, wlen)

%generate the movingmean matrix
cmmResult = myCMovingMean(timeVsAcceleration, wlen);

clen = length(cmmResult);
prev = 0;
j = 1;

%get rid of duplicates for  now
for i = 1: clen
    if cmmResult(i,1) ~= prev
        wpdInput(j,1)= cmmResult(i,1);
        wpdInput(j,2)= cmmResult(i,2);
        prev = cmmResult(i,1);
        j = j + 1;
    end
end

%generate wpd vector
%at which times do peaks occur?
totalSteps = myWpd(wpdInput, wsize, thresh, minTime);

end

%Smooth the data using centredMovingMean
function cmmResult = myCMovingMean(timeVsAcceleration, wlen)
    
    time = timeVsAcceleration(:,1);
    acceleration = timeVsAcceleration(:,2);

    %find number of signal entries
    xlen = length(acceleration);
    
    %indices for checking the first window
    v=1;
    d=1;
    %setup the first window  and get its length so to know 
    %at what index to start writing results
	timeLimit = time(1) + wlen;
    while time(v) < timeLimit
        window(d) = acceleration(v);
        v=v+1;
        d=d+1;
    end
      
      firstWindowSize = length(window);
      
      if mod(firstWindowSize, 2) == 0
          start = firstWindowSize/2;
      else 
          start = ceil(firstWindowSize);
      end 

    lastTime = time(xlen) - wlen;
    
    %for each reading
    for i=start:xlen
        
    %if we have hit the final window
      if time(i) == lastTime
         %stop the loop
         break;  
      end
      
      %setup an empty window
      window = [];
     
      %time for which the window cannot go past
      timeLimit = time(i) + wlen;
      
      %fill the window
      idx = find(time>=timeLimit);
      window = acceleration(i:idx-1);
       
      %calculate the cmm entry for that window
      total = sum(window);
      cmm = total/length(window);
      cmmResult(i,1)= time(i);
      cmmResult(i,2) = cmm;
    end   
end


%perform Windowed Peak Detection with params
function totalSteps = myWpd(cmmResult, wlen, thresh, minTimeElapsedSincePeak)

% INPUTS
%cmmResult is the vector of results from centred moving mean calculation
%These give a smoothed version of the wave over time

%length of window for wpd
if ~exist ('wlen', 'var') || isempty(wlen)
    wlen = 20;
end

%set default threshold value for wpd
if ~exist ('thresh', 'var') || isempty(thresh)
    thresh = 10;
end

%set default threshold time elapsed since last peak
if ~exist ('minTimeElapsedSincePeak', 'var') || isempty(minTimeElapsedSincePeak)
    minTimeElapsedSincePeak = 300;
end

%plot or not, boolean
if ~exist ('show', 'var') || isempty(show)
    %set default to not plot
    show = 0;
end


%extract centred moving mean and time columns
wpdTime = cmmResult(:,1);
cmm = cmmResult(:,2);

totalSteps = 0;
clen = length(cmm);

%set dummy first peak before 0
peakTime = wpdTime(1)-minTimeElapsedSincePeak;
j = 1;

%get the time for the first entry in the final window
lastTime = wpdTime(clen) - wlen;

%for each centred moving mean
for i = 1:clen
    %if we have hit the final window
    if wpdTime(i) == lastTime
        %stop the loop
        break;
    end
    
    %initialise empty arrays for window values
    windowVals = [];
    windowTimes = [];
    
    %time for which the window cannot go past
    timeLimit = wpdTime(i) + wlen;
    
    %fill the window
    idx = find(wpdTime>=timeLimit);
    windowTimes= wpdTime(i:idx-1);
    windowVals = cmm(i:idx-1);
    
    %get the max val and index of that val in the window
    [maxVal, maxIdx] = max(windowVals);
    thisTime = windowTimes(maxIdx);
    thisVal = windowVals(maxIdx);
    %check maximum in window is greater than threshold
    if maxVal > thresh
    %check min time between peaks has elapsed
        if  (thisTime - peakTime) > minTimeElapsedSincePeak
            %update array of times at which steps occur
            if show == 1
                steps(j,1) = thisTime;
                steps(j,2) = thisVal;
               % update latest peak
                peakTime = steps(j,1);
            end 
                totalSteps = totalSteps +1;
            j=j+1;
        end
    end
end

if show == 1
    %extract times at which steps occur
    stepTimes = steps(:,1);
    stepVals = steps(:,2);

    %plot my results with peaks marked as circles
    figure
    plot(wpdTime, cmm)
    hold on
    scatter(stepTimes, stepVals)
    title('My WPD Results, steps circled');
    xlabel('Time (ms)');
    ylabel('Smoothed Acceleration (m/s^2)');

    %test against findpeaks function
    figure
    findpeaks(cmm, wpdTime, 'MinPeakDistance', minTimeElapsedSincePeak, 'MinPeakHeight', thresh);
    title('Matlab FindPeaks function results');
    xlabel('Time (ms)');
    ylabel('Smoothed Acceleration (m/s^2)');
end 
end
