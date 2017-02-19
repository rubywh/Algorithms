function o = StandardDeviation(x, sdWinSize )



    sdInTime = x(:,1);
    sdInVals = x(:,2);
    
    aSz = length(sdInVals);
       for j = 1:aSz
        aTimeLimit = sdInTime(j) + sdWinSize;
        amIdx = find(sdInTime>sdInTime(j),1);
        aStart = amIdx-1;
        anIdx = find(sdInTime>aTimeLimit,1);

        %Set up the window
        aWindowTimes= sdInTime(aStart:anIdx-1);
        aWindowVals = sdInVals(aStart:anIdx-1);
        aWindowCount = length(aWindowVals);   
        windowCounts(j,1) = aWindowCount;
       end
    
    
    
    o = ones(aSz, 1);
    
    for i = 1:aSz
        thisWinSize = windowCounts(i,1);  
        h = floor(thisWinSize /2);
        o(i,1) = std(sdInVals(max(1, i - h): min(aSz, i + h)));
    end
    
    
%{
    for j = sdInTime(1):sdWinSize:sdInTime(aSz)
        aTimeLimit = j + sdWinSize;
        amIdx = find(sdInTime>j,1);
        aStart = amIdx-1;
        anIdx = find(sdInTime>aTimeLimit,1);

        %Set up the window
        aWindowTimes= sdInTime(aStart:anIdx-1);
        aWindowVals = sdInVals(aStart:anIdx-1);
        aWindowCount = length(aWindowVals);   
        
        %Calculate SD of the window
        thisStd = std(aWindowVals);

        %Set the SD value for each item in the window
        stdDeviation(aStart:anIdx-1,1) = aWindowTimes;
        stdDeviation(aStart:anIdx-1,2) = thisStd;
        
    %{
    window = zeros(sdWinSize);
        %Calculate sd of vals over sliding window
        for i=1:(sz - sdWinSize + 1)
                window = vals(i:i+sdWinSize-1);
                mySd(i,1) = time(i);
                mySd(i,2) = vals(i);
                mySd(i,3) = std(window);
        end
    %}
    end
    %}
end


