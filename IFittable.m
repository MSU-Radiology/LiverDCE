classdef (Abstract) IFittable < handle
    % IFittable interface   Defines the common functionality shared by parameterized models that can be fit to 
    %                       empirical data. Such a model class or an abstract base class for a family of models should 
    %                       inherit this interface. 
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    %% Abstract properties
    properties (Abstract, SetAccess = protected, GetAccess = public)
        NumberOfFreeParameters(1,1) uint16
    end

    %% Abstract Dependent properties
    properties (Abstract, SetObservable = true, AbortSet = true, Dependent = true)
        FitOptions
        LockParameterToInitialEstimate
    end

    %% Abstract Protected, observable properties
    properties (Abstract, SetObservable = true, SetAccess = protected)
        FitOptionsInitialized
    end

    %% Protected properties
    properties (Abstract, Access = protected)
        ProtectedFitOptions
        ProtectedLockParameterToInitialEstimate
        ProtectedSavedWarningState
    end

    %% Abstract methods
    methods (Abstract, Access = public)
        evaluatedSignal = Evaluate(this, freeParameters, fixedParameters, varargin)

        modeledSignal = Solution(this, freeParameters, fixedParameters, varargin)

        cost = ComputeCost(this, modeledSignal, empiricalSignal, freeParameters)
    end

    %% Public methods
    methods (Access = public)
        %% FitToData
        function fittedParameters = FitToData(this, fixedParameters, varargin)
            arguments
                this (1,1) IFittable
                fixedParameters (1,1) struct
            end
            arguments (Repeating)
                varargin
            end
            fittedParameters = NaN;
            this.ResetReproduciblePseudorandomNumberSource(1, 'twister');
        end
    end

    %% Protected methods
    methods (Access = protected)
        %% SuppressSingularMatrixWarnings
        function SuppressSingularMatrixWarnings(this)
            this.ProtectedSavedWarningState = warning;
            warning('off', 'MATLAB:singularMatrix');
            warning('off', 'MATLAB:nearlySingularMatrix');
            if(this.FitOptions.UseParallelComputation)
                gcp();
                spmd
                    warning('off', 'MATLAB:singularMatrix');
                    warning('off', 'MATLAB:nearlySingularMatrix');
                end
            end
        end

        %% RestoreSupressedWarnings
        function RestoreSupressedWarnings(this)
            warning(this.ProtectedSavedWarningState);
            if(this.FitOptions.UseParallelComputation)
                gcp();
                spmd
                    warning('on', 'MATLAB:singularMatrix');
                    warning('on', 'MATLAB:nearlySingularMatrix');
                end
            end
        end

        %% ResetReproduciblePseudorandomNumberSource
        function ResetReproduciblePseudorandomNumberSource(this, seed, algorithm)
            rng(seed, algorithm);   % Reset random number generator on the main thread
            if(this.FitOptions.UseParallelComputation)
                gcp();
                spmd
                    rng(seed, algorithm);   % Reset random number generator on each worker
                end
            end
        end
    end
end