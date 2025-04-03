function triggerVensimSimulation()
% triggerVensimSimulation Launches the external Vensim simulation and monitors its execution.
%
% This function triggers Vensim using an external command (via system calls) and
% monitors the process. If the simulation does not complete within the timeout,
% it terminates the process.

    % Define the external command to trigger Vensim.
    externalCommand = '"C:\Program Files\Vensim\vendss64.exe" "C:\Users\enos9\OneDrive - Colostate\combined\scripts\sdcommand.cmd"';
    
    % Launch the command asynchronously.
    system(['start "" ' externalCommand]);
    
    % Define timeout duration (in seconds).
    timeoutDuration = 90;
    
    disp('Monitoring the external Vensim simulation...');
    startTime = tic;
    
    while true
        [~, result] = system('tasklist');
        % Check if Vensim is still running (process name vendss64.exe).
        if ~contains(result, 'vendss64.exe')
            disp('External Vensim simulation completed successfully.');
            break;
        end
        
        if toc(startTime) > timeoutDuration
            disp('Timeout exceeded. Terminating external Vensim simulation...');
            system('taskkill /IM vendss64.exe /F /T');
            break;
        end
        
        pause(1);
    end
end
