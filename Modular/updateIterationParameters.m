function [baseParams, desHistory, residuals] = updateIterationParameters(baseParams, desHistory, ~)
% updateIterationParameters Updates carry-over parameters and computes residuals.
%   [baseParams, desHistory, residuals] = updateIterationParameters(baseParams, desHistory, ~)
%
% This function reads the Vensim output file "sddataout.xlsx" and computes the
% mean for each row (ignoring labels and the time row). The resulting vector is
% assumed to have at least 17 rows. In particular:
%
%   Row 13: BaseMgmtPreempt
%   Row 9:  BaseMgmtPress
%   Row 10: BaseFatigue (which is then multiplied by 0.75)
%   Row 16: BaseQueuedTasks
%   Row 17: BaseQueuedTickets
%
% The function updates baseParams accordingly, updates ServiceTimeAct (with a
% lower bound of 1/48 to ensure at least 10 minutes per task), increments the iteration
% number, and updates the DES input history.
%
% (Any extra rows not needed are ignored.)

    % Read Vensim output from Excel.
    outputFile = "C:\Users\enos9\OneDrive - Colostate\combined\sddataout.xlsx";
    SDDataOut = readmatrix(outputFile, 'Sheet', 1);
    
    % Remove the first column (labels) and the first row (time).
    SDDataOut(:,1) = [];
    SDDataOut(1,:) = [];
    
    % Compute the mean of each row across the simulation days.
    SDDataOutMean = mean(SDDataOut, 2);
    
    % We now expect at least 17 rows (the 17th row gives BaseQueuedTickets).
    expectedRows = 17;
    if length(SDDataOutMean) < expectedRows
        warning('SDDataOutMean has fewer rows than expected. Missing values will be set to 0.');
        SDDataOutMean(end+1:expectedRows) = 0;
    end
    
    % Extract the values needed.
    newMgmtPreempt   = SDDataOutMean(13);
    newMgmtPress     = SDDataOutMean(9);
    newFatigue       = SDDataOutMean(10) * 0.75; % apply fatigue adjustment
    newQueuedTasks   = SDDataOutMean(16);
    newQueuedTickets = SDDataOutMean(17);
    
    % For complete work numbers, use the existing baseParams values.
    newCompleteTasks  = baseParams.BaseCompleteTasks;
    newCompleteTickets = baseParams.BaseCompleteTickets;
    
    % Save the old BaseMgmtPreempt for computing the change.
    oldMgmtPreempt = baseParams.BaseMgmtPreempt;
    
    % Update the base parameters with the new values from Vensim output.
    baseParams.BaseMgmtPreempt   = newMgmtPreempt;
    baseParams.BaseMgmtPress     = newMgmtPress;
    baseParams.BaseFatigue       = newFatigue;
    baseParams.BaseQueuedTasks   = newQueuedTasks;
    baseParams.BaseQueuedTickets = newQueuedTickets;
    baseParams.BaseCompleteTasks = newCompleteTasks;
    baseParams.BaseCompleteTickets = newCompleteTickets;
    
    % Update ServiceTimeAct based on the change in management preemption.
    SDMgmtChange = newMgmtPreempt - oldMgmtPreempt;
    SDSvcTimeChange = (1 + SDMgmtChange);
    baseParams.ServiceTimeAct = max(baseParams.ServiceTimeAct * SDSvcTimeChange, 1/48);
    
    % Increment the iteration number.
    baseParams.Iteration = baseParams.Iteration + 1;
    
    % Update the DES input history.
    newHistory = [baseParams.ErrorRate; baseParams.ServiceTimeAct; baseParams.Iteration];
    if isstruct(desHistory)
        if isfield(desHistory, 'history')
            desHistory.history = [desHistory.history, newHistory];
        else
            desHistory.history = newHistory;
        end
    else
        desHistory = [desHistory, newHistory];
    end
    
    % (Residuals can be computed here if needed; placeholders below.)
    residuals = zeros(4,1);
end
