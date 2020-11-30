function SurrogateData = generateSurrData(D,par,fun)

nSamples = 30;
nsub = length(D);

dsurr0 = repmat(struct('A',[],'S',[], 'R',[], 'trans',[],'Qmb_chosen',[],...
    'Qmb_unchosen',[],'Qmf_chosen',[], 'Qmf_unchosen',[], 'Qmb_new_chosen',[],'Qmb_new_unchosen',[],...
    'Qs2_chosen',[],'Qs2_unchosen',[], 'winState',[], 'bestStateChosen',[],'bestS1choice',[],...
    'RPE1',[],'RPE2',[], 'RPE3',[], 'RPE4',[],'RPE5',[],'RPE6',[], 'RPE7',[],'RPE8',[],...
     'RPE9',[],'RPE10',[],'RPE11',[],'TruePar',[], 'Nch',[]),1,nSamples);
opts.generatesurrogatedata = 1;
opts.simulate = 0;

disp(['Generating surrogate data']);

% fun = str2func('LLmodelRating');

for sub=1:nsub
    dsurr=dsurr0;
    for ns=1:nSamples
        [~,~,dsurr(ns)] = fun(par(sub,:),D(sub),opts); 
    end
    SurrogateData(sub).subject = dsurr; 
end


end
