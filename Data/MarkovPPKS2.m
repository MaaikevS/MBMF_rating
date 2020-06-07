function result=MarkovTaskPPKS(r)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The Nat Daw / Peter Dayan / Quentin task
% (Markov decision task)
% Two stage decisions, each with a two-alternative forced choice. The decision
% is "stateful" in that the options presented in choice 2 are contingent on the
% response selected in choice 1. The contingence is probabilistic. 
% 
% "Model based choice" is indicated by the ability to select choice 1 in order
% to obtain the correct "goal" option on choice 2. The knowledge of the goal
% option is measured as the probability of correct choice given the option is
% shown in choice 2. 
% "Model based learning" is the ability to attribute the reward outcomes to the
% item selected in choice 1, rather than choice 2.
% 
% The idea is that both of these are confounded by the need for working memory.
% This version of the task is  adapted for simple stimuli, so as 
% to be comparable with my new task which probes model-based learning using
% single choices. 
% 
% sgm 2015


ex.type                  = 'Markov task Max version';
ex.subjectNumber         = 1;
ex.counterbalanceColours = 1;
ex.counterbalanceShapes  = 1;

%% SETUP
ex.skipScreenCheck    = 1;             
ex.displayNumber      = 0;  % for multiple monitors
ex.practiceTrials     = 0;
ex.useMouse           = 0 ; % show the mouse cursor while touch?

%% STRUCTURE
% 8 blocks * 32 trials * 5 seconds = 21 minutes
ex.blockLen           = 32;            
ex.blocks             = 8;    

% (flip UD) * (flip LR) * (3/4 consistent) = 16 trial types
ex.trialVariables.vertFlip  = [0 1];  % is stimulus 1 up or down?
ex.trialVariables.horzFlip  = [0 1];  % is stimulus 1 left or right?
% is attention being directed in this trial?ci
ex.trialVariables.directedAttention   = [0 1];  

% which stimulus results in reward, if chosen
ex.blockVariables.rewardedStimulus  = [1 2 3 4]; 
% which response dimension presented first? 1=L/R, 2=U/D
ex.blockVariables.firstResponseDimension = [1 2];     
ex.breakBlocksRandomly = 64;

% does colour 1 lead to stimulus 1/2 or 3/4? if 1, then 1/2.
% currently set for 70% consistent
ex.consistentMappingProbability = 0.70; 

%% DISPLAY
ex.bgColour             = [0 0 0];         % background
ex.fgColour             = [255 255 255];   % text colour
%                           red        blue          yellow      green 
ex.stimulusColours      = { [192 0 0]; [0 128 204]; [224 224 0]; [0 224 0] };
ex.stimulusSize         = [80 80];
ex.stimulusShapes       = { [-1 -1; 1 -1; 1 1; -1 1] % square
                            [0 1; 1 0; 0 -1; -1 0]*1.2 % diamond
                            [-1 1; 1 1; 0 -1] % triangle
                            [-0.3 1; 0.3 1; 0.3 0.3; 1 0.3; 1 -0.3; 0.3 -0.3; 0.3 -1; 
                             -0.3 -1; -0.3 -0.3; -1 -0.3; -1 0.3; -0.3 0.3 ] % plus
                          };
% create a random polygon with vertex angles equally spaced around a 
% circle, but with random radius for each vertex, 0.5 to 1.5
% find random number generator seed - MAX 
angles      = linspace(0,2*pi,7);
ex.irrelShapes          = {[-0.5 -0.4; 0.5 -0.4; 1 0.7; -1 0.7]*1.45 % trapezium 
                           [ -1 1; 1 -1; 1 1; -1 -1;]*1.4 % double diamond
                           [ -0.6 -0.8; 0.4 -0.8; 1 0; 0.4 0.8; -0.6 0.8; 0 0]*1.45 % fat arrow 
                           [-1 -0.2; 0 -1; 1 -0.2; 0.5 0.8; -0.5 0.8; -1 -0.2]*1.3% pentagon
                           [-1 -0.1; 1 -1; 1 1; -1 1]*1.2% irreg trap 
                             
                          }; 
ex.choice1shape         = [cos(0:0.1:2*pi); sin(0:0.1:2*pi)]'; % circle
ex.choice2colour        = [192 192 192]; % grey
ex.chosenOutline        = [255 255 0]; % yellow outline for chosen item

% the four locations at which stimuli can appear. 
% the multiplier is the distance from the centre of the screen.
% x coords 1.2 times larger for the 4/3 pixel aspect ratio.
ex.stimulusLocations    = [-1.2 0; 1.2 0; 0 1; 0 -1] * 250;


% re-order the shapes or colours to 1,3,2,4 - depending on between-subject
% counterbalancing. 
if ex.counterbalanceColours==2,   ex.stimulusColours = ex.stimulusColours([1 3 2 4]); end
if ex.counterbalanceShapes ==2,   ex.stimulusShapes  = ex.stimulusShapes( [1 3 2 4]); end
ex.width=400; % width of the visual analogue line 
ex.vasLeft='0'
ex.vasRight='10'
ex.penWidth=4
%% TIMING
ex.delayForeperiod   = 0.25;  % seconds wait at start of trial
ex.delayInterchoice  = 0.25;  % between choice 1 and choice 2
ex.delayPostChoice   = 0.30;  % between choice 2 and feedback
ex.delayPostFeedback = 0.25;  % after feedback, before next trial
ex.delayPreAttention = 0.5;   % before asked what shape chosen
ex.choice1Timeout    = 4;     % seconds permitted for choice 1 before "too slow" message.
%% WIN/LOSE
ex.probability  = 0.8; % how nonderterministic is the reward?
ex.soundFiles   = {'media/click.wav', ... % 1: played on touching a target
                   'media/lose.wav', ...  % 2: played if incorrect
                   'media/win.wav', ...   % 3: played if win
                   'media/REGISTER2.wav' };    % 4: jackpot sound?
% initialise money
global bank; bank=0;

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%% RUN EXPERIMENT %%%%%%%%%%%%%
if ~exist('params','var') params=struct(); end;
result = RunExperiment( @doTrial, ex, params, @blockfn);
function blockfn(scr, el, ex, tr) % remove end-of-block screens
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function tr=doTrial(scr, el, ex, tr)
%% The sequenceof events for each trial
    % 0. Load variables for this trial
    pa = combineStruct(ex, tr);
    global bank
    global lasttrial
    tr.bank=bank;
    
    % 1. DETERMINE LOCATIONS
    tr.stimulusLocations = pa.stimulusLocations;
    if pa.vertFlip
      tr.stimulusLocations=tr.stimulusLocations([1 2 4 3],:);
    end
    if pa.horzFlip
      tr.stimulusLocations=tr.stimulusLocations([2 1 3 4],:);
    end

    if pa.firstResponseDimension==1  % which response dimension is the first decision?
      tr.dim1 = tr.stimulusLocations([1 2]  ,:); % L/R
      tr.dim2 = tr.stimulusLocations([3 4]  ,:); % then U/D
    else
      tr.dim1 = tr.stimulusLocations([3 4]  ,:); % U/D 
      tr.dim2 = tr.stimulusLocations([1 2]  ,:); % then L/R
    end
    
    
    % 2. End of block?
    if ex.breakBlocksRandomly
      [x, y, b]=GetMouse; oldp=[x y];
      if(mod(tr.allTrialIndex, ex.breakBlocksRandomly)==0)
        drawTextCentred(scr,'End of block');
        Screen('Flip',scr.w);
        while(x==oldp(1) && y==oldp(2))
          [x, y, b]=GetMouse;
          WaitSecs(0.2);
        end
      end
    end
    
    % 3. CHOICE 1 : show 2 colours, along dim1
    % choose two shape indices without replacement
    
    % we could use any irrel shape
    tr.irrelShapePossibilities = 1:length(pa.irrelShapes); 
    % but not the one probed on the previous trial
    if tr.allTrialIndex > 1 % ignore on the first trial
      tr.irrelShapePossibilities( lasttrial.transferprobe ) = [];
    end
    tr.irrelShapeIndex = randsample(tr.irrelShapePossibilities, 2, false);
    
    drawScene(scr,pa,tr,1);    % foreperiod
    WaitSecs(pa.delayForeperiod)
    drawScene(scr,pa,tr,2);    % choice of dice
    
    % get touch or mouse click
    if(pa.useMouse)
      ShowCursor
    end
    SetMouse(scr.centre(1),scr.centre(2));
    tr.choice1 = 0;
    tr=LogEvent(pa, el, tr,'startChoice1');
    b=1; while any(b), [~,~,b]=GetMouse; end % wait for all buttons up
    while ~tr.choice1 
      [z z kcode]=KbCheck; 
      if kcode(27) tr.R=pa.R_ESCAPE; return; end
      [x y b]=GetMouse(scr.w);
      if(any(b)) || 1 % ignore click events, just go on coordinates
        for i=1:size(tr.dim1,1) % for each stimulus on dim1
          d=norm( [x y]-(scr.centre+tr.dim1(i,:)) );
          if(d<norm(pa.stimulusSize))
            tr.choice1 = i;
          end
        end
      end
      if GetSecs > tr.startChoice1 + pa.choice1Timeout
        tr.R = 2; % if the timeout occurs, 
        drawTextCentred(scr, 'Too Slow', ex.fgColour);
        Screen('Flip', scr.w);
        WaitSecs(0.5);
        return;   % exit the trial straight away...
      end
    end
    % record choice
    tr=LogEvent(pa, el, tr,'endChoice1');
    tr.choice1Location = tr.dim1(tr.choice1,:);
    tr.choice1Coords   = [x y b];
    ap=audioplayer(scr.soundData{1}, scr.soundFs{1});     play(ap); % click
    drawScene(scr,pa,tr,3);   % show chosen choice 1
    WaitSecs(pa.delayInterchoice);
    
    % 4. CHOICE 2 : show 2 shapes.
    % if choice 1 was colour 1, then show 1/2 if isConsistentMapping
    %                                 or  3/4 if not
    % if chocie 1 was colour 2, then show 3/4 if isConsistentMapping
    %                                 of  1/2 if not
    
    % randomise which pair is shown at second stage
    pa.isConsistentMapping = rand < pa.consistentMappingProbability; 
    tr.isConsistentMapping = pa.isConsistentMapping;
    tr.choice2mapping = xor(tr.choice1==1, pa.isConsistentMapping)+1;  % 1 means show 1/2, 2 means 3/4
    tr.choice2stimuliIndices = 2*tr.choice2mapping+[-1 0] ; % [1,2] or [3,4]
    drawScene(scr,pa,tr,4);   % choice 2 appears
    tr.choice2 = 0;
    tr=LogEvent(pa, el, tr,'startChoice2');
    
    b=1; while any(b), [~,~,b]=GetMouse; end % wait for all buttons up
    SetMouse(scr.centre(1),scr.centre(2));
    % get touch or mouse click
    while ~tr.choice2 
      [z z kcode]=KbCheck; 
      if kcode(27) tr.R=pa.R_ESCAPE; return; end
      [x, y, b]=GetMouse(scr.w);
      if(any(b)) || 1 % ignore clicks, just use coords
        for i=1:length(tr.dim2)
          d=norm( [x y]-(scr.centre+tr.dim2(i,:)) );
          if(d<norm(pa.stimulusSize))
            tr.choice2=i;
          end
        end
      end
    end
    % record choice
    tr=LogEvent(pa, el, tr,'endChoice2');
    tr.choice2Location = tr.dim2(tr.choice2,:);
    tr.choice2Coords   = [x y b];
    tr.choice2Stim     = tr.choice2stimuliIndices(tr.choice2);
    %ap=audioplayer(scr.soundData{1}, scr.soundFs{1});     play(ap); % click 
    play(scr.soundPlayer{1}); % click
    
    drawScene(scr,pa,tr,5); % chosen choice 2
    WaitSecs(pa.delayPostChoice);    % dice roll time......
    
    % 5. OUTCOME
    tr.correct  = tr.choice2Stim == pa.rewardedStimulus;
    if tr.correct       tr.win = rand < pa.probability;     % calculate win or not
    else                tr.win = rand > pa.probability; end
    tr.winnings = tr.win;
    % ap=audioplayer(scr.soundData{tr.win+2}, scr.soundFs{tr.win+2}); % sound 2 = lose, 3 = win
    drawScene(scr,pa,tr,6);                               % show outcome
    play(scr.soundPlayer{tr.win+2});   WaitSecs(1);
    tr=LogEvent(pa, el, tr,'startReward');
    WaitSecs(pa.delayPostFeedback);                % wait till next trial
    
    HideCursor
    tr=LogEvent(pa, el, tr,'startITI');
    bank=bank+tr.winnings;
        
    % 6. ATTENTION PHASE
    tr=LogEvent(pa, el, tr,'startAttentionChoice');
    if pa.directedAttention % should we show the attention phase?
      % show blank screen 
      drawScene(scr,pa,tr,1);
      WaitSecs(pa.delayPreAttention)
      drawAttentionScene(scr,pa,tr,2);    % remind them about what they chose
      tr.choice3 = 0;
      b=1; while any(b), [~,~,b]=GetMouse; end % wait for all buttons up
      SetMouse(scr.centre(1),scr.centre(2)); % move invisible cursor to screen centre
      
      while ~tr.choice3
        [z z kcode]=KbCheck;
        if kcode(27) tr.R=pa.R_ESCAPE; return; end
        [x y b]=GetMouse(scr.w);
        if(any(b)) || 1 % ignore click events, just go on coordinates
          for i=1:size(tr.dim1,1) % for each stimulus on dim1
            d=norm( [x y]-(scr.centre+tr.dim1(i,:)) );
            if(d<norm(pa.stimulusSize))
              tr.choice3 = i;
            end
          end
        end
      end
      tr.choice3Location = tr.dim1(tr.choice3,:);
      tr.choice3Corrds   = [x y b];
      play(scr.soundPlayer{1}); % click
      
      drawAttentionScene(scr,pa,tr,3); % show chosen attention choice
    else
      WaitSecs(1); % if not directing attention, ...
    end
    tr=LogEvent(pa, el, tr,'endAttentionChoice');
    WaitSecs(pa.delayPostChoice);
      
    
    % 7. TRANSFER PHASE
    tr.transferpossibilities = 1:length(pa.irrelShapes) % we can probe any shape
    tr.transferpossibilities (tr.irrelShapeIndex)=[]; % but not the ones shown in choice1
    
    % and not the one probed on the previous trial
    if tr.allTrialIndex>1 % skip on first trial
      tr.transferpossibilities(tr.transferpossibilities == lasttrial.transferprobe) = [];
    end
    
    tr.transferprobe = randsample (tr.transferpossibilities,1)
    if tr.allTrialIndex > 10
        
        drawTransferScene(scr,pa,tr,2);    % ask which shape is more valuable
        tr.choice4 = 0;
        tr=LogEvent(pa, el, tr,'startTransferChoice');

    
        b=1; while any(b), [~,~,b]=GetMouse; end % wait for all buttons up
        SetMouse(scr.centre(1),scr.centre(2)); % move invisible cursor to screen centre

        while ~tr.choice4
          [z z kcode]=KbCheck; 
          if kcode(27) tr.R=pa.R_ESCAPE; return; end
          [x y b]=GetMouse(scr.w);
          if(any(b)) || 1 % ignore click events, just go on coordinates
                 if(y<scr.centre(2)+300 && y>scr.centre(2)+100)
                tr.choice4 = x;
              end

          end
        end
        tr=LogEvent(pa, el, tr,'endTransferChoice');
        tr.choice4Corrds   = [x y b];
        play(scr.soundPlayer{1}); % click

        drawTransferScene(scr,pa,tr,3); % show chosen attention choice 
        WaitSecs(pa.delayPostChoice);   
    end     
    
    % Manually instigate "End of block" if key pressed during feedback
    [z z kcode]=KbCheck;
    if any(kcode) % pause and zero
        drawTextCentred(scr, 'End of block', ex.fgColour);
        Screen('Flip', scr.w)
        while(KbCheck) ;end;
        KbWait;           % wait for keypress after each block
        bank=100;         % and reset money
    end
    
    % store which shape was probed on this trial, so the next trial can avoid it.
    lasttrial.transferprobe = tr.transferprobe;
    tr.R=1; % trial is complete 

function drawScene(scr,pa,tr,stage)
%% How to draw a particular stage of the trial
    Screen('TextSize',scr.w,40);
    drawTextCentred(scr, sprintf('Points: %g', tr.bank) ...
      , pa.fgColour, scr.centre-[0 0.4*scr.ssz(2)]);
    if(stage>1) % draw choice 1
      for i=1:size(tr.dim1,1) % 2 locations on dimension 1
        ce = tr.dim1(i,:) + scr.centre; % centre of location
        sh = bsxfun(@plus, ...
               bsxfun(@times, pa.irrelShapes{ tr.irrelShapeIndex(i) }, pa.stimulusSize) ... % scale shape
             , ce); % translate shape
        Screen('FillPoly',scr.w, pa.stimulusColours{i}, sh );
      end      
    end
    if(stage>2) % draw chosen choice 1
      ce = tr.dim1(tr.choice1,:) + scr.centre;
      sh = bsxfun(@plus, ...
             bsxfun(@times, pa.irrelShapes{ tr.irrelShapeIndex(tr.choice1) }, pa.stimulusSize) ...
           , ce);
      Screen('FramePoly',scr.w, pa.chosenOutline, sh, 6);
    end

    if(stage>3) % draw choice 2
      for i=1:length(tr.dim2)
        ce = tr.dim2(i,:) + scr.centre;
        % select correct shape, using stimulus indices
        sh = bsxfun(@plus, ...
               bsxfun(@times, pa.stimulusShapes{ tr.choice2stimuliIndices(i) }, pa.stimulusSize) ...
             , ce);
        Screen('FillPoly',scr.w, pa.choice2colour, sh);
      end
    end
    if(stage>4) % draw chosen choice 2
      ce = tr.dim2(tr.choice2,:) + scr.centre;
      sh = bsxfun(@plus, ...
             bsxfun(@times, pa.stimulusShapes{ tr.choice2stimuliIndices( tr.choice2 ) }, pa.stimulusSize) ...
           , ce );
      Screen('FramePoly',scr.w, pa.chosenOutline, sh,6);
    end
    if(stage>5) % draw outcome
      if     (tr.winnings>0)  text=sprintf('Win!',tr.winnings);
      elseif (tr.winnings==0) text='Lose.';
      else                    text=sprintf('Lose!', -1);
      end
      drawTextCentred(scr, text, pa.fgColour, scr.centre);
    end
    Screen('Flip',scr.w);

function drawAttentionScene(scr, pa, tr, stage)
  % give options left and right, and ask 
  % on which side was the previously chosen shape? (working memory / attention shift)
  drawTextCentred(scr, sprintf('Points: %g', tr.bank) ...
    , pa.fgColour, scr.centre-[0 0.4*scr.ssz(2)]);
  dim = tr.dim1; % show the colours on the first axis
  if(stage>1) % draw choice 1
    for i=1:size(dim,1) % 2 locations on dimension 1
      ce = dim(i,:) + scr.centre; % centre of location
      sh = bsxfun(@plus, ...
        bsxfun(@times, pa.choice1shape, pa.stimulusSize) ... % scale shape
        , ce); % translate shape
      Screen('FillPoly',scr.w, pa.fgColour, sh );
    end
  end
  drawTextCentred(scr, 'Which side was the shape you selected?', ...
    pa.fgColour,scr.centre +[0 0.1*scr.ssz(2)]);
  if(stage>2) % draw chosen remembered item and ask how it is valued 
  ce = dim(tr.choice3,:) + scr.centre;
    sh = bsxfun(@plus, ...
      bsxfun(@times, pa.choice1shape, pa.stimulusSize) ...
      , ce);
    Screen('FramePoly',scr.w, pa.chosenOutline, sh, 6);
  end
  Screen('Flip',scr.w);
  
function drawTransferScene(scr,pa,tr,stage)
  % draw the two shapes from stage 1, in grey. 
  % Ask which one is more valuable.
  drawTextCentred(scr, sprintf('Points: %g', tr.bank) ...
    , pa.fgColour, scr.centre-[0 0.4*scr.ssz(2)]);
  dim = tr.dim2; % show the shapes on the second axis
  if(stage>1) % draw choice 1
 
      ce = scr.centre; % centre of location
      sh = bsxfun(@plus, ...
        bsxfun(@times, pa.irrelShapes{tr.transferprobe}, ...
        pa.stimulusSize) ... % scale shape
        , ce); % translate shape
      Screen('FillPoly',scr.w, pa.choice2colour, sh ); % grey

  end
  drawTextCentred(scr, 'How much do you value this shape?', ...
    pa.fgColour,scr.centre +[0 0.3*scr.ssz(2)]);
y=scr.centre(2)+200;
    drawTextCentred(scr, pa.vasLeft, pa.fgColour, scr.centre+[-pa.width +250]);
    drawTextCentred(scr, pa.vasRight, pa.fgColour, scr.centre+[pa.width +250]);
    Screen('DrawLine', scr.w, pa.fgColour, scr.centre(1)-pa.width, y, scr.centre(1)+pa.width, y, pa.penWidth);
    Screen('Flip', scr.w);
    if stage>2
        Screen('DrawLine', scr.w, pa.chosenOutline, tr.choice4, y+25,tr.choice4,y-25, pa.penWidth)
    end
    

