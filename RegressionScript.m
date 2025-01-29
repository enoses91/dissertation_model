
% Establish parameters - intial guesses and bounds

    ServiceTimeActOpt = 0.3424;               %Starting average amount of time engineer has available to work, from particle swarm analysis
    ServiceTimeAct = ServiceTimeActOpt;
    ServiceTimeActMin = 0.06;           %Lower bound average amount of time engineer has available to work, ~.5 min (28.8 min)
    ServiceTimeActMax = 0.24;           %Upper bound average amount of time engineer has available to work, ~2 hrs (115.2 min)

    ReqServiceTimeOpt = 0.5994;              %Initial guess average amount of time a work item requires , from particle swarm analysis
    ReqServiceTime = ReqServiceTimeOpt;
    ReqServiceTimeMin = 0.06;           %Lower bound average amount of time a work item requires, ~.5 min (28.8 min)
    ReqServiceTimeMax = 0.24;           %Upper bound Average amount of time a work item requires, ~2 hrs (115.2 min)

    ProjTaskArrivalRateOpt = 0.2411;          %Initial guess project task interarrival rate coefficient, from particle swarm analysis
    ProjTaskArrivalRate = ProjTaskArrivalRateOpt;
    ProjTaskArrivalRateMin = 0.02128;   %Lower bound project task interarrival rate coefficient
    ProjTaskArrivalRateMax = 0.34235;   %Upper bound project task interarrival rate coefficient

    MaintTaskArrivalRateOpt = 0.1543;       %Initial guess maint task interarrival rate coefficient, from particle swarm analysis
    MaintTaskArrivalRate = MaintTaskArrivalRateOpt;
    MaintTaskArrivalRateMin = 0.06386;  %Lower bound maint task interarrival rate coefficient
    MaintTaskArrivalRateMax = 1.02704;  %Upper bound maint task interarrival rate coefficient

    AdminTaskArrivalRateOpt = 0.1713;         %Initial guess admin task interarrival rate coefficient, from particle swarm analysis
    AdminTaskArrivalRate = AdminTaskArrivalRateOpt;
    AdminTaskArrivalRateMin = 0.06383;  %Lower bound admin task interarrival rate coefficient
    AdminTaskArrivalRateMax = 0.25532;  %Upper bound admin task interarrival rate coefficient

    lb = [ProjTaskArrivalRateMin, MaintTaskArrivalRateMin, AdminTaskArrivalRateMin, ServiceTimeActMin, ReqServiceTimeMin];
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

% Sensitivity analysis

ServiceTimeActPercentRg = 0.1;
ServiceTimeActNumPts = 9
ServiceTimeActValues = linspace((1-ServiceTimeActPercentRg)*ServiceTimeAct, (1+ServiceTimeActPercentRg)*ServiceTimeAct, ServiceTimeActNumPts);

ReqServiceTimePercentRg = 0.1;
ReqServiceTimeNumPts = 9;
ReqServiceTimeValues = linspace((1-ReqServiceTimePercentRg)*ReqServiceTime, (1+ReqServiceTimePercentRg)*ReqServiceTime, ReqServiceTimeNumPts);

ProjTaskArrivalRatePercentRg = 0.1;
ProjTaskArrivalRateNumPts = 9;
ProjTaskArrivalRateValues = linspace((1-ProjTaskArrivalRatePercentRg)*ProjTaskArrivalRate, (1+ProjTaskArrivalRatePercentRg)*ProjTaskArrivalRate, ProjTaskArrivalRateNumPts);

MaintTaskArrivalRatePercentRg = 0.1;
MaintTaskArrivalRateNumPts = 9;
MaintTaskArrivalRateValues = linspace((1-MaintTaskArrivalRatePercentRg)*MaintTaskArrivalRate, (1+MaintTaskArrivalRatePercentRg)*MaintTaskArrivalRate, MaintTaskArrivalRateNumPts);

AdminjTaskArrivalRatePercentRg = 0.1;
AdminTaskArrivalRateNumPts = 9;
AdminTaskArrivalRateValues = linspace((1-AdminjTaskArrivalRatePercentRg)*AdminTaskArrivalRate, (1+AdminjTaskArrivalRatePercentRg)*AdminTaskArrivalRate, AdminTaskArrivalRateNumPts);

% Local sensitivity on ServiceTimeAct
resultsServiceTimeAct = zeros(ServiceTimeActNumPts, 3); 
%for i = 1:ServiceTimeActNumPts
    % Define new parameter set
%    testServiceTimeAct = ServiceTimeActValues(i);
    
    % Set model parameters (e.g., in the workspace or via set_param)
    % Or pass them as input arguments to a function that runs the sim
%    ServiceTimeAct = testServiceTimeAct;
    
    % Run simulation
%    run('CombinedSim.m');
    
    % Extract performance metrics
%    ServiceTimeActutilization = util_pred;
%    ServiceTimeActqueueLength = queue_pred;
    
    % Store results
%    resultsServiceTimeAct(i,:) = [testServiceTimeAct, ServiceTimeActutilization(end), ServiceTimeActqueueLength(end)];
%   ServiceTimeAct = ServiceTimeActOpt;
%end

% Local sensitivity on ReqServiceTime
%resultsReqServiceTime = zeros(ReqServiceTimeNumPts, 3); 
%for i = 1:ReqServiceTimeNumPts
    % Define new parameter set
%    testReqServiceTime = ReqServiceTimeValues(i);
%    ReqServiceTime = testReqServiceTime;
    
    % Set model parameters (e.g., in the workspace or via set_param)
    % Or pass them as input arguments to a function that runs the sim
%    ReqServiceTime = testReqServiceTime;

    % Run simulation
%    run('CombinedSim.m');
    
    % Extract performance metrics
%    ReqServiceTimeutilization = util_pred;
%    ReqServiceTimequeueLength = queue_pred;
    
    % Store results
%    resultsReqServiceTime(i,:) = [testReqServiceTime, ReqServiceTimeutilization(end), ReqServiceTimequeueLength(end)];
%    ReqServiceTime = ReqServiceTimeOpt;
%end

% Local sensitivity on ProjTaskArrivalRate
%resultsProjTaskArrivalRate = zeros(ProjTaskArrivalRateNumPts, 3); 
%for i = 1:ProjTaskArrivalRateNumPts
    % Define new parameter set
%    testProjTaskArrivalRate = ProjTaskArrivalRateValues(i);
    
    % Set model parameters (e.g., in the workspace or via set_param)
    % Or pass them as input arguments to a function that runs the sim
%    ProjTaskArrivalRate = testProjTaskArrivalRate;

    % Run simulation
%    run('CombinedSim.m');
    
    % Extract performance metrics
%    testProjTaskArrivalRateutilization = util_pred;
%    testProjTaskArrivalRatequeueLength = queue_pred;
    
    % Store results
%    resultsProjTaskArrivalRate(i,:) = [testProjTaskArrivalRate, testProjTaskArrivalRateutilization(end), testProjTaskArrivalRatequeueLength(end)];
%    ProjTaskArrivalRate = ProjTaskArrivalRateOpt;
%end

% Local sensitivity on MaintTaskArrivalRate
%resultsMaintTaskArrivalRate = zeros(MaintTaskArrivalRateNumPts, 3); 
%for i = 1:MaintTaskArrivalRateNumPts
    % Define new parameter set
%    testMaintTaskArrivalRate = MaintTaskArrivalRateValues(i);
    
    % Set model parameters (e.g., in the workspace or via set_param)
    % Or pass them as input arguments to a function that runs the sim
%    MaintTaskArrivalRate = testMaintTaskArrivalRate;
    
    % Run simulation
%    run('CombinedSim.m');
    
    % Extract performance metrics
%    testMaintTaskArrivalRateutilization = util_pred;
%    testMaintTaskArrivalRatequeueLength = queue_pred;
    
    % Store results
%    resultsMaintTaskArrivalRate(i,:) = [testMaintTaskArrivalRate, testMaintTaskArrivalRateutilization(end), testMaintTaskArrivalRatequeueLength(end)];
%    MaintTaskArrivalRate = MaintTaskArrivalRateOpt;
%end

% Local sensitivity on MaintTaskArrivalRate
%resultsAdminTaskArrivalRate = zeros(AdminTaskArrivalRateNumPts, 3); 
%for i = 1:AdminTaskArrivalRateNumPts
    % Define new parameter set
%    testAdminTaskArrivalRate = AdminTaskArrivalRateValues(i);
    
    % Set model parameters (e.g., in the workspace or via set_param)
    % Or pass them as input arguments to a function that runs the sim
%    AdminTaskArrivalRate = testAdminTaskArrivalRate;
    
    % Run simulation
%    run('CombinedSim.m');
    
    % Extract performance metrics
%    testAdminTaskArrivalRateutilization = util_pred;
%    testAdminTaskArrivalRatequeueLength = queue_pred;
    
    % Store results
%    resultsAdminTaskArrivalRate(i,:) = [testAdminTaskArrivalRate, testAdminTaskArrivalRateutilization(end), testAdminTaskArrivalRatequeueLength(end)];
%    AdminTaskArrivalRate = AdminTaskArrivalRateOpt;
%end

% Example sensitivity plot
%plot(resultsReqServiceTime(:,1), resultsReqServiceTime(:,3), '-o'); % '-o' specifies a line with circular markers
%xlabel('Required Service Time'); % Label for the x-axis
%ylabel('Queue Depth'); % Label for the y-axis
%title('Plot of Service Time vs Queue Depth'); % Title of the plot
%grid on; % Enable grid for better readability