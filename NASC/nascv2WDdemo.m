%nascv2WDdemo


function [walkingPeriods] = nascv2WDdemo(source, tstart, tend, tmin, tmax, sm)

data = xlsread(source);
%{
idx = data(:,2) == 1;
    dataTime = data(idx,1);
    xReading = data(idx,2);
    yReading = data(idx,3);
    zReading = data(idx,4);
    format long;
%}
dataTime = data(:,1);
xReading = data(:,2);
yReading = data(:,3);
zReading = data(:,4);


if ~exist ('tend', 'var') || isempty(tend) || tend ==0
    tend = length(dataTime);
    findFinal = 0;
else
    findFinal =1;
end

if ~exist ('tstart', 'var') || isempty(tstart) || tstart ==0
    tstart = dataTime(1);
    crop = 0;
else
    crop = 1;
end

sz = length(xReading);
timeVsAcceleration = zeros(sz, 2);

%set the values for acceleration magnitude
for i=1:sz
    timeVsAcceleration(i, 1) = dataTime(i);
    timeVsAcceleration(i, 2) = sqrt((xReading(i).^2) + (yReading(i).^2) + (zReading(i).^2));
end

%set timestamps to time elapsed
timeVsAcceleration(:, 1) = (timeVsAcceleration(:, 1) - timeVsAcceleration(1,1));
%crop those less than start

if crop == 1
    timeVsAcceleration(timeVsAcceleration(:, 1)<tstart, :) = [];
end
tlen = length(timeVsAcceleration(:,1));
m=1;
toDelete = [];
for k=2:tlen
    if (timeVsAcceleration(k,2) == timeVsAcceleration(k-1,2))
        toDelete(m) = k;
        m=m+1;
    end
end

for n =1: length(toDelete)
    timeVsAcceleration(n,:) = [];
end

firstItem = timeVsAcceleration(1,1);

%shift all
timeVsAcceleration(:, 1) = timeVsAcceleration(:, 1) - firstItem;


clen = length(timeVsAcceleration(:,1));
if findFinal ==1
    final = find(timeVsAcceleration(:,1)>(tend-firstItem), 1) - 1;
else
    final = clen;
end

if sm ==1
    timeVsAcceleration(:,2) = smooth(timeVsAcceleration(:,2),10);
end

sdWalkingThresh = 0.6;

%calculate the standard deviations
%stdDeviation = StandardDeviation(timeVsAcceleration, sdWindow);

RThresh = 0.4;
nascWindowSize = 2000000000;
z=1;

timeElapsed = timeVsAcceleration(final,1);
numWindows = ceil(timeElapsed/nascWindowSize);
lastWindow = nascWindowSize * (numWindows-1);
lastTime = find(timeVsAcceleration(:,1)>lastWindow,1);

walkingPerWindow = zeros(numWindows, 1);
walkingPeriods = 0;

for p = timeVsAcceleration(1,1):nascWindowSize:timeVsAcceleration(lastTime,1)
    
    if p == timeVsAcceleration(lastTime,1)
        start = lastTime;
    else
        %set up the window
        mIdx = find(timeVsAcceleration(:,1)>p,1);
        %If dealing with the first reading
        if p == 0
            %The window should start at this reading
            start = 1;
        else
            start = mIdx;
        end
        
        %Set the time limit to the time at which the last item in the window
        %cannot exceed
        % timeLimit = time(start) + nascWindowSize;
        timeLimit = p + nascWindowSize;
        
        %Find the first item that exceeds the window timelimit
        %The last item in the window will be the reading before this one
        nIdx = find(timeVsAcceleration(:,1)>timeLimit,1);
        
        sdThisWindow = std(timeVsAcceleration((start:nIdx-1),2));
        if sdThisWindow < sdWalkingThresh
            walkingPerWindow(z,1) = 0;
            continue;
        end
        
    end
    
    %do Nasc on all in window
    [nascForWindow] = nascv2WD(timeVsAcceleration, start, tmax, tmin);
    
    if nascForWindow > RThresh
        walkingPerWindow(z,1) = 1;
    else
        walkingPerWindow(z,1) = 0;
    end
    z=z+1;
end

stoppedWalking = 0;
startedWalking = 0;
for p = 1:numWindows
    if p == 1
        continue
    else
        prev = p-1;
        if walkingPerWindow(prev, 1) == 0
            if walkingPerWindow(p, 1) == 1
                startedWalking=startedWalking +1;
            end
        end
        if walkingPerWindow(prev, 1) == 1
            if walkingPerWindow(p, 1) == 0
                stoppedWalking = stoppedWalking+1;
            end
        end
    end
end

if walkingPerWindow(1,1) ==  1
   walkingPeriods = stoppedWalking;
   if walkingPerWindow(numWindows,1) == 1
       walkingPeriods = walkingPeriods +1;
   end
else 
   walkingPeriods = startedWalking;
end
