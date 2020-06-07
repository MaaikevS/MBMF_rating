function [pMB pMBPOS pMBNEG pMF pwin barv lastseendis RT cbarc errcbarc ucbarc errucbarc ucbara errucbara barbb errbarbb ucbarb errucbarb ucbarr errucbarr baraa errbaraa barr errbarr pMTbA pMFbA pMBTPOSA pMBTNEGA pMBT pMBTA pMBTNA baraaq errbaraaq last_chosen_distance MBMFD baraaqa errbaraaqa MBMFDII errMBMFD baraRT errbaraRT RTinf errRTinf barl errbarl baratt errbaratt bias_tot] = GraphingTR(result) 
%% GraphingTR 
%%
c1=[result.data.choice1]; %did they choose red or blue in choice 1 
win=[result.data.win]; % did they win 
con=[result.data.isConsistentMapping]; % was the mapping consistent between choice 1 colour and stage 2 shapes 
start = [result.data.startChoice1]; % start time for choice 1
finish = [result.data.endChoice1]; % end time for choice 1
choice3 = [result.data.choice3]; % which side did they choose for the attention manipulation - nan if no attn screen
rawratings = [result.data.choice4]; % shape ratings 


[nan  c1(1:end-1)==c1(2:end) ]; % this is just me messing around with the stay prob stuff 
stick=[nan c1(1:end-1)==c1(2:end) ];
attman=((choice3==1)|(choice3==2));
nanmean(stick);%prop of trials where response is repeated
stick(win);% trials where i stuck and won as 1;
s=stick(2:end);
s(win(1:end-1)==1);
stickwin=s(win(1:end-1)==1);
s(win(1:end-1)==0);
mean(s(win(1:end-1)==0));
locationa=[ result.data. choice1Location];
location = locationa(:,1:2:end);
leftvright = (location/300);
lstick = [nan location(1:end-1)==location(2:end) ];
l=lstick(2:end);
%[win ; con ; win & con]
win(1:end-1);
s(win(1:end-1)&con(2:end));

% standard daw bar chart 
barv(1)=mean(s(win(1:end-1) & con(1:end-1)));% bar(1) is rewarded and common; 
barv(2)=mean(s(win(1:end-1) & con(1:end-1)==0));% bar(4) is rewarded and rare
barv(3)=mean(s(win(1:end-1)==0 & con(1:end-1)));% bar(2) is not-rewarded and common;
barv(4)=mean(s(win(1:end-1)==0 & con(1:end-1)==0));% bar(3) is not-rewarded and rare;
bar(barv);

%measures of MB and MFness 
pMB = ((barv(1)+barv(4))-(barv(3)+barv(2)));%model based index
pMBPOS = (barv(1))-(barv(2));
pMBNEG = (barv(4))-(barv(3));
pMF = ((barv(1)+barv(2))-(barv(3)+barv(4)));
mbi = pMB - pMF;
pwin = mean(win);
pMF = (barv(1)+barv(2))-(barv(3)+barv(4));


tp = [result.data.transferprobe]; % 1 to 5, which item probed
irrels = vertcat(result.data.irrelShapeIndex); % 

conmap=[result.data.isConsistentMapping];
correct =[result.data.correct];
antic1=abs(c1-3); % 1 to 2 and 2 to 1 
startTP = [result.data.startTransferChoice];
endTP = [result.data.endTransferChoice];
RTTP = endTP - startTP;
for i = 1:length(c1) % for each trial?
    if c1(i)==0; 
        chosens(i) = nan;
        unchosens(i) = nan;
    else
        chosens(i) = irrels( i, c1(i) );   %find the shape for the chossen colour
        unchosens(i) = irrels(i,antic1(i)); % find the shape for the unchosen colour
    end
end
for i = 1:length(c1) % for each trial
    % find the last time where the chosen stimulus was the currently probed
    % item 
    lastcs = find(chosens(1:i) == tp(i), 1, 'last'); 
    %find last time at which the probed item on this trial was the unchosen
    %shape on choice 1 
    lastus = find(unchosens(1:i) == tp(i), 1, 'last');
    if ~isempty(lastcs);    % was the chosen shape rewarded in that trial
        woncs(i) = win(lastcs);
    else
        woncs(i) = nan;
    end 
    if ~isempty(lastus);
        wonus(i) = win(lastus); %wonus tells us of the shape not chosen was a winning shape
    else
        wonus(i) = nan;
    end 
    % find out if directed MW took place 
        if ~isempty(lastcs);
        MWc(i) = choice3(lastcs); % for chosen shape
    else
        MWc(i) = nan;
    end 
    if ~isempty(lastus);
        MWuc(i) = choice3(lastus); % for unchosen shape
    else
        MWuc(i) = nan;
    end 
    if ~isempty(lastcs)% new consistentcy bit
        consiscs(i) = conmap(lastcs);
    else
        consiscs(i) = nan;
    end 
    if ~isempty(lastus)%new consistency bit for unchosen 
        consisucs(i) = conmap(lastus);
    else
        consisucs(i) = nan;
    end 
    if ~isempty(lastcs)% did they make the correct choice (different from winning ofc) 
        corr(i) = correct(lastcs);
    else
        corr(i) = nan;
    end 
    if ~isempty(lastcs)% distance to trial i for chosen shape
        last_chosen_distance (i) = i - lastcs;
    else
        last_chosen_distance(i) = nan;
    end
    if ~isempty(lastus)% distance to trial i for unchsoen shape  
        last_unchosen_distance (i) = i - lastus;
    else
        last_unchosen_distance(i) = nan;
    end
   lastseendis (i) = min(last_chosen_distance (i), last_unchosen_distance (i));
end
for i = 1:length(c1) % for each trial 
    % find out if directed MW took place 
    lasts = find(chosens(1:i) == tp(i), 1, 'last');
    if ~isempty(lasts)
        RT(i) = finish(i)-start(i);
    else
        RT(i) = nan;
    end 
end



% standardisation of ratings 

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

% important variables for graphs 
attnc=((MWc==1)|(MWc==2)); %attention for chosen shape
attnuc=((MWuc==1)|(MWuc==2)); %attention for unchosen shape
consistentcs=(consiscs==1); % was the chosen shape shown on a consis trial 
inconsistentcs=(consiscs==0);
consistentucs=(consisucs==1); % was the chosen shape shown on a consis trial 
inconsistentucs=(consisucs==0);
selectcs = last_chosen_distance<10; %only give ratings for chosen shapes shown x trials ago 
selectucs = last_unchosen_distance<10;%only give ratings for unchosen shapes shown x trials ago 
chosennotreseen = last_chosen_distance < last_unchosen_distance; %gives on ratings for chosen shapes that havent been re-shown before probe
unchosennotreseen = last_chosen_distance > last_unchosen_distance; %gives on ratings for unchosen shapes that havent been re-shown before probe
selandnotreseen = selectcs & chosennotreseen; % gives both less than x since seen and not reseen since for chosen
unselandnotreseen = selectucs & unchosennotreseen; % gives both less than x since seen and not reseen since for chosen

%graphs 
cbarc(1) = nanmean(normratings(woncs==1&attnc&(selandnotreseen)));
cbarc(2) = nanmean(normratings(woncs==1&~attnc&(selandnotreseen)));
cbarc(3) = nanmean(normratings(woncs==0&attnc&(selandnotreseen)));
cbarc(4) = nanmean(normratings(woncs==0&~attnc&(selandnotreseen)));
errcbarc = cbarc - mean(cbarc);
ucbarc(1) = nanmean(normratings(wonus==1&attnuc&(unselandnotreseen)));
ucbarc(2) = nanmean(normratings(wonus==1&~attnuc&(unselandnotreseen)));
ucbarc(3) = nanmean(normratings(wonus==0&attnuc&(unselandnotreseen)));
ucbarc(4) = nanmean(normratings(wonus==0&~attnuc&(unselandnotreseen)));
errucbarc = ucbarc - mean(ucbarc);

baraa(1)= nanmean(normratings(woncs==1&consistentcs&(selandnotreseen)));
baraa(2)= nanmean(normratings(woncs==1&inconsistentcs&(selandnotreseen)));
baraa(3)= nanmean(normratings(woncs==0&consistentcs&(selandnotreseen)));
baraa(4)= nanmean(normratings(woncs==0&inconsistentcs&(selandnotreseen)));
errbaraa = baraa - mean(baraa);
ucbara(1)= nanmean(normratings(wonus==1&consistentucs&(unselandnotreseen)));
ucbara(2)= nanmean(normratings(wonus==1&inconsistentucs&(unselandnotreseen)));
ucbara(3)= nanmean(normratings(wonus==0&consistentucs&(unselandnotreseen)));
ucbara(4)= nanmean(normratings(wonus==0&inconsistentucs&(unselandnotreseen)));
errucbara = ucbara - mean(ucbara);

barbb(1)= nanmean(normratings(woncs==1&consistentcs&attnc&(selandnotreseen)));
barbb(2)= nanmean(normratings(woncs==1&inconsistentcs&attnc&(selandnotreseen)));
barbb(3)= nanmean(normratings(woncs==0&consistentcs&attnc&(selandnotreseen)));
barbb(4)= nanmean(normratings(woncs==0&inconsistentcs&attnc&(selandnotreseen)));
barbb(5)= nanmean(normratings(woncs==1&consistentcs&~attnc&(selandnotreseen)));
barbb(6)= nanmean(normratings(woncs==1&inconsistentcs&~attnc&(selandnotreseen)));
barbb(7)= nanmean(normratings(woncs==0&consistentcs&~attnc&(selandnotreseen)));
barbb(8)= nanmean(normratings(woncs==0&inconsistentcs&~attnc&(selandnotreseen)));
errbarbb = barbb - mean(barbb);
ucbarb(1)= nanmean(normratings(wonus==1&consistentucs&attnuc&(unselandnotreseen)));
ucbarb(2)= nanmean(normratings(wonus==1&inconsistentucs&attnuc&(unselandnotreseen)));
ucbarb(3)= nanmean(normratings(wonus==0&consistentucs&attnuc&(unselandnotreseen)));
ucbarb(4)= nanmean(normratings(wonus==0&inconsistentucs&attnuc&(unselandnotreseen)));
ucbarb(5)= nanmean(normratings(wonus==1&consistentucs&~attnuc&(unselandnotreseen)));
ucbarb(6)= nanmean(normratings(wonus==1&inconsistentucs&~attnuc&(unselandnotreseen)));
ucbarb(7)= nanmean(normratings(wonus==0&consistentucs&~attnuc&(unselandnotreseen)));
ucbarb(8)= nanmean(normratings(wonus==0&inconsistentucs&~attnuc&(unselandnotreseen)));
errucbarb = ucbarb - mean(ucbarb);

barr(1)= (barbb(1)-barbb(5));
barr(2)= (barbb(2)-barbb(6));
barr(3)= (barbb(3)-barbb(7));
barr(4)= (barbb(4)-barbb(8));
errbarr = barr - mean(barr);
ucbarr(1)= (ucbarb(1)-ucbarb(5));
ucbarr(2)= (ucbarb(2)-ucbarb(6));
ucbarr(3)= (ucbarb(3)-ucbarb(7));
ucbarr(4)= (ucbarb(4)-ucbarb(8));
errucbarr = ucbarr - mean(ucbarr);



pMTbA = ((baraa(1)+baraa(4))-(baraa(3)+baraa(2))); %prob of MBT to bara (general conis in conis graphh)
pMFbA = ((baraa(1)+baraa(2))-(baraa(3)+baraa(4))); % prob of MFT to bara 
pMBTPOSA = ((baraa(1))-(baraa(2))); %MBT for positive only 
pMBTNEGA = ((baraa(4))-(baraa(3))); %MBT for neg only 
pMBT = ((barr(1)+barr(4))-(barr(3)+barr(2))); %prob of MB shape in barr
pMBTA = ((barbb(1)+barbb(4))-(barbb(3)+barbb(2)));
pMBTNA = ((barbb(5)+barbb(8))-(barbb(7)+barbb(6))); 

select1 = last_chosen_distance==2;
select2 = last_chosen_distance==3;
select3 = last_chosen_distance==4;
select4 = last_chosen_distance==5;
select5 = last_chosen_distance==6;
select6 = last_chosen_distance==7;
select7 = last_chosen_distance==8;
select8 = last_chosen_distance==9;
baraaq(1)= nanmean(normratings(woncs==1&consistentcs&(select1)&chosennotreseen));
baraaq(2)= nanmean(normratings(woncs==1&inconsistentcs&(select1)&chosennotreseen));
baraaq(3)= nanmean(normratings(woncs==0&consistentcs&(select1)&chosennotreseen));
baraaq(4)= nanmean(normratings(woncs==0&inconsistentcs&(select1)&chosennotreseen));
baraaq(5)= nanmean(normratings(woncs==1&consistentcs&(select2)&chosennotreseen));
baraaq(6)= nanmean(normratings(woncs==1&inconsistentcs&(select2)&chosennotreseen));
baraaq(7)= nanmean(normratings(woncs==0&consistentcs&(select2)&chosennotreseen));
baraaq(8)= nanmean(normratings(woncs==0&inconsistentcs&(select2)&chosennotreseen));
baraaq(9)= nanmean(normratings(woncs==1&consistentcs&(select3)&chosennotreseen));
baraaq(10)= nanmean(normratings(woncs==1&inconsistentcs&(select3)&chosennotreseen));
baraaq(11)= nanmean(normratings(woncs==0&consistentcs&(select3)&chosennotreseen));
baraaq(12)= nanmean(normratings(woncs==0&inconsistentcs&(select3)&chosennotreseen));
baraaq(13)= nanmean(normratings(woncs==1&consistentcs&(select4)&chosennotreseen));
baraaq(14)= nanmean(normratings(woncs==1&inconsistentcs&(select4)&chosennotreseen));
baraaq(15)= nanmean(normratings(woncs==0&consistentcs&(select4)&chosennotreseen));
baraaq(16)= nanmean(normratings(woncs==0&inconsistentcs&(select4)&chosennotreseen));
baraaq(17)= nanmean(normratings(woncs==1&consistentcs&(select5)&chosennotreseen));
baraaq(18)= nanmean(normratings(woncs==1&inconsistentcs&(select5)&chosennotreseen));
baraaq(19)= nanmean(normratings(woncs==0&consistentcs&(select5)&chosennotreseen));
baraaq(20)= nanmean(normratings(woncs==0&inconsistentcs&(select5)&chosennotreseen));
baraaq(21)= nanmean(normratings(woncs==1&consistentcs&(select6)&chosennotreseen));
baraaq(22)= nanmean(normratings(woncs==1&inconsistentcs&(select6)&chosennotreseen));
baraaq(23)= nanmean(normratings(woncs==0&consistentcs&(select6)&chosennotreseen));
baraaq(24)= nanmean(normratings(woncs==0&inconsistentcs&(select6)&chosennotreseen));
baraaq(25)= nanmean(normratings(woncs==1&consistentcs&(select7)&chosennotreseen));
baraaq(26)= nanmean(normratings(woncs==1&inconsistentcs&(select7)&chosennotreseen));
baraaq(27)= nanmean(normratings(woncs==0&consistentcs&(select7)&chosennotreseen));
baraaq(28)= nanmean(normratings(woncs==0&inconsistentcs&(select7)&chosennotreseen));
baraaq(29)= nanmean(normratings(woncs==1&consistentcs&(select8)&chosennotreseen));
baraaq(30)= nanmean(normratings(woncs==1&inconsistentcs&(select8)&chosennotreseen));
baraaq(31)= nanmean(normratings(woncs==0&consistentcs&(select8)&chosennotreseen));
baraaq(32)= nanmean(normratings(woncs==0&inconsistentcs&(select8)&chosennotreseen));
errbaraaq = baraaq - mean(baraaq);

% MB vs MF decay (MB first MF last)
MBMFD(1)=((baraaq(1)+baraaq(4))-(baraaq(3)+baraaq(2)));
MBMFD(2)=((baraaq(5)+baraaq(8))-(baraaq(7)+baraaq(6)));
MBMFD(3)=((baraaq(9)+baraaq(12))-(baraaq(11)+baraaq(10)));
MBMFD(4)=((baraaq(13)+baraaq(16))-(baraaq(15)+baraaq(14)));
MBMFD(5)=((baraaq(17)+baraaq(20))-(baraaq(19)+baraaq(18)));
MBMFD(6)=((baraaq(21)+baraaq(24))-(baraaq(23)+baraaq(22)));
MBMFD(7)=((baraaq(25)+baraaq(28))-(baraaq(27)+baraaq(26)));
MBMFD(8)=((baraaq(29)+baraaq(32))-(baraaq(31)+baraaq(30)));
MBMFD(10)=((baraaq(1)+baraaq(2))-(baraaq(3)+baraaq(4)));
MBMFD(11)=((baraaq(5)+baraaq(6))-(baraaq(7)+baraaq(8)));
MBMFD(12)=((baraaq(8)+baraaq(10))-(baraaq(11)+baraaq(12)));
MBMFD(13)=((baraaq(13)+baraaq(14))-(baraaq(15)+baraaq(16)));
MBMFD(14)=((baraaq(17)+baraaq(18))-(baraaq(19)+baraaq(20)));
MBMFD(15)=((baraaq(21)+baraaq(22))-(baraaq(23)+baraaq(24)));
MBMFD(16)=((baraaq(25)+baraaq(26))-(baraaq(27)+baraaq(28)));
MBMFD(17)=((baraaq(29)+baraaq(30))-(baraaq(31)+baraaq(32)));


select1 = last_chosen_distance<5;
select2 = last_chosen_distance>4;

baraaqa(1)= nanmean(normratings(woncs==1&consistentcs&(select1)&chosennotreseen));
baraaqa(2)= nanmean(normratings(woncs==1&inconsistentcs&(select1)&chosennotreseen));
baraaqa(3)= nanmean(normratings(woncs==0&consistentcs&(select1)&chosennotreseen));
baraaqa(4)= nanmean(normratings(woncs==0&inconsistentcs&(select1)&chosennotreseen));
baraaqa(5)= nanmean(normratings(woncs==1&consistentcs&(select2)&chosennotreseen));
baraaqa(6)= nanmean(normratings(woncs==1&inconsistentcs&(select2)&chosennotreseen));
baraaqa(7)= nanmean(normratings(woncs==0&consistentcs&(select2)&chosennotreseen));
baraaqa(8)= nanmean(normratings(woncs==0&inconsistentcs&(select2)&chosennotreseen));
errbaraaqa = baraaqa - mean(baraaqa);

% MB vs MF decay (MB first MF last)
MBMFDII(1)=((baraaqa(1)+baraaqa(4))-(baraaqa(3)+baraaqa(2)));
MBMFDII(2)=((baraaqa(5)+baraaqa(8))-(baraaqa(7)+baraaqa(6)));
MBMFDII(3)=((baraaqa(1)+baraaqa(2))-(baraaqa(3)+baraaqa(4)));
MBMFDII(4)=((baraaqa(5)+baraaqa(6))-(baraaqa(7)+baraaqa(8)));
errMBMFD = MBMFD - mean(MBMFD);

RT11 = (0.6<RT);
RT12 = (RT<2.7);
RT21 = (0.6<RT);
RT22 = (RT>0.7);
baraRT(1)= nanmean(normratings(woncs==1&consistentcs&(selandnotreseen)&(RT11)&(RT12)));
baraRT(2)= nanmean(normratings(woncs==1&inconsistentcs&(selandnotreseen)&(RT11)&(RT12)));
baraRT(3)= nanmean(normratings(woncs==0&consistentcs&(selandnotreseen)&(RT11)&(RT12)));
baraRT(4)= nanmean(normratings(woncs==0&inconsistentcs&(selandnotreseen)&(RT11)&(RT12)));
baraRT(5)= nanmean(normratings(woncs==1&consistentcs&(selandnotreseen)&(RT21)&(RT22)));
baraRT(6)= nanmean(normratings(woncs==1&inconsistentcs&(selandnotreseen)&(RT21)&(RT22)));
baraRT(7)= nanmean(normratings(woncs==0&consistentcs&(selandnotreseen)&(RT21)&(RT22)));
baraRT(8)= nanmean(normratings(woncs==0&inconsistentcs&(selandnotreseen)&(RT21)&(RT22)));
errbaraRT = baraRT - mean(baraRT);


RTcomp = [nan RT(1:end-1)]; %shifts RTs along one so can look at how previous trial affected 
%RTinf(1)= nanmean(RTcomp(woncs==1&consistentcs));
%RTinf(2)= nanmean(RTcomp(woncs==1&inconsistentcs));
%RTinf(3)= nanmean(RTcomp(woncs==0&consistentcs));
%RTinf(4)= nanmean(RTcomp(woncs==0&inconsistentcs));
%errRTinf = RTinf - mean(RTinf);

% this produces strong inverse MB trans 
RTinf(1)= nanmean(RTcomp(win==1&con==1));
RTinf(2)= nanmean(RTcomp(win==1&con==0));
RTinf(3)= nanmean(RTcomp(win==0&con==1));
RTinf(4)= nanmean(RTcomp(win==0&con==0));
errRTinf = RTinf - mean(RTinf);



%RTcomp = [nan RT(1:end-1)]; %shifts RTs along one so can look at how previous trial affected 
%RTinf(1)= nanmean(RTTP((woncs==1&consistentcs)&(selandnotreseen)));
%RTinf(2)= nanmean(RTTP((woncs==1&inconsistentcs)&(selandnotreseen)));
%RTinf(3)= nanmean(RTTP((woncs==0&consistentcs)&(selandnotreseen)));
%RTinf(4)= nanmean(RTTP((woncs==0&inconsistentcs)&(selandnotreseen)));
%errRTinf = RTinf - mean(RTinf);

barl(1)=mean(l(win(1:end-1) & con(1:end-1)));% bar(1) is rewarded and common; 
barl(2)=mean(l(win(1:end-1) & con(1:end-1)==0));% bar(4) is rewarded and rare
barl(3)=mean(l(win(1:end-1)==0 & con(1:end-1)));% bar(2) is not-rewarded and common;
barl(4)=mean(l(win(1:end-1)==0 & con(1:end-1)==0));% bar(3) is not-rewarded and rare;
errbarl = barl - mean(barl);

proxyatp = (attman==1); % attn on previous trial 
proxyatnp = (attman==0); % nattn on previous trial

atp = [  proxyatp(1:256)  ];
atnp = [  proxyatnp(1:256)  ];
baratt(1)=(nanmean(s(win(1:end-1) & atp(1:end-1) & con(1:end-1))))-(nanmean(s(win(1:end-1) & atnp(1:end-1) & con(1:end-1))));% bar(1) is rewarded and common; 
baratt(2)=(nanmean(s(win(1:end-1) & atp(1:end-1) & con(1:end-1)==0)))-(nanmean(s(win(1:end-1) & atnp(1:end-1) & con(1:end-1)==0)));% bar(4) is rewarded and rare
baratt(3)=(nanmean(s(win(1:end-1)==0 & atp(1:end-1) & con(1:end-1))))-(nanmean(s(win(1:end-1)==0 & atnp(1:end-1) & con(1:end-1))));% bar(2) is not-rewarded and common;
baratt(4)=(nanmean(s(win(1:end-1)==0 & atp(1:end-1) & con(1:end-1)==0)))-(nanmean(s(win(1:end-1)==0 & atnp(1:end-1) & con(1:end-1)==0)));% bar(3) is not-rewarded and rare;
errbaratt = baratt - nanmean(baratt);

%baratt(1)=(nanmean(s(win(1:end-1) & atnp(1:end-1) & con(1:end-1))));% bar(1) is rewarded and common; 
%baratt(2)=(nanmean(s(win(1:end-1) & atnp(1:end-1) & con(1:end-1)==0)));% bar(4) is rewarded and rare
%baratt(3)=(nanmean(s(win(1:end-1)==0 & atnp(1:end-1) & con(1:end-1))));% bar(2) is not-rewarded and common;
%baratt(4)=(nanmean(s(win(1:end-1)==0 & atnp(1:end-1) & con(1:end-1)==0)));% bar(3) is not-rewarded and rare;
%errbaratt = baratt - nanmean(baratt);
irrels_shown = [result.data.irrelShapeIndex];

for i = 1:length(c1) % for each trial?
    if irrels_shown(i)==0; 
        irrels(i) = nan;
       
    else
        irrels(i); % 
    end
end



for i = 1:length(c1) % for each trial?
    if chosens (i) == 1; 
        chosen1(i) = 1;
    else 
        chosen1(i) = 0;
    end
    if chosens (i) == 2; 
        chosen2(i) = 1;
    else 
        chosen2(i) = 0; 
    end
    if chosens (i) == 3; 
        chosen3(i) = 1;
    else 
        chosen3(i) = 0; 
    end
    if chosens (i) == 4; 
        chosen4(i) = 1;
    else 
        chosen4(i) = 0;    
    end
    if chosens (i) == 5; 
        chosen5(i) = 1;
    else 
        chosen5(i) = 0;
    end
    
    
    if irrels (i) == [1,;]&[;,2]
        pair_12(i) = 1;
    else 
        pair_12(i) = 0;
    end
    if irrels (i) == [1,;]&[;,3];
        pair_13(i) = 1;
    else 
        pair_13(i) = 0;
    end
    if irrels (i) == [1,;]&[;,4];
        pair_14(i) = 1;
    else 
        pair_14(i) = 0;
    end
    if irrels (i) == [1,;]&[;,5];
        pair_15(i) = 1;
    else 
        pair_15(i) = 0;
    end
        if irrels (i) == [2,;]&[;,1]
        pair_21(i) = 1;
        else 
            pair_21(i) = 0;
        end
        if irrels (i) == [2,;]&[;,3];
            pair_23(i) = 1;
        else 
            pair_23(i) = 0;
        end
        if irrels (i) == [2,;]&[;,4];
            pair_24(i) = 1;
        else 
            pair_24(i) = 0;
        end
        if irrels (i) == [2,;]&[;,5];
            pair_25(i) = 1;
        else 
            pair_25(i) = 0;
        end
            if irrels (i) == [3,;]&[;,1]
                pair_31(i) = 1;
            else 
                pair_31(i) = 0;
            end
            if irrels (i) == [3,;]&[;,2];
                pair_32(i) = 1;
            else 
                pair_32(i) = 0;
            end
            if irrels (i) == [3,;]&[;,4];
                pair_34(i) = 1;
            else 
                pair_34(i) = 0;
            end
            if irrels (i) == [3,;]&[;,5];
                pair_35(i) = 1;
            else 
                pair_35(i) = 0;
            end
                if irrels (i) == [4,;]&[;,1]
                    pair_41(i) = 1;
                else 
                    pair_41(i) = 0;
                end
                if irrels (i) == [4,;]&[;,2];
                    pair_42(i) = 1;
                else 
                    pair_42(i) = 0;
                end
                if irrels (i) == [4,;]&[;,3];
                    pair_43(i) = 1;
                else 
                    pair_43(i) = 0;
                end
                if irrels (i) == [4,;]&[;,5];
                    pair_45(i) = 1;
                else 
                    pair_45(i) = 0;
                end
                     if irrels (i) == [5,;]&[;,1]
                        pair_51(i) = 1;
                    else 
                        pair_51(i) = 0;
                    end
                    if irrels (i) == [5,;]&[;,2];
                        pair_52(i) = 1;
                    else 
                        pair_52(i) = 0;
                    end
                    if irrels (i) == [5,;]&[;,3];
                        pair_53(i) = 1;
                    else 
                        pair_53(i) = 0;
                    end
                    if irrels (i) == [5,;]&[;,4];
                        pair_54(i) = 1;
                    else 
                        pair_54(i) = 0;
                    end

end





bias_1 (1) = mean((chosen1 & (pair_12 | pair_21))-(chosen2 & (pair_12 | pair_21)));
bias_1 (2) = mean((chosen1 & (pair_13 | pair_31))-(chosen3 & (pair_13 | pair_31)));
bias_1 (3) = mean((chosen1 & (pair_14 | pair_41))-(chosen4 & (pair_14 | pair_41)));
bias_1 (4) = mean((chosen1 & (pair_15 | pair_51))-(chosen5 & (pair_15 | pair_51)));
bias_1tot = abs(mean(bias_1));

bias_2 (1) = mean((chosen2 & (pair_12 | pair_21))-(chosen1 & (pair_12 | pair_21)));
bias_2 (2) = mean((chosen2 & (pair_23 | pair_32))-(chosen3 & (pair_23 | pair_32)));
bias_2 (3) = mean((chosen2 & (pair_24 | pair_42))-(chosen4 & (pair_24 | pair_42)));
bias_2 (4) = mean((chosen2 & (pair_25 | pair_52))-(chosen5 & (pair_25 | pair_52)));
bias_2tot = abs(mean(bias_1));

bias_3 (1) = mean((chosen3 & (pair_32 | pair_23))-(chosen2 & (pair_32 | pair_23)));
bias_3 (2) = mean((chosen3 & (pair_31 | pair_13))-(chosen1 & (pair_31 | pair_13)));
bias_3 (3) = mean((chosen3 & (pair_34 | pair_43))-(chosen4 & (pair_34 | pair_43)));
bias_3 (4) = mean((chosen3 & (pair_35 | pair_53))-(chosen5 & (pair_35 | pair_53)));
bias_3tot = abs(mean(bias_1));

bias_4 (1) = mean((chosen4 & (pair_42 | pair_24))-(chosen2 & (pair_42 | pair_24)));
bias_4 (2) = mean((chosen4 & (pair_43 | pair_34))-(chosen3 & (pair_43 | pair_34)));
bias_4 (3) = mean((chosen4 & (pair_41 | pair_14))-(chosen1 & (pair_41 | pair_14)));
bias_4 (4) = mean((chosen4 & (pair_45 | pair_54))-(chosen5 & (pair_45 | pair_54)));
bias_4tot = abs(mean(bias_1));

bias_5 (1) = mean((chosen5 & (pair_52 | pair_25))-(chosen2 & (pair_52 | pair_25)));
bias_5 (2) = mean((chosen5 & (pair_53 | pair_35))-(chosen3 & (pair_53 | pair_35)));
bias_5 (3) = mean((chosen5 & (pair_54 | pair_45))-(chosen4 & (pair_54 | pair_45)));
bias_5 (4) = mean((chosen5 & (pair_51 | pair_15))-(chosen5 & (pair_51 | pair_15)));
bias_5tot = abs(mean(bias_1));

bias_tot = abs(bias_1tot + bias_2tot + bias_3tot + bias_4tot + bias_5tot);

