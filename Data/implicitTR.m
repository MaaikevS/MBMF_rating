%% implicit groupTR (G2)
R={  'MD001.mat' 'MD002.mat'  'MD004.mat' 'MD005.mat' ... 
     'MD007.mat' 'MD008.mat' 'MD009.mat' 'MD010.mat' 'MD011.mat'...
     'MD012.mat' 'MD013.mat' 'MD014.mat' 'MD015.mat' 'MD016.mat'...
     'MD017.mat' 'MD018.mat' 'MD019.mat'  'MD020.mat'  'MD021.mat'  'MD022.mat' };
 
for i = 1:length(R) % for data set
   load(R{i});
   [ pMB(i,:) pMBPOS(i,:) pMBNEG(i,:) pMF(i,:) pwin(i,:) barvtot(i,:) lastseendistot(i,:) RT(i,:) cbarctot(i,:)...
       errcbarctot(i,:) ucbarctot(i,:) errucbarctot(i,:) ucbaratot(i,:) errucbaratot(i,:) barbbtot(i,:) errbarbbtot(i,:)...
       ucbarbtot(i,:) errucbarbtot(i,:) ucbarrtot(i,:) errucbarrtot(i,:) baraatot(i,:) errbaraatot(i,:) barrtot(i,:) errbarrtot(i,:)...
       pMTbA(i,:) pMFbA(i,:) pMBTPOSA(i,:) pMBTNEGA(i,:) pMBT(i,:) pMBTA(i,:)...
       pMBTNA(i,:) baraaqtot(i,:) errbaraaqtot(i,:) last_chosen_distance(i,:) MBMFD(i,:) baraaqa(i,:) errbaraaqa(i,:) MBMFDII(i,:) errMBMFD(i,:) baraRT(i,:) errbaraRT(i,:) RTinf(i,:) errRTinf(i,:) barl(i,:) errbarl(i,:) baratt(i,:) errbaratt(i,:) bias_tot(i,:)] = GraphingTR(result);
   [rawratings(i,:) bard(i,:) errbard(i,:) bardSTRICT(i,:) errbardSTRICT(i,:) baratot(i,:) errbaratot(i,:) barbtot(i,:) errbarbtot(i,:) earlyratings(i,:) lateratings(i,:)] = Graphing2TR (result); 
end


meanbarvtot = nanmean(barvtot); %MF/MB graph classic Daw
meancbarctot = nanmean(cbarctot); % win (attn/~not) loss (attn/~attn)
meanucbarctot = nanmean(ucbarctot); %attn delta ratings on win/loss of unchosen shape
meanbaratot = nanmean(baratot); % win (con and incon) loss (con and incon)
meanbarbtot = nanmean(barbtot);% bara but first for ~attn and last for attn
meanbarrtot = nanmean(barrtot); % attn - ~attn on the above
meanlastseendistot = nanmean(lastseendistot); % mean is 2.54, std is 0.43
meanbaraatot = nanmean (baraatot);
meanbarbbtot = nanmean(barbbtot);
meanbaraaqtot = nanmean(baraaqtot);
meanbardtot = nanmean(bard);
meanbardSTRICTtot = nanmean(bardSTRICT);
meanMBMFD = nanmean(MBMFD);
meanucbaratot = mean(ucbaratot);
meanucbarbtot = mean(ucbarbtot);
meanucbarrtot = mean(ucbarrtot);
meanbaraaqa = nanmean(baraaqa);
meanMBMFDII = nanmean(MBMFDII);
meanbaraRT = nanmean (baraRT);
meanRTinf = nanmean (RTinf);
meanbarl = nanmean (barl);
meanbaratt = nanmean(baratt);
bias_tot; %this is the overall shape bias a person has 
meanbias_tot = mean(bias_tot); %this is the total bias in the data set 

[R1,P1] = corrcoef(pMB, pMTbA);% correlation between MB and U shaped consis inconis in bara
%[R2,P2] = corrcoef(pMB,pMBT);% correlation between model basedness and MB in barr
[R3,P3] = corrcoef(pMB, pMBTA); % correlation between MB and U shape in attention trials
[R4,P4] = corrcoef(pMB, pMBTNA); % correlation between MB and U shape in not attention trials
[R5,P5] = corrcoef(pMF, pMFbA); %correlation between model free and model free transfer in bara
[R6,P6] = corrcoef(pMB,pwin); 
[R7,P7] = corrcoef(pMBPOS,pMBTPOSA); % correlation between pos MB and transfer in wins to bara 
[R8,P8] = corrcoef(pMBNEG,pMBTNEGA); % correlation between pos MB and transfer in wins to bara 
mean(pMB);
mean(pMF);

%% MF/MB graph classic Daw w/t error bars 
% this is the standard daw graph 
errbarv = std( barvtot ) / sqrt(i);
x=1:4;
%bar([meanbarvtot(1:2); meanbarvtot(3:4)]);  
bar(x, meanbarvtot);                
hold on;
er = errorbar(x, meanbarvtot, errbarv, -errbarv);   
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
ylim([0.5, 0.91]);
xlabel('win/loss divied by con/incon');
ylabel('Stay Probability');
title('Daw Graph');
hold off
%% MF/MB graph for left and right 
% stay prob for left and right of the screen in choice 1 
errbarl = std( barl ) / sqrt(i);
x=1:4;
%bar([meanbarvtot(1:2); meanbarvtot(3:4)]);  
bar(x, meanbarl);                
hold on;
er = errorbar(x, meanbarl, errbarl, -errbarl);   
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
ylim([0.5, 0.91]);
xlabel('win/loss divied by con/incon');
ylabel('Stay Probability');
title('Daw Graph');
hold off
%% Daw graph for WM effect on stay prob  
errbaratt = std( baratt ) / sqrt(i);
x=1:4;

bar(x, meanbaratt);                
hold on;
er = errorbar(x, meanbaratt, errbaratt, -errbaratt);   
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
ylim([0.5, 0.91]);
xlabel('win/loss divied by con/incon');
ylabel('Stay Probability');
title('Effect of WM on implicit stay prob');
hold off
%% win (attn/~not) loss (attn/~attn)
% the effect of attn on reward split by win and loss 
errcbarc = std( errcbarctot ) / sqrt(i);
x=1:4;
bar(x, meancbarctot);                
hold on;
er = errorbar(x, meancbarctot, errcbarc, -errcbarc);   
er.Color = [0 0 0];                            
er.LineStyle = 'none'; 
ylim([105, 145]);
xlabel('Win/loss divied by attn/~attn');
ylabel('Ratings');
title('Ratings of chosen shape split by win and attn');
hold off;

%% attn delta ratings on win/loss of unchosen shape 
% the same as above but for the unchosen shape 
errucbarcf = std( errucbarctot ) / sqrt(i);
x=1:4;
bar(x, meanucbarctot);                
hold on;
er = errorbar(x, meanucbarctot, errucbarcf, -errucbarcf);   
er.Color = [0 0 0];                            
er.LineStyle = 'none'; 
ylim([105, 145]);
xlabel('Win/loss divied by attn/~attn');
ylabel('Ratings');
title('Ratings of unchosen shape split by win and attn');
hold off;
%% ratings win (con and incon) loss (con and incon)for chosen shape
% this is the core findings figure if you like, with mixed MB MF transfer
% in the explicit group 
errbaraf = std( errbaratot ) / sqrt(i)
x=1:4;
bar(x, meanbaratot);                
hold on;
er = errorbar(x, meanbaratot, errbaraf, -errbaraf);   
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
xlabel('Win/loss divied by con/incon');
ylabel('Ratings');
title('Ratings of chosen shape split by win and consistency');
ylim([110, 150]);
hold off;
%% win (con and incon) loss (con and incon)rating change since last chosen
errbardf = std( errbard ) / sqrt(i)
x=1:4;
bar(x, meanbardtot);                
hold on;
er = errorbar(x, meanbardtot, errbardf, -errbardf);   
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
xlabel('Win/loss divied by con/incon');
ylabel('Ratings');
title('Ratings of chosen shape split by win and consistency');
%ylim([40, 70]);
hold off;
%% win (con and incon) loss (con and incon)rating change since last chosen
% strictly only with items before they were last probed 
errbardSTRICTf = std( errbardSTRICT ) / sqrt(i)
x=1:4;
bar(x, meanbardSTRICTtot);                
hold on;
er = errorbar(x, meanbardSTRICTtot, errbardSTRICTf, -errbardSTRICTf);   
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
xlabel('Win/loss divied by con/incon');
ylabel('Ratings');
title('Ratings of chosen shape split by win and consistency');
%ylim([40, 70]);
hold off;
%% win (con and incon) loss (con and incon)for chosen shape II
bar(meanbaraaqtot)
%errbaraaqf = std( errbaraaqtot ) / sqrt(i)
%x=1:16;
%bar(x, meanbaraaqtot);                
%hold on;
%er = errorbar(x, meanbaraaqtot, errbaraaqf, -errbaraaqf);   
%er.Color = [0 0 0];                            
%er.LineStyle = 'none';  
%ylim([-0.15, 0.22]);
%xlabel('Win/loss divied by con/incon');
%ylabel('Ratings');
%title('Ratings on chosen shape split by win and consistency (G2)');
%hold off;
%% win (con and incon) loss (con and incon) for unchosen shape
errucbaraf = std( errucbaratot ) / sqrt(i);
x=1:4;
bar(x, meanucbaratot);                
hold on;
er = errorbar(x, meanucbaratot, errucbaraf, -errucbaraf);   
er.Color = [0 0 0];                            
er.LineStyle = 'none';
ylim([100, 130]);
xlabel('Win/loss divied by con/incon');
ylabel('Ratings');
title('Ratings on unchosen shape split by win and consistency (G2)');
hold off;

%% bara but first for attn and last for ~attn chosen
errbarbf = std( errbarbtot ) / sqrt(i);
x=1:8;
bar(x, meanbarbtot);                
hold on;
er = errorbar(x, meanbarbtot, errbarbf, -errbarbf);   
er.Color = [0 0 0];                            
er.LineStyle = 'none'; 
ylim([110, 140]);
xlabel('Win/loss divied by consis/incon and attn/~attn');
ylabel('Ratings');
title('Ratings on chosen shape split by win, consistency and attn (G2)');
hold off;
%% bara but first for attn and last for ~attn chosen II
errbarbbf = std( errbarbbtot ) / sqrt(i);
x=1:8;
bar(x, meanbarbbtot);                
hold on;
er = errorbar(x, meanbarbbtot, errbarbbf, -errbarbbf);   
er.Color = [0 0 0];                            
er.LineStyle = 'none'; 
ylim([110, 150]);
xlabel('Win/loss divied by consis/incon and attn/~attn');
ylabel('Ratings');
title('Ratings on chosen shape split by win, consistency and attn (G2)');
hold off;
%% bara but first for attn and last for ~attn unchosen
errucbarbf = std( errucbarbtot ) / sqrt(i);
x=1:8;
bar(x, meanucbarbtot);                
hold on;
er = errorbar(x, meanucbarbtot, errucbarbf, -errucbarbf);   
er.Color = [0 0 0];                            
er.LineStyle = 'none'; 
ylim([100, 135]);
xlabel('Win/loss divied by consis/incon and attn/~attn');
ylabel('Ratings');
title('Ratings on unchosen shape split by win, consistency and attn (G2)');
hold off;
%% baraaqa which is split to early late trials 
errbaraaqaf = std( errbaraaqa ) / sqrt(i);
x=1:8;
bar(x, meanucbaraaqa);                
hold on;
er = errorbar(x, meanbaraaqa, errbaraaqaf, -errbaraaqaf);   
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
xlabel('attnal difference in win/loss divied by con/incon');
ylabel('Ratings');
title('Attntional diff in ratings on unchosen s split by win and con (G2)');
hold off;
%% baraaqa which is split to early late trials 
errbaraaqaf = std( errbaraaqa ) / sqrt(i);
x=1:8;
bar(x, meanucbaraaqa);                
hold on;
er = errorbar(x, meanbaraaqa, errbaraaqaf, -errbaraaqaf);   
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
xlabel('attnal difference in win/loss divied by con/incon');
ylabel('Ratings');
title('Attntional diff in ratings on unchosen s split by win and con (G2)');
hold off;
%% MF vs MB decay 
errMBMFDf = std( errMBMFD ) / sqrt(i);
x=1:4;
bar(x, meanMBMFDII);                
hold on;
er = errorbar(x, meanMBMFDII, errMBMFDf, -errMBMFDf);   
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
xlabel('attnal difference in win/loss divied by con/incon');
ylabel('Ratings');
title('Attntional diff in ratings on chosen s split by win and con (G2)');
hold off;
%% attn - ~attn on the above for unchosen
errucbarrf = std( errucbarrtot ) / sqrt(i);
x=1:4;
bar(x, meanucbarrtot);                
hold on;
er = errorbar(x, meanucbarrtot, errucbarrf, -errucbarrf);   
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
xlabel('attnal difference in win/loss divied by con/incon');
ylabel('Ratings');
ylim([-10, 25]);
title('Attntional diff in ratings on unchosen s split by win and con (G2)');
hold off;
%% attn - ~attn on the above for chosen
errbarr = nanstd( errbarrtot ) / sqrt(i);
x=1:4;
bar(x, meanbarrtot);                
hold on;
er = errorbar(x, meanbarrtot, errbarr, -errbarr);   
er.Color = [0 0 0];                            
er.LineStyle = 'none';  
xlabel('attnal difference in win/loss divied by con/incon');
ylabel('Ratings');
title('Attntional diff in ratings on chosen s split by win and con (G2)');
hold off;
%% baraRT
errbaraRTf = nanstd( errbaraRT ) / sqrt(i);
x=1:8;
bar(x, meanbaraRT);                
hold on;
er = errorbar(x, meanbaraRT, errbaraRTf, -errbaraRTf);   
er.Color = [0 0 0];                            
er.LineStyle = 'none'; 
%ylim([900, 1050]);
xlabel('Win/loss divied by consis/incon and attn/~attn');
ylabel('Ratings');
title('Ratings on chosen shape split by win, consistency and attn (G2)');
hold off;
%% RTinf 
errRTinff = nanstd( errRTinf ) / sqrt(i);
x=1:4;
bar(x, meanRTinf);                
hold on;
er = errorbar(x, meanRTinf, errRTinff, -errRTinff);   
er.Color = [0 0 0];                            
er.LineStyle = 'none'; 
ylim([1.00, 1.2]);
xlabel('Win/loss divied by consis/incon and attn/~attn');
ylabel('RT');
title('Reaction time in transfer probe split by last chosen win, consistency and attn (G2)');
hold off;
