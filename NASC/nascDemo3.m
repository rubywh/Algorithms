%nasc version 3: find t opt in first window, stick with that, if not
%counted as a step try to widen the window
data = xlsread('traces_test5.csv');

 idx = data(:,2) == 1;
    time = data(idx,1);
    xReading = data(idx,2);
    yReading = data(idx,3);
    zReading = data(idx,4);
    format long;
       
    sz = length(xReading);
    timeVsAcceleration = zeros(sz, 2);
    
    j = 1;   
   
    %set the values for acceleration magnitude
    for i=1:sz 
        timeVsAcceleration(i, 1) = time(i);
        timeVsAcceleration(i, 2) = sqrt((xReading(i).^2) + (yReading(i).^2) + (zReading(i).^2));
    end
    
     
    %traces test 
    tstart = 44210000000;
    tend =95080000000;
    goal = 85; 
    
    %{
       tstart = 44210000000;
    tend =95080000000;
    %}
    
    timeVsAcceleration(:, 1) = (timeVsAcceleration(:, 1) - timeVsAcceleration(1,1));
    timeVsAcceleration(timeVsAcceleration(:, 1)<=tstart, :) = [];
    timeVsAcceleration(timeVsAcceleration(:, 1)>=tend, :) = [];
    timeVsAcceleration(:, 1) = (timeVsAcceleration(:, 1) - timeVsAcceleration(1,1));
    

sdWalkingThresh = 0.6;

RThresh = 0.4;
tmin = 400000000;
nascWindowSize = 2000000000;
tmax = 1500000000;

time = timeVsAcceleration(:,1);
acc = timeVsAcceleration(:,2);

clen = length(time);

walking = zeros(clen, 1);
attempt = 0;
z = 1;
foundT = 0;
for p = time(1):nascWindowSize:time(clen)-nascWindowSize

        %set up the window
         mIdx = find(time>p,1);
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
        nIdx = find(time>timeLimit,1);
    
        sdThisWindow = std(acc(start:nIdx-1));
        if sdThisWindow < sdWalkingThresh
            continue;
        end
              
        windowEnd = nIdx - 1;
        windowCount = length(acc(start:windowEnd));
        %do Nasc on all in window
        
        if foundT == 0 
            [tOpt, nascForWindow] = nasc(timeVsAcceleration, start, windowEnd, tmax, tmin, windowCount);
            if nascForWindow > RThresh
                walking(start:windowEnd, 1) = 1;
                toptResults(z, 1) = tOpt;
                toptResults(z, 2) = nascForWindow;
                stepsTaken(z,1) = (2000000000./(toptResults(z,1)./2));
                stepsSoFar = sum(stepsTaken);
                foundT = 1;
                refinedT = tOpt;
                z=z+1; 
                message = 'found initial topt';
                disp(message);
            else
                walking(start:windowEnd, 1) = 0;
                foundT = 0;
                continue;
            end
        else
            [provisTOpt, provisNasc] = nascv3RefinedT(timeVsAcceleration, start, windowEnd, refinedT);
            if provisNasc>RThresh
                message = 'used first discovered topt';
                disp(message);
                walking(start:windowEnd, 1) = 1;
                toptResults(z, 1) = provisTOpt;
                toptResults(z, 2) = provisNasc;
                stepsTaken(z,1) = (2000000000./(toptResults(z,1)./2));
                stepsSoFar = sum(stepsTaken);
                z=z+1; 
                continue;
            else
                while attempt<RThresh
                    tMin = refinedT - 10000000;
                    tMax = refinedT + 10000000;
                    [testTOpt, attempt] = nasc(timeVsAcceleration, start, windowEnd, tmax, tmin, windowCount);
                    message = 'using adjusted topt';
                    disp(message);
                end
                walking(start:windowEnd, 1) = 1;
                toptResults(z, 1) = testTOpt;
                toptResults(z, 2) = attempt;  
                stepsTaken(z, 1) = (2000000000./(toptResults(z,1)./2));
                stepsSoFar = sum(stepsTaken);
                foundT = 1;
                z=z+1; 
            end
        end
end
