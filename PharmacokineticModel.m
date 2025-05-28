classdef (Abstract) PharmacokineticModel < IFittable & matlab.mixin.Heterogeneous & handle
    % PharmacokineticModel		Abstract base class for the various PBPK models that can be fit to concentration vs. 
    %                           time data
    %
    % Copyright (C) 2025   Michigan State University
    % Author:  Matt Latourette

    %% Abstract properties
    properties (Abstract)
    end

    %% Read-only properties
    properties (SetAccess = protected, GetAccess = public)
        NumberOfFreeParameters
    end

    %% Dependent properties
    properties (SetObservable = true, AbortSet = true, Dependent = true)
        FitOptions
        LockParameterToInitialEstimate
    end

    %% Protected, observable properties
    properties (SetObservable = true, SetAccess = protected)
        FitOptionsInitialized
        LockParameterToInitialEstimateInitialized
    end

    %% Protected properties
    properties (Access = protected)
        ProtectedFitOptions
        ProtectedLockParameterToInitialEstimate
        ProtectedSavedWarningState
    end
    
    %% Public, abstract methods (must be implemented by subclasses)
    methods (Abstract, Access = public)
    end

    %% Public, concrete methods
    methods
        %% Constructors
        function this = PharmacokineticModel(varargin)
            if (nargin < 1)
                this.FitOptionsInitialized = false;
                this.FitOptions = [];
            else
                this.FitOptionsInitialized = true;
                this.FitOptions = varargin{1};
            end
            this.LockParameterToInitialEstimateInitialized = false;
            this.ProtectedLockParameterToInitialEstimate = [];
        end

        %% Getters and Setters
        function fitOptions = get.FitOptions(this)
            if(this.FitOptionsInitialized)
                fitOptions = this.ProtectedFitOptions;
            else
                fitOptions = [];
            end
        end

        function set.FitOptions(this, fitOptions)
            initialized = this.FitOptionsInitialized;
            if(~isempty(fitOptions) && ...
                    isa(fitOptions, 'KineticsPickerModel'))
                this.ProtectedFitOptions = fitOptions;
                if(~initialized)
                    this.FitOptionsInitialized = true;
                end
            end
        end

        function lockParameterToInitialEstimate = get.LockParameterToInitialEstimate(this)
            if(this.LockParameterToInitialEstimateInitialized)
                lockParameterToInitialEstimate = this.ProtectedLockParameterToInitialEstimate;
            else
                lockParameterToInitialEstimate = false(1, this.NumberOfFreeParameters);
            end
        end

        function set.LockParameterToInitialEstimate(this, lockParameterToInitialEstimate)
            initialized = this.LockParameterToInitialEstimateInitialized;
            if(~isempty(lockParameterToInitialEstimate) && islogical(lockParameterToInitialEstimate) && ...
                    size(lockParameterToInitialEstimate,2) == this.NumberOfFreeParameters)
                this.ProtectedLockParameterToInitialEstimate = lockParameterToInitialEstimate;
                if(~initialized)
                    this.LockParameterToInitialEstimateInitialized = true;
                end
            end
        end

        function number = get.NumberOfFreeParameters(this)
            number = this.NumberOfFreeParameters;
        end

        function set.NumberOfFreeParameters(this, numberOfFreeParameters)
            if(isscalar(numberOfFreeParameters) && isinteger(numberOfFreeParameters))
                this.NumberOfFreeParameters = uint8(numberOfFreeParameters);
            end
        end

        %% Public methods
        function cost = ComputeCost(this, modeledSignal, empiricalSignal, fittedParameters)
            arguments
                this (1,1) PharmacokineticModel
                modeledSignal (1,:) double
                empiricalSignal (1,:) double
                fittedParameters (1,:) double
            end

            m = length(modeledSignal);
            err = modeledSignal - empiricalSignal;

            lambda = this.FitOptions.Lambda;
            switch this.FitOptions.FitnessMeasure
                case 'LSQ'
                    % Least Squares
                    if (this.FitOptions.UseRegularization)
                        cost = 1/(2*m)*sqrt(err*err') + lambda/(2*m)*(fittedParameters*fittedParameters');
                    else
                        cost = 1/(2*m)*sqrt(err*err');
                    end
                case 'LAR'
                    % Least Absolute Residuals
                    if (this.FitOptions.UseRegularization)
                        cost = 1/(2*m)*sum(abs(err)) + lambda/(2*m)*(fittedParameters*fittedParameters');
                    else
                        cost = 1/(2*m)*sum(abs(err));
                    end
                case 'MSQ'
                    % Least Median of Squares
                    if (this.FitOptions.UseRegularization)
                        cost = 1/(2*m)*median(err.*err) + lambda/(2*m)*(fittedParameters*fittedParameters');
                    else
                        cost = 1/(2*m)*median(err.*err);
                    end
                case 'MAR'
                    % Least Median of Absolute Residuals
                    if (this.FitOptions.UseRegularization)
                        cost = 1/(2*m)*median(abs(err)) + lambda/(2*m)*(fittedParameters*fittedParameters');
                    else
                        cost = 1/(2*m)*median(abs(err));
                    end
                otherwise
                    error('Unkown fitness measure');
            end
        end

        function fixedParameters = GetFixedParameters(this, timeData, acqZero)
            if(isa(this, 'ITruncatable') && this.TruncateData)
                truncationIndex = this.TruncationIndex;
                fixedParameters.time = timeData(1:truncationIndex);
            else
                fixedParameters.time = timeData;
            end
            fixedParameters.acqZero = acqZero;
        end
    end

    %% Protected methods
    methods (Access = protected)
        %% GetScaledFitOptions
        function [initialEstimate, lb, ub, fitOptions, numberOfFreeParameters] = GetScaledFitOptions(this)
            arguments
                this (1,1) PharmacokineticModel
            end

            fitOptions = this.FitOptions;
            numberOfFreeParameters = this.NumberOfFreeParameters;

            [success, initialEstimate] = this.MatchParameterVectorSizeToFitModel(fitOptions.InitialEstimate);
            if(~success)
                error('Not enough initial parameter estimates for the selected model.');
            end
            [success, lb] = this.MatchBoundsVectorSizeToFitModel(fitOptions.LowerBound);
            if(~success)
                error('Not enough initial parameter estimates for the selected model.');
            end
            [success, ub] = this.MatchBoundsVectorSizeToFitModel(fitOptions.UpperBound);
            if(~success)
                error('Not enough initial parameter estimates for the selected model.');
            end

            [initialEstimate, lb, ub] = this.ScaleParametersAndBounds(initialEstimate, lb, ub);
        end

        %% ScaleParametersAndBounds
        function [scaledParameterEstimate, scaledLowerBound, scaledUpperBound] = ScaleParametersAndBounds(this, ...
                parameterEstimate, lowerBound, upperBound)
            scaledParameterEstimate = ScaleParameter(parameterEstimate);
            scaledLowerBound = ScaleParameter(lowerBound);
            scaledUpperBound = ScaleParameter(upperBound);
        end

        %% MatchParameterVectorSizeToFitModel
        function [matchSuccessful, sizeMatchedParameterVector] = MatchParameterVectorSizeToFitModel(...
                this, parameterVector)
            numberOfFreeParameters = this.NumberOfFreeParameters;
            parameterVectorSize = length(parameterVector);
            if (parameterVectorSize < numberOfFreeParameters)
                sizeMatchedParameterVector = parameterVector;
                matchSuccessful = false;
                return
            end
            sizeMatchedParameterVector = parameterVector(1:numberOfFreeParameters);
            matchSuccessful = true;
        end

        %% MatchBoundsVectorSizeToFitModel
        function [matchSuccessful, sizeMatchedBoundsVector] = MatchBoundsVectorSizeToFitModel(this, boundsVector)
            if(isempty(boundsVector))
                matchSuccessful = true;
                sizeMatchedBoundsVector = boundsVector;
                return
            end
            [matchSuccessful, sizeMatchedBoundsVector] = this.MatchParameterVectorSizeToFitModel(boundsVector);
        end
    end
end