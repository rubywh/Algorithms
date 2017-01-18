function Topt = nasc(idx, signal, tmin, tmax)

%correlation is a measure of how similar two signals are
%scale correlation function by factor determined by energy of signals
myTime = signal(:,1);
acceleration = signal(:,2);
len = length(acceleration);

%calculate only over 2 second window 
i =1;
%calculate correlation

%replace for conditions with array of t's to try.
    for t=tmin:tmax
       
        sum = 0; 
        for k=0:t-1
            
             if (idx + k) > len || (idx + t) > len || (idx + 2*t-1) > len
                  sum = NaN;
                  break;
             else
                a = acceleration(idx + k) - mean(acceleration(idx:idx+t-1));
                b = acceleration(idx + k + t) - (mean(acceleration((idx+t):idx+2*t-1)));
                sum = sum + (a*b);
             end
        end

        if (idx + k + t-1) > len || (idx + t -1) > len 
                  s1 = NaN;
                  s2 = NaN;
        else
            %scale by factor
            s1 = std(acceleration(idx:idx+k+t-1));
            s2 = std(acceleration(idx:idx+t-1));

            result(i, 1) = t;
            result(i, 2) = sum/(t*s1*s2);
            i = i+1;
        end
   end
   Topt = max(result(:,2));
end