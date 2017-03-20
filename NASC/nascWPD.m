
function [stepsSoFar] = nascWPD(source, tstart, tend, tmin, tmax, sm)

data = xlsread(source);

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
MovAvrWin = 310000000;

thresh = 10;


toptResults = zeros(final,2);
z = 1;
for p = 1:final
        
        %do Nasc on all data
        [tOpt, nascResult] = nascv2(timeVsAcceleration, p, tmax, tmin);
                
        if nascResult > RThresh
            %walking(p, 1) = 1;
            toptResults(z, 1) = tOpt;
            toptResults(z, 2) = nascResult;
            z=z+1;
        else
            %walking(p, 1) = 0;
        end
end


[~, maxIdx] = max(toptResults(:,2));
maxTOpt = toptResults(maxIdx, 1);
    
   wpdInput = myCMovingMean(timeVsAcceleration, MovAvrWin);
   stepsSoFar = myWpd(wpdInput, maxTOpt/2, thresh, 0);


%{
z = 1;
for p = timeVsAcceleration(1,1):nascWindowSize:timeVsAcceleration(lastTime,1)
    window =[];
    if p == timeVsAcceleration(lastTime,1)
        start = lastTime;
        windowEnd = final;
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
        
        windowEnd = nIdx - 1;
       
        window(:,1) = timeVsAcceleration(start:windowEnd, 1);
        window(:,2) = timeVsAcceleration(start:windowEnd, 2);
        
        sdThisWindow = std(timeVsAcceleration(start:windowEnd, 2));
        if sdThisWindow < sdWalkingThresh
            stepsTaken(z,1) = 0;
            z=z+1;
            continue;
        end
    end
    [tOpt, nascResult] = nasc(timeVsAcceleration, start, tmax, tmin);
   
    %wpdInput = myCMovingMean(timeVsAcceleration, MovAvrWin);
    
     %   window(:,1) = wpdInput(start:windowEnd, 1);
      %  window(:,2) = wpdInput(start:windowEnd, 2);
        
    if nascResult>Rthresh
    %smooth the data once
    stepsTaken(z,1) = myWpd(window, tOpt, thresh, 0);
    z=z+1;
    end 
    stepsSoFar = ceil(sum(stepsTaken));
%}
end
