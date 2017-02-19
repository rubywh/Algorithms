function [resTime, res] = nascv3RefinedT(signal, startIdx, windowEnd, tRefined)
    
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
 testT = tRefined;
 %For each in this window
 for m = startIdx:windowEnd
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
                                
                top = a(m:numWithinTminusOne + m) - firstMean;
                topTimes = time(m:numWithinTminusOne +m);
                topBottom = a((m + numWithinT):(m + numWithinT + numWithinTminusOne)) - secondMean;
                topBottomTimes = time((m + numWithinT):(m + numWithinT + numWithinTminusOne));
                thisTopResult = top.*topBottom;
                totalSum = sum(thisTopResult);
                
            bottom = (numWithinT+1) * firstStd * secondStd;
            thisNascResult = totalSum/bottom;
            
            if thisNascResult > maxSoFar
                maxSoFar = thisNascResult;
            end
end
        
        if maxSoFar>maxInWindowSoFar
            res = maxSoFar;
            
        end 
        resTime = testT;
 end


