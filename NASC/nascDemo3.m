%nasc version 3: find t opt in first window, stick with that, if not
%counted as a step try to widen the window
function [stepsTotal] = nascDemo3(source, tstart, tend, tmin, tmax,sm)

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
%timeVsAcceleration = zeros(sz, 2);

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

for n =1:length(toDelete)
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

time = timeVsAcceleration(:,1);
acc = timeVsAcceleration(:,2);
if sm ==1
       acc = smooth(acc(:,1),5);
end
sdWalkingThresh = 0.6;

%calculate the standard deviations
%stdDeviation = StandardDeviation(timeVsAcceleration, sdWindow);

RThresh = 0.4;
%tmin = 400000000;
nascWindowSize = 2000000000;
%tmax = 750000000;

walking = zeros(clen, 1);


timeElapsed = time(final);
numWindows = ceil(timeElapsed/nascWindowSize);
lastWindow = nascWindowSize * (numWindows-1);
lastTime = find(time>lastWindow,1);

toptResults = zeros(numWindows,2);
stepsTaken = zeros(numWindows, 1);

walking = zeros(clen, 1);
toptResults = zeros(numWindows,2);
stepsTaken = zeros(numWindows, 1);

z = 1;
foundT = 0;
for p = time(1):nascWindowSize:time(lastTime)
    if(p == time(lastTime))
        start = lastTime;
        windowEnd = final;
        lastWindowLength = time(final) - time(lastTime);
    else
        
        
        %set up the window
        mIdx = find(time>p,1);
        %If dealing with the first reading
        if p == 0
            %The window should start at this reading
            start = 1;
        else
            start = mIdx;
        end
        
        timeLimit = p + nascWindowSize;
        
        %Find the first item that exceeds the window timelimit
        %The last item in the window will be the reading before this one
        if timeLimit > time(clen)
            timeLimit = time(clen)-1;
        end
        nIdx = find(time>timeLimit,1);
        
        sdThisWindow = std(acc(start:nIdx-1));
        if sdThisWindow < sdWalkingThresh
            stepsTaken(z,1) = 0;
            toptResults(z, 1) = 0;
            toptResults(z, 2) = 0;
            z =z+1;
            continue;
        end
        
        windowEnd = nIdx - 1;
    end
    %do Nasc on all in window
    
    if foundT == 0
        [tOpt, nascForWindow] = nasc(timeVsAcceleration, start, tmax, tmin);
        if nascForWindow > RThresh
            walking(start:windowEnd, 1) = 1;
            toptResults(z, 1) = tOpt;
            toptResults(z, 2) = nascForWindow;
            if p == time(lastTime)
                stepsTaken(z,1) = (nascWindowSize/(toptResults(z, 1)/2));
                stepsSoFar = sum(stepsTaken);
            else
                stepsTaken(z,1) = (nascWindowSize/(toptResults(z, 1)/2));
                stepsSoFar = sum(stepsTaken);
                foundT = 1;
                refinedT = tOpt;
                message = 'found initial topt';
                %disp(message);
            end
        else
            walking(start:windowEnd, 1) = 0;
            foundT = 0;
            continue;
        end
    else
        [provisTOpt, provisNasc] = nascv3RefinedT(timeVsAcceleration, start, windowEnd, refinedT);
        if provisNasc>RThresh
            message = 'used first discovered topt';
            %disp(message);
            walking(start:windowEnd, 1) = 1;
            toptResults(z, 1) = provisTOpt;
            toptResults(z, 2) = provisNasc;
            if p == time(lastTime)
                stepsTaken(z,1) = (nascWindowSize/(toptResults(z, 1)/2));
                stepsSoFar = sum(stepsTaken);
            else
                stepsTaken(z,1) = (nascWindowSize/(toptResults(z, 1)/2));
                stepsSoFar = sum(stepsTaken);
                z=z+1;
                continue;
            end
        else
            %%%%
            tMin = refinedT;
            tMax = refinedT;
            attempt = 0;
            while attempt<RThresh
                if tMin >= 700000000
                    tMin = tMin - 10000000;
                    if tMin <700000000
                        tMin = 700000000;
                    end
                end
                if tMax<=1500000000
                    tMax = tMax + 10000000;
                    if tMax >1500000000
                        tMax = 1500000000;
                    end
                end
                
               
                
                [testTOpt, attempt] = nasc(timeVsAcceleration, start, tMax, tMin);
                message = 'adjusting';
                
                if tMax == 1500000000 && tMin == 700000000
                    testTOpt = 0;
                    attempt = 0;
                    break;
                end
                
                %disp(message);
            end
            walking(start:windowEnd, 1) = 1;
            toptResults(z, 1) = testTOpt;
            toptResults(z, 2) = attempt;
              message = 'used adjusted';
            
            if testTOpt == 0
                stepsTaken(z,1) = 0;
            else
                if p == time(lastTime)
                %stepsTaken(z,1) = 1+floor((lastWindowLength-half)/tOpt);
                stepsTaken(z,1) = (lastWindowLength/(testTOpt/2));
                else
                % stepsTaken(z, 1) = 1+floor((nascWindowSize-half)/provisTOpt);
                
                stepsTaken(z,1) = (nascWindowSize/(testTOpt/2));
                stepsSoFar = sum(stepsTaken);
                foundT = 1;
                refinedT = testTOpt;
                end
            end
        end
    end
    z=z+1;
end
stepsTotal = ceil(sum(stepsTaken));
end
