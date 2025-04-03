function simOut = runSimEvents(simIn)
% runSimEvents Runs the SimEvents simulation with the given input configuration.
%   simOut = runSimEvents(simIn)
%
% Input:
%   simIn  - A Simulink.SimulationInput object configured for the simulation.
%
% Output:
%   simOut - The simulation output structure.

    simOut = sim(simIn);
end
