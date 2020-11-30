function [LL, N, dsurr] = LLmodelRating_new(y,D,opts)
% Retrospective learning (instead of model-based) and model-free learning

    % Find parameters estimates for original reduced model with 5
    % parameters. Learning rates and softmax parameteres for stage 1 and 2 
    % are assumed to be the same.
    % Transition probabilities are associated with colour. Shapes presented
    % at stage 1 are irrelevant, but will accquire value through rating.
    %
    % USAGE: [LL, N,dsurr] = LLmodelRating_new(y,data,opts)
    %
    % INPUTS:
    % Free parameters (y):
    %   b1          = y(1);
    %   b2          = y(2);
    %   alpha 1     = y(3);
    %   alpha 2     = y(4);
    %   lambda      = y(5);
    %   omega       = y(6);
    %   pi          = y(7);

    %
    % OUTPUTS:
    %   LL = Log likelihood 
    %   N = number of trials

    N = D.Nch;
    LL = 0;
    
    b1      = exp(y(1));
    b2      = b1;
    alpha1  = 1./(1+exp(-y(2)));
    alpha2  = alpha1;
    lambda  = 1./(1+exp(-y(3)));
    w       = 1./(1+exp(-y(4)));
    st      = exp(y(5));

    if opts.generatesurrogatedata == 1
        rewprob = D.rewprob; 
        trans = D.trans;
    end

    for t=1:length(D.A)

        s1=D.S(t,1); s2=D.S(t,2)+1;
        c1=D.A(t,1); c2=D.A(t,2);
        c_shape = D.Ashape(t,1);
        shapeIdx = D.shapeIdx(t,:);
        r=D.R(t,1);
        rating = D.zRating(t);%D.rating(t)/100;%
        ratingIdx = D.ratingIdx(t);

        if t == 1 
            Qd = zeros(3,2);            % Q(s,a): state-action value function for Q-learning
            QshapeMB = zeros(5,1);
            QshapeMF = zeros(5,1);
            M = [0 0];
            count = zeros(2);
            Qr = [0 0];
        end   
        
        % Break if trial was missed
        if (c1 == -1 || c2 == -1) && opts.generatesurrogatedata == 0
            continue
        end

        if count(1,1) + count(2,2) > count(1,2) + count(2,1)
			Tr = .3+.4*eye(2);
		else
			Tr = .3+.4*(1-eye(2));
        end
        
        maxQ = max(Qd(2:3,:),[],2);                                   % optimal reward at second step
        Qm = (Tr'*maxQ)';

        Q = w * Qr + (1-w) * Qd(s1,:) + st * M;                      % mix TD and model-based values

        % first stage choice
        if opts.generatesurrogatedata == 1
            c1 = (rand > exp(b1*Q(1))/sum(exp(b1*Q))) +1;
            c_shape = shapeIdx(c1);
            	if trans(t) ; if c1 == 1; s2 = 2; else s2 = 3; end
                else    ; if c1 == 1; s2 = 3; else s2 = 2; end
                end
        else
            LL = LL + b1*Q(c1) - log(sum(exp(b1*Q)));                  % update likelihoods stage 1
        end
        % second stage choice
        if opts.generatesurrogatedata == 1
            c2 =  (rand > exp(b2*Qd(s2,1))/sum(exp(b2*Qd(s2,:))))  +1; % make choice using softmax 
            r = rand < rewprob(s2-1,c2,t);  
        else
            LL = LL + b2*Qd(s2,c2) - log(sum(exp(b2*Qd(s2,:))));  % update likelihoods stage 2
        end
        
        dtQ(1) = Qd(s2,c2) - Qd(1,c1);                      % backup with actual choice (i.e., sarsa)
        Qd(1,c1) = Qd(1,c1) + alpha1 * dtQ(1);              % update TD value function

        dtQ(2) = r - Qd(s2,c2);                             % prediction error (2nd choice)

        Qd(s2,c2) = Qd(s2,c2) + alpha2 * dtQ(2);            % update TD value function
        Qd(1,c1) = Qd(1,c1) + lambda * alpha1 * dtQ(2);     % eligibility trace

        if s2 == 2 % common
            RPE11 =(r - Qr(c1)); 
            Qr(c1) = Qr(c1) + alpha1 * (r - Qr(c1));
        else % rare
            RPE11 = (r - Qr(3- c1));
            Qr(3-c1) = Qr(3-c1) + alpha1 * (r - Qr(3- c1));
        end

        count(s2-1,c1) =  count(s2-1,c1)+1;
        
        M = [0 0];
        M(c1) = 1;                                          % make the last choice sticky

        if opts.generatesurrogatedata == 1
            MB_new = (Tr'* (max(Qd(2:3,:),[],2)))';                                   % optimal reward at second step
            if mean(D.rewprob(1,:,t)) > 0.2
                winState = 2;
            else
                winState = 3;
            end
            dsurr.A(t,1)=c1; dsurr.A(t,2)=c2;
            dsurr.S(t,1)=1; dsurr.S(t,2)=s2-1;
            dsurr.R(t,1)=r;
            dsurr.trans(t,1)=trans(t);   
            dsurr.Qmb_chosen(t,1) = Qm(c1);
            dsurr.Qmb_unchosen(t,1) = Qm(3-c1);
            dsurr.Qmf_chosen(t,1) = Qd(1,c1);
            dsurr.Qmf_unchosen(t,1) = Qd(1,3-c1);
            dsurr.Qmb_new_chosen(t,1) = MB_new(c1);
            dsurr.Qmb_new_unchosen(t,1) = MB_new(3-c1);
            dsurr.Qs2_chosen(t,1) = Qd(s2,c2);
            dsurr.Qs2_unchosen(t,1) = Qd(s2,3-c2);
            dsurr.winState(t,1) = winState;
            dsurr.bestStateChosen(t,1) = (winState == s2); 
            if trans(t) == 1 && (winState == s2)
                dsurr.bestS1choice(t,1) = c1;
            else
                dsurr.bestS1choice(t,1) = 3-c1;
            end            
            dsurr.RPE1(t,1) = r - Qm(c1);
            dsurr.RPE2(t,1) = r - Qd(1,c1);
            dsurr.RPE3(t,1) = Qd(s2,c2) - Qd(1,c1);
            dsurr.RPE4(t,1) = r - MB_new(c1);
            dsurr.RPE5(t,1) = r - Qd(s2,c2);
            dsurr.RPE6(t,1) = (Qd(s2,c2) - Qd(1,c1)) +  (r - Qd(1,c1));
            dsurr.RPE7(t,1) = r - Qm(dsurr.bestS1choice(t,1));
            dsurr.RPE8(t,1) = r - Qd(1,dsurr.bestS1choice(t,1));
            dsurr.RPE9(t,1) = r - Qm(s2-1);                     % RPE MB of choice that had greatest likelihood of leading to current state
            dsurr.RPE10(t,1) = r - Qd(1,s2-1);                  % RPE MB of choice that had greatest likelihood of leading to current state
            dsurr.RPE11(t,1) = RPE11;                           % RPE10*
            dsurr.TruePar(1,:) = y;                             % Parameters used 
            dsurr.Nch(1) = N;                                   % number of trials
        end
        
    end

end

