# A Model-Based System for On-Premises Software DefinedInfrastructure


RegressionScript.m will call CombinedSim.m which ONLY runs the SimEvents model
  RegressionScript.m has commented version of both patternsearch and particleswarm algorithms which can be modified
  This script also contains sections to enable sensitivity analysis of the dependent variables

DESAutomation.m will run for the number of iterations configured in MaxIterations, and call sdcommand.cmd to call the Vensim model during each iteration. This is a monolithic script >800 lines. 
