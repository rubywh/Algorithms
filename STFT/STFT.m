function [T,F,Stft] = STFT(acceleration, overlap, FFTLength, windowSize, threshold, show)

%length of each frame overlap
if ~exist ('overlap', 'var') || isempty(overlap)
    overlap = FFTLength / 2;
end

%length of each frame
if ~exist ('FFTLength', 'var') || isempty(FFTLength)
    FFTLength = 20;
end

if ~exist('windowSize', 'var') || isempty(windowSize)
     windowSize = 700000000;
end

if ~exist('threshold', 'var') || isempty(threshold)
     threshold = 20;
end

%plot or not, boolean
if ~exist ('show', 'var') || isempty(show)
    %set default to not plot
    show = 0;
end

time = acceleration(:,1);
acc = acceleration(:,2)-mean(acceleration(:,2));
dataSize = length(acc);

matrixRows = ceil(FFTLength/2 + 1);

%Number of columns can't depend on window size as this changed on each
%iteration. So dynamically add columns to Stft when needed..
%matrixCols = floor((dataSize-windowSize)/(windowSize - overlap)) + 1;

Stft = zeros(matrixRows)';

%Start at first reading, jump by windowSize each iteration
for i = time(1):windowSize:(time(dataSize)-windowSize)
    

    %Find the index of the reading to be first in the window
    %i.e. the first one with time elapsed > i, such that it is the next
    %reading after the end of the previous window
    mIdx = find(time>i,1);
    
    %empty the window
    currentWindow = [];
    
     %If dealing with the first reading
        if i == 0
            %The window should start at this reading
            start = 1;
        else 
            start = mIdx;
        end

        %Set the time limit to the time at which the last item in the window
        %cannot exceed
        timeLimit = time(start) + windowSize;

        %Find the first item that exceeds the window timelimit
        %The last item in the window will be the reading before this one
        nIdx = find(time>timeLimit,1);

        currentWindow(:,1) = acceleration(start:nIdx-1);

        %Count the number of entries in the window
        %This will vary due to a varying sampling rate
        wSize = length(currentWindow);
        
        %Construct window function
        windowFunction = hamming(wSize, 'periodic');

        %perform the fourier transform on this window 
        %i.e. multiply accelerometer data currently in window by the window function
        Y = fft(currentWindow.*windowFunction, FFTLength);

        %add the data from this frame to the spectogram
        %The row length is the length of the frame
        %the column length is the number of frames
        
        %add to S, the 1st column of the fft from 1 to half of the samples
        %Stft = [Stft Y(1:round(nsample/2), 1)];  

        %Stft(:,currentColumn) = Y(1:matrixRows);

        Stft = [Stft Y(1:matrixRows)];
        
end
    

 %%!! 
    for col = 1: length(Stft)
       % spectralEnergy = abs(Stft(:,col)).^2;
       Energy = sum(abs(Stft(:,col)).^2) / length(Stft(:,col))
    end
    
    T=[];
    F=[];

end


