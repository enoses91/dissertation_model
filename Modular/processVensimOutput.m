function venOut = processVensimOutput()
% processVensimOutput Reads and processes the Vensim output Excel file.
%   venOut = processVensimOutput()
%
% Output:
%   venOut - A structure containing processed Vensim output data.
%
% The function reads "sddataout.xlsx", extracts the numerical data, computes
% mean values across days, and calculates error rate metrics.

    filePath = 'C:\Users\enos9\OneDrive - Colostate\combined\sddataout.xlsx';
    SDDataOut = readmatrix(filePath, 'Sheet', 1);
    
    % Remove the first column if it contains labels.
    SDDataOutVal = SDDataOut;
    SDDataOutVal(:,1) = []; % remove labels
    
    % Separate time row (assumed to be the first row) from data.
    SDDataOutValWithTime = SDDataOutVal; % retain data with time row
    SDDataOutVal(1,:) = []; % remove time row
    
    % Compute the mean of each metric across (assumed) 5 days.
    SDDataOutValMean = mean(SDDataOutVal, 2);
    
    % Calculate error rates.
    SDReworkRateMean = SDDataOutValMean(7);  % average rework rate
    SDIncFrChgMean   = SDDataOutValMean(6);  % average incident from change rate
    SDErrorRateMean  = SDReworkRateMean + SDIncFrChgMean;
    SDErrorsOnRun    = SDErrorRateMean * 5;   % total errors during 5-day run

    % Package output into a structure.
    venOut = struct();
    venOut.SDDataOut         = SDDataOut;
    venOut.SDDataOutMean     = SDDataOutValMean;
    venOut.SDReworkRateMean  = SDReworkRateMean;
    venOut.SDIncFrChgMean    = SDIncFrChgMean;
    venOut.SDErrorRateMean   = SDErrorRateMean;
    venOut.SDErrorsOnRun     = SDErrorsOnRun;
end
