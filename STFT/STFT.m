%not yet working

function Stft = STFT(x, frameOverlap, frameLength, fs, show)

% length of the signal
xlen = length(x);


%length of each frame overlap
if ~exist ('frameOverlap', 'var') || isempty(frameOverlap)
    frameOverlap = frameLength / 2;
end

%length of each frame
if ~exist ('frameLength', 'var') || isempty(frameLength)
    frameLength = 20;
end

if ~exist('fs', 'var') || isempty(fs)
     fs = 10000;
end

%plot or not, boolean
if ~exist ('show', 'var') || isempty(show)
    %set default to not plot
    show = 0;
end

%number of entries per frame
nsample = round(frameLength * fs / 1000); 
window = hamming(nsample, 'periodic');

N = length(x);
Stft = [];
pos = 1;


%while the frame lies within the acceleration readings vector
while(pos+nsample <=N)
    %set up the frame
    frame = x(pos: pos + nsample - 1)';
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


%unsure about this bit

%Generate the frequency vector
% # entries = window length
% vector of M rows, 1 column of frequencies 
% Take set of values: 0, 1, 2....(nsample/2)-1;
% 
%F = (0:round(nsample/2)-1)' / nsample * freq;
%divide each element by #in frame * freq i.e. number of fft points

%1 row, K columns with values that correspond to center of each frame
%[round(nsample/2), round(nsample/2) + (nsample - noverlap),
%round(nsample/2) + 2(nsample - noverlap)...
    % round(nsample/2) + m(nsample - noverlap)
    % m = fix((N-1-round(nsample/2) - round(nsample/2))/(nsample -
    % noverlap)
    
    %fix rounds each element to nearest integer towards zero
    
    %start at half of nsample, add overlap each time
    %until half of final frame
%T = (round(nsample/2):(nsample-noverlap):N-1-round(nsample/2))/freq;

end

