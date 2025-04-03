function simMetrics = processSimOutput(simOut, baseParams)
% processSimOutput Processes simulation output from SimEvents and extracts metrics.
%
% This version ensures that each engineer (E1, SE1, SE2, SE3) is handled
% separately for "picked up" work, matching the monolithic DESAutomation.m script.

    %% 1. Basic info
    IterationLength = simOut.SimulationMetadata.ModelInfo.StopTime;
    simMetrics.IterationLength = IterationLength;

    %% 2. Totals for Stopped Work
    % -- E1
    TS_E1 = get(simOut.logsout, "CompSwitchEng1Stop").Values.WorkType;
    [StoppedIncidentsE1, StoppedRequestsE1, StoppedProjTasksE1, StoppedMaintTasksE1, StoppedAdminTasksE1] ...
        = countStoppedByWorkType(TS_E1);
    AllTicketsStoppedE1    = StoppedIncidentsE1 + StoppedRequestsE1;
    AllWorkTasksStoppedE1  = StoppedProjTasksE1 + StoppedMaintTasksE1;

    % -- SE1
    TS_SE1 = get(simOut.logsout, "CompSwitchSrEng1Stop").Values.WorkType;
    [StoppedIncidentsSE1, StoppedRequestsSE1, StoppedProjTasksSE1, StoppedMaintTasksSE1, StoppedAdminTasksSE1] ...
        = countStoppedByWorkType(TS_SE1);

    % -- SE2
    TS_SE2 = get(simOut.logsout, "CompSwitchSrEng2Stop").Values.WorkType;
    [StoppedIncidentsSE2, StoppedRequestsSE2, StoppedProjTasksSE2, StoppedMaintTasksSE2, StoppedAdminTasksSE2] ...
        = countStoppedByWorkType(TS_SE2);

    % -- SE3
    TS_SE3 = get(simOut.logsout, "CompSwitchSrEng3Stop").Values.WorkType;
    [StoppedIncidentsSE3, StoppedRequestsSE3, StoppedProjTasksSE3, StoppedMaintTasksSE3, StoppedAdminTasksSE3] ...
        = countStoppedByWorkType(TS_SE3);

    AllTicketsStopped = (StoppedIncidentsE1 + StoppedRequestsE1) ...
                      + (StoppedIncidentsSE2 + StoppedRequestsSE2) ...
                      + (StoppedIncidentsSE3 + StoppedRequestsSE3) ...
                      + (StoppedIncidentsSE1 + StoppedRequestsSE1);

    AllWorkTasksStopped = (StoppedProjTasksE1 + StoppedMaintTasksE1) ...
                        + (StoppedProjTasksSE1 + StoppedMaintTasksSE1) ...
                        + (StoppedProjTasksSE2 + StoppedMaintTasksSE2) ...
                        + (StoppedProjTasksSE3 + StoppedMaintTasksSE3);

    %% 3. Totals for Picked-Up Work
    % E1
    [PickedUpIncidentsE1, PickedUpRequestsE1, PickedUpProjTasksE1, PickedUpMaintTasksE1] = ...
        countPickedUpNonAdmin(simOut, "IndivQueueE1Out");

    % SE1
    [PickedUpIncidentsSE1, PickedUpRequestsSE1, PickedUpProjTasksSE1, PickedUpMaintTasksSE1] = ...
        countPickedUpNonAdmin(simOut, "IndivQueueSE1Out");

    % SE2
    [PickedUpIncidentsSE2, PickedUpRequestsSE2, PickedUpProjTasksSE2, PickedUpMaintTasksSE2] = ...
        countPickedUpNonAdmin(simOut, "IndivQueueSE2Out");

    % SE3
    [PickedUpIncidentsSE3, PickedUpRequestsSE3, PickedUpProjTasksSE3, PickedUpMaintTasksSE3] = ...
        countPickedUpNonAdmin(simOut, "IndivQueueSE3Out");

    AllTicketsPickedUp = (PickedUpIncidentsE1 + PickedUpRequestsE1) ...
                       + (PickedUpIncidentsSE1 + PickedUpRequestsSE1) ...
                       + (PickedUpIncidentsSE2 + PickedUpRequestsSE2) ...
                       + (PickedUpIncidentsSE3 + PickedUpRequestsSE3);

    AllTasksPickedUp = (PickedUpProjTasksE1 + PickedUpMaintTasksE1) ...
                     + (PickedUpProjTasksSE1 + PickedUpMaintTasksSE1) ...
                     + (PickedUpProjTasksSE2 + PickedUpMaintTasksSE2) ...
                     + (PickedUpProjTasksSE3 + PickedUpMaintTasksSE3);

    AllWorkedPickedUp = AllTicketsPickedUp + AllTasksPickedUp;

    %% 4. Generated Work (same as monolithic)
    IncidentsGenerated         = countGenerated(simOut, "IncGen");
    IncFromChgGenerated        = countGenerated(simOut, "IncidentsfromReworkGen");
    RequestsGenerated          = countGenerated(simOut, "ReqGen");
    ProjectTasksGenerated      = countGenerated(simOut, "ProjTaskGen");
    MaintenanceTasksGenerated  = countGenerated(simOut, "MaintTaskGen");
    AdminTasksGenerated        = countGenerated(simOut, "AdminTaskGen");

    AllTicketsGenerated        = IncidentsGenerated + RequestsGenerated;
    AllWorkTasksGenerated      = ProjectTasksGenerated + IncFromChgGenerated + MaintenanceTasksGenerated;
    AllWorkGenerated           = AllTicketsGenerated + AllWorkTasksGenerated;

    if AllWorkGenerated > 0
        PercentTasks   = AllWorkTasksGenerated / AllWorkGenerated;
        PercentTickets = AllTicketsGenerated   / AllWorkGenerated;
    else
        PercentTasks   = 0;
        PercentTickets = 0;
    end

    %% 5. Completed Work (same as monolithic)
    IncidentsCompleted          = countCompleted(simOut, "IncComp");
    RequestsCompleted           = countCompleted(simOut, "ReqComp");
    ProjectTasksCompleted       = countCompleted(simOut, "ProjTaskComp");
    MaintenanceTasksCompleted   = countCompleted(simOut, "MaintTaskComp");
    AdminTasksCompleted         = countCompleted(simOut, "AdminWorkComp");

    AllTicketsCompleted         = IncidentsCompleted + RequestsCompleted;
    AllWorkTasksCompleted       = ProjectTasksCompleted + MaintenanceTasksCompleted;
    AllWorkCompleted            = AllTicketsCompleted + AllWorkTasksCompleted;

    %% 6. Compute Rates
    TicketsPickedUpPerDay   = AllTicketsPickedUp     / IterationLength;
    TasksPickedUpPerDay     = AllTasksPickedUp       / IterationLength;
    TicketsStoppedPerDay    = AllTicketsStopped      / IterationLength;
    TasksStoppedPerDay      = AllWorkTasksStopped    / IterationLength;
    TicketsCompletedPerDay  = AllTicketsCompleted    / IterationLength;
    TasksCompletedPerDay    = AllWorkTasksCompleted  / IterationLength;

    errRate = baseParams.ErrorRate;  % Or from simOut if appropriate
    ErrorsPerDay       = AllWorkCompleted * errRate;
    BaseReworkRate     = ErrorsPerDay * PercentTasks;
    BaseIncFromChange  = ErrorsPerDay * PercentTickets;

    %% 7. Build simMetrics
    simMetrics.TicketsPickedUpPerDay    = TicketsPickedUpPerDay;
    simMetrics.TasksPickedUpPerDay      = TasksPickedUpPerDay;
    simMetrics.TicketsStoppedPerDay     = TicketsStoppedPerDay;
    simMetrics.TasksStoppedPerDay       = TasksStoppedPerDay;
    simMetrics.TicketsCompletedPerDay   = TicketsCompletedPerDay;
    simMetrics.TasksCompletedPerDay     = TasksCompletedPerDay;
    simMetrics.BaseReworkRate           = BaseReworkRate;
    simMetrics.BaseIncFromChange        = BaseIncFromChange;
    simMetrics.BaseMgmtPress            = baseParams.BaseMgmtPress;
    simMetrics.BaseFatigue              = baseParams.BaseFatigue;
    simMetrics.BaseQueuedTasks          = baseParams.BaseQueuedTasks;
    simMetrics.BaseQueuedTickets        = baseParams.BaseQueuedTickets;
    simMetrics.BaseMgmtPreempt          = baseParams.BaseMgmtPreempt;
    simMetrics.BaseCompleteTasks        = baseParams.BaseCompleteTasks;
    simMetrics.BaseCompleteTickets      = baseParams.BaseCompleteTickets;
    simMetrics.Iteration                = baseParams.Iteration;

    % Also store any raw totals if desired.
    simMetrics.AllTicketsPickedUp       = AllTicketsPickedUp;
    simMetrics.AllWorkTasksPickedUp     = AllTasksPickedUp;
    simMetrics.AllTicketsStopped        = AllTicketsStopped;
    simMetrics.AllWorkTasksStopped      = AllWorkTasksStopped;
    simMetrics.AllTicketsCompleted      = AllTicketsCompleted;
    simMetrics.AllWorkTasksCompleted    = AllWorkTasksCompleted;
end

%% Helper Functions
function [nInc, nReq, nProj, nMaint, nAdmin] = countStoppedByWorkType(tsVals)
    if isempty(tsVals.Time)
        nInc=0; nReq=0; nProj=0; nMaint=0; nAdmin=0;
    else
        T      = timetable2table(timeseries2timetable(tsVals));
        Summ   = groupsummary(T, "WorkType");
        nInc   = getCount(Summ,1);
        nReq   = getCount(Summ,2);
        nProj  = getCount(Summ,3);
        nMaint = getCount(Summ,4);
        nAdmin = getCount(Summ,5);
    end
end

function [inc, req, proj, maint] = countPickedUpNonAdmin(simOut, signalName)
    TS_admin = get(simOut.logsout, signalName).Values.IsAdmin;
    if isempty(TS_admin.Time)
        inc=0; req=0; proj=0; maint=0;
        return
    end
    T_admin = timetable2table(timeseries2timetable(TS_admin));
    T_type  = timetable2table(timeseries2timetable(get(simOut.logsout, signalName).Values.WorkType));
    % Remove the time column from T_type
    T_type(:,1) = [];
    Combined = [T_admin, table(T_type.WorkType, 'VariableNames', {'WorkType'})];
    NonAdmin = Combined(Combined.IsAdmin ~= 1, :);
    Summ = groupsummary(NonAdmin,"WorkType");
    inc   = getCount(Summ,1);
    req   = getCount(Summ,2);
    proj  = getCount(Summ,3);
    maint = getCount(Summ,4);
end

function nGenerated = countGenerated(simOut, blockName)
    valObj = get(simOut.logsout, blockName).Values.IsAdmin;
    if isempty(valObj.Data)
        nGenerated = 0;
    else
        nGenerated = height(timetable2table(timeseries2timetable(valObj)));
    end
end

function nCompleted = countCompleted(simOut, blockName)
    tsObj = get(simOut.logsout, blockName).Values.IsAdmin;
    if isempty(tsObj.Time)
        tsObj = timeseries(0,0);
    end
    nCompleted = height(timetable2table(timeseries2timetable(tsObj)));
end

function c = getCount(tbl, wtype)
    idx = find(tbl.WorkType == wtype, 1);
    if isempty(idx)
        c = 0;
    else
        c = tbl.GroupCount(idx);
    end
end
