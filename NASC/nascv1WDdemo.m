function [walkingPeriods] = nascv1WDdemo(source, tstart, tend, tmin, tmax, sm)

data = xlsread(source);

 dataTime = data(:,1);
    xReading = data(:,2);
    yReading = data(:,3);
    zReading = data(:,4);

    later=0;
    if ~exist ('tend', 'var') || isempty(tend) || tend ==0
        tend = length(dataTime);
        findFinal = 0;
        later=1;
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
    
    if findFinal ==1
        final = find(timeVsAcceleration(:,1)>(tend), 1) - 1;
    else 
        later = 1; 
    end
     
    firstItem = timeVsAcceleration(1,1);
    toDelete = [];
    %shift all 
    timeVsAcceleration(:, 1) = timeVsAcceleration(:, 1) - firstItem;
       tlen = length(timeVsAcceleration(:,1));
       m=1;
    for k=2:tlen
        if (timeVsAcceleration(k,2) == timeVsAcceleration(k-1,2))
           toDelete(m) = k;
           m=m+1;
        end
    end
    
    for n =1: length(toDelete)
       timeVsAcceleration(n,:) = []; 
    end
    
    if sm ==1
       timeVsAcceleration(:,2) = smooth(timeVsAcceleration(:,2), 5);
    end
   
sdWalkingThresh = 0.6;
RThresh = 0.3;

clen = length(timeVsAcceleration(:,1));
if later == 1; 
    
    final = clen;
end


walking = zeros(clen, 1);
z = 1;

sdData = std(timeVsAcceleration(:,2));
        if sdData < sdWalkingThresh
         walking(:,1) = 0;
        end

for p = 1:final
        
        %do Nasc on all data
        [nascResult] = nascv1WD(timeVsAcceleration,p, tmin, tmax);
                
        if nascResult > RThresh
            walking(z, 1) = 1;
        else
            walking(z, 1) = 0;
        end
        z=z+1;
end

wlen = length(walking);
startedWalking = 0;
stoppedWalking = 0;
walkingPeriods = 0;


for p = 1:wlen
    if p == 1
      continue
    else 
        prev = p-1;
        if walking(prev, 1) == 0 
            if walking(p, 1) == 1 
                startedWalking=startedWalking +1;
            end
        end
        if walking(prev, 1) == 1
            if walking(p,1) == 0
                stoppedWalking = stoppedWalking+1;
            end
        end
    end
end

if walking(1,1) ==  1
   walkingPeriods = stoppedWalking;
   if walking(wlen,1) == 1
       walkingPeriods = walkingPeriods +1;
   end
else 
   walkingPeriods = startedWalking;
end
end