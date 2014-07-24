function BattleShipsControlInstructions(taskParam, subject)
% Function BattleShipsControlInstructions is an intro for the control session.

KbReleaseWait();

% Screen 1.
txtPressEnter = 'Weiter mit Enter';
header = 'Ged�chtnisaufgabe';
if isequal(taskParam.gParam.computer, 'D_Pilot')
txt = ['Zum Abschluss kommt eine Ged�chtnisaufgabe. Hier sollst du dir '...
        'die Position des Bootes merken\n\nund den blauen Punkt '...
        'daraufhin genau auf diese Position steuern.'];
elseif isequal(taskParam.gParam.computer, 'Dresden')
txt = ['Zum Abschluss kommt eine Ged�chtnisaufgabe. Hier sollst du dir '...
        'die\n\nPosition des Bootes merken und den blauen Punkt '...
        'daraufhin genau\n\nauf diese Position steuern.'];    
else
txt = ['Zum Abschluss kommt eine Ged�chtnisaufgabe. Hier sollst du dir '...
        'die Position der Kanonenkugel merken und den blauen Punkt '...
        'daraufhin genau auf diese Position steuern.'];    
end
feedback = false;
BigScreen(taskParam, txtPressEnter, header, txt, feedback)

% Screen 2.
outcome = 238;
txt = 'Merke dir jetzt die Position der Kanonenkugel...';

while 1
    
    LineAndBack(taskParam.gParam.window, taskParam.gParam.screensize)
    DrawFormattedText(taskParam.gParam.window,txt,taskParam.gParam.screensize(3)*0.15,taskParam.gParam.screensize(4)*0.1, []);
    
    DrawCircle(taskParam)
    DrawCross(taskParam)
    DrawOutcome(taskParam, outcome)
    
    PredictionSpot(taskParam)
    DrawFormattedText(taskParam.gParam.window,txtPressEnter,'center',taskParam.gParam.screensize(4)*0.9);
    Screen('DrawingFinished', taskParam.gParam.window);
    time = GetSecs;
    Screen('Flip', taskParam.gParam.window, time + 0.1);
    
    [~, ~, keyCode] = KbCheck;
    if find(keyCode) == taskParam.keys.enter
        break
    end
    
end

% Screen 3.
button = taskParam.keys.space;
if isequal(taskParam.gParam.computer, 'D_Pilot')
txt = ['...und steuere den blauen Punkt auf die Postition, die du '...
        'dir gemerkt hast. Dr�cke dann LEERTASTE.'];
elseif isequal(taskParam.gParam.computer, 'Dresden')
txt = ['...und steuere den blauen Punkt auf die Postition, die\n\ndu '...
        'dir gemerkt hast. Dr�cke dann LEERTASTE.'];    
else
txt = ['...und steuere den blauen Punkt auf die Postition, die du '...
        'dir gemerkt\n\nhast. Dr�cke dann LEERTASTE.'];
end
cannon = false;
distMean = 100
[taskParam, fw, bw, Data] = InstrLoopTxt(taskParam, txt, cannon, 'space', distMean);
time = GetSecs;

% Show baseline 2.
LineAndBack(taskParam.gParam.window, taskParam.gParam.screensize)
DrawCross(taskParam)
DrawCircle(taskParam)
Screen('DrawingFinished', taskParam.gParam.window);
Screen('Flip', taskParam.gParam.window, time + 0.1)

% Show boat.
LineAndBack(taskParam.gParam.window, taskParam.gParam.screensize)
DrawCircle(taskParam)
if subject.rew == '1'
    RewardTxt = Reward(taskParam, 'gold');
else
    RewardTxt = Reward(taskParam, 'silver');
end
Screen('DrawingFinished', taskParam.gParam.window);
Screen('Flip', taskParam.gParam.window, time + 1.1);
Screen('Close', RewardTxt);

% Show baseline 3.
LineAndBack(taskParam.gParam.window, taskParam.gParam.screensize)
DrawCircle(taskParam)
DrawCross(taskParam)
Screen('DrawingFinished', taskParam.gParam.window);
Screen('Flip', taskParam.gParam.window, time + 1.6);
WaitSecs(1);

KbReleaseWait();

header = 'Start der Ged�chtnisaufgabe';
if subject.rew == '1'
    if isequal(taskParam.gParam.computer, 'D_Pilot')
    txt = ['Denke daran, dass du den blauen Punkt ab jetzt immer auf '...
        'die letzte Position des Kanonekugel steuerst.\nWenn du dir '...
        'die letzte Position richtig gemerkt hast, bekommst du...'...
        'Goldenes Boot: 10 CENT Steine: Hier verdienst du '...
        'leider nichts\nBitte vermeide Augenbewegungen und '...
        'blinzeln wieder so gut wie m�glich'];
    elseif isequal(taskParam.gParam.computer, 'Dresden')
         txt = ['Denke daran, dass du den blauen Punkt ab jetzt immer auf '...
        'die letzte Position des Bootes steuerst.\nWenn du dir '...
        'die letzte Position richtig gemerkt hast, bekommst du...'...
        'Goldenes Boot: 10 CENTSteine: Hier verdienst du '...
        'leider nichts\nBitte vermeide Augenbewegungen und '...
        'blinzeln\n\nwieder so gut wie m�glich'];
    else
    txt = ['Denke daran, dass du den blauen Punkt ab jetzt immer auf '...
        'die letzte Position des Bootes steuerst.\nWenn du dir die letzte Position richtig gemerkt hast, bekommst du... Goldenes Boot: 10 CENT Steine: Hier verdienst du leider nichts\nBitte vermeide Augenbewegungen und blinzeln wieder so gut wie m�glich'];
    end
else
    txt = ['Denke daran, dass du den blauen Punkt ab jetzt immer auf '...
        'die letzte Position des Bootes steuerst.\nWenn du dir die letzte Position richtig gemerkt hast, bekommst du...Silbernes Boot: 10 CENT Sand: Hier verdienst du leider nichts\nBitte vermeide Augenbewegungen und blinzeln wieder so gut wie m�glich.'];
end
feedback = false
BigScreen(taskParam, txtPressEnter, header, txt, feedback)