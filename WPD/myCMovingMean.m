function cmmResult = myCMovingMean(timeVsAcceleration, cmmWinSize)
    
    time = timeVsAcceleration(:,1);
    acceleration = timeVsAcceleration(:,2);

    %find number of signal entries
    xlen = length(acceleration);
    
    timeLimit = time(1) + cmmWinSize;
    firstWinIdx = find(time>timeLimit,1);
    firstWindow = acceleration(1:firstWinIdx-1);
    firstWindowSize = length(firstWindow);
         
      if mod(firstWindowSize, 2) == 0
          start = firstWindowSize/2;
      else 
          start = ceil(firstWindowSize/2);
      end 

    lastTime = time(xlen) - cmmWinSize;
    
    %for each reading
    j=1;
    
    
for i=start:xlen-start
    %if we have hit the final window
      if time(i) == lastTime
         %stop the loop
         break;  
      end
     
      %setup an empty window
      window = [];
            
    timeLimit = time(j) + cmmWinSize;
    %+ wpdWinSize
   % mIdx = find(time>time(i),1);
    %start = mIdx-1;
    nIdx = find(time>timeLimit,1);
   % windowTimes= time(start:nIdx-1);
    window = acceleration(j:nIdx-1);
    windowCount = length(window);
      
     %{
      %time for which the window cannot go past
      timeLimit = time(i) + cmmWinSize;
      
      %fill the window
      idx = find(time>=timeLimit);
      window = acceleration(i:idx-1);
       %}
    
      %calculate the cmm entry for that window
      total = sum(window);
      cmm = total/windowCount;
      cmmResult(i,1)= time(i);
      cmmResult(i,2) = cmm;
      j=j+1;
end   
end
