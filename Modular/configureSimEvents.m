function simIn = configureSimEvents(baseParams)
% configureSimEvents Configures the SimEvents simulation input.
%   simIn = configureSimEvents(baseParams)
%
% Attempts to load the SimEvents model "iterateddes.slx" from the parent folder.
% If not found, it then checks the current folder. Before loading, any previously
% loaded instance of the model is closed to ensure a fresh start. The SimulationInput
% is then configured with 'LoadInitialState' set to 'off', forcing a fresh simulation
% state.
%
% This version also sets each generator block's AttributeInitialValue so
% that the modular approach fully matches the monolithic DESAutomation.m.

    mdlName = 'iterateddes';
    mdlFile = [mdlName, '.slx'];
    
    % Try to locate the model in the parent folder
    mdlPathParent = fullfile('..', mdlFile);
    if exist(mdlPathParent, 'file')
        mdlPath = mdlPathParent;
    else
        % If not found, try the current folder
        mdlPathCurrent = fullfile(pwd, mdlFile);
        if exist(mdlPathCurrent, 'file')
            mdlPath = mdlPathCurrent;
        else
            error('Model file %s not found in either the parent folder or the current folder.', mdlFile);
        end
    end

    % Pre-load cleanup: if the model is already loaded, close it.
    if bdIsLoaded(mdlName)
        close_system(mdlName, 0);
    end
    pause(1);  % Allow time for cleanup
    
    % Load the system freshly
    load_system(mdlPath);
    
    % Create a SimulationInput object
    simIn = Simulink.SimulationInput(mdlName);
    
    % Ensure that a saved final state is not used for the next run.
    simIn = setModelParameter(simIn, 'LoadInitialState', 'off');
    
    % ---------------------------------------------------------------------
    % (1) Set the intergeneration time actions based on arrival rates.
    % ---------------------------------------------------------------------
    simIn = setBlockParameter(simIn, [mdlName, '/IncGen'], ...
        'IntergenerationTimeAction', ...
        "dt = -" + baseParams.IncTaskArrivalRate + "*log(1-rand());");
    
    simIn = setBlockParameter(simIn, [mdlName, '/ReqGen'], ...
        'IntergenerationTimeAction', ...
        "dt = -" + baseParams.ReqTaskArrivalRate + "*log(1-rand());");
    
    simIn = setBlockParameter(simIn, [mdlName, '/ProjTaskGen'], ...
        'IntergenerationTimeAction', ...
        "dt = -" + baseParams.ProjTaskArrivalRate + "*log(1-rand());");
    
    simIn = setBlockParameter(simIn, [mdlName, '/MaintTaskGen'], ...
        'IntergenerationTimeAction', ...
        "dt = -" + baseParams.MaintTaskArrivalRate + "*log(1-rand());");
    
    simIn = setBlockParameter(simIn, [mdlName, '/AdminTaskGen'], ...
        'IntergenerationTimeAction', ...
        "dt = -" + baseParams.AdminTaskArrivalRate + "*log(1-rand());");
    
    % ---------------------------------------------------------------------
    % (2) Match the monolithic AttributeInitialValue settings for ALL blocks.
    % ---------------------------------------------------------------------
    % Format in DESAutomation.m: 
    % "0|0|0|ReqServiceTime|0|0|0|0|0|ErrorRate|(WorkType)|1|0|1|ServiceTimeAct|(finalFlag)"
    %
    % WorkType:  1=Inc, 2=Req, 3=Proj, 4=Maint, 5=Admin
    % finalFlag: 2 for Inc/Req/Proj/Maint, 1 for Admin
    %
    % (a) IncGen
    simIn = setBlockParameter(simIn, [mdlName, '/IncGen'], ...
        'AttributeInitialValue', ...
        "0|0|0|" + baseParams.ReqServiceTime + "|0|0|0|0|0|" + baseParams.ErrorRate ...
        + "|1|1|0|1|" + baseParams.ServiceTimeAct + "|2");
    
    % (b) IncidentsfromReworkGen — same settings as IncGen, still WorkType=1
    simIn = setBlockParameter(simIn, [mdlName, '/IncidentsfromReworkGen'], ...
        'AttributeInitialValue', ...
        "0|0|0|" + baseParams.ReqServiceTime + "|0|0|0|0|0|" + baseParams.ErrorRate ...
        + "|1|1|0|1|" + baseParams.ServiceTimeAct + "|2");
    
    % (c) ReqGen — WorkType=2
    simIn = setBlockParameter(simIn, [mdlName, '/ReqGen'], ...
        'AttributeInitialValue', ...
        "0|0|0|" + baseParams.ReqServiceTime + "|0|0|0|0|0|" + baseParams.ErrorRate ...
        + "|2|1|0|1|" + baseParams.ServiceTimeAct + "|2");
    
    % (d) ProjTaskGen — WorkType=3
    simIn = setBlockParameter(simIn, [mdlName, '/ProjTaskGen'], ...
        'AttributeInitialValue', ...
        "0|0|0|" + baseParams.ReqServiceTime + "|0|0|0|0|0|" + baseParams.ErrorRate ...
        + "|3|1|0|1|" + baseParams.ServiceTimeAct + "|2");
    
    % (e) MaintTaskGen — WorkType=4
    simIn = setBlockParameter(simIn, [mdlName, '/MaintTaskGen'], ...
        'AttributeInitialValue', ...
        "0|0|0|" + baseParams.ReqServiceTime + "|0|0|0|0|0|" + baseParams.ErrorRate ...
        + "|4|1|0|1|" + baseParams.ServiceTimeAct + "|2");
    
    % (f) AdminTaskGen — WorkType=5, finalFlag=1
    simIn = setBlockParameter(simIn, [mdlName, '/AdminTaskGen'], ...
        'AttributeInitialValue', ...
        "0|0|0|" + baseParams.ReqServiceTime + "|0|0|0|0|0|" + baseParams.ErrorRate ...
        + "|5|1|0|1|" + baseParams.ServiceTimeAct + "|1");

end
