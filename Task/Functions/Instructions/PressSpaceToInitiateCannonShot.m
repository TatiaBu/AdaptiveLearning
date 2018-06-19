function [screenIndex, Data, taskParam] = PressSpaceToInitiateCannonShot...
        (taskParam, screenIndex, introduceNeedle, cannon)
    
    if introduceNeedle

        if isequal(taskParam.gParam.taskType, 'dresden')

            if isequal(subject.group, '1')


                txt=['Das Ziel der Kanone wird mit der '...
                    'schwarzen Nadel angezeigt. Dr�cke LEERTASTE, '...
                    'damit die Kanone schie�t.'];

            else
                txt=['Das Ziel der Kanone wird mit der '...
                    'schwarzen Nadel angezeigt. Dr�cke Sie bitte '...
                    'LEERTASTE, damit die Kanone schie�t.'];

            end

        elseif isequal(taskParam.gParam.taskType, 'oddball') 
            txt = ['The aim of the cannon is indicated with the '...
                'black line. Hit SPACE to initiate a cannon shot.'];
        elseif isequal(taskParam.gParam.taskType, 'reversal') ||...
                isequal(taskParam.gParam.taskType, 'ARC')
            txt = ['The aim of the cannon is indicated with the '...
                'black line. Hit the left mouse button to '...
                'initiate a cannon shot.'];
        elseif isequal(taskParam.gParam.taskType, 'chinese')
            txt = ['Das Ziel der Kanone wird mit der schwarzen '...
                'Linie angezeigt. Dr�cke die linke '...
                'Maustaste, damit die Kanone schie�t.'];

        end
    else
        if isequal(subject.group, '1')

            txt=['Dr�cke LEERTASTE, '...
                'damit die Kanone schie�t.'];
        else
            txt=['Dr�cken Sie bitte LEERTASTE, '...
                'damit die Kanone schie�t.'];

        end

    end
    distMean = 240;
    outcome = 240;
    tickInstruction.savedTickmark = nan;
    tickInstruction.previousOutcome = nan;
    [taskParam, fw, Data] = al_instrLoopTxt(taskParam,...
        txt, cannon, 'space', distMean, tickInstruction);

    if fw == 1

        outcome = distMean;
        background = true;
        al_cannonball(taskParam, distMean, outcome, background, 1, 0)
        screenIndex = screenIndex + 1;
        WaitSecs(taskParam.timingParam.outcomeLength);
        return
    end
    WaitSecs(0.1);

end