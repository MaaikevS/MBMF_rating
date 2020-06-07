function [rawratings ratingschange bard errbard bara errbara barb errbarb earlyratings lateratings] = Graphing2TR(result)
%%Graphing2TR
%%
ratings=[result.data.choice4];
c1=[result.data.choice1];
tp = [result.data.transferprobe];
win=[result.data.win];
conmap=[result.data.isConsistentMapping];
irrels = vertcat(result.data.irrelShapeIndex);
choice3 = [result.data.choice3];
for i = 1:length(c1); % for each trial
    if c1(i)==0 ;
        chosens(i) = nan;
    else
        chosens(i) = irrels( i, c1(i) );   
    end
end
for i = 1:length(c1); % for each trial
       lasts = find(chosens(1:i) == tp(i), 1, 'last');
    if ~isempty(lasts);
        wons(i) = win(lasts);
    else
        wons(i) = nan;
    end 
end
for i = 1:length(c1); % for each trial 
    % find out if directed MW took place 
    lasts = find(chosens(1:i) == tp(i), 1, 'last');
    if ~isempty(lasts);
        consis(i) = conmap(lasts);
    else
        consis(i) = nan;
    end 
end
for i = 1:length(c1) % for each trial 
    % find out if directed MW took place 
    lasts = find(chosens(1:i) == tp(i), 1, 'last');
    if ~isempty(lasts);
        MW(i) = choice3(lasts);
    else
        MW(i) = nan;
    end 
end

ratings = [result.data.choice4];
for i = 1:length(ratings)%i % for each trial 
    % find out if directed MW took place 
    lasts = find(chosens(1:i) == tp(i), 1, 'last');
    if ~isempty(lasts)% distance to trial i for unchsoen shape  
        last_chosen_distance (i) = i - lasts;
    else
        last_chosen_distance(i) = nan;
    end
   
end
for i = 1:length(ratings)%i
    %find out ratings diff to last time chosen 
    %lasts = find(chosens(1:i) == tp(i), 1, 'last'); % find effect in healthy
    lastrated = find(tp(1:i-1) == tp(i), 1, 'last'); % find effect in healthy 
    if ~isempty(lastrated);
        %diffratings(i) = ((normratings(i)) - (normratings(chosens(1:i) == tp(i), 1, 'last')));
         diffratings1(i) = ratings(i);
         diffratings2(i) = ratings(lastrated);
    else 
        diffratings1(i) = nan;
        diffratings2(i) = nan;
    end
     if ~isempty(lastrated)% distance to trial i for unchsoen shape  
        last_rated_distance (i) = i - lastrated;
    else
        last_rated_distance(i) = nan;
    end

end
    

diffratings = diffratings1 - diffratings2;
%need to convert 0s to nans
%diffratings123 = diffratings(1:123);

% diffratings(diffratings==0) = NaN; % not sure if you should do this. the
% regression excludes nan values, but not zeros.
ratingschange = diffratings;


consistent=(consis==1);
inconsistent=(consis==0);%Split according to whether that previous trial j was consistent /inconsistent
bard(1)= nanmean(diffratings(wons==1&consistent));
bard(2)= nanmean(diffratings(wons==1&inconsistent));
bard(3)= nanmean(diffratings(wons==0&consistent));
bard(4)= nanmean(diffratings(wons==0&inconsistent));
errbard = bard - mean(bard);

% taking into account only  trials where it was chosen since last probed 
%bardSTRICT(1)= nanmean(diffratings((wons==1&consistent)&(last_chosen_distance<last_rated_distance)));
%bardSTRICT(2)= nanmean(diffratings((wons==1&inconsistent)&(last_chosen_distance<last_rated_distance)));
%bardSTRICT(3)= nanmean(diffratings((wons==0&consistent)&(last_chosen_distance<last_rated_distance)));
%bardSTRICT(4)= nanmean(diffratings((wons==0&inconsistent)&(last_chosen_distance<last_rated_distance)));
%errbardSTRICT = bardSTRICT - mean(bardSTRICT);

% standardisation of ratings 
rawratings = [result.data.choice4];
rawmean = nanmean(rawratings);
stdratings = nanstd(rawratings); 
%for i = 1:length(c1); 
    %normratings(i) = ((rawratings(i)-rawmean)/ stdratings);
%end 
% for tiedrankings
for i = 1:length(c1); 
    normratingz(i) = ((rawratings(i)-rawmean)/ stdratings);
end 
normratings = tiedrank (normratingz);


attn=((MW==1)|(MW==2));
consistent=(consis==1);
inconsistent=(consis==0);%Split according to whether that previous trial j was consistent /inconsistent
bara(1)= nanmean(normratings(wons==1&consistent));
bara(2)= nanmean(normratings(wons==1&inconsistent));
bara(3)= nanmean(normratings(wons==0&consistent));
bara(4)= nanmean(normratings(wons==0&inconsistent));
errbara = bara - mean(bara);


barb(1)= nanmean(normratings(wons==1&consistent&attn));
barb(2)= nanmean(normratings(wons==1&inconsistent&attn));
barb(3)= nanmean(normratings(wons==0&consistent&attn));
barb(4)= nanmean(normratings(wons==0&inconsistent&attn));
barb(5)= nanmean(normratings(wons==1&consistent&~attn));
barb(6)= nanmean(normratings(wons==1&inconsistent&~attn));
barb(7)= nanmean(normratings(wons==0&consistent&~attn));
barb(8)= nanmean(normratings(wons==0&inconsistent&~attn));
errbarb = barb - mean(barb);

barr(1)= (barb(1)-barb(5));
barr(2)= (barb(2)-barb(6));
barr(3)= (barb(3)-barb(7));
barr(4)= (barb(4)-barb(8));
errbarr = barr - mean(barr);

pMTbA = ((bara(1)+bara(4))-(bara(3)+bara(2))); %prob of MBT to bara (general conis in conis graphh)
pMFbA = ((bara(1)+bara(2))-(bara(3)+bara(4))); % prob of MFT to bara 
pMBTPOSA = ((bara(1))-(bara(2))); %MBT for positive only 
pMBTNEGA = ((bara(4))-(bara(3))); %MBT for neg only 
pMBT = ((barr(1)+barr(4))-(barr(3)+barr(2))); %prob of MB shape in barr
pMBTA = ((barb(1)+barb(4))-(barb(3)+barb(2)));
pMBTNA = ((barb(5)+barb(8))-(barb(7)+barb(6))); 

earlyratings = nanmean(diffratings(10:123));
lateratings = nanmean(diffratings(123:255));

