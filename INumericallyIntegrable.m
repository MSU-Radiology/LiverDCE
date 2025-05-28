classdef (Abstract) INumericallyIntegrable < handle
    % INumericallyIntegrable    Interface representing the common data and functionality for a parameterized model
    %                           expressed in the form of an ordinary differential equation that may be solved 
    %                           numerically using one of MATLAB's ODE solvers
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    properties
        OdeSolver(1,1) function_handle = @(varargin) eval('return') %#ok<EVLCS> 
    end

    %% Abstract methods
    methods (Abstract, Access = public)
    end

    %% Concrete methods
    methods (Access = public)
        % function [t, y] = SolveOde(this, fitModel, freeParameters, fixedParameters, tspan, initialConditions, ...
        %         solverOptions)
        %     % This code is untested
        %     [t, y] = this.OdeSolver(@(t,y) fitModel.Evaluate(ScaleParameter(freeParameters), fixedParameters, t, y), ...
        %         tspan, initialConditions, solverOptions);
        % end

        % Usage would be like:
        %   [t, y] = pkModel.SolveOde(pkModel, freeParameters, fixedParameters, ...
        %       [fixedParameters.time(fixedParameters.acqZero) fixedParameters.time(end)], 0, []);
    end

    %% Static methods
    methods (Static, Access = protected)
    end
end