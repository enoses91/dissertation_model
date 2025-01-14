
% Establish parameters - intial guesses and bounds

    ServiceTimeAct = 0.3424;               %Starting average amount of time engineer has available to work
    ServiceTimeActMin = 0.06;           %Lower bound average amount of time engineer has available to work, ~.5 min (28.8 min)
    ServiceTimeActMax = 0.24;           %Upper bound average amount of time engineer has available to work, ~2 hrs (115.2 min)

    ReqServiceTime = 1.0270;              %Initial guess average amount of time a work item requires 
    ReqServiceTimeMin = 0.06;           %Lower bound average amount of time a work item requires, ~.5 min (28.8 min)
    ReqServiceTimeMax = 0.24;           %Upper bound Average amount of time a work item requires, ~2 hrs (115.2 min)

    ProjTaskArrivalRate = 0.2553;          %Initial guess project task interarrival rate coefficient
    ProjTaskArrivalRateMin = 0.02128;   %Lower bound project task interarrival rate coefficient
    ProjTaskArrivalRateMax = 0.34235;   %Upper bound project task interarrival rate coefficient

    MaintTaskArrivalRate = 0.1229;       %Initial guess maint task interarrival rate coefficient
    MaintTaskArrivalRateMin = 0.06386;  %Lower bound maint task interarrival rate coefficient
    MaintTaskArrivalRateMax = 1.02704;  %Upper bound maint task interarrival rate coefficient

    AdminTaskArrivalRate = 0.2334;         %Initial guess admin task interarrival rate coefficient
    AdminTaskArrivalRateMin = 0.06383;  %Lower bound admin task interarrival rate coefficient
    AdminTaskArrivalRateMax = 0.25532;  %Upper bound admin task interarrival rate coefficient

    lb = [ProjTaskArrivalRateMin, MaintTaskArrivalRate, AdminTaskArrivalRate, ServiceTimeActMin, ReqServiceTimeMin];
    ub = [ProjTaskArrivalRateMax, MaintTaskArrivalRateMax, AdminTaskArrivalRateMax, ServiceTimeActMax, ReqServiceTimeMax];
    x0 = [ProjTaskArrivalRate, MaintTaskArrivalRate, AdminTaskArrivalRate, ServiceTimeAct, ReqServiceTime];

% Automatically calculate Jacobian (fails as undefined with certain
% options)

    % Establish objective function for use with Automatic Jacobian calculation
%function residuals = myObjectiveFun(lambdas)
    % lambdas: [ProjTaskArrivalRate, MaintTaskArrivalRate, AdminTaskArrivalRate, ReqServiceTime, ServiceTimeAct]
    %    ProjTaskArrivalRate = lambdas(1);
    %    MaintTaskArrivalRate = lambdas(2);
    %    AdminTaskArrivalRate = lambdas(3);
    %    ReqServiceTime = lambdas(4);
    %    ServiceTimeAct = lambdas(5);
    %    run('CombinedSim.m');
    %    residuals(1) = util_pred - util_obs;
    %    residuals(2) = IncTimePDFLambdaSim - IncTimePDFLambdaObs;
    %    residuals(3) = ReqTimePDFLambdaSim - ReqTimePDFLambdaObs;
    %    residuals(4) = queue_pred - queue_obs;
    %    residuals = residuals(:);
%end

    %function [r, J] = myObjFunAndJacobian(x)
    % x: [ProjTaskArrivalRate, MaintTaskArrivalRate, AdminTaskArrivalRate, ReqServiceTime, ServiceTimeAct]
%    ProjTaskArrivalRate = x(1);
%    MaintTaskArrivalRate = x(2);
%    AdminTaskArrivalRate = x(3);
%    ReqServiceTime = x(4);
%    ServiceTimeAct = x(5);
%    r = runSimEventsModel(x);
%    n = numel(x);
%    m = numel(r);
%    J = zeros(m, n);
%    stepSize = 1e-8;
%    for i = 1:n
%        xMinus = x;
%        xPlus = x;
%        xMinus(i) = xMinus(i) - stepSize;
%        xPlus(i) = xPlus(i) + stepSize;
%        rMinus = runSimEventsModel(xMinus);
%        rPlus = runSimEventsModel(xPlus);
%        J(:, i) = (rPlus - rMinus) / (2 * stepSize);
%    end
%end

%Derivative-based regression using lsqnonlin

    %Automatic Jacobian calculation
%    options = optimoptions('lsqnonlin','Display','iter','MaxFunctionEvaluations', 300, 'FiniteDifferenceType','central', 'StepTolerance', 1e-12,'FunctionTolerance', 1e-12,'OptimalityTolerance', 1e-12,'Algorithm','trust-region-reflective');
%    [estimatedLambdas, resnorm, residuals, exitflag, output] = lsqnonlin(@myObjectiveFun, x0, lb, ub, options);

    %Manual Jacobian calculation
    %options = optimoptions('lsqnonlin','Display','iter','MaxFunctionEvaluations', 50, 'StepTolerance', 1e-12,'FunctionTolerance', 1e-12,'OptimalityTolerance', 1e-12,'Algorithm','trust-region-reflective','Jacobian','on');
    %[estimatedLambdas, ~, residuals, exitflag, output] = lsqnonlin(@myObjFunAndJacobian, x0, lb, ub, options);

%Derivative-free regression

function cost = myCostFun(x)

    ProjTaskArrivalRate = x(1);
    MaintTaskArrivalRate = x(2);
    AdminTaskArrivalRate = x(3);
    ReqServiceTime = x(4);
    ServiceTimeAct = x(5);

    run('CombinedSim.m');

    residuals(1) = util_pred - util_obs;
    residuals(2) = IncTimePDFLambdaSim - IncTimePDFLambdaObs;
    residuals(3) = ReqTimePDFLambdaSim - ReqTimePDFLambdaObs;
    residuals(4) = queue_pred - queue_obs;
    residuals = residuals(:);

    cost = residuals(1)^2 + residuals(2)^2 + residuals(3)^2 + residuals(4)^2;

end



%Patternsearch
%    options = optimoptions('patternsearch', ...
%        'Display','iter', ...
%        'InitialMeshSize', 1,  ...
%        'MeshExpansionFactor', 2, ...
%        'MeshContractionFactor', 0.5, ...
%        'MaxFunctionEvaluations', 5000, ...
%        'StepTolerance', 1e-8, ...
%        'FunctionTolerance', 1e-8,...
%        'UseParallel',true);
%    [xOpt, fval, exitflag, output] = patternsearch(@myCostFun, x0, [], [], [], [], lb, ub, [], options)

%Particleswarm (can't run with 'UseParallel', true due to Vensim call)
%With nVars =5, recommendation is for 'SwarmSize', 100 - 150,  'MaxIterations',
%500 - 1000
    nVars = 5;
    options = optimoptions('particleswarm', ...
        'Display','iter', ...
        'SwarmSize', 100,  ...
        'MaxIterations', 1000, ...
        'MaxStallIterations', 20);
    [xOpt, fval, exitflag, output] = particleswarm(@myCostFun, nVars, lb, ub, options)

%Genetic Algorithm
%With nVars =5, recommendation is for 'PopulationSize', 75,  'MaxGenerations', 500
%    nVars = 5;
%    options = optimoptions('ga','Display','iter', 'PopulationSize', 75,  'MaxGenerations', 500,  'MaxStallGenerations', 20);
%    [xOpt, fval, exitflag, output, population, scores] = ga(@myCostFun, nVars, [], [], [], [], lb, ub, [], options)


%Extract residuals based on xOpt
%    function resVec = computeResiduals(x)
%        run('CombinedSim.m');
%        logs = simOut.logsout;
%        util_pred = logs.getElement('util_pred').Values.Data(end);
%        util_obs = logs.getElement('util_obs').Values.Data(end);
%        IncTimePDFLambdaSim = logs.getElement('IncTimePDFLambdaSim').Values.Data(end);
%        IncTimePDFLambdaObs = logs.getElement('IncTimePDFLambdaObs').Values.Data(end);
%        ReqTimePDFLambdaSim = logs.getElement('ReqTimePDFLambdaSim').Values.Data(end);
%        ReqTimePDFLambdaObs = logs.getElement('ReqTimePDFLambdaObs').Values.Data(end);
%        queue_pred = logs.getElement('queue_pred').Values.Data(end);
%        queue_obs = logs.getElement('queue_obs').Values.Data(end);
%        residuals(1) = util_pred - util_obs;
%        residuals(2) = IncTimePDFLambdaSim - IncTimePDFLambdaObs;
%        residuals(3) = ReqTimePDFLambdaSim - ReqTimePDFLambdaObs;
%        residuals(4) = queue_pred - queue_obs;
%        residuals = residuals(:);
%    end
%finalRes = computeResiduals(xOpt);
