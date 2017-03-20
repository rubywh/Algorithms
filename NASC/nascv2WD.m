function [res] = nascv2WD(signal, startIdx, tMax, tMin)

time = signal(:,1);
a = signal(:,2);

clen = length(time);

maxSoFar = -Inf;
maxInWindowSoFar = -Inf;
res =0;

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
        
        topBottom = a((m + numWithinT):(m + numWithinT + numWithinTminusOne)) - secondMean;
        
        
        thisTopResult = top.*topBottom;
        totalSum = sum(thisTopResult);
        
        
        bottom = (numWithinT) * firstStd * secondStd;
        thisNascResult = totalSum/bottom;
        
        if thisNascResult >= maxSoFar
            maxSoFar = thisNascResult;
        end
        
    end
    
    if maxSoFar>=maxInWindowSoFar
        res = maxSoFar;
        maxInWindowSoFar = maxSoFar;
    end
end
end


