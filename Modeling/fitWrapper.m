function [fit]  = fitWrapper(data,functionName,EM,parallel)
% 
% USAGE: [fit] = fitWrapper(data,functionName,EM,parallel)
%
% INPUTS:
%     data:         groupdata_explicit.data or groupdata_implicit.data
%     functionName: 'LLmodelRating' or 'LLmodelRating_new'
%     EM:           1 if hierarchical fit, 0 if individual fit
%     parallel:     1 if parallel loop, 0 if not

% OUTPUT:
%     fit: structure that contains:
%         the model properties
%         model fitting results
%         BIC values
%         surrogate data
%         real data

%% Find parameter estimates
nStarts = 5;
nsub = length(data);
    
% disp(['Fitting model ',num2str(1)])
% model = getParam(modelN,type,0);

model.parnames = {'\beta_{1/2}', '\alpha_{1/2}','\lambda', '\omega', '\pi'};
model.parnamesU = {'b_{1/2}', 'a_{1/2}','l', 'w', 'p'};

param = struct;
for i = 1:length(model.parnames)%model.npar
    param(i).name = model.parnames{i};
end

opts.generatesurrogatedata = 0;
opts.simulate = 0;
fun = str2func(functionName);
likfun = @(x,data) fun(x,data,opts);

if EM == 1 % expectation - maximisation
    [results] = optimiseLL_EM(likfun,param,data,nStarts,nsub,parallel);
else
    results = optimiseLL(likfun,param,data,nStarts,nsub);
end

fit.results = results;
fit.model = model;
fit.param = param;
fit.BIC = sum(results.BIC);
fit.fitfun = fun;
   
%% Generate surrogate data

fit.SurrogateData = generateSurrData(data,fit.results.paramfit,fun);
fit.RealData = data;

disp(['Done']);

end
