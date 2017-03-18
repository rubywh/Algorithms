
function [stepsSoFar] = nascdemov2(source, tstart, tend, tmin, tmax, sm)

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
%tmin = 400000000;
nascWindowSize = 2000000000;
%tmax = 750000000;

%walking = zeros(clen, 1);

timeElapsed = timeVsAcceleration(final,1);
numWindows = ceil(timeElapsed/nascWindowSize);
lastWindow = nascWindowSize * (numWindows-1);
lastTime = find(timeVsAcceleration(:,1)>lastWindow,1);

toptResults = zeros(numWindows,2);
stepsTaken = zeros(numWindows, 1);
stepsSoFar = 0;

z = 1;
for p = timeVsAcceleration(1,1):nascWindowSize:timeVsAcceleration(lastTime,1)
    
    if p == timeVsAcceleration(lastTime,1)
        start = lastTime;
        windowEnd = final;
        lastWindowLength = timeVsAcceleration(final, 1) - timeVsAcceleration(lastTime,1);
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
            stepsTaken(z,1) = 0;
            z=z+1;
            continue;
        end
        %windowEnd = nIdx - 1;
     end
    %{
    figure
    plot(timeVsAcceleration(start:windowEnd, 1), timeVsAcceleration(start:windowEnd, 2))
    %}
    
    %do Nasc on all in window
    [tOpt, nascForWindow] = nasc(timeVsAcceleration, start, tmax, tmin);
    
    %maxForWindow = max(nascForWindow(:,1));
    
    if nascForWindow > RThresh
        %walking(start:windowEnd, 1) = 1;
        toptResults(z, 1) = tOpt;
        toptResults(z, 2) = nascForWindow;
        
        if p == timeVsAcceleration(lastTime,1)
            stepsTaken(z,1) = (lastWindowLength/(toptResults(z, 1)/2));
            
        else
           
            %stepsSoFar = (sum(stepsTaken));
            stepsTaken(z,1) = (nascWindowSize/(toptResults(z, 1)/2));
        end
    else
        %walking(start:windowEnd, 1) = 0;
        stepsTaken(z,1) = 0;
    end
    z=z+1;
    stepsSoFar = ceil(sum(stepsTaken));
end
