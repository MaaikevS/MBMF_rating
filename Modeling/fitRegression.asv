 
function result = fitRegression(fit,R)
 
% usage: result = fitRegression(fit_explicit,R)
% 
% fit = fit_explicit or fit_implicit
% 
% R={  'MD101.mat' 'MD102.mat' 'MD103.mat' 'MD104.mat' 'MD105.mat' 'MD106.mat'...
%      'MD107.mat' 'MD108.mat' 'MD109.mat' 'MD110.mat' 'MD111.mat' 'MD112.mat'...
%      'MD113.mat' 'MD114.mat' 'MD115.mat' 'MD116.mat' 'MD117.mat' 'MD118.mat' 'MD119.mat'...
%      'MD120.mat' 'MD121.mat' 'MD122.mat' 'MD123.mat' 'MD124.mat' 'MD125.mat'...
%      'MD126.mat' 'MD127.mat' 'MD128.mat' 'MD129.mat'};
% 

addpath('..\\Data')
warning off

nsub = length(R);
RPEregressions = zeros(nsub,8);
 
for sub = 1:nsub % number of participants
    
    % Get the change in rating (see function below)
    ratingschange = getRating(sub,R); 

    %Run this regression in a for loop of 1:30 repeats
    for repeat = 1:30 % number of repeats

        % Create a matrix with predictors
        RPEmatrix = [fit.SurrogateData(sub).subject(repeat).RPE1,...
                     fit.SurrogateData(sub).subject(repeat).RPE2,...
                     fit.SurrogateData(sub).subject(repeat).RPE3,...
                     fit.SurrogateData(sub).subject(repeat).RPE4,...
                     fit.SurrogateData(sub).subject(repeat).RPE5,...
                     fit.SurrogateData(sub).subject(repeat).RPE6,...
                     fit.SurrogateData(sub).subject(repeat).RPE7,...
                     fit.SurrogateData(sub).subject(repeat).RPE8];
        
        if length(RPEmatrix) < 256 % participant did not respond on last trial
            RPEmatrix(length(RPEmatrix),1:8) = nan;
        end

        regression(repeat,:) = regress((ratingschange)',RPEmatrix);

    end

    RPEmeans = nanmean(regression, 1);
    RPEregressions (sub,:) = RPEmeans;
    
    result(sub).regression = regression; % store results of all 30 regressions
    result(sub).RPEmeans = RPEmeans; % store the mean of the repeats
    
end

% summary of all subjects
result(1).RPEregressions = RPEregressions;

end
   
function ratingschange = getRating(sub,R)

  load(R{sub});
  [ ~, ratingschange] = Graphing2TR(result); 

end