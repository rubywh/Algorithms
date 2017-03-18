function [resTime, res] = nasc(signal, startIdx, tMax, tMin)

time = signal(:,1);
a = signal(:,2);

clen = length(time);

maxSoFar = -Inf;
maxInWindowSoFar = -Inf;
maxTime = 0;
res =0;
resTime = 0;

%{
 if startIdx == 1
     figure
     plot(a(startIdx:windowEnd))
 end
%}
mEnd = find(time>(time(startIdx) + tMax),1) - 1;

timeEnd = length(time);
%For each in this window
for m = startIdx:mEnd
   
    if size(mEnd) == 0
        break
    end
    for testT = tMin: 10000000: tMax
        timeLimit = time(m) + testT;
        if timeLimit>time(timeEnd);
            break;
        end
      
        %get index for first item greater than timestamp
        %get t-1
        tMinusOneIndex= find(time>timeLimit,1) - 2;
        
        %number of items in range from m to t-1
        numWithinTminusOne = length(time(m:tMinusOneIndex));
        numWithinT = numWithinTminusOne+1;
        
        if (m + numWithinT + numWithinT -1) > clen
            break;
        end
        
        firstMean = mean(a(m:tMinusOneIndex));
        secondMean = mean(a((m + numWithinT):(m + numWithinT + numWithinTminusOne)));
        firstStd =  std(a(m:tMinusOneIndex));
        secondStd = std(a((m + numWithinTminusOne):(m + numWithinT + numWithinTminusOne)));
        
        top = a(m:numWithinTminusOne + m) - firstMean;
        
        
        %topTimes = time(m:numWithinTminusOne +m);
        topBottom = a((m + numWithinT):(m + numWithinT + numWithinTminusOne)) - secondMean;
        
        %{
                 if startIdx == 1
 figure
                plot(time(m:numWithinTminusOne + m),a(m:numWithinTminusOne + m));
        %}
        
        %{
                figure
                plot( time((m + numWithinT):(m + numWithinT + numWithinTminusOne)), a((m + numWithinT):(m + numWithinT + numWithinTminusOne)));
        %}
        
        %topBottomTimes = time((m + numWithinT):(m + numWithinT + numWithinTminusOne));
        thisTopResult = top.*topBottom;
        totalSum = sum(thisTopResult);
        
        
        bottom = (numWithinT) * firstStd * secondStd;
        thisNascResult = totalSum/bottom;
        
        if thisNascResult >= maxSoFar
            maxSoFar = thisNascResult;
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
    
    if maxSoFar>=maxInWindowSoFar
        res = maxSoFar;
        resTime = maxTime;
        maxInWindowSoFar = maxSoFar;
    end
    
end


end


