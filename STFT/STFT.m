function [T,F, Stft] = STFT(x, frameOverlap, frameLength, fs, show)

threshSpecEnergy = 20;
% length of the signal
xlen = length(x(:,2));


%length of each frame overlap
if ~exist ('frameOverlap', 'var') || isempty(frameOverlap)
    frameOverlap = frameLength / 2;
end

%length of each frame
if ~exist ('frameLength', 'var') || isempty(frameLength)
    frameLength = 20;
end

if ~exist('fs', 'var') || isempty(fs)
     fs = 7000;
end

%plot or not, boolean
if ~exist ('show', 'var') || isempty(show)
    %set default to not plot
    show = 0;
end

%number of entries per frame
nsample = round(frameLength * fs / 1000)
window = hamming(nsample, 'periodic');

acc = x(:,2);
N = length(acc);
Stft = [];
pos = 1;


%while the frame lies within the acceleration readings vector
while(pos+nsample <=N)
    %set up the frame
    frame = acc(pos: pos + nsample - 1);
    %set starting position of new frame
    pos = pos + (nsample - frameOverlap);
    %perform the fourier transform on this frame 
    %i.e. multiply accelerometer data currently in frame by the window function
    %perform this over nsample number of points
    Y = fft(frame .* window, nsample);
    %add the data from this frame to the spectogram
    %The row length is the length of the frame
    %the column length is the number of frames
    
    %add to S, the 1st column of the fft from 1 to half of the samples
    Stft = [Stft Y(1:round(nsample/2), 1)];  
end

handleSTFT(Stft, threshSpecEnergy);

spectrogram(acc, window, frameOverlap);

%unsure about this bit

%Generate the frequency vector
% Take set of values: 0, 1, 2....(nsample/2)-1;
% f = 1/T = fs/N

    F = (0:round(nsample/2)-1)' / nsample * fs
  
    %T = N/fs where N = number of samples acquired
    % time at which STFT calculated each time, i.e. centre of frame
    T = (round(nsample/2):(nsample-frameOverlap):N-1-round(nsample/2))/fs;

end

function results = handleSTFT(stft, threshSpecEnergy)

end


