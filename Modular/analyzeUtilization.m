function util_pred = analyzeUtilization(simOut)
% analyzeUtilization Analyzes utilization data.
%   util_pred = analyzeUtilization(simOut)
%
% Retrieves utilization time series for each engineer, converts them to timetables,
% synchronizes the timetables, computes the average utilization over time, and returns
% the final average value.

    E1UtilTS = simOut.E1Utilization;
    if isempty(E1UtilTS.Time)
        E1UtilTS = timeseries(0,0);
    end
    E1UtilTT = timeseries2timetable(E1UtilTS);

    SE1UtilTS = simOut.SE1Utilization;
    if isempty(SE1UtilTS.Time)
        SE1UtilTS = timeseries(0,0);
    end
    SE1UtilTT = timeseries2timetable(SE1UtilTS);

    SE2UtilTS = simOut.SE2Utilization;
    if isempty(SE2UtilTS.Time)
        SE2UtilTS = timeseries(0,0);
    end
    SE2UtilTT = timeseries2timetable(SE2UtilTS);

    SE3UtilTS = simOut.SE3Utilization;
    if isempty(SE3UtilTS.Time)
        SE3UtilTS = timeseries(0,0);
    end
    SE3UtilTT = timeseries2timetable(SE3UtilTS);

    TTUtilsync = synchronize(E1UtilTT, SE1UtilTT, SE2UtilTT, SE3UtilTT, 'union', 'previous');
    TTUtilsync.AvgUtil = mean(TTUtilsync{:,{'Data_E1UtilTT','Data_SE1UtilTT','Data_SE2UtilTT','Data_SE3UtilTT'}}, 2);
    util_pred = TTUtilsync.AvgUtil(end);
end
