function [resTime, res] = nasc(signal, startIdx, windowEnd, tMax, tMin, windowCount)
    
    time = signal(:,1);
    a = signal(:,2);
    i = 1;
   % m = startIdx;

    %windowResult = zeros(windowCount,1);
    clen = length(time);
    
 %for this T, loop through K  , give one result
% windowResult = zeros(windowCount, 2);
 totalSum = 0;
 maxSoFar = -Inf;
 maxInWindowSoFar = -Inf;
 maxTime = 0;
 
 if startIdx == 1 
     figure
     plot(a(startIdx:windowEnd))
 end
 
 
 %For each in this window
 for m = startIdx:windowEnd
        for testT = tMin: 10000000: tMax
            timeLimit = time(m) + testT;
                
                %get index for first item greater than timestamp
                %get t-1
                tMinusOneIndex= find(time>timeLimit,1) - 2;
                 
                %number of items in range from m to t-1
                numWithinTminusOne = length(time(m:tMinusOneIndex));
                numWithinT = numWithinTminusOne+1;
                
                 if (m + numWithinT + numWithinT -1) > clen
                       break;
                 end
                   
                 firstMean = mean(a(m:tMinusOneIndex + 1));
                 secondMean = mean(a((m + numWithinT):(m + numWithinT + numWithinT -1)));
                 firstStd =  std(a(m:tMinusOneIndex + 1));
                 secondStd = std(a((m + numWithinT):(m + numWithinT + numWithinT -1)));
                 %{
                for k=0:numWithinTminusOne 
                    top = (a(m + k) - firstMean);
                    topBottom = (a(m + k + numWithinT) - secondMean);
                    thisTopResult = (top*topBottom);
                    totalSum = totalSum + thisTopResult;
                end
                
            %}
                 
                top = a(m:numWithinTminusOne + m) - firstMean;
                topTimes = time(m:numWithinTminusOne +m);
                topBottom = a((m + numWithinT):(m + numWithinT + numWithinTminusOne)) - secondMean;
                topBottomTimes = time((m + numWithinT):(m + numWithinT + numWithinTminusOne));
                thisTopResult = top.*topBottom;
                totalSum = sum(thisTopResult);
                

            bottom = (numWithinT+1) * firstStd * secondStd;
            thisNascResult = totalSum/bottom;
            
            if thisNascResult > maxSoFar
                maxSoFar = totalSum/bottom;
                maxTime = testT;
            end
            %{
               if startIdx ==1  && testT == 400000000
                 figure
                 plot(topTimes, top+firstMean)
                 
                 figure
                 plot(topBottomTimes, topBottom + secondMean)
                end
            %}
        end
        
        if maxSoFar>maxInWindowSoFar
            maxInWindowSoFar = maxSoFar;
            tOptForWindowSoFar = maxTime;
        end
        
         
             
        %Record maxResult for that reading
        %{
windowResult(i, 1) = maxSoFar;
        windowResult(i, 2) = maxTime;
        i=i+1;
        %}
       
 end
  	resTime= tOptForWindowSoFar;
    res = maxInWindowSoFar;
 
 end


