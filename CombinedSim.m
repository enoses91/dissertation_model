%Initialize SD Variables for first run

    IncTaskArrivalRate = 0.2024906;
    ReqTaskArrivalRate = 0.0930726;
    util_obs = 0.95;
    queue_obs = 4.0;
    ReqTimePDFLambdaObs = 0.1961;
    IncTimePDFLambdaObs = 0.1469;

    BaseMgmtPreempt = 1;
    BaseMgmtPress = 1;
    BaseFatigue = 1;
    BaseQueuedTasks = 0;
    BaseQueuedTickets = 0;
    BaseCompleteTickets = 0;
    BaseCompleteTasks = 0;
    ErrorRate = .005;       %assumed base rate of 1 in 200 (.5%)
    Iteration = 1;


    DESInputLabels = cat(1,"Error Rate","Service Time", "Iteration");
    DESInputHistory = cat(1,ErrorRate,ServiceTimeAct,Iteration);
    DESInputHistory = cat(2,DESInputLabels,DESInputHistory);



%iterate script

MaxIterations = 1;

for Iteration = 1:MaxIterations

%Run SimEvents simulation

mdlName = "iterateddes";

simIn = Simulink.SimulationInput(mdlName); 

    simIn = setBlockParameter(simIn,"iterateddes/IncGen","IntergenerationTimeAction","dt = -"+IncTaskArrivalRate+"*log(1-rand());");
    simIn = setBlockParameter(simIn,"iterateddes/ReqGen","IntergenerationTimeAction","dt = -"+ReqTaskArrivalRate+"*log(1-rand());");
    simIn = setBlockParameter(simIn,"iterateddes/ProjTaskGen","IntergenerationTimeAction","dt = -"+ProjTaskArrivalRate+"*log(1-rand());");
    simIn = setBlockParameter(simIn,"iterateddes/MaintTaskGen","IntergenerationTimeAction","dt = -"+MaintTaskArrivalRate+"*log(1-rand());");
    simIn = setBlockParameter(simIn,"iterateddes/AdminTaskGen","IntergenerationTimeAction","dt = -"+AdminTaskArrivalRate+"*log(1-rand());");

	simIn = setBlockParameter(simIn,"iterateddes/IncGen","AttributeInitialValue","0|0|0|"+ReqServiceTime+"|0|0|0|0|0|"+ErrorRate+"|1|1|0|1|"+ServiceTimeAct+"|2"); 
	simIn = setBlockParameter(simIn,"iterateddes/IncidentsfromReworkGen","AttributeInitialValue","0|0|0|"+ReqServiceTime+"|0|0|0|0|0|"+ErrorRate+"|1|1|0|1|"+ServiceTimeAct+"|2"); 
	simIn = setBlockParameter(simIn,"iterateddes/ReqGen","AttributeInitialValue","0|0|0|"+ReqServiceTime+"|0|0|0|0|0|"+ErrorRate+"|2|1|0|1|"+ServiceTimeAct+"|2"); 
	simIn = setBlockParameter(simIn,"iterateddes/ProjTaskGen","AttributeInitialValue","0|0|0|"+ReqServiceTime+"|0|0|0|0|0|"+ErrorRate+"|3|1|0|1|"+ServiceTimeAct+"|2"); 
	simIn = setBlockParameter(simIn,"iterateddes/MaintTaskGen","AttributeInitialValue","0|0|0|"+ReqServiceTime+"|0|0|0|0|0|"+ErrorRate+"|4|1|0|1|"+ServiceTimeAct+"|2");
    simIn = setBlockParameter(simIn,"iterateddes/AdminTaskGen","AttributeInitialValue","0|0|0|"+ReqServiceTime+"|0|0|0|0|0|"+ErrorRate+"|5|1|0|1|"+ServiceTimeAct+"|1");

out = sim(simIn);

%Generate data

%WorkTypes = [1;2;3;4];
%WorkTypesV = [1 2 3 4 5];
IterationLength = out.SimulationMetadata.ModelInfo.StopTime;

%Totals

    %Stopped work E1
        SWE1TS = get(out.logsout,"CompSwitchEng1Stop").Values.WorkType;
        if isempty (SWE1TS.Time)
            StoppedIncidentsE1 = 0;
            StoppedRequestsE1 = 0;
            StoppedProjectTasksE1 = 0;
            StoppedMaintenanceTasksE1 = 0;
            StoppedAdminTasksE1 = 0;
        else
            StoppedWorkE1 = groupsummary(timetable2table(timeseries2timetable(SWE1TS)),"WorkType");
        %Incidents
            StoppedIncidentsE1T = StoppedWorkE1(find(StoppedWorkE1.WorkType == [1]),"GroupCount");
            if isempty(StoppedIncidentsE1T)
                StoppedIncidentsE1 = 0;
            else
                StoppedIncidentsE1 = StoppedIncidentsE1T{1,1};
            end
        %Requests
            StoppedRequestsE1T = StoppedWorkE1(find(StoppedWorkE1.WorkType == [2]),"GroupCount");
            if isempty(StoppedRequestsE1T)
                StoppedRequestsE1 = 0;
            else
                StoppedRequestsE1 = StoppedRequestsE1T{1,1};
            end
        %Project Tasks
            StoppedProjectTasksE1T = StoppedWorkE1(find(StoppedWorkE1.WorkType == [3]),"GroupCount");
            if isempty(StoppedProjectTasksE1T)
                StoppedProjectTasksE1 = 0;
            else
                StoppedProjectTasksE1 = StoppedProjectTasksE1T{1,1};
            end
        %Maintenance Tasks
            StoppedMaintenanceTasksE1T = StoppedWorkE1(find(StoppedWorkE1.WorkType == [4]),"GroupCount");
            if isempty(StoppedMaintenanceTasksE1T)
                StoppedMaintenanceTasksE1 = 0;
            else
                StoppedMaintenanceTasksE1 = StoppedMaintenanceTasksE1T{1,1};
            end
        %Admin Tasks
            StoppedAdminTasksE1T = StoppedWorkE1(find(StoppedWorkE1.WorkType == [5]),"GroupCount");
            if isempty(StoppedAdminTasksE1T)
                StoppedAdminTasksE1 = 0;
            else
                StoppedAdminTasksE1 = StoppedAdminTasksE1T{1,1};
            end
        end
        AllTicketsStoppedE1 = StoppedIncidentsE1 + StoppedRequestsE1;
        AllWorkTasksStoppedE1 = StoppedProjectTasksE1 + StoppedMaintenanceTasksE1;
        AllWorkStoppedE1 = AllTicketsStoppedE1 + AllWorkTasksStoppedE1;
    %Picked up work E1, not including admin tasks (serviced, but not
    %necessarily complete
        WBAE1 = get(out.logsout,"IndivQueueE1Out").Values.IsAdmin;
        if isempty (WBAE1.Time)
            PickedUpIncidentsE1 = 0;
            PickedUpRequestsE1 = 0;
            PickedUpProjectTasksE1 = 0;
            PickedUpMaintTasksE1 = 0;
        else  
        WorkByAdminE1 = timetable2table(timeseries2timetable(WBAE1));
        WorkByTypeE1 = timetable2table(timeseries2timetable(get(out.logsout,"IndivQueueE1Out").Values.WorkType));
        WorkByTypeE1(:,1) = [];
        WorkByAdminTypeE1 = renamevars(addvars(WorkByAdminE1,WorkByTypeE1.WorkType),["Var3"],["WorkType"]);
        WorkByTypeE1NoAdmin = WorkByAdminTypeE1(~(WorkByAdminTypeE1.IsAdmin == 1),:);
        WorkByTypeE1NoAdmin = groupsummary(WorkByTypeE1NoAdmin,"WorkType");
        %Incidents
            PickedUpIncidentsE1T = WorkByTypeE1NoAdmin(find(WorkByTypeE1NoAdmin.WorkType == [1]),"GroupCount");
            if isempty(PickedUpIncidentsE1T)
                PickedUpIncidentsE1 = 0;
            else
                PickedUpIncidentsE1 = PickedUpIncidentsE1T{1,1};
            end
        %Requests
            PickedUpRequestsE1T = WorkByTypeE1NoAdmin(find(WorkByTypeE1NoAdmin.WorkType == [2]),"GroupCount");
            if isempty(PickedUpRequestsE1T)
                PickedUpRequestsE1 = 0;
            else
                PickedUpRequestsE1 = PickedUpRequestsE1T{1,1};
            end
        %ProjectTasks
            PickedUpProjectTasksE1T = WorkByTypeE1NoAdmin(find(WorkByTypeE1NoAdmin.WorkType == [3]),"GroupCount");
            if isempty(PickedUpProjectTasksE1T)
                PickedUpProjectTasksE1 = 0;
            else
                PickedUpProjectTasksE1 = PickedUpProjectTasksE1T{1,1};
            end
        %MaintTasks
            PickedUpMaintTasksE1T = WorkByTypeE1NoAdmin(find(WorkByTypeE1NoAdmin.WorkType == [4]),"GroupCount");
            if isempty(PickedUpMaintTasksE1T)
                PickedUpMaintTasksE1 = 0;
            else
                PickedUpMaintTasksE1 = PickedUpMaintTasksE1T{1,1};
            end
        end
        AllTicketsPickedUpE1 = PickedUpIncidentsE1 + PickedUpRequestsE1;
        AllTasksPickedUpE1 = PickedUpProjectTasksE1 + PickedUpMaintTasksE1;
        AllWorkedPickedUpE1 = AllTicketsPickedUpE1 + AllTasksPickedUpE1;


    %Stopped work SE1
        SWSE1TS = get(out.logsout,"CompSwitchSrEng1Stop").Values.WorkType;
        if isempty (SWSE1TS.Time)
            StoppedIncidentsSE1 = 0;
            StoppedRequestsSE1 = 0;
            StoppedProjectTasksSE1 = 0;
            StoppedMaintenanceTasksSE1 = 0;
            StoppedAdminTasksSE1 = 0;
        else
        StoppedWorkSE1 = groupsummary(timetable2table(timeseries2timetable(SWSE1TS)),"WorkType");
        %Incidents
            StoppedIncidentsSE1T = StoppedWorkSE1(find(StoppedWorkSE1.WorkType == [1]),"GroupCount");
            if isempty(StoppedIncidentsSE1T)
                StoppedIncidentsSE1 = 0;
            else
                StoppedIncidentsSE1 = StoppedIncidentsSE1T{1,1};
            end
        %Requests
            StoppedRequestsSE1T = StoppedWorkSE1(find(StoppedWorkSE1.WorkType == [2]),"GroupCount");
            if isempty(StoppedRequestsSE1T)
                StoppedRequestsSE1 = 0;
            else
                StoppedRequestsSE1 = StoppedRequestsSE1T{1,1};
            end
        %Project Tasks
            StoppedProjectTasksSE1T = StoppedWorkSE1(find(StoppedWorkSE1.WorkType == [3]),"GroupCount");
            if isempty(StoppedProjectTasksSE1T)
                StoppedProjectTasksSE1 = 0;
            else
                StoppedProjectTasksSE1 = StoppedProjectTasksSE1T{1,1};
            end
        %Maintenance Tasks
            StoppedMaintenanceTasksSE1T = StoppedWorkSE1(find(StoppedWorkSE1.WorkType == [4]),"GroupCount");
            if isempty(StoppedMaintenanceTasksSE1T)
                StoppedMaintenanceTasksSE1 = 0;
            else
                StoppedMaintenanceTasksSE1 = StoppedMaintenanceTasksSE1T{1,1};
            end
        %Admin Tasks
            StoppedAdminTasksSE1T = StoppedWorkSE1(find(StoppedWorkSE1.WorkType == [5]),"GroupCount");
            if isempty(StoppedAdminTasksSE1T)
                StoppedAdminTasksSE1 = 0;
            else
                StoppedAdminTasksSE1 = StoppedAdminTasksSE1T{1,1};
            end
        end
        AllTicketsStoppedSE1 = StoppedIncidentsSE1 + StoppedRequestsSE1;
        AllWorkTasksStoppedSE1 = StoppedProjectTasksSE1 + StoppedMaintenanceTasksSE1;
        AllWorkStoppedSE1 = AllTicketsStoppedSE1 + AllWorkTasksStoppedSE1;

    %Picked up work SE1, not including admin tasks (serviced, but not
    %necessarily complete
        WBASE1 = get(out.logsout,"IndivQueueSE1Out").Values.IsAdmin;
        if isempty (WBASE1.Time)
            PickedUpIncidentsSE1 = 0;
            PickedUpRequestsSE1 = 0;
            PickedUpProjectTasksSE1 = 0;
            PickedUpMaintTasksSE1 = 0;
        else      
        WorkByAdminSE1 = timetable2table(timeseries2timetable(WBASE1));
        WorkByTypeSE1 = timetable2table(timeseries2timetable(get(out.logsout,"IndivQueueSE1Out").Values.WorkType));
        WorkByTypeSE1(:,1) = [];
        WorkByAdminTypeSE1 = renamevars(addvars(WorkByAdminSE1,WorkByTypeSE1.WorkType),["Var3"],["WorkType"]);
        WorkByTypeSE1NoAdmin = WorkByAdminTypeSE1(~(WorkByAdminTypeSE1.IsAdmin == 1),:);
        WorkByTypeSE1NoAdmin = groupsummary(WorkByTypeSE1NoAdmin,"WorkType");
        %Incidents
            PickedUpIncidentsSE1T = WorkByTypeSE1NoAdmin(find(WorkByTypeSE1NoAdmin.WorkType == [1]),"GroupCount");
            if isempty(PickedUpIncidentsSE1T)
                PickedUpIncidentsSE1 = 0;
            else
                PickedUpIncidentsSE1 = PickedUpIncidentsSE1T{1,1};
            end
        %Requests
            PickedUpRequestsSE1T = WorkByTypeSE1NoAdmin(find(WorkByTypeSE1NoAdmin.WorkType == [2]),"GroupCount");
            if isempty(PickedUpRequestsSE1T)
                PickedUpRequestsSE1 = 0;
            else
                PickedUpRequestsSE1 = PickedUpRequestsSE1T{1,1};
            end
        %ProjectTasks
            PickedUpProjectTasksSE1T = WorkByTypeSE1NoAdmin(find(WorkByTypeSE1NoAdmin.WorkType == [3]),"GroupCount");
            if isempty(PickedUpProjectTasksSE1T)
                PickedUpProjectTasksSE1 = 0;
            else
                PickedUpProjectTasksSE1 = PickedUpProjectTasksSE1T{1,1};
            end
        %MaintTasks
            PickedUpMaintTasksSE1T = WorkByTypeSE1NoAdmin(find(WorkByTypeSE1NoAdmin.WorkType == [4]),"GroupCount");
            if isempty(PickedUpMaintTasksSE1T)
                PickedUpMaintTasksSE1 = 0;
            else
                PickedUpMaintTasksSE1 = PickedUpMaintTasksSE1T{1,1};
            end
        end
        AllTicketsPickedUpSE1 = PickedUpIncidentsSE1 + PickedUpRequestsSE1;
        AllTasksPickedUpSE1 = PickedUpProjectTasksSE1 + PickedUpMaintTasksSE1;
        AllWorkedPickedUpSE1 = AllTicketsPickedUpSE1 + AllTasksPickedUpSE1;

    %Stopped work SE2
        SWSE2TS = get(out.logsout,"CompSwitchSrEng2Stop").Values.WorkType;
        if isempty (SWSE2TS.Time)
            StoppedIncidentsSE2 = 0;
            StoppedRequestsSE2 = 0;
            StoppedProjectTasksSE2 = 0;
            StoppedMaintenanceTasksSE2 = 0;
            StoppedAdminTasksSE2 = 0;
        else    
        StoppedWorkSE2 = groupsummary(timetable2table(timeseries2timetable(SWSE2TS)),"WorkType");
        %Incidents
            StoppedIncidentsSE2T = StoppedWorkSE2(find(StoppedWorkSE2.WorkType == [1]),"GroupCount");
            if isempty(StoppedIncidentsSE2T)
                StoppedIncidentsSE2 = 0;
            else
                StoppedIncidentsSE2 = StoppedIncidentsSE2T{1,1};
            end
        %Requests
            StoppedRequestsSE2T = StoppedWorkSE2(find(StoppedWorkSE2.WorkType == [2]),"GroupCount");
            if isempty(StoppedRequestsSE2T)
                StoppedRequestsSE2 = 0;
            else
                StoppedRequestsSE2 = StoppedRequestsSE2T{1,1};
            end
        %Project Tasks
            StoppedProjectTasksSE2T = StoppedWorkSE2(find(StoppedWorkSE2.WorkType == [3]),"GroupCount");
            if isempty(StoppedProjectTasksSE2T)
                StoppedProjectTasksSE2 = 0;
            else
                StoppedProjectTasksSE2 = StoppedProjectTasksSE2T{1,1};
            end
        %Maintenance Tasks
            StoppedMaintenanceTasksSE2T = StoppedWorkSE2(find(StoppedWorkSE2.WorkType == [4]),"GroupCount");
            if isempty(StoppedMaintenanceTasksSE2T)
                StoppedMaintenanceTasksSE2 = 0;
            else
                StoppedMaintenanceTasksSE2 = StoppedMaintenanceTasksSE2T{1,1};
            end
        %Admin Tasks
            StoppedAdminTasksSE2T = StoppedWorkSE2(find(StoppedWorkSE2.WorkType == [5]),"GroupCount");
            if isempty(StoppedAdminTasksSE2T)
                StoppedAdminTasksSE2 = 0;
            else
                StoppedAdminTasksSE2 = StoppedAdminTasksSE2T{1,1};
            end
        end
        AllTicketsStoppedSE2 = StoppedIncidentsSE2 + StoppedRequestsSE2;
        AllWorkTasksStoppedSE2 = StoppedProjectTasksSE2 + StoppedMaintenanceTasksSE2;
        AllWorkStoppedSE2 = AllTicketsStoppedSE2 + AllWorkTasksStoppedSE2;
    %Picked up work SE2, not including admin tasks (serviced, but not
    %necessarily complete
        WBASE2 = get(out.logsout,"IndivQueueSE2Out").Values.IsAdmin;
        if isempty (WBASE2.Time)
            PickedUpIncidentsSE2 = 0;
            PickedUpRequestsSE2 = 0;
            PickedUpProjectTasksSE2 = 0;
            PickedUpMaintTasksSE2 = 0;
        else          
        WorkByAdminSE2 = timetable2table(timeseries2timetable(WBASE2));
        WorkByTypeSE2 = timetable2table(timeseries2timetable(get(out.logsout,"IndivQueueSE2Out").Values.WorkType));
        WorkByTypeSE2(:,1) = [];
        WorkByAdminTypeSE2 = renamevars(addvars(WorkByAdminSE2,WorkByTypeSE2.WorkType),["Var3"],["WorkType"]);
        WorkByTypeSE2NoAdmin = WorkByAdminTypeSE2(~(WorkByAdminTypeSE2.IsAdmin == 1),:);
        WorkByTypeSE2NoAdmin = groupsummary(WorkByTypeSE2NoAdmin,"WorkType");
        %Incidents
            PickedUpIncidentsSE2T = WorkByTypeSE2NoAdmin(find(WorkByTypeSE2NoAdmin.WorkType == [1]),"GroupCount");
            if isempty(PickedUpIncidentsSE2T)
                PickedUpIncidentsSE2 = 0;
            else
                PickedUpIncidentsSE2 = PickedUpIncidentsSE2T{1,1};
            end
        %Requests
            PickedUpRequestsSE2T = WorkByTypeSE2NoAdmin(find(WorkByTypeSE2NoAdmin.WorkType == [2]),"GroupCount");
            if isempty(PickedUpRequestsSE2T)
                PickedUpRequestsSE2 = 0;
            else
                PickedUpRequestsSE2 = PickedUpRequestsSE2T{1,1};
            end
        %ProjectTasks
            PickedUpProjectTasksSE2T = WorkByTypeSE2NoAdmin(find(WorkByTypeSE2NoAdmin.WorkType == [3]),"GroupCount");
            if isempty(PickedUpProjectTasksSE2T)
                PickedUpProjectTasksSE2 = 0;
            else
                PickedUpProjectTasksSE2 = PickedUpProjectTasksSE2T{1,1};
            end
        %MaintTasks
            PickedUpMaintTasksSE2T = WorkByTypeSE2NoAdmin(find(WorkByTypeSE2NoAdmin.WorkType == [4]),"GroupCount");
            if isempty(PickedUpMaintTasksSE2T)
                PickedUpMaintTasksSE2 = 0;
            else
                PickedUpMaintTasksSE2 = PickedUpMaintTasksSE2T{1,1};
            end
        end
        AllTicketsPickedUpSE2 = PickedUpIncidentsSE2 + PickedUpRequestsSE2;
        AllTasksPickedUpSE2 = PickedUpProjectTasksSE2 + PickedUpMaintTasksSE2;
        AllWorkedPickedUpSE2 = AllTicketsPickedUpSE2 + AllTasksPickedUpSE2;

    %Stopped work SE3
        SWSE3TS = get(out.logsout,"CompSwitchSrEng3Stop").Values.WorkType;
        if isempty (SWSE3TS.Time)
            StoppedIncidentsSE3 = 0;
            StoppedRequestsSE3 = 0;
            StoppedProjectTasksSE3 = 0;
            StoppedMaintTasksSE3 = 0;
        else        
        StoppedWorkSE3 = groupsummary(timetable2table(timeseries2timetable(SWSE3TS)),"WorkType");
        %Incidents
            StoppedIncidentsSE3T = StoppedWorkSE3(find(StoppedWorkSE3.WorkType == [1]),"GroupCount");
            if isempty(StoppedIncidentsSE3T)
                StoppedIncidentsSE3 = 0;
            else
                StoppedIncidentsSE3 = StoppedIncidentsSE3T{1,1};
            end
        %Requests
            StoppedRequestsSE3T = StoppedWorkSE3(find(StoppedWorkSE3.WorkType == [2]),"GroupCount");
            if isempty(StoppedRequestsSE3T)
                StoppedRequestsSE3 = 0;
            else
                StoppedRequestsSE3 = StoppedRequestsSE3T{1,1};
            end
        %Project Tasks
            StoppedProjectTasksSE3T = StoppedWorkSE3(find(StoppedWorkSE3.WorkType == [3]),"GroupCount");
            if isempty(StoppedProjectTasksSE3T)
                StoppedProjectTasksSE3 = 0;
            else
                StoppedProjectTasksSE3 = StoppedProjectTasksSE3T{1,1};
            end
         %MaintTasks
            StoppedMaintTasksSE3T = StoppedWorkSE3(find(StoppedWorkSE3.WorkType == [4]),"GroupCount");
            if isempty(StoppedMaintTasksSE3T)
                StoppedMaintTasksSE3 = 0;
            else
                StoppedMaintTasksSE3 = StoppedMaintTasksSE3T{1,1};
            end
        end
        AllTicketsStoppedSE3 = StoppedIncidentsSE3 + StoppedRequestsSE3;
        AllWorkTasksStoppedSE3 = StoppedProjectTasksSE3 + StoppedMaintTasksSE3;
        AllWorkStoppedSE3 = AllTicketsStoppedSE3 + AllWorkTasksStoppedSE3;
    %Picked up work SE3, not including admin tasks (serviced, but not
    %necessarily complete
        WBASE3 = get(out.logsout,"IndivQueueSE3Out").Values.IsAdmin
        if isempty (WBASE3.Time)
            PickedUpIncidentsSE3 = 0;
            PickedUpRequestsSE3 = 0;
            PickedUpProjectTasksSE3 = 0;
            PickedUpMaintTasksSE3 = 0;
        else    
        WorkByAdminSE3 = timetable2table(timeseries2timetable(WBASE3));
        WorkByTypeSE3 = timetable2table(timeseries2timetable(get(out.logsout,"IndivQueueSE3Out").Values.WorkType));
        WorkByTypeSE3(:,1) = [];
        WorkByAdminTypeSE3 = renamevars(addvars(WorkByAdminSE3,WorkByTypeSE3.WorkType),["Var3"],["WorkType"]);
        WorkByTypeSE3NoAdmin = WorkByAdminTypeSE3(~(WorkByAdminTypeSE3.IsAdmin == 1),:);
        WorkByTypeSE3NoAdmin = groupsummary(WorkByTypeSE3NoAdmin,"WorkType");
        %Incidents
            PickedUpIncidentsSE3T = WorkByTypeSE3NoAdmin(find(WorkByTypeSE3NoAdmin.WorkType == [1]),"GroupCount");
            if isempty(PickedUpIncidentsSE3T)
                PickedUpIncidentsSE3 = 0;
            else
                PickedUpIncidentsSE3 = PickedUpIncidentsSE3T{1,1};
            end
        %Requests
            PickedUpRequestsSE3T = WorkByTypeSE3NoAdmin(find(WorkByTypeSE3NoAdmin.WorkType == [2]),"GroupCount");
            if isempty(PickedUpRequestsSE3T)
                PickedUpRequestsSE3 = 0;
            else
                PickedUpRequestsSE3 = PickedUpRequestsSE3T{1,1};
            end
        %ProjectTasks
            PickedUpProjectTasksSE3T = WorkByTypeSE3NoAdmin(find(WorkByTypeSE3NoAdmin.WorkType == [3]),"GroupCount");
            if isempty(PickedUpProjectTasksSE3T)
                PickedUpProjectTasksSE3 = 0;
            else
                PickedUpProjectTasksSE3 = PickedUpProjectTasksSE3T{1,1};
            end
        %MaintTasks
            PickedUpMaintTasksSE3T = WorkByTypeSE3NoAdmin(find(WorkByTypeSE3NoAdmin.WorkType == [4]),"GroupCount");
            if isempty(PickedUpMaintTasksSE3T)
                PickedUpMaintTasksSE3 = 0;
            else
                PickedUpMaintTasksSE3 = PickedUpMaintTasksSE3T{1,1};
            end
        end
        AllTicketsPickedUpSE3 = PickedUpIncidentsSE3 + PickedUpRequestsSE3;
        AllTasksPickedUpSE3 = PickedUpProjectTasksSE3 + PickedUpMaintTasksSE3;
        AllWorkedPickedUpSE3 = AllTicketsPickedUpSE3 + AllTasksPickedUpSE3;

    %Total stopped work - all engineers
    AllTicketsStopped = AllTicketsStoppedE1 + AllTicketsStoppedSE1 + AllTicketsStoppedSE2 + AllTicketsStoppedSE3;
    AllWorkTasksStopped = AllWorkTasksStoppedE1 + AllWorkTasksStoppedSE1 + AllWorkTasksStoppedSE2 + AllWorkTasksStoppedSE3;
    AllWorkStopped = AllTicketsStopped + AllWorkTasksStopped;

    %Total picked up work - all engineers (excluding admin tasks)
    AllTicketsPickedUp = AllTicketsPickedUpE1 + AllTicketsPickedUpSE1 + AllTicketsPickedUpSE2 + AllTicketsPickedUpSE3;
    AllTasksPickedUp = AllTasksPickedUpE1 + AllTasksPickedUpSE1 + AllTasksPickedUpSE2 + AllTasksPickedUpSE3;
    AllWorkPickedUp = AllTicketsPickedUp + AllTasksPickedUp;

    %Generated work
        %Incidents
            if isempty(get(out.logsout,"IncGen").Values.IsAdmin.Data)
                IncidentsGenerated = 0;
            else
                IncidentsGenerated = height(timetable2table(timeseries2timetable(get(out.logsout,"IncGen").Values.IsAdmin)));
            end
        %Incidents from Change
            if isempty(get(out.logsout,"IncidentsfromReworkGen").Values.IsAdmin.Data)
                IncFromChgGenerated = 0;
            else
                IncFromChgGenerated = height(timetable2table(timeseries2timetable(get(out.logsout,"IncidentsfromReworkGen").Values.IsAdmin)));
            end
        %Requests
            if isempty(get(out.logsout,"ReqGen").Values.IsAdmin.Data)
                RequestsGenerated = 0;
            else
                RequestsGenerated = height(timetable2table(timeseries2timetable(get(out.logsout,"ReqGen").Values.IsAdmin)));
            end
        %Project Tasks
            if isempty(get(out.logsout,"ProjTaskGen").Values.IsAdmin.Data)
                ProjectTasksGenerated = 0;
            else
                ProjectTasksGenerated = height(timetable2table(timeseries2timetable(get(out.logsout,"ProjTaskGen").Values.IsAdmin)));
            end
        %Maintenance Tasks
            if isempty(get(out.logsout,"MaintTaskGen").Values.IsAdmin.Data)
                MaintenanceTasksGenerated = 0;
            else
                MaintenanceTasksGenerated = height(timetable2table(timeseries2timetable(get(out.logsout,"MaintTaskGen").Values.IsAdmin)));
            end
        %Admin Tasks
            if isempty(get(out.logsout,"AdminTaskGen").Values.IsAdmin.Data)
                AdminTasksGenerated = 0;
            else
                AdminTasksGenerated = height(timetable2table(timeseries2timetable(get(out.logsout,"AdminTaskGen").Values.IsAdmin)));
            end
        AllTicketsGenerated = RequestsGenerated + IncidentsGenerated;
        AllWorkTasksGenerated = ProjectTasksGenerated + IncFromChgGenerated + MaintenanceTasksGenerated;
        AllWorkGenerated = AllTicketsGenerated + AllWorkTasksGenerated;
        PercentTasks = AllWorkTasksGenerated./AllWorkGenerated;
        PercentTickets = AllTicketsGenerated./AllWorkGenerated;

    %Completed work
        %Incidents
            IncidentsCompletedTS = get(out.logsout,"IncComp").Values.IsAdmin;
            if isempty (IncidentsCompletedTS.Time)
                IncidentsCompletedTS = timeseries(0, 0);
            end
            IncidentsCompleted = height(timetable2table(timeseries2timetable(IncidentsCompletedTS)));
        %Requests
            RequestsCompletedTS = get(out.logsout,"ReqComp").Values.IsAdmin;
            if isempty (RequestsCompletedTS.Time)
                RequestsCompletedTS = timeseries(0, 0);
            end
            RequestsCompleted = height(timetable2table(timeseries2timetable(RequestsCompletedTS)));
        %Project Tasks
            ProjectTasksCompletedTS = get(out.logsout,"ProjTaskComp").Values.IsAdmin;
            if isempty (ProjectTasksCompletedTS.Time)
                ProjectTasksCompletedTS = timeseries(0, 0);
            end
            ProjectTasksCompleted = height(timetable2table(timeseries2timetable(ProjectTasksCompletedTS)));
        %Maintenance Tasks
            MaintenanceTasksCompletedTS = get(out.logsout,"MaintTaskComp").Values.IsAdmin;
            if isempty (MaintenanceTasksCompletedTS.Time)
                MaintenanceTasksCompletedTS = timeseries(0, 0);
            end
            MaintenanceTasksCompleted = height(timetable2table(timeseries2timetable(MaintenanceTasksCompletedTS)));
        %Admin Tasks
            AdminTasksCompletedTS = get(out.logsout,"AdminWorkComp").Values.IsAdmin;
            if isempty (AdminTasksCompletedTS.Time)
                AdminTasksCompletedTS = timeseries(0, 0);
            end
            AdminTasksCompleted = height(timetable2table(timeseries2timetable(AdminTasksCompletedTS)));
        AllTicketsCompleted = RequestsCompleted + IncidentsCompleted;
        AllWorkTasksCompleted = ProjectTasksCompleted + MaintenanceTasksCompleted;
        AllWorkCompleted = AllTicketsCompleted + AllWorkTasksCompleted;

    %Rates

    TicketStoppageRate = AllTicketsStopped./AllTicketsCompleted;
    TicketsStoppedPerDay = AllTicketsStopped./IterationLength;
    TicketsCompletedPerDay = AllTicketsCompleted./IterationLength;
    TaskStoppageRate = AllWorkTasksStopped./AllWorkTasksCompleted;
    TasksStoppedPerDay = AllWorkTasksStopped./IterationLength;
    TasksCompletedPerDay = AllWorkTasksCompleted./IterationLength;
    ReworkPerDay = IncFromChgGenerated./IterationLength;
    TicketPickupRate = AllTicketsPickedUp./AllTicketsGenerated;
    TicketsPickedUpPerDay = AllTicketsPickedUp./IterationLength;
    TaskPickupRate = AllTasksPickedUp./AllWorkTasksGenerated;
    TasksPickedUpPerDay = AllTasksPickedUp./IterationLength;
    WorkPickedUpPerDay = AllWorkPickedUp./IterationLength;
%due to low overall counts, if any occur the statistic will be heavily skewed upwards...
%   ReworkRate = ReworkPerDay./WorkPickedUpPerDay; %percentage
    TotalWorkSessions = AllTasksPickedUp + AllTicketsPickedUp;
    WorkSessionsPerDay = TotalWorkSessions./IterationLength;
    ErrorsPerDay = AllWorkCompleted*ErrorRate;
    BaseReworkRate = ErrorsPerDay*PercentTasks;
    BaseIncFromChange = ErrorsPerDay*PercentTickets;

    %Analyze DES Utilization data

    IncrTime = seconds(0:0.0325:5);
    E1UtilTS = out.E1Utilization;
    if isempty(E1UtilTS.Time)
        E1UtilTS = timeseries(0,0);
    end
    E1UtilTT = timeseries2timetable(E1UtilTS);

    SE1UtilTS = out.SE1Utilization;
    if isempty(SE1UtilTS.Time)
        SE1UtilTS = timeseries(0,0);
    end
    SE1UtilTT = timeseries2timetable(SE1UtilTS);

    SE2UtilTS = out.SE2Utilization;
    if isempty(SE2UtilTS.Time)
        SE2UtilTS = timeseries(0,0);
    end
    SE2UtilTT = timeseries2timetable(SE2UtilTS);
    SE2UtilTT = timeseries2timetable(out.SE2Utilization);

    SE3UtilTS = out.SE3Utilization;
    if isempty(SE3UtilTS.Time)
        SE3UtilTS = timeseries(0,0);
    end
    SE3UtilTT = timeseries2timetable(SE3UtilTS);
    SE3UtilTT = timeseries2timetable(out.SE3Utilization);

    TTUtilsync = synchronize(E1UtilTT, SE1UtilTT, SE2UtilTT, SE3UtilTT, 'union', 'previous');
    TTUtilsync.AvgUtil = mean(TTUtilsync{:,{'Data_E1UtilTT','Data_SE1UtilTT','Data_SE2UtilTT','Data_SE3UtilTT'}},2);

    util_pred = TTUtilsync.AvgUtil(end);

    %Analyze DES Total Time data
    IncTimeTS = get(out.logsout,"TotalTimeInc").Values;
    if isempty(IncTimeTS.Time)
        IncTimeTS = timeseries(0,0);
    end
    IncTimeTT = timeseries2timetable(IncTimeTS);
    IncTimeTTColName = IncTimeTT.Properties.VariableNames{1};
    if isempty(IncTimeTS.Time)
        IncTimePDFLambdaSim = 0;
    else
        IncTimeMean = mean(IncTimeTT.(IncTimeTTColName));
        IncTimePDFLambdaSim = 1/IncTimeMean;
    end

    ReqTimeTS = get(out.logsout,"TotalTimeReq").Values;
    if isempty(ReqTimeTS.Time)
        ReqTimeTS = timeseries(0,0);
    end
    ReqTimeTT = timeseries2timetable(ReqTimeTS);
    ReqTimeTTColName = ReqTimeTT.Properties.VariableNames{1};
    if isempty(ReqTimeTS.Time)
        ReqTimePDFLambdaSim = 0;
    else
        ReqTimeMean = mean(ReqTimeTT.(ReqTimeTTColName));
        ReqTimePDFLambdaSim = 1/ReqTimeMean;
    end

    %Analyze queue depth
    E1QueueTS = out.E1QueueLength;
    if isempty(E1QueueTS.Time)
        E1QueueTS = timeseries(0,0);
    end
    E1QueueTT = timeseries2timetable(E1QueueTS);

    SE1QueueTS = out.SE1QueueLength;
    if isempty(SE1QueueTS.Time)
        SE1QueueTS = timeseries(0,0);
    end
    SE1QueueTT = timeseries2timetable(SE1QueueTS);

    SE2QueueTS = out.SE2QueueLength;
    if isempty(SE2QueueTS.Time)
        SE2QueueTS = timeseries(0,0);
    end
    SE2QueueTT = timeseries2timetable(SE2QueueTS);

    SE3QueueTS = out.SE3QueueLength;
    if isempty(SE3QueueTS.Time)
        SE3QueueTS = timeseries(0,0);
    end
    SE3QueueTT = timeseries2timetable(SE3QueueTS);

    TTQueuesync = synchronize(E1QueueTT, SE1QueueTT, SE2QueueTT, SE3QueueTT, 'union', 'previous');
    TTQueuesync.AvgQueue = mean(TTQueuesync{:,{'Data_E1QueueTT','Data_SE1QueueTT','Data_SE2QueueTT','Data_SE3QueueTT'}},2);

    queue_pred = TTQueuesync.AvgQueue(end);

end
