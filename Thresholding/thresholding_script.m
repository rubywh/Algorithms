

%%% Master Function to get results for each metric %%%

function thresholding_script(timeVsAcceleration, accMagThresh, enerWalkingThresh, enerWinSize, sdWinSize, sdWalkingThresh)
 

    time = timeVsAcceleration(:,1);
    acceleration = timeVsAcceleration(:,2);
    

    %plot the data for reference
    figure
    plot(time,acceleration,'b')
    xlabel('Time');
    ylabel('Acceleration (m/s.^2)');
    title('Walk Detection using Acceleration');


    %---------------------Acceleration Magnitude--------------------------

    %Format for input into thresholding function
    acc(:,1) = time;
    acc(:,2) = acceleration;
    
    %Returns a vector of times vs binary values 
    accWalking = thresholding(acc, accMagThresh);

    %{
    hold on
    for len = 1:length(times)
        if len == 1
           prev = 0;
        else
            prev = binary(len-1);
            %if two consecutive values are 'walking', plot a line between them
            if binary(len) == 1 && prev ==1;
            %plot just the walking sections of the line
            plot(times(len-1:len), accelerations(len-1:len), 'r','LineWidth',0.8); 
            end
        end
    end
    %}


    %-------------------Energy------------------------
    adjustedAcceleration = acceleration - mean(acceleration);
    energy = thresh_energy(time, adjustedAcceleration, enerWinSize);
    energyWalking = thresholding(energy, enerWalkingThresh);


    %{
    plot the data for reference
    figure
    plot(time,acceleration,'b')
    xlabel('Time (ms)');
    ylabel('Acceleration (m/s.^2)');
    title('Walk Detection using Energy');
    %}

    %{
    hold on
    %SD results
    for len = 1:length(energyWalking)
        if len == 1
           prev = 1;
        else
            prev = energyWalking(len-1);
            %if two consecutive values are 'walking', plot a line between them
            if energyWalking(len) == 1 && prev ==1;
            hold on
            %plot just the walking sections of the line
            plot(time(len-1:len), acceleration(len-1:len), 'r','LineWidth',0.8); 
            end
        end

    end 
    %}


    %---------------------SD--------------------------

    %calculate the standard deviations 
    sd = thresh_sd(time, acceleration, sdWinSize);

    %perform thresholding on the standard deviations
    sdWalking = thresholding(sd, sdWalkingThresh);

    %plot(time, sdWalking);
    %{
    hold on
    %SD results
    for len = 1:length(sdWalking)
        if len == 1
           prev = 1;
        else
            prev = sdWalking(len-1);
            %if two consecutive values are 'walking', plot a line between them
            if sdWalking(len) == 1 && prev ==1;
            hold on
            %plot just the walking sections of the line
            plot(time(len-1:len), acceleration(len-1:len), 'r', 'LineWidth',0.8); 
            end
        end
    end
    %}
end


%{
  mySd column 1 contains time elapsed of reading, column 2 contains the
  calculated standard deviation for that window. Uses a jumping window for
  now but may need sliding window?
%}
function mySd = thresh_sd(sdInTime, sdInVals, sdWinSize)

    aSz = length(sdInVals);

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
        mySd(aStart:anIdx-1,1) = aWindowTimes;
        mySd(aStart:anIdx-1,2) = thisStd;
        
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
end


%{
  myEnergy column 1 contains time elapsed of reading, column 2 contains the
  calculated energy for that window. Uses a jumping window for
  now but may need sliding window?

!! This is not giving correct results at the moment
- all energy values lie way above 0.04 threshold despite subtracting mean
from accelration values.
%}
function myEnergy = thresh_energy(time, vals, enerWinSize)

    %Shift data down in preparation for energy calculation
    vals = vals - mean(vals);
    sz = length(vals);
 

    for i = time(1):enerWinSize:time(sz)
        timeLimit = i + enerWinSize;
        mIdx = find(time>i,1);
        start = mIdx-1;
        nIdx = find(time>timeLimit,1);
        
        %Set up the window
        windowTimes= time(start:nIdx-1);
        windowVals = vals(start:nIdx-1);
        windowCount = length(windowVals);
        
        %Calculate the enrgy of the values in the window
        energy = trapz(windowTimes, (abs(windowVals)).^2);
        
        %Set energy values in the output
        myEnergy(start:nIdx-1,1) = windowTimes;
        myEnergy(start:nIdx-1,2) = energy;
    end    
       %{
    %window = zeros(enerWinSize);
        for i=1:(sz-enerWinSize + 1)
                window = abs(vals(i:i+enerWinSize-1)).^2;
                myEnergy(i,1) = time(i);
                myEnergy(i,2) = vals(i);
                myEnergy(i,3) =  trapz(window);
        end
    %}
end

%%%%%% perform thresholding %%%%%%

function walkResults = thresholding(array, thresh)
    walkResults = zeros(length(array),2);
    vals = length(array(:,1));

    %Check if each val over threshold, if so, assign 1
    for i=1:vals
        walkResults(i,1) = array(i,1);
        if (array(i,2) > thresh)
            walkResults(i,2) = 1;
        else
            walkResults(i,2) = 0;
        end
    end
end
