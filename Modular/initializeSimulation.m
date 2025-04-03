function [baseParams, desHistory] = initializeSimulation()
    % initializeSimulation.m
    % This function initializes the simulation parameters and the DES input history.
    
    % Base simulation parameters and independent variables
    baseParams.BaseMgmtPreempt = 1;
    baseParams.BaseMgmtPress   = 1;
    baseParams.BaseFatigue     = 1;
    baseParams.BaseQueuedTasks = 0;
    baseParams.BaseQueuedTickets = 0;
    baseParams.BaseCompleteTickets = 0;
    baseParams.BaseCompleteTasks = 0;
    baseParams.ErrorRate = 0.005;
    baseParams.Iteration = 1;
    
    % Arrival rates and other parameters
    baseParams.IncTaskArrivalRate = 0.2024906;
    baseParams.ReqTaskArrivalRate = 0.0930726;
    baseParams.util_obs = 0.95;
    baseParams.queue_obs = 4.0;
    baseParams.ReqTimePDFLambdaObs = 0.1961;
    baseParams.IncTimePDFLambdaObs = 0.1469;

    % Initial guess for independent variables
    baseParams.ServiceTimeAct = 0.255;
    baseParams.ReqServiceTime = 0.123;
    baseParams.ProjTaskArrivalRate = 0.2;
    baseParams.MaintTaskArrivalRate = 0.125;
    baseParams.AdminTaskArrivalRate = 2.0;
    
    % Regression-determined variables
%    baseParams.ServiceTimeAct = 0.3424;
%    baseParams.ReqServiceTime = 0.5994;
%    baseParams.ProjTaskArrivalRate = 0.2411;
%    baseParams.MaintTaskArrivalRate = 0.1543;
%    baseParams.AdminTaskArrivalRate = 0.1713;


    
    % Initialize DES input history as a numeric matrix (each column is an iteration):
    % [ErrorRate; ServiceTimeAct; Iteration]
    desHistory = [baseParams.ErrorRate; baseParams.ServiceTimeAct; baseParams.Iteration];
end
