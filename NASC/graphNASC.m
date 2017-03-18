%%% function to take results and graph them
% graph the two signals

% graph the whole timeVsAcceleration, scatter plot where tOpt/2 is for
% nascV1, adjust t per reading.
%[tSteps ,timeVsAcceleration, toptResults] = nascdemov1();
    

f1 = @() nascdemov1; % handle to function
timeForV1 = timeit(f1)

f2 = @() NASC_script; % handle to function
timeForV2 = timeit(f2)

f3 = @() nascDemo3; % handle to function
timeForV3 = timeit(f3)

f4 = @() nascDemo4; % handle to function
timeForV4 = timeit(f4)


%figure
%plot(timeVsAcceleration(:,1), timeVsAcceleration(:,2))


%graph the whole window, scatter plot where tOpt/2 is for nascV2 (try all
%ts on all windows)

%graph the second window, with the initial topt 
% show that it works as couting a step
%graph the slow walkijn seciont (the one where it has to adjust)
% graph what would have happened if had kept topt there
%plot nasc overtime (on top of graph) , show how it fluctuates.

%graph the whole tVA, scatter plot for nascV4 (single topt)
%maybe run find peaks? 