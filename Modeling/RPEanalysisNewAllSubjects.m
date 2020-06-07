% Maaike method 

% can we explain the zeros % MD115 does not want to load so Ive put 114 in
% twice as a placeholder. Issue is that MD115 has a ratingschange size of
% 255



load 'fit_explicit.mat'

R={  'MD101.mat' 'MD102.mat' 'MD103.mat' 'MD104.mat' 'MD105.mat' 'MD106.mat'...
     'MD107.mat' 'MD108.mat' 'MD109.mat' 'MD110.mat' 'MD111.mat' 'MD112.mat'...
     'MD113.mat' 'MD114.mat' 'MD114.mat' 'MD116.mat' 'MD117.mat' 'MD118.mat' 'MD119.mat'...
     'MD120.mat' 'MD121.mat' 'MD122.mat' 'MD123.mat' 'MD124.mat' 'MD125.mat'...
     'MD126.mat' 'MD127.mat' 'MD128.mat' 'MD129.mat'};
 
 
RPEregressions = zeros(29,8);
 
 for i = 1:length(R) % for data set

  load(R{i});
  [ rawratings(i,:) ratingschange(i,:) bard(i,:) errbard(i,:) baratot(i,:) errbaratot(i,:) barbtot(i,:) errbarbtot(i,:) earlyratings(i,:) lateratings(i,:)] = Graphing2TR (result); 



%Run this regression in a for loop of 1:30 repeats


K={  fit_explicit.SurrogateData(1).subject(1), fit_explicit.SurrogateData(i).subject(2)...
     fit_explicit.SurrogateData(1).subject(3), fit_explicit.SurrogateData(i).subject(4)...
     fit_explicit.SurrogateData(1).subject(5), fit_explicit.SurrogateData(i).subject(6)...
     fit_explicit.SurrogateData(1).subject(7), fit_explicit.SurrogateData(i).subject(8)...
     fit_explicit.SurrogateData(1).subject(9), fit_explicit.SurrogateData(i).subject(10)...
     fit_explicit.SurrogateData(1).subject(11), fit_explicit.SurrogateData(i).subject(12)...
     fit_explicit.SurrogateData(1).subject(13), fit_explicit.SurrogateData(i).subject(14)...
     fit_explicit.SurrogateData(1).subject(15), fit_explicit.SurrogateData(i).subject(16)...
     fit_explicit.SurrogateData(1).subject(17), fit_explicit.SurrogateData(i).subject(18)...
     fit_explicit.SurrogateData(1).subject(19), fit_explicit.SurrogateData(i).subject(20)...
     fit_explicit.SurrogateData(1).subject(21), fit_explicit.SurrogateData(i).subject(22)...
     fit_explicit.SurrogateData(1).subject(23), fit_explicit.SurrogateData(i).subject(24)...
     fit_explicit.SurrogateData(1).subject(25), fit_explicit.SurrogateData(i).subject(26)...
     fit_explicit.SurrogateData(1).subject(27), fit_explicit.SurrogateData(i).subject(28)...
     fit_explicit.SurrogateData(1).subject(29), fit_explicit.SurrogateData(i).subject(30)};




for h = 1:length(K) % for data set
   
    RPEmatrix = [fit_explicit.SurrogateData(1).subject(h).RPE1,fit_explicit.SurrogateData(1).subject(h).RPE2,fit_explicit.SurrogateData(1).subject(h).RPE3,fit_explicit.SurrogateData(1).subject(h).RPE4,fit_explicit.SurrogateData(1).subject(h).RPE5,fit_explicit.SurrogateData(1).subject(h).RPE6,fit_explicit.SurrogateData(1).subject(h).RPE7,fit_explicit.SurrogateData(1).subject(h).RPE8];
    
    regression (h,:) = regress((ratingschange(i,:))',RPEmatrix);
    
        %,fit_explicit.SurrogateData(1).subject(i).RPE2,fit_explicit.SurrogateData(1).subject(i).RPE3,fit_explicit.SurrogateData(1).subject(i).RPE4,fit_explicit.SurrogateData(1).subject(i).RPE5,fit_explicit.SurrogateData(1).subject(i).RPE6,fit_explicit.SurrogateData(1).subject(i).RPE7,fit_explicit.SurrogateData(1).subject(i).RPE8];
    %MD101regression(i) = regress(ratingschange',RPEmatrix(i));
end

RPEmeans = nanmean(regression, 1);
RPEregressions (i,:) = RPEmeans;

end 

    