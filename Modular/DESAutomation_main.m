%% DESAutomation_main.m
clear; clc;

% 1. Initialization: get base parameters and DES input history.
[baseParams, desHistory] = initializeSimulation();

% Define maximum iterations.
MaxIterations = 1;

for Iteration = 1:MaxIterations
    fprintf('Iteration %d\n', Iteration);
    
    % --- Pre-Iteration Cleanup: ensure any previous instance is unloaded ---
    if bdIsLoaded('iterateddes')
        close_system('iterateddes', 0);
    end
    pause(1);  % allow time for cleanup

    % 2. Configure simulation parameters for SimEvents (loads model fresh)
    simIn = configureSimEvents(baseParams);
    
    % 3. Run the SimEvents simulation
    simOut = runSimEvents(simIn);
    
    % 4. Process simulation output.
    simMetrics = processSimOutput(simOut, baseParams);
    
    % 5. Analyze additional signals.
    util_pred = analyzeUtilization(simOut);
    [IncTimePDFLambdaSim, ReqTimePDFLambdaSim] = analyzeTimeData(simOut);
    queue_pred = analyzeQueueData(simOut);
    
    % 6. Build the SDParameters vector using fields from simMetrics.
    TicketsPickedUpPerDay = simMetrics.TicketsPickedUpPerDay;
    TasksPickedUpPerDay   = simMetrics.TasksPickedUpPerDay;
    TicketsStoppedPerDay  = simMetrics.TicketsStoppedPerDay;
    TasksStoppedPerDay    = simMetrics.TasksStoppedPerDay;
    TicketsCompletedPerDay = simMetrics.TicketsCompletedPerDay;
    TasksCompletedPerDay  = simMetrics.TasksCompletedPerDay;
    BaseReworkRate        = simMetrics.BaseReworkRate;
    BaseIncFromChange     = simMetrics.BaseIncFromChange;
    BaseMgmtPress         = simMetrics.BaseMgmtPress;
    BaseFatigue           = simMetrics.BaseFatigue;
    BaseQueuedTasks       = simMetrics.BaseQueuedTasks;
    BaseQueuedTickets     = simMetrics.BaseQueuedTickets;
    BaseMgmtPreempt       = simMetrics.BaseMgmtPreempt;
    BaseCompleteTasks     = simMetrics.BaseCompleteTasks;
    BaseCompleteTickets   = simMetrics.BaseCompleteTickets;
    % --- New items: include the current error rate and service time ---
    ErrorRateVal          = baseParams.ErrorRate;      
    ServiceTimeActVal     = baseParams.ServiceTimeAct;   
    IterationVal          = simMetrics.Iteration;
    
    % Now build an 18-element vector.
    SDParameters = [TicketsPickedUpPerDay;
                    TasksPickedUpPerDay;
                    TicketsStoppedPerDay;
                    TasksStoppedPerDay;
                    TicketsCompletedPerDay;
                    TasksCompletedPerDay;
                    BaseReworkRate;
                    BaseIncFromChange;
                    BaseMgmtPress;
                    BaseFatigue;
                    BaseQueuedTasks;
                    BaseQueuedTickets;
                    BaseMgmtPreempt;
                    BaseCompleteTasks;
                    BaseCompleteTickets;
                    ErrorRateVal;
                    ServiceTimeActVal;
                    IterationVal];
                
    % 7. Write the SDParameters vector to Excel.
    excelOperations('write', SDParameters);
    
    % 8. Trigger external Vensim simulation and wait for completion.
    triggerVensimSimulation();
    
    % 9. Update iteration parameters and compute residuals.
    [baseParams, desHistory, residuals] = updateIterationParameters(baseParams, desHistory, []);
    
    % --- Post-Iteration Cleanup: unload the model completely ---
    if bdIsLoaded('iterateddes')
        close_system('iterateddes', 0);
    end
    pause(1);
end
