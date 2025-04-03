function excelOperations(operation, SDParameters)
% excelOperations Performs Excel file operations such as closing or writing data.
%   excelOperations('close')
%   excelOperations('write', SDParameters)
%
% For the 'write' operation, SDParameters should be a numeric array containing
% the following values (in order) in column A:
% TicketsPickedUpPerDay,
% TasksPickedUpPerDay,
% TicketsStoppedPerDay,
% TasksStoppedPerDay,
% TicketsCompletedPerDay,
% TasksCompletedPerDay,
% BaseReworkRate,
% BaseIncFromChange,
% BaseMgmtPress,
% BaseFatigue,
% BaseQueuedTasks,
% BaseQueuedTickets,
% BaseMgmtPreempt,
% BaseCompleteTasks,
% BaseCompleteTickets,
% Iteration
%
% The data is written to the Excel file "sddatain.xlsx" in the specified folder,
% with no column headings. Before writing, the function attempts to close any
% open instance of the workbook.

    targetWorkbookName = 'sddatain.xlsx';
    filePath = fullfile('C:\Users\enos9\OneDrive - Colostate\combined\', targetWorkbookName);
    
    switch lower(operation)
        case 'close'
            try
                excelApp = actxGetRunningServer('Excel.Application');
            catch
                % If no Excel instance is running, nothing to close.
                disp('No running Excel instance found.');
                return;
            end
            
            % Close any open workbook matching the target name.
            for i = excelApp.Workbooks.Count:-1:1
                if strcmpi(excelApp.Workbooks.Item(i).Name, targetWorkbookName)
                    excelApp.Workbooks.Item(i).Close(false);
                end
            end
            release(excelApp);
            disp('All matching workbooks closed.');
            
        case 'write'
            if nargin < 2
                error('For the write operation, you must provide the SDParameters numeric array.');
            end
            
            % Attempt to close the workbook if it is open.
            try
                excelApp = actxGetRunningServer('Excel.Application');
                for i = excelApp.Workbooks.Count:-1:1
                    wb = excelApp.Workbooks.Item(i);
                    if strcmpi(wb.Name, targetWorkbookName)
                        wb.Close(false);
                    end
                end
                release(excelApp);
            catch
                % If Excel is not running, we simply continue.
            end
            
            % Ensure SDParameters is a column vector.
            if size(SDParameters, 2) > 1
                SDParameters = SDParameters(:);
            end
            
            % Write the matrix to Excel without any column headings.
            writematrix(SDParameters, filePath, 'Sheet', 1);
            disp(['Data written to ', filePath]);
            
        otherwise
            error('Unknown operation specified for excelOperations.');
    end
end
