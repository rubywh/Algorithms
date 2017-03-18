%{
This is the windowed peak detection function. It takes a set of timestamps
and acceleration readings and performs the peak detection over a window of
size wpdWinSize. There can only exist one peak per window and it must lie
above threshold 'thresh' in order to be counted as a step. The output is a
value for total number of steps taken. If input 'show' = 1, the
times/values of each step are recorded in a vector, which is displayed as a
scatter graph overlaying the plot of acceleration over time. 
%}

function totalSteps = myWpd(wpdInput, wpdWinSize, thresh, show)

%%% INPUTS %%%

    if ~exist ('wpdInput', 'var') || isempty(wpdInput)
        error('No input data to process');
    end

    %set default threshold value for wpd
    if ~exist ('thresh', 'var') || isempty(thresh)
        thresh = 10;
    end

    %length of window for peak detection
    if ~exist ('wpdWinSize', 'var') || isempty(wpdWinSize)
        wpdWinSize = 590000000;
    end

    %Don't graph by default
    if ~exist ('show', 'var') || isempty(show)
        show = 0;
    end

    
%%% Setup %%%
    %Get time elapsed
    wpdTimes = wpdInput(:,1);
    %Get smoothed accelerometer values
    wpdValues = wpdInput(:,2);

    %No steps have been recorded yet
    totalSteps = 0;

    %Count the number of smoothed acceleromter values
    clen = length(wpdValues);
    j = 1;
    
%%%Find Peaks%%%
    
    %Starting at the time elapsed of the first accelerometer reading
    %On each iteration, jump the number of seconds defined by the window
    for i = wpdTimes(1):wpdWinSize:wpdTimes(clen)-wpdWinSize

       %Find the index of the reading to be first in the window
       %i.e. the first one with time elapsed > i, such that it is the next
       %reading after the end of the previous window
        mIdx = find(wpdTimes>i,1);

        %If dealing with the first reading
        if i == 0
            %The window should start at this reading
            start = 1;
        else 
            start = mIdx;
        end

        %Set the time limit to the time at which the last item in the window
        %cannot exceed
        timeLimit = wpdTimes(start) + wpdWinSize;

        %Find the first item that exceeds the window timelimit
        %The last item in the window will be the reading before this one
        nIdx = find(wpdTimes>timeLimit,1);

        %Set up the window
        windowTimes= wpdTimes(start:nIdx-1);
        windowVals = wpdValues(start:nIdx-1);

        %Count the number of entries in the window
        %This will vary due to a varying sampling rate
        windowCount = length(windowVals);


        %Find the value and index of the peak within this window
        [maxVal, maxIdx] = max(windowVals);
        thisTime = windowTimes(maxIdx);
        thisVal = windowVals(maxIdx);

        %check maximum in window is greater than threshold
        if maxVal > thresh
            %If we wish to graph or see when specific steps occur
             if show == 1
               %Record time and value of peak in this window
               steps(j,1) = thisTime;
               steps(j,2) = thisVal;
             end
                %Increment the number of steps taken
                totalSteps = totalSteps +1;
                j=j+1;     
        end
    end


%%% Graphing functionality %%% 
    
    if show == 1
        %extract times at which steps occur
        stepTimes = steps(:,1);
        stepVals = steps(:,2);

        %plot my results with peaks marked as circles
        figure
        plot(wpdTimes, wpdValues)
        
        %On the same graph, scatter plot each step
        hold on
        scatter(stepTimes, stepVals, 'filled')
        title('My WPD Results, steps circled');
        
        xlabel('Time');
        ylabel('Smoothed Acceleration (m/s^2)');
    end 
end