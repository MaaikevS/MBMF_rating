function [output] = AnalyseBehaviour(implicit,toplot)
% Inputs:
%   implicit = 1 when data of implicit task should be analysed
%   implicit = 0 when data of explicit task should be analysed
%   toplot   = 1 when data should be plotted, else 0
%
% Output:
%   output   = structure
%     .StayData     = stay probabilities
%     .StaySim      = stay probabilities simulated data
%     .Rating       = ratings
%     .Attention    = attention effect on stay behaviour
%     .Location     = location effect on stay behaviour
%     .MB           = model-based control
%     .MF           = model-free control
%     .MBsim        = model-based control simulated data
%     .MFsim        = model-free control simulated data
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if implicit 
    load('Fit_implicit22.mat')
    SurrData = fit_implicit.SurrogateData;
    data = fit_implicit.RealData;
    experiment = 'Implicit task';
else
    load('Fit_explicit28.mat')
    SurrData = fit_explicit_28.SurrogateData;
    data = fit_explicit_28.RealData;
    experiment = 'Explicit task';
end

nsub        = length(data);
nRepeat     = length(SurrData(1).subject);
rr          = nan(nsub,4);
rrs         = nan(nsub,4,nRepeat);
missed      = nan(nsub,1);
AvRating    = nan(nsub,4);
AvAttention = nan(nsub,4);
ll          = nan(nsub,4);

for sub = 1:nsub
    %% Analyse Real Data
    a       = data(sub).A;
    missed(sub,1) = sum(isnan(sum(a,2)));
    idx     = find(~isnan(sum(a,2)));
    a       = a(idx,:);
    s       = data(sub).S(idx,:);
    r       = data(sub).R(idx);
    trans   = data(sub).trans(idx);
    stay    = a(2:end,1)==a(1:end-1,1);
    rr(sub,1) = mean(stay (trans(1:end-1)==1 & r(1:end-1)==1)); % CR
    rr(sub,2) = mean(stay (trans(1:end-1)==0 & r(1:end-1)==1)); % RR
    rr(sub,3) = mean(stay (trans(1:end-1)==1 & r(1:end-1)==0)); % CU
    rr(sub,4) = mean(stay (trans(1:end-1)==0 & r(1:end-1)==0)); % RU
    
    %% Analyse Rating and Attention effect
    irrelshape      = data(sub).shapeIdx(idx,:);
    ratingIdx       = data(sub).ratingIdx(idx);
    attentionIdx    = data(sub).attentionIdx(idx);
    attIdx          = ~isnan(data(sub).attentionIdx(idx));
    c1              = data(sub).A(idx,1);
    win             = data(sub).R(idx);
    stay            = c1(2:end,1)==c1(1:end-1,1);
    correct         = data(sub).correct(idx);
    u1              = 3 - c1;
    ratings         = data(sub).rating(idx);

    chosenShapes    = nan(length(c1),1);
    unchosenShapes  = nan(length(u1),1);

    for t = 1:length(c1)
        if c1(t) ~= -1
            chosenShapes(t) = irrelshape(t,c1(t));
            unchosenShapes(t) = irrelshape(t,u1(t));
        end
    end

    woncs   = nan(length(c1),1);    % last time won chosen shape
    wonus   = nan(length(c1),1);    % last time won unchosen shape 
    MWc     = nan(length(c1),1);    % working memory chosen shape
    MWu     = nan(length(c1),1);    % working memory unchosen shape
    commonC = nan(length(c1),1);    % transition chosen shape
    commonU = nan(length(c1),1);    % transition unchosen shape
    last_chosen_distance    = nan(length(c1),1);    % distance between probes chosen
    last_unchosen_distance  = nan(length(c1),1);    % distance between probes unchosen
    correctChoice           = nan(length(c1),1);    % choice that leads to best outcome

    for i = 1:length(c1)
        % find the last time chosen stimulus was probed
        lastcs = find(chosenShapes(1:i) == ratingIdx(i), 1, 'last'); 
        % find last time the unchosen shape was choice 1 
        lastus = find(unchosenShapes(1:i) == ratingIdx(i), 1, 'last');

        % for chosen shape
        if ~isempty(lastcs)
            woncs(i)        = win(lastcs);
            MWc(i)          = attentionIdx(lastcs); 
            commonC(i)      = trans(lastcs);
            correctChoice(i) = correct(lastcs);
            last_chosen_distance(i) = i - lastcs;
        end

        % for unchosen shape
        if ~isempty(lastus)
            wonus(i)        = win(lastus);
            commonU(i)      = trans(lastus);
            MWu(i)          = attentionIdx(lastus); 
            last_unchosen_distance (i) = i - lastus;
        end

    end

    % standardisation of ratings 
    rawmean = nanmean(ratings);
    stdratings = nanstd(ratings); 
    normratingz = nan(length(c1),1);
    
    for i = 1:length(c1) 
        normratingz(i) = ((ratings(i)-rawmean)/ stdratings);
    end 
    normratings = tiedrank (normratingz);

    % Compute average rating for each transition and reward
    AvRating(sub,1)= nanmean(normratings(commonC == 1 & woncs == 1));
    AvRating(sub,2)= nanmean(normratings(commonC == 0 & woncs == 1));
    AvRating(sub,3)= nanmean(normratings(commonC == 1 & woncs == 0));
    AvRating(sub,4)= nanmean(normratings(commonC == 0 & woncs == 0));

    % Effect of attention on stay behaviour for each transition and reward
    % Substract the trials without attention to assess the effect of the
    % manipulation
    AvAttention(sub,1)=(nanmean(stay(win(1:end-1) & attIdx(1:end-1) & trans(1:end-1)))) - ...
        (nanmean(stay(win(1:end-1) & attIdx(1:end-1) == 0 & trans(1:end-1)))); % CR
    AvAttention(sub,2)=(nanmean(stay(win(1:end-1) & attIdx(1:end-1) & trans(1:end-1)==0))) - ...
        (nanmean(stay(win(1:end-1) & attIdx(1:end-1) == 0 & trans(1:end-1)==0)));% RR
    AvAttention(sub,3)=(nanmean(stay(win(1:end-1)==0 & attIdx(1:end-1) & trans(1:end-1)))) - ...
        (nanmean(stay(win(1:end-1)==0 & attIdx(1:end-1) == 0& trans(1:end-1))));% CU
    AvAttention(sub,4)=(nanmean(stay(win(1:end-1)==0 & attIdx(1:end-1) & trans(1:end-1)==0))) - ...
        (nanmean(stay(win(1:end-1)==0 & attIdx(1:end-1) == 0& trans(1:end-1)==0)));% RU
    
    %% Analyse location effects
    location        = data(sub).location(idx);
    locationStay    = location(2:end,1) == location(1:end-1,1);
    
    ll(sub,1) = mean(locationStay (trans(1:end-1)==1 & r(1:end-1)==1)); % CR
    ll(sub,2) = mean(locationStay (trans(1:end-1)==0 & r(1:end-1)==1)); % RR
    ll(sub,3) = mean(locationStay (trans(1:end-1)==1 & r(1:end-1)==0)); % CU
    ll(sub,4) = mean(locationStay (trans(1:end-1)==0 & r(1:end-1)==0)); % RU

    %% Analyse Surrogate data
    for it=1:nRepeat
        a = SurrData(sub).subject(it).A;
        i = ~isnan(sum(a,2));
        a = a(i,:);
        s = SurrData(sub).subject(it).S(i,:);
        r = SurrData(sub).subject(it).R(i);
        trans = SurrData(sub).subject(it).trans(i);
        stay = a(2:end,1)== a(1:end-1,1);
        rrs(sub,1,it) = mean(stay (trans(1:end-1)==1 & r(1:end-1)==1));
        rrs(sub,2,it) = mean(stay (trans(1:end-1)==0 & r(1:end-1)==1));
        rrs(sub,3,it) = mean(stay (trans(1:end-1)==1 & r(1:end-1)==0));
        rrs(sub,4,it) = mean(stay (trans(1:end-1)==0 & r(1:end-1)==0));
    end
end

% Compute the model-based and model-free values
mb = (rr(:,1) - rr(:,2)) - (rr(:,3) - rr(:,4));
mf = (rr(:,1) + rr(:,2)) - (rr(:,3) + rr(:,4));
mbs = rrs(:,1,:) - rrs(:,2,:) - (rrs(:,3,:) - rrs(:,4,:));
mfs = rrs(:,1,:) + rrs(:,2,:) - (rrs(:,3,:) + rrs(:,4,:));

stayData = rr;
staySim = squeeze(nanmean(rrs(:,:,:),3));
stayLocation = ll;

%% Plot the data
if toplot   % plot the data
%% Stay behaviour real data
    f = figure;
    axes1 = subplot(1,5,1);
    hold(axes1,'on');

    y = [mean(stayData(:,1:2)); mean(stayData(:,3:4))];
    stdev = [std(stayData(:,1:2)); std(stayData(:,3:4))]/sqrt(nsub);

    ngroups = size(y, 1);
    nbars = size(y, 2);
    groupwidth = min(0.8, nbars/(nbars + 1.5));

    ha1 = bar(y, 'Parent',axes1,'BarWidth',1);
    set(ha1(1),'DisplayName','Common','FaceColor','b', 'FaceAlpha', 1);
    set(ha1(2),'DisplayName','Rare','FaceColor','r', 'FaceAlpha', 1);
    for i = 1:nbars
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        errorbar(x, y(:,i), stdev(:,i),'k', 'LineStyle', 'none');
    end
    box(axes1,'on');
    set(axes1,'XTick',[1 2],'XTickLabel',{'Rewarded','Unrewarded'});
    set(axes1,'Ylim',[0.5 1], 'YTick',[0.5 0.75 1]);
    ylabel('Stay Probability');
    title('Real Data');

%% Stay behaviour Simulated data
    axes3 = subplot(1,5,3);
    hold(axes3,'on');

    y = [mean(staySim(:,1:2)); mean(staySim(:,3:4))];
    stdev = [std(staySim(:,1:2)); std(staySim(:,3:4))]/sqrt(nsub);

    ngroups = size(y, 1);
    nbars = size(y, 2);
    groupwidth = min(0.8, nbars/(nbars + 1.5));

    ha1 = bar(y, 'Parent',axes3,'BarWidth',1);
    set(ha1(1),'DisplayName','Common','FaceColor','b', 'FaceAlpha', 1);
    set(ha1(2),'DisplayName','Rare','FaceColor','r', 'FaceAlpha', 1);
    for i = 1:nbars
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        errorbar(x, y(:,i), stdev(:,i),'k', 'LineStyle', 'none');
    end
    box(axes3,'on');
    set(axes3,'XTick',[1 2],'XTickLabel',{'Rewarded','Unrewarded'});
    set(axes3,'Ylim',[0.5 1], 'YTick',[0.5 0.75 1]);
    ylabel('Stay Probability');
    title('Simulated Data');

%% Rating data
    axes2 = subplot(1,5,2);
    hold(axes2,'on');

    y = [mean(AvRating(:,1:2)); mean(AvRating(:,3:4))];
    stdev = [std(AvRating(:,1:2)); std(AvRating(:,3:4))]/sqrt(nsub);

    ngroups = size(y, 1);
    nbars = size(y, 2);
    groupwidth = min(0.8, nbars/(nbars + 1.5));

    ha1 = bar(y, 'Parent',axes2,'BarWidth',1);
    set(ha1(1),'DisplayName','Common','FaceColor','b', 'FaceAlpha', 1);
    set(ha1(2),'DisplayName','Rare','FaceColor','r', 'FaceAlpha', 1);
    for i = 1:nbars
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        errorbar(x, y(:,i), stdev(:,i),'k', 'LineStyle', 'none');
    end
    box(axes2,'on');
    set(axes2,'XTick',[1 2],'XTickLabel',{'Rewarded','Unrewarded'});
    set(axes2,'Ylim',[110 150], 'YTick',[110 120 130 140 150]);
    ylabel('Rating');
    title('Ratings');

%% Effect of Attention on stay behaviour
    axes4 = subplot(1,5,4);
    hold(axes4,'on');

    y = [mean(AvAttention(:,1:2)); mean(AvAttention(:,3:4))];
    stdev = [std(AvAttention(:,1:2)); std(AvAttention(:,3:4))]/sqrt(nsub);

    ngroups = size(y, 1);
    nbars = size(y, 2);
    groupwidth = min(0.8, nbars/(nbars + 1.5));

    ha1 = bar(y, 'Parent',axes4,'BarWidth',1);
    set(ha1(1),'DisplayName','Common','FaceColor','b', 'FaceAlpha', 1);
    set(ha1(2),'DisplayName','Rare','FaceColor','r', 'FaceAlpha', 1);
    for i = 1:nbars
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        errorbar(x, y(:,i), stdev(:,i),'k', 'LineStyle', 'none');
    end
    box(axes4,'on');
    set(axes4,'XTick',[1 2],'XTickLabel',{'Rewarded','Unrewarded'});
    set(axes4,'Ylim',[-0.1 0.1], 'YTick',[-0.1 0 0.1]);
    ylabel('Stay Probability');
    title('Attention Effect');
    
%% Stay behaviour Location
    axes5 = subplot(1,5,5);
    hold(axes5,'on');

    y = [mean(stayLocation(:,1:2)); mean(stayLocation(:,3:4))];
    stdev = [std(stayLocation(:,1:2)); std(stayLocation(:,3:4))]/sqrt(nsub);

    ngroups = size(y, 1);
    nbars = size(y, 2);
    groupwidth = min(0.8, nbars/(nbars + 1.5));

    ha1 = bar(y, 'Parent',axes5,'BarWidth',1);
    set(ha1(1),'DisplayName','Common','FaceColor','b', 'FaceAlpha', 1);
    set(ha1(2),'DisplayName','Rare','FaceColor','r', 'FaceAlpha', 1);
    for i = 1:nbars
        x = (1:ngroups) - groupwidth/2 + (2*i-1) * groupwidth / (2*nbars);
        errorbar(x, y(:,i), stdev(:,i),'k', 'LineStyle', 'none');
    end
    box(axes5,'on');
    set(axes5,'XTick',[1 2],'XTickLabel',{'Rewarded','Unrewarded'});
    set(axes5,'Ylim',[0 1], 'YTick',[0 0.5 1]);
    ylabel('Stay Probability');
    title('Location Effect');

    suptitle(experiment)

    set(f,'units','centimeter','position',[1,5,35,7])

end

%% Store relevant data
output.stayData     = stayData;
output.staySim      = staySim;
output.Rating       = AvRating;
output.Attention    = AvAttention;
output.Location     = stayLocation;
output.MB           = mb;
output.MF           = mf;
output.MBsim        = squeeze(nanmean(mbs,3));
output.MFsim        = squeeze(nanmean(mfs,3));
end
