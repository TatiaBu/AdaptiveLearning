function taskParam = al_takeBreak(taskParam, taskData, currTrial, siezen)
%AL_TAKEBREAK This function manages the breaks in the cannon task
%
%   Input
%       taskParam: Task-parameter-object instance
%       taskData: Task-data-object instance
%       trial: Current trial
%       siezen: "Sie" vs "Du" 
%
%   Output
%       taskParam: Task-parameter-object instance


% Check if "du" or "Sie" is given in input (default: "Sie")
if ~exist('siezen', 'var') || isempty(siezen)
    siezen = true;
end

if currTrial > 1 && currTrial < taskParam.gParam.trials
    
    if taskData.block(currTrial+1) ~= taskData.block(currTrial)

        % Present text indicating the break
        if siezen
            txt = sprintf('Kurze Pause!\n\nSie haben bereits %i von insgesamt %i Durchgängen geschafft.', currTrial, taskParam.gParam.trials);
        else
            txt = sprintf('Kurze Pause!\n\nDu hast bereits %i von insgesamt %i Durchgängen geschafft.', currTrial, taskParam.gParam.trials);
        end

        header = ' ';
        feedback = true;
        al_bigScreen(taskParam, header, txt, feedback);
    
        % Wait until keys released
        KbReleaseWait();
    
        % Set prediction spot to default after break
        taskParam.circle.rotAngle =  taskParam.circle.initialRotAngle;
    end
end
end