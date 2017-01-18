function thresholding_script(timeVsAcceleration, accMagThresh, enerWalkingThresh, enerWinSize, sdWinSize, sdWalkingThresh)
 
time = timeVsAcceleration(:,1);
acceleration = timeVsAcceleration(:,2);
acc = thresh_accMag(time, acceleration);
%---------------------Acc--------------------------

accWalking = thresholding(acc, accMagThresh);

%plot the data for reference
figure
plot(time,acceleration,'b')
xlabel('Time (ms)');
ylabel('Acceleration (m/s.^2)');
title('Walk Detection using Acceleration');

hold on
%SD results
for len = 1:length(accWalking)
    if len == 1
       prev = 1;
    else
        prev = accWalking(len-1);
        %if two consecutive values are 'walking', plot a line between them
        if accWalking(len) == 1 && prev ==1;
        hold on
        %plot just the walking sections of the line
        plot(time(len-1:len), acceleration(len-1:len), 'r','LineWidth',0.8); 
        end
    end

end 



%-------------------Energy------------------------

energy = thresh_energy(acceleration, time, enerWinSize);
energyWalking = thresholding(energy, enerWalkingThresh);


%plot the data for reference
figure
plot(time,acceleration,'b')
xlabel('Time (ms)');
ylabel('Acceleration (m/s.^2)');
title('Walk Detection using Energy');

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


%---------------------SD--------------------------

%calculate the standard deviations 
sd = thresh_sd(acceleration, time, sdWinSize);

%perform thresholding on the standard deviations
sdWalking = thresholding(sd, sdWalkingThresh);

%plot the data for reference
figure
plot(time,acceleration,'b')
xlabel('Time (ms)');
ylabel('Acceleration (m/s.^2)');
title('Walk Detection using Standard Deviation');

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
end

function myAcc = thresh_accMag(time, acceleration)

sz = length(acceleration);
myAcc = zeros(sz, 2);

    for i=1:sz 
        myAcc(i,1) = time(i);
        myAcc(i,2) = acceleration(i);
        myAcc(i,3) = acceleration(i);
    end
end

function mySd = thresh_sd(vals, time, sdWinSize)

sz = length(vals);
window = zeros(sdWinSize);
    %Calculate sd of vals over sliding window
    for i=1:(sz - sdWinSize + 1)
            window = vals(i:i+sdWinSize-1);
            mySd(i,1) = time(i);
            mySd(i,2) = vals(i);
            mySd(i,3) = std(window);
    end
end

function myEnergy = thresh_energy(vals, time, enerWinSize)

sz = length(vals);
window = zeros(enerWinSize);

for i=1:(sz-enerWinSize + 1)
        window = abs(vals(i:i+enerWinSize-1)).^2;
        myEnergy(i,1) = time(i);
        myEnergy(i,2) = vals(i);
        myEnergy(i,3) =  trapz(window);
end
end

function walkResults = thresholding(array, thresh)

%times = array(:,1);
%sd or energy or acceleration
setValues = array(:,3);

%acceleration
%values = array(:,2);

vals = length(setValues);

%Check if each val over threshold, if so, assign 1
    for i=1:vals
        if(setValues(i) > thresh)
            walkResults(i) = 1;
        else
            walkResults(i) = 0;
        end
    end
end
