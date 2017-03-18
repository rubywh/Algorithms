function [maxSoFar] = nascv1WD(signal,p, tMin, tMax)

time = signal(:,1);
a = signal(:,2);

clen = length(time);

maxSoFar = -Inf;


for testT = tMin: 10000000: tMax
    timeLimit = time(p) + testT;
    
    %get index for first item greater than timestamp
    %get t-1
    tMinusOneIndex= find(time>timeLimit,1) - 2;
    
    %number of items in range from m to t-1
    numWithinTminusOne = length(time(p:tMinusOneIndex));
    numWithinT = numWithinTminusOne+1;
    
    if (p + numWithinT + numWithinT -1) > clen
        break;
    end
    
    firstMean = mean(a(p:tMinusOneIndex));
    secondMean = mean(a((p + numWithinT):(p + numWithinT + numWithinTminusOne)));
    firstStd =  std(a(p:tMinusOneIndex ));
    secondStd = std(a((p + numWithinTminusOne):(p + numWithinT + numWithinTminusOne)));
    
    top = a(p:numWithinTminusOne + p) - firstMean;
    % topTimes = time(p:numWithinTminusOne + p);
    topBottom = a((p + numWithinT):(p + numWithinT + numWithinTminusOne)) - secondMean;
    % topBottomTimes = time((p + numWithinT):(p + numWithinT + numWithinTminusOne));
    thisTopResult = top.*topBottom;
    totalSum = sum(thisTopResult);
    
    bottom = (numWithinT+1) * firstStd * secondStd;
    thisNascResult = totalSum/bottom;
    
    if thisNascResult >= maxSoFar
        maxSoFar = thisNascResult;
    end
end