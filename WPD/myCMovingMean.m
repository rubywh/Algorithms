function cmmResult = myCMovingMean(timeVsAcceleration, cmmWinSize)
    
    time = timeVsAcceleration(:,1);
    acceleration = timeVsAcceleration(:,2);

    %find number of signal entries
    xlen = length(acceleration);
    
    %indices for checking the first window
    v=1;
    d=1;
    %setup the first window  and get its length so to know 
    %at what index to start writing results
	timeLimit = time(1) + cmmWinSize;
    while time(v) < timeLimit
        window(d) = acceleration(v);
        v=v+1;
        d=d+1;
    end
      
      firstWindowSize = length(window);
      
      if mod(firstWindowSize, 2) == 0
          start = firstWindowSize/2;
      else 
          start = ceil(firstWindowSize);
      end 

    lastTime = time(xlen) - cmmWinSize;
    
    %for each reading
    for i=start:xlen
        
    %if we have hit the final window
      if time(i) == lastTime
         %stop the loop
         break;  
      end
      
      %setup an empty window
      window = [];
     
      %time for which the window cannot go past
      timeLimit = time(i) + cmmWinSize;
      
      %fill the window
      idx = find(time>=timeLimit);
      window = acceleration(i:idx-1);
       
      %calculate the cmm entry for that window
      total = sum(window);
      cmm = total/length(window);
      cmmResult(i,1)= time(i);
      cmmResult(i,2) = cmm;
    end   
end
