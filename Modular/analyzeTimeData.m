function [IncTimePDFLambdaSim, ReqTimePDFLambdaSim, AllTimePDFlambdaSim] = analyzeTimeData(simOut)
% analyzeTimeData Analyzes total time data for incidents, requests, and optionally for 
% project, maintenance, and admin tasks to replicate the monolithic script fully.
%
%   [IncTimePDFLambdaSim, ReqTimePDFLambdaSim, AllTimePDFlambdaSim] = analyzeTimeData(simOut)
%
% IncTimePDFLambdaSim:   1 / mean(IncTime), or 0 if no incident times
% ReqTimePDFLambdaSim:   1 / mean(ReqTime),  or 0 if no request times
% AllTimePDFlambdaSim:   1 / mean of all times combined (Inc, Req, Proj, Maint, Admin),
%                        or 0 if no data

    % --- Incidents ---
    IncTimeTS = get(simOut.logsout, "TotalTimeInc").Values;
    if isempty(IncTimeTS.Time)
        IncTimeTS = timeseries(0,0);
    end
    IncTimeTT = timeseries2timetable(IncTimeTS);
    if isempty(IncTimeTT.Time)
        IncTimePDFLambdaSim = 0;
        IncTimeTTData = table();
    else
        incVarName  = IncTimeTT.Properties.VariableNames{1};
        IncTimeMean = mean(IncTimeTT.(incVarName));
        IncTimePDFLambdaSim = 1 / IncTimeMean;
        % rename the data column so we can combine easily
        IncTimeTTData = IncTimeTT;
        IncTimeTTData.Properties.VariableNames{incVarName} = 'Data';
    end

    % --- Requests ---
    ReqTimeTS = get(simOut.logsout, "TotalTimeReq").Values;
    if isempty(ReqTimeTS.Time)
        ReqTimeTS = timeseries(0,0);
    end
    ReqTimeTT = timeseries2timetable(ReqTimeTS);
    if isempty(ReqTimeTT.Time)
        ReqTimePDFLambdaSim = 0;
        ReqTimeTTData = table();
    else
        reqVarName  = ReqTimeTT.Properties.VariableNames{1};
        ReqTimeMean = mean(ReqTimeTT.(reqVarName));
        ReqTimePDFLambdaSim = 1 / ReqTimeMean;
        ReqTimeTTData = ReqTimeTT;
        ReqTimeTTData.Properties.VariableNames{reqVarName} = 'Data';
    end

    % --- Projects ---
    ProjTimeTS = get(simOut.logsout, "TotalTimeProj").Values;
    if isempty(ProjTimeTS.Time)
        ProjTimeTS = timeseries(0,0);
    end
    ProjTimeTT = timeseries2timetable(ProjTimeTS);
    if isempty(ProjTimeTT.Time)
        ProjTimeTTData = table();
    else
        projVarName = ProjTimeTT.Properties.VariableNames{1};
        ProjTimeTTData = ProjTimeTT;
        ProjTimeTTData.Properties.VariableNames{projVarName} = 'Data';
    end

    % --- Maintenance ---
    MaintTimeTS = get(simOut.logsout, "TotalTimeMaint").Values;
    if isempty(MaintTimeTS.Time)
        MaintTimeTS = timeseries(0,0);
    end
    MaintTimeTT = timeseries2timetable(MaintTimeTS);
    if isempty(MaintTimeTT.Time)
        MaintTimeTTData = table();
    else
        maintVarName = MaintTimeTT.Properties.VariableNames{1};
        MaintTimeTTData = MaintTimeTT;
        MaintTimeTTData.Properties.VariableNames{maintVarName} = 'Data';
    end

    % --- Admin ---
    AdminTimeTS = get(simOut.logsout, "TotalTimeAdmin").Values;
    if isempty(AdminTimeTS.Time)
        AdminTimeTS = timeseries(0,0);
    end
    AdminTimeTT = timeseries2timetable(AdminTimeTS);
    if isempty(AdminTimeTT.Time)
        AdminTimeTTData = table();
    else
        adminVarName = AdminTimeTT.Properties.VariableNames{1};
        AdminTimeTTData = AdminTimeTT;
        AdminTimeTTData.Properties.VariableNames{adminVarName} = 'Data';
    end

    % --- Combine all data for a single "AllTime" distribution ---
    AllTimeTT = [IncTimeTTData; ReqTimeTTData; ProjTimeTTData; MaintTimeTTData; AdminTimeTTData];
    if isempty(AllTimeTT)
        AllTimePDFlambdaSim = 0;
    else
        % Fit an exponential distribution across *all* data, just like the monolithic script:
        AllTimePDF = fitdist(AllTimeTT.Data, 'Exponential');
        AllTimePDFlambdaSim = 1 / AllTimePDF.mu;
    end
end
