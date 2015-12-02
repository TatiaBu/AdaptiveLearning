function Data = AdaptiveLearning(unitTest)

if nargin == 0
    unitTest = false;
end

if ~unitTest
    clear all
    unitTest = false;
end

% indentifies your machine. If you have internet!
computer = identifyPC;
%computer = 'Macbook'

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       - condition:
%%           - shield
%%               - oddballPractice
%%               - oddballPractice_NoOddball
%%               - main
%%               - mainPractice
%%           - followOutcome
%%          - followOutcomePractice
%%          - followCannon
%%          - followCannonPractice
%
%       - whichPractice:
%           oddballPractice
%           cpPractice
%           followOutcomePractice
%           followCannonPractice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% changes in the task:
% renamed variables:

% boatType --> shieldType
% sigma --> concentration
% vola --> haz

%% for brown:
% ID length?
% text size?
% check trigger!
% check behavioral data!
% check sample rate!
% find a good name for each task!
% what about catch trials?
%% adapt folder path! line: XXXXX

runIntro = true;
askSubjInfo = true;
oddball = true;
sendTrigger = false;
randomize = false;
shieldTrials = 4; % 4
practTrials = 20; % 20
trials = 10; % 240
blockIndices = [1 5 120 180];
haz = [.25 1 0];
oddballProb = [.25 0];
driftConc = [30 99999999];
safe = [3 0];
rewMag = 0.1;
jitter = 0.2;
practiceTrialCriterion = 10;
%test = false;
debug = false;

if ~oddball
    % Dresden
    controlTrials = 1; % 120
    concentration = [12 12 99999999];
    DataFollowOutcome = nan;
    DataFollowCannon = nan;            
    textSize = 19;
    % Check number of trials in each condition
    if  (trials > 1 && mod(trials, 2)) == 1 || (controlTrials > 1 && mod(controlTrials, 2) == 1)
        msgbox('All trials must be even or equal to 1!');
        return
    end
else
    % Brown
    controlTrials = nan;
    concentration = [10 12 99999999];
    DataOddball = nan;
    textSize = 30;
end

% Savedirectory
if isequal(computer, 'Macbook')
    cd('/Users/Bruckner/Documents/MATLAB/AdaptiveLearning/DataDirectory');
elseif isequal(computer, 'Dresden')
    cd('C:\\Users\\TU-Dresden\\Documents\\MATLAB\\AdaptiveLearning\\DataDirectory');
elseif isequal(computer, 'Brown')
    %savdir = 'C:\Users\lncc\Dropbox\HeliEEG';
    %% Matt: please adapt this
    cd('C:\Users\lncc\Dropbox\CannonDrugStudy\data');
end

%% User Input

a = clock;
rand('twister', a(6).*10000);

if askSubjInfo == false
    ID = '99999';
    age = '99';
    sex = 'm/w';
    cBal = 1;
    reward = 1;
    if ~oddball
        group = '1';
        Subject = struct('ID', ID, 'age', age, 'sex', sex, 'group', group, 'cBal', cBal, 'rew', reward, 'date', date, 'session', '1');
    else
        session = '1';
        Subject = struct('ID', ID, 'age', age, 'sex', sex, 'session', session, 'cBal', cBal, 'rew', reward, 'date', date);
    end
elseif askSubjInfo == true
    if ~ oddball
        prompt = {'ID:','Age:', 'Group:', 'Sex:', 'cBal', 'Reward'};
    else
        prompt = {'ID:','Age:', 'Session:', 'Sex:', 'cBal', 'Reward'};
        
    end
    name = 'SubjInfo';
    numlines = 1;
    
    if randomize
        if ~oddball
            cBal = num2str(round(unifrnd(1,6)));
        else
            cBal = num2str(round(unifrnd(1,2)));
        end
        reward = num2str(round(unifrnd(1,2)));
        defaultanswer = {'99999','99', '1', 'm', cBal, reward};
    else
        defaultanswer = {'99999','99', '1', 'm', '1', '1'};
    end
    subjInfo = inputdlg(prompt,name,numlines,defaultanswer);
    subjInfo{7} = date;
    
    if numel(subjInfo{1}) < 5 || numel(subjInfo{1}) > 5
        msgbox('ID: must consist of five numbers!');
        return
    end
    
    if ~ oddball
        if subjInfo{3} ~= '1' && subjInfo{3} ~= '2'
            msgbox('Group: "1" or "2"?');
            return
        end
    else
        if subjInfo{3} ~= '1' && subjInfo{3} ~= '2' && subjInfo{3} ~= '3'
            msgbox('Session: "1", "2" or "3"?');
            return
        end
    end
    
    if subjInfo{4} ~= 'm' && subjInfo{4} ~= 'f'
        msgbox('Sex: "m" or "f"?');
        return
    end
    
    if ~oddball
        if subjInfo{5} ~= '1' && subjInfo{5} ~= '2' && subjInfo{5} ~= '3'...
                && subjInfo{5} ~= '4' && subjInfo{5} ~= '5' && subjInfo{5} ~= '6'
            msgbox('cBal: 1, 2, 3, 4, 5 or 6?');
            return
        end
    else
        if subjInfo{5} ~= '1' && subjInfo{5} ~= '2'
            msgbox('cBal: 1 or 2 ?');
            return
        end
    end
    
    if subjInfo{6} ~= '1' && subjInfo{6} ~= '2'
        msgbox('Reward: 1 or 2?');
        return
    end
    
    if ~oddball
        Subject = struct('ID', subjInfo(1), 'age', subjInfo(2), 'sex',...
            subjInfo(4), 'group', subjInfo(3), 'cBal', str2double(cell2mat(subjInfo(5))), 'rew',...
            str2double(cell2mat(subjInfo(6))), 'date', subjInfo(7), 'session', '1');
    else
        Subject = struct('ID', subjInfo(1), 'age', subjInfo(2), 'sex',...
            subjInfo(4), 'session', subjInfo(3), 'cBal', str2double(cell2mat(subjInfo(5))), 'rew',...
            str2double(cell2mat(subjInfo(6))), 'date', subjInfo(7));
    end
    
    if ~oddball
        checkIdInData = dir(sprintf('*%s*', num2str(cell2mat((subjInfo(1))))));
    else
        checkIdInData = dir(sprintf('*%s_session%s*' , num2str(cell2mat((subjInfo(1)))), num2str(cell2mat((subjInfo(3))))));
    end
    
    fileNames = {checkIdInData.name};
    
    if  ~isempty(fileNames);
        if ~oddball
            msgbox('Diese ID wird bereits verwendet!');
        else
            msgbox('ID and session have already been used!');
        end
        return
    end
end

Screen('Preference', 'VisualDebugLevel', 3);
Screen('Preference', 'SuppressAllWarnings', 1);
Screen('Preference', 'SkipSyncTests', 2);

fScreensize = 'screensize'; screensize = get(0,'MonitorPositions');
screensizePart = (screensize(3:4));
fZero = 'zero'; zero = screensizePart / 2;
fWindow = 'window';
fWindowRect = 'windowRect';

[window, windowRect, textures] = OpenWindow;

startTime = GetSecs;

ID = 'ID';
age = 'age';
sex = 'sex';
rew = 'rew';
actRew = 'actRew';
Date = 'Date';
cond = 'cond';
trial = 'trial';
outcome = 'outcome';
allASS = 'allASS';
distMean = 'distMean';
cp = 'cp';
fTAC = 'TAC'; TAC = fTAC;
shieldType = 'shieldType';
catchTrial = 'catchTrial';
%fshieldType = 'shieldType'; shieldType = fshieldType;
%fCatchTrial = 'catchTrial'; catchTrial = fCatchTrial;
triggers = 'triggers';
pred = 'pred';
predErr = 'predErr';
%fMemErr = 'memErr'; memErr = fMemErr;
memErr = 'memErr';
%fUP = 'UP'; UP = fUP;
UP = 'UP';
hit = 'hit';
cBal = 'cBal';
perf = 'perf';
accPerf = 'accPerf';
actJitter = 'actJitter';
block = 'block';
initiationRTs = 'initiationRTs';
timestampOnset = 'timestampOnset';
timestampPrediction = 'timestampPrediction';
timestampOffset = 'timestampOffset';
fhazs = 'haz'; hazs = fhazs;
fOddballProb = 'oddballProb'; oddballProbs = fOddballProb;
fDriftConc = 'driftConc'; driftConcentrations = fDriftConc;
fconcentrations = 'concentration'; concentrations = fconcentrations;
fOddBall = 'oddBall'; oddBall = fOddBall;
oddBall = 'oddBall';

fieldNames = struct(actJitter, actJitter, block, block,...
    initiationRTs, initiationRTs,timestampOnset, timestampOnset,...
    timestampPrediction, timestampPrediction, timestampOffset,...
    timestampOffset, oddBall, oddBall, 'oddball', oddball, 'oddballProb',...
    oddballProbs, fDriftConc, driftConcentrations, allASS, allASS, ID, ID,...
    fconcentrations, concentrations, age, age, sex, sex, rew, rew, actRew,...
    actRew, 'date',Date, cond, cond, trial, trial, outcome, outcome,...
    distMean, distMean, cp, cp,fhazs, hazs, fTAC, TAC, shieldType,...
    shieldType, catchTrial, catchTrial, triggers, triggers, pred, pred,...
    predErr, predErr, memErr, memErr, UP, UP,...
    hit, hit, cBal, cBal, perf, perf, accPerf, accPerf);

if isequal(computer, 'Dresden')
    sentenceLength = 70;
elseif isequal(computer, 'Brown')
    sentenceLength = 75;
else
    sentenceLength = 85;
end
ref = GetSecs;
gParam = struct('jitter', jitter,...
    'blockIndices', blockIndices, 'ref', ref, 'sentenceLength',...
    sentenceLength, 'oddball', oddball, 'driftConc', driftConc,...
    'oddballProb', oddballProb, fconcentrations, concentration, fhazs, haz,...
    'sendTrigger', sendTrigger, 'computer', computer, 'trials',...
    trials, 'shieldTrials', shieldTrials, 'practTrials', practTrials,...
    'controlTrials', controlTrials, 'safe', safe, 'rewMag', rewMag,...
    fScreensize, screensize, fZero, zero,fWindow, window, fWindowRect,...
    windowRect, 'practiceTrialCriterion',practiceTrialCriterion, 'askSubjInfo',...
    askSubjInfo);

predSpotRad = 10;
shieldAngle = 30;
outcSize = 10;
cannonEnd = 5;
meanPoint = 1;
rotationRad = 150;
predSpotDiam = predSpotRad * 2;
outcDiam = outcSize * 2;
spotDiamMean = meanPoint * 2;
cannonEndDiam = cannonEnd * 2;
predSpotRect = [0 0 predSpotDiam predSpotDiam];
outcRect = [0 0 outcDiam outcDiam];
cannonEndRect = [0 0 cannonEndDiam cannonEndDiam];
spotRectMean = [0 0 spotDiamMean spotDiamMean];
boatRect = [0 0 50 50];
centBoatRect = CenterRect(boatRect, windowRect);
predCentSpotRect = CenterRect(predSpotRect, windowRect);
outcCentRect = CenterRect(outcRect, windowRect);
outcCentSpotRect = CenterRect(outcRect, windowRect);
cannonEndCent = CenterRect(cannonEndRect, windowRect);
centSpotRectMean = CenterRect(spotRectMean,windowRect);

unit = 2*pi/360;
initialRotAngle = 0*unit;
rotAngle = initialRotAngle;

circle = struct('shieldAngle', shieldAngle, 'cannonEndCent',...
    cannonEndCent, 'outcCentSpotRect', outcCentSpotRect, 'predSpotRad',...
    predSpotRad, 'outcSize', outcSize, 'meanRad', meanPoint, 'rotationRad',...
    rotationRad, 'predSpotDiam', predSpotDiam, 'outcDiam',...
    outcDiam, 'spotDiamMean', spotDiamMean, 'predSpotRect', predSpotRect,...
    'outcRect', outcRect, 'spotRectMean', spotRectMean,...
    'boatRect', boatRect, 'centBoatRect', centBoatRect, 'predCentSpotRect',...
    predCentSpotRect, 'outcCentRect', outcCentRect, 'centSpotRectMean',...
    centSpotRectMean, 'unit', unit, 'initialRotAngle', initialRotAngle, 'rotAngle', rotAngle);

gold = [255 215 0];
blue = [0 0 255];
silver = [160 160 160];
green = [0 255 0];
colors = struct('gold', gold, 'blue', blue, 'silver', silver, 'green', green);

KbName('UnifyKeyNames')
rightKey = KbName('j');
leftKey = KbName('f');
delete = KbName('DELETE');
rightArrow = KbName('RightArrow');
leftArrow = KbName('LeftArrow');
rightSlowKey = KbName('h');
leftSlowKey = KbName('g');
space = KbName('Space');

if isequal(computer, 'Macbook')
    enter = 40;
    s = 22;
elseif isequal(computer, 'Dresden')
    enter = 13;
    s = 83;
elseif isequal(computer, 'Brown')
    enter = 13;
    s = 83;
end

keys = struct('delete', delete, 'rightKey', rightKey, 'rightArrow',...
    rightArrow, 'leftArrow', leftArrow, 'rightSlowKey', rightSlowKey,...
    'leftKey', leftKey, 'leftSlowKey', leftSlowKey, 'space', space,...
    'enter', enter, 's', s);

%% Trigger settings
if sendTrigger == true
    config_io;
end

fSampleRate = 'sampleRate'; sampleRate = 512; % Sample rate.
%fPort = 'port'; port = 53328; % LPT port (Dresden)
%LPT1address = hex2dec('E050'); %standard location of LPT1 port % copied from heliEEG_main
fPort = 'port'; port = hex2dec('E050'); % LPT port
triggers = struct(fSampleRate, sampleRate, fPort, port);

%IndicateOddball = 'Oddball Task';
%IndicateMain = 'Change Point Task';
IndicateFollowCannon = 'Follow Cannon Task';
IndicateFollowOutcome = 'Follow Outcome Task';
fTxtPressEnter = 'txtPressEnter';

if oddball
    header = 'Real Task!';
    txtPressEnter = 'Press Enter to continue';
    if Subject.cBal == 1
        txtStartTask = ['This is the beginning of the real task. During '...
            'this block you will earn real money for your performance. '...
            'The trials will be exactly the same as those in the '...
            'previous practice block. On each trial a cannon will aim '...
            'at a location on the circle. On most trials the cannon will '...
            'fire a ball somewhere near the point of aim. '...
            'However, on a few trials a ball will be shot '...
            'from a different cannon that is equally likely to '...
            'hit any location on the circle. Like in the previous '...
            'block you will not see the cannon, but still have to infer its '...
            'aim in order to catch balls and earn money.'];
    else
        txtStartTask = ['This is the beginning of the real task. During '...
            'this block you will earn real money for your performance. '...
            'The trials will be exactly the same as those in the '...
            'previous practice block. On each trial a cannon will aim '...
            'at a location on the circle. On all trials the cannon will '...
            'fire a ball somewhere near the point of aim. '...
            'Most of the time the cannon will remain aimed at '...
            'the same location, but occasionally the cannon '...
            'will be reaimed. Like in the previous '...
            'block you will not see the cannon, but still '...
            'have to infer its aim in order to catch balls and earn money.'];
    end
else
    txtPressEnter = 'Weiter mit Enter';
    
    header = 'Anfang der Studie';
    if Subject.cBal == 1
        txtStartTask = ['Du hast die �bungsphase abgeschlossen. Kurz '...
            'zusammengefasst f�ngst du also die meisten '...
            'Kugeln, wenn du den orangenen Punkt auf die Stelle '...
            'bewegst, auf die die Kanone zielt. Weil du die '...
            'Kanone nicht mehr sehen kannst, musst du diese '...
            'Stelle aufgrund der Position der letzten Kugeln '...
            'einsch�tzen. Das Geld f�r die gefangenen '...
            'Kugeln bekommst du nach der Studie '...
            'ausgezahlt.\n\nViel Erfolg!'];
    else
        txtStartTask = ['Du hast die �bungsphase abgeschlossen. Kurz '...
            'zusammengefasst ist es deine Aufgabe Kanonenkugeln '...
            'aufzusammeln, indem du deinen Korb '...
            'an der Stelle platzierst, wo die letzte Kanonenkugel '...
            'gelandet ist (schwarzer Strich). '...
            'Das Geld f�r die gesammelten '...
            'Kugeln bekommst du nach der Studie '...
            'ausgezahlt.\n\nViel Erfolg!'];
    end
end

strings = struct(fTxtPressEnter, txtPressEnter);
taskParam = struct('gParam', gParam, 'circle', circle, 'keys', keys,...
    'fieldNames', fieldNames, 'triggers', triggers,...
    'colors', colors, 'strings', strings, 'textures', textures,...
    'unitTest', unitTest);

if ~oddball
    
    if Subject.cBal == 1
        DataMain = MainCondition;
        taskParam.gParam.window = CloseScreenAndOpenAgain;
        DataFollowOutcome = FollowOutcomeCondition;
        taskParam.gParam.window = CloseScreenAndOpenAgain;
        DataFollowCannon = FollowCannonCondition;
        
    elseif Subject.cBal == 2
        
        DataMain = MainCondition;
        taskParam.gParam.window = CloseScreenAndOpenAgain;
        DataFollowCannon = FollowCannonCondition;
        taskParam.gParam.window = CloseScreenAndOpenAgain;
        DataFollowOutcome = FollowOutcomeCondition;
        
    elseif Subject.cBal == 3
        
        DataFollowOutcome = FollowOutcomeCondition;
        taskParam.gParam.window = CloseScreenAndOpenAgain;
        DataMain = MainCondition;
        taskParam.gParam.window = CloseScreenAndOpenAgain;
        DataFollowCannon = FollowCannonCondition;
        
    elseif Subject.cBal == 4
        
        DataFollowCannon = FollowCannonCondition;
        taskParam.gParam.window = CloseScreenAndOpenAgain;
        DataMain = MainCondition;
        taskParam.gParam.window = CloseScreenAndOpenAgain;
        DataFollowOutcome = FollowOutcomeCondition;
        
    elseif Subject.cBal == 5
        
        DataFollowOutcome = FollowOutcomeCondition;
        taskParam.gParam.window = CloseScreenAndOpenAgain;
        DataFollowCannon = FollowCannonCondition;
        taskParam.gParam.window = CloseScreenAndOpenAgain;
        DataMain = MainCondition;
        
    elseif Subject.cBal == 6
        
        DataFollowCannon = FollowCannonCondition;
        taskParam.gParam.window = CloseScreenAndOpenAgain;
        DataFollowOutcome = FollowOutcomeCondition;
        taskParam.gParam.window = CloseScreenAndOpenAgain;
        DataMain = MainCondition;
        
    end
    
else
    
    if Subject.cBal == 1
        DataOddball = OddballCondition;
        DataMain = MainCondition;
    elseif Subject.cBal == 2
        DataMain = MainCondition;
        DataOddball = OddballCondition;
    end
    
end

if ~oddball
    totWin = DataFollowOutcome.accPerf(end) + DataMain.accPerf(end)...
        + DataFollowCannon.accPerf(end);
else
    totWin = DataOddball.accPerf(end) + DataMain.accPerf(end);
end

if ~oddball
    Data.DataMain = DataMain;
    Data.DataFollowOutcome = DataFollowOutcome;
    Data.DataFollowCannon = DataFollowCannon;
else
    Data.DataMain = DataMain;
    Data.DataOddball = DataOddball;
end

EndOfTask

ListenChar();
ShowCursor;
Screen('CloseAll');

    function DataOddball = OddballCondition
        
        if runIntro && ~unitTest
            if isequal(Subject.session, '1')
                Instructions(taskParam, 'oddballPractice', Subject);
                
                Main(taskParam, haz(3), concentration(1), 'oddballPractice', Subject);
                
                txtStartTask = ['This is the beginning of the real task. During '...
                    'this block you will earn real money for your performance. '...
                    'The trials will be exactly the same as those in the '...
                    'previous practice block. On each trial a cannon will aim '...
                    'at a location on the circle. On most trials the cannon will '...
                    'fire a ball somewhere near the point of aim. '...
                    'However, on a few trials a ball will be shot '...
                    'from a different cannon that is equally likely to '...
                    'hit any location on the circle. Like in the previous '...
                    'block you will not see the cannon, but still have to infer its '...
                    'aim in order to catch balls and earn money.'];
                
            elseif isequal(Subject.session, '2') || isequal(Subject.session, '3')
                header = 'Oddball Task';
                txtStartTask = ['This is the beginning of the ODDBALL TASK. During '...
                    'this block you will earn real money for your performance. '...
                    'The trials will be exactly the same as those in the '...
                    'in the last session. On each trial a cannon will aim '...
                    'at a location on the circle. On most trials the cannon will '...
                    'fire a ball somewhere near the point of aim. '...
                    'However, on a few trials a ball will be shot '...
                    'from a different cannon that is equally likely to '...
                    'hit any location on the circle. Like in the previous '...
                    'session you will not see the cannon, but still have to infer its '...
                    'aim in order to catch balls and earn money.'];
                
            end
            
            feedback = false;
            BigScreen(taskParam, txtPressEnter, header, txtStartTask, feedback);
        end
        [~, DataOddball] = Main(taskParam, haz(1), concentration(1), 'oddball', Subject);
        
    end

    function DataMain = MainCondition
        
        if runIntro && ~unitTest
            
            if isequal(Subject.session, '1')
                
                if ~oddball
                    if isequal(Subject.group, '1')
                        txtStartTask = ['Du hast die �bungsphase abgeschlossen. Kurz '...
                            'zusammengefasst wehrst du also die meisten '...
                            'Kugeln ab, wenn du den orangenen Punkt auf die Stelle '...
                            'bewegst, auf die die Kanone zielt. Weil du die '...
                            'Kanone meistens nicht mehr sehen kannst, musst du diese '...
                            'Stelle aufgrund der Position der letzten Kugeln '...
                            'einsch�tzen. Das Geld f�r die abgewehrten '...
                            'Kugeln bekommst du nach der Studie '...
                            'ausgezahlt.\n\nViel Erfolg!'];
                    else
                        txtStartTask = ['Sie haben die �bungsphase abgeschlossen. Kurz '...
                            'zusammengefasst wehren Sie also die meisten '...
                            'Kugeln ab, wenn Sie den orangenen Punkt auf die Stelle '...
                            'bewegen, auf die die Kanone zielt. Weil Sie die '...
                            'Kanone meistens nicht mehr sehen k�nnen, m�ssen Sie diese '...
                            'Stelle aufgrund der Position der letzten Kugeln '...
                            'einsch�tzen. Das Geld f�r die abgewehrten '...
                            'Kugeln bekommen Sie nach der Studie '...
                            'ausgezahlt.\n\nViel Erfolg!'];
                    end
                end
                
                Instructions(taskParam, 'mainPractice', Subject);
                Main(taskParam, haz(3), concentration(1), 'mainPractice', Subject);
                feedback = false;
                BigScreen(taskParam, txtPressEnter, header, txtStartTask, feedback);
            else
                header = 'Change Point Task';
                txt = ['This is the beginning of the CHANGE POINT TASK. During '...
                    'this block you will earn real money for your performance. '...
                    'The trials will be exactly the same as those in the '...
                    'previous session. On each trial a cannon will aim '...
                    'at a location on the circle. On all trials the cannon will '...
                    'fire a ball somewhere near the point of aim. '...
                    'Most of the time the cannon will remain aimed at '...
                    'the same location, but occasionally the cannon '...
                    'will be reaimed. Like in the previous '...
                    'session you will not see the cannon, but still '...
                    'have to infer its aim in order to catch balls and earn money.'];
                feedback = false;
                BigScreen(taskParam, txtPressEnter, header, txt, feedback);
            end
            
        elseif isequal(Subject.session, '2') || isequal(Subject.session, '3')
            
            
            Screen('TextSize', taskParam.gParam.window, 30);
            Screen('TextFont', taskParam.gParam.window, 'Arial');
            VolaIndication(taskParam,txtStartTask, txtPressEnter)
            %feedback = false;
            %BigScreen(taskParam, txtPressEnter, header, txt, feedback);
            
        end
        [~, DataMain] = Main(taskParam, haz(1), concentration(1), 'main', Subject);
        
    end

    function DataFollowOutcome = FollowOutcomeCondition
        
        if runIntro && ~unitTest
            if isequal(Subject.group, '1')
                txtStartTask = ['Du hast die �bungsphase abgeschlossen. Kurz '...
                    'zusammengefasst ist es deine Aufgabe Kanonenkugeln '...
                    'aufzusammeln, indem du deinen Korb '...
                    'an der Stelle platzierst, wo die letzte Kanonenkugel '...
                    'gelandet ist (schwarzer Strich). '...
                    'Das Geld f�r die gesammelten '...
                    'Kugeln bekommst du nach der Studie '...
                    'ausgezahlt.\n\nViel Erfolg!'];
            else
                txtStartTask = ['Sie haben die �bungsphase abgeschlossen. Kurz '...
                    'zusammengefasst ist es Ihre Aufgabe Kanonenkugeln '...
                    'aufzusammeln, indem Sie Ihren Korb '...
                    'an der Stelle platzieren, wo die letzte Kanonenkugel '...
                    'gelandet ist (schwarzer Strich). '...
                    'Das Geld f�r die gesammelten '...
                    'Kugeln bekommen Sie nach der Studie '...
                    'ausgezahlt.\n\nViel Erfolg!'];
            end
            Instructions(taskParam, 'followOutcomePractice', Subject)
            Main(taskParam, haz(3),concentration(1), 'followOutcomePractice', Subject);
            feedback = false;
            BigScreen(taskParam, txtPressEnter, header, txtStartTask, feedback);
        else
            Screen('TextSize', taskParam.gParam.window, 30);
            Screen('TextFont', taskParam.gParam.window, 'Arial');
            VolaIndication(taskParam, IndicateFollowOutcome, txtPressEnter)
        end
        [~, DataFollowOutcome] = Main(taskParam, haz(1), concentration(1), 'followOutcome', Subject);
        
    end

    function DataFollowCannon = FollowCannonCondition
        
        if runIntro && ~unitTest
            if isequal(Subject.group, '1')
                txtStartTask = ['Du hast die �bungsphase abgeschlossen. Kurz '...
                    'zusammengefasst wehrst du die meisten '...
                    'Kugeln ab, wenn du den orangenen Punkt auf die Stelle '...
                    'bewegst, auf die die Kanone zielt (schwarze Nadel). '...
                    'Dieses Mal kannst du die Kanone sehen.\n\nViel Erfolg!'];
            else
                txtStartTask = ['Sie haben die �bungsphase abgeschlossen. Kurz '...
                    'zusammengefasst wehren Sie die meisten '...
                    'Kugeln ab, wenn Sie den orangenen Punkt auf die Stelle '...
                    'bewegen, auf die die Kanone zielt (schwarze Nadel). '...
                    'Dieses Mal k�nnen Sie die Kanone sehen.\n\nViel Erfolg!'];
            end
            Instructions(taskParam, 'followCannonPractice', Subject)
            Main(taskParam, haz(3),concentration(1), 'followCannonPractice', Subject);
            feedback = false;
            BigScreen(taskParam, txtPressEnter, header, txtStartTask, feedback);
        else
            Screen('TextSize', taskParam.gParam.window, 30);
            Screen('TextFont', taskParam.gParam.window, 'Arial');
            VolaIndication(taskParam, IndicateFollowCannon, txtPressEnter)
        end
        [~, DataFollowCannon] = Main(taskParam, haz(1), concentration(1), 'followCannon', Subject);
        
    end

    function [window, windowRect, textures] = OpenWindow
        
        if debug == true
            [ window, windowRect] = Screen('OpenWindow', 0, [66 66 66], [420 250 1020 650]);
        else
            [ window, windowRect ] = Screen('OpenWindow', 0, [66 66 66], []);
        end
        
        imageRect = [0 0 120 120];
        dstRect = CenterRect(imageRect, windowRect);
        [cannonPic, ~, alpha]  = imread('cannon.png');
        cannonPic(:,:,4) = alpha(:,:);
        Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        cannonTxt = Screen('MakeTexture', window, cannonPic);
        [shieldPic, ~, alpha]  = imread('shield.png');
        shieldPic(:,:,4) = alpha(:,:);
        shieldTxt = Screen('MakeTexture', window, shieldPic);
        [basketPic, ~, alpha]  = imread('basket.png');
        basketPic(:,:,4) = alpha(:,:);
        basketTxt = Screen('MakeTexture', window, basketPic);
        textures = struct('cannonTxt', cannonTxt, 'shieldTxt', shieldTxt,...
            'basketTxt', basketTxt, 'dstRect', dstRect);
        
        ListenChar(2);
        %HideCursor;
        
    end

    function window = CloseScreenAndOpenAgain
        
        if ~unitTest
            Screen('TextFont', taskParam.gParam.window, 'Arial');
            Screen('TextSize', taskParam.gParam.window, 30);
            
            txt='Ende der Aufgabe!\n\nBitte auf den Versuchsleiter warten';
            
            while 1
                
                Screen('FillRect', taskParam.gParam.window, []);
                DrawFormattedText(taskParam.gParam.window, txt,...
                    'center', 100, [0 0 0]);
                Screen('DrawingFinished', taskParam.gParam.window);
                
                
                t = GetSecs;
                Screen('Flip', taskParam.gParam.window, t + 0.1);
                [~, ~, keyCode] = KbCheck;
                
                if find(keyCode) == taskParam.keys.s
                    break
                end
            end
            
            WaitSecs(1);
            
            %ListenChar();
            ShowCursor;
            Screen('CloseAll');
            disp('Press start to continue...')
            WaitSecs(1);
            
            while 1
                [ keyIsDown, ~, keyCode ] = KbCheck;
                if keyIsDown
                    if keyCode(taskParam.keys.s)
                        break
                    end
                end
            end
            
            window = OpenWindow;
            
        end
        window = taskParam.gParam.window;
    end

    function EndOfTask
        
        while 1
            
            if oddball
                header = 'End of task!';
                txt = sprintf('Thank you for participating!\n\n\nYou earned $ %.2f', totWin);
            else
                header = 'Ende des Versuchs!';
                if isequal(Subject.group, '1')
                    txt = sprintf('Vielen Dank f�r deine Teilnahme!\n\n\nDu hast %.2f Euro verdient', totWin);
                else
                    txt = sprintf('Vielen Dank f�r Ihre Teilnahme!\n\n\nSie haben %.2f Euro verdient', totWin);
                end
            end
            Screen('DrawLine', taskParam.gParam.window, [0 0 0], 0,...
                taskParam.gParam.screensize(4)*0.16,...
                taskParam.gParam.screensize(3), taskParam.gParam.screensize(4)*0.16, 5);
            Screen('DrawLine', taskParam.gParam.window, [0 0 0], 0,...
                taskParam.gParam.screensize(4)*0.8,...
                taskParam.gParam.screensize(3), taskParam.gParam.screensize(4)*0.8, 5);
            Screen('FillRect', taskParam.gParam.window, [0 25 51],...
                [0, (taskParam.gParam.screensize(4)*0.16)+3,...
                taskParam.gParam.screensize(3), (taskParam.gParam.screensize(4)*0.8)-2]);
            Screen('TextSize', taskParam.gParam.window, 30);
            DrawFormattedText(taskParam.gParam.window, header,...
                'center', taskParam.gParam.screensize(4)*0.1);
            Screen('TextSize', taskParam.gParam.window, textSize);
            DrawFormattedText(taskParam.gParam.window, txt,...
                'center', 'center');
            Screen('DrawingFinished', taskParam.gParam.window, [], []);
            time = GetSecs;
            Screen('Flip', taskParam.gParam.window, time + 0.1);
            
            [ ~, ~, keyCode ] = KbCheck;
            if find(keyCode) == taskParam.keys.s & ~taskParam.unitTest
                break
            elseif taskParam.unitTest
                WaitSecs(1);
                break
            end
        end
    end

sprintf('total time: %s minutes', (GetSecs - startTime)/60)

end

