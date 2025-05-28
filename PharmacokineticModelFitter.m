classdef PharmacokineticModelFitter < handle
    % PharmacokineticModelFitter    A class for accumulating the results of parameter estimation, as well as any 
    %                               relevant supporting data necessary for reproducing the result, in a structure 
    %                               suitable for use as a persistent record of the computation
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    %% Properties

    % Observable Properties (listeners receive notification of changes
    properties (SetObservable = true, AbortSet = true)
    end

    % Dependent properties
    properties (SetObservable = true, AbortSet = true, Dependent = true)
    end

    % Private Properties
    properties (Access = private)
        Results struct
    end

    % Private Computable Dependent Properties
    properties (Dependent = true, SetAccess = private)
    end

    %% Events
    events
    end

    %% Public Methods
    methods
        %% Constructors
        function this = PharmacokineticModelFitter(varargin)
            if(nargin == 0)
                this = PharmacokineticModelFitter.empty;
            elseif(nargin == 1)
                if(isa(varargin{1}, 'struct'))
                    this.Results = varargin{1};
                else
                    this = PharmacokineticModelFitter.empty;
                end
            elseif(nargin == 3)
                uiModel = varargin{1};
                roiColors = varargin{2};
                roiTissues = varargin{3};

                imageVolume = uiModel.ImageVolume;
                this.Results = struct;
                this.Results.PreContrastLiverT1 = uiModel.PreContrastLiverT1;
                this.Results.PreContrastSpleenT1 = uiModel.PreContrastSpleenT1;
                this.Results.PreContrastLiverR1 = uiModel.PreContrastLiverR1;
                this.Results.PreContrastSpleenR1 = uiModel.PreContrastSpleenR1;
                this.Results.UseBaselineAveraging = uiModel.UseBaselineAveraging;
                this.Results.LiverVolumeFractionES = uiModel.LiverVolumeFractionES;
                this.Results.SpleenVolumeFractionES = uiModel.SpleenVolumeFractionES;
                this.Results.UseMedianFilter = uiModel.UseMedianFilter;
                this.Results.Hematocrit = uiModel.Hematocrit;
                this.Results.LoadImageDataOptions = uiModel.LoadImageDataOptions;
                this.Results.KineticsModelOptions = uiModel.KineticsModelOptions;
                this.Results.SelectedSliceLocation = uiModel.SelectedSliceLocation;
                this.Results.TransitionStartIndex = uiModel.TransitionStartIndex;
                this.Results.TransitionEndIndex = uiModel.TransitionEndIndex;
                this.Results.FilterWindowStartSize = uiModel.FilterWindowStartSize;
                this.Results.FilterWindowEndSize = uiModel.FilterWindowEndSize;
                this.Results.theta = imageVolume.theta;
                this.Results.TR = imageVolume.TR;
                this.Results.TE = imageVolume.TE;
                this.Results.Time = imageVolume.Time;
                this.Results.AcquisitionZero = uiModel.AcquisitionZero;
                this.Results.roiColors = roiColors;
                this.Results.roiTissues = roiTissues;
                if(uiModel.ActivePharmacokineticModelInitialized && ...
                        isa(uiModel.ActivePharmacokineticModel, 'INumericallyIntegrable'))
                    this.Results.odeSolver = uiModel.ActivePharmacokineticModel.OdeSolver;
                end
                this.Results.kineticsModel = uiModel.KineticsModelOptions.KineticsModelName;
            else
                error('Too many arguments');
            end
        end

        %% Getters for Computable Dependent Properties

        %% Getters and Setters

        %% Other Public Methods

        %% GetESConcentrationFromSpleenReferenceRegion
        function C_ES = GetESConcentrationFromSpleenReferenceRegion(this, uiModel, spleenRois, ...
                    spleenRoiIndices, spleenRoi, spleenIndex)
            imageVolume = uiModel.ImageVolume;
            [spleenMask, spleenRoiSignalMu, spleenRoiSignalSigma, spleenRoiR1, C_ES, spleenRoiC_t, ...
                    spleenRoiAucTimeSeries] = imageVolume.ComputeSpleenSignals(spleenRoi);

            this.RecordSpleenRoiInformation(spleenRois, spleenRoiIndices, C_ES, spleenIndex, ...
                spleenMask, spleenRoiSignalMu, spleenRoiSignalSigma, spleenRoiR1, spleenRoiC_t, ...
                spleenRoiAucTimeSeries, spleenRoi.Color);
        end

        %% GetIntracellularConcentrationForLiver
        function liverC_i = GetIntracellularConcentrationForLiver(this, uiModel, nthLiverRoiIndices, ...
                liverRoi, C_ES)
            imageVolume = uiModel.ImageVolume;
            roiColor = liverRoi.Color;

            % Compute the mask, for the liver ROI, as well as the mean SI, std. dev. SI, R1 relaxation rate,
            % concentration in the intracellular space of liver, total tissue concentration in liver, and area
            % under the curve for liver
            [liverMask, liverRoiSignalMu, liverRoiSignalSigma, liverRoiR1, liverC_i, liverRoiC_t, ...
                liverRoiAucTimeSeries] = imageVolume.ComputeLiverSignals(liverRoi, C_ES);

            % Record intermediate results for persistence to disk
            this.RecordModelFittingPrerequisites(nthLiverRoiIndices, liverMask, liverRoiSignalMu, ...
                liverRoiSignalSigma, liverRoiR1, liverRoiC_t, liverRoiAucTimeSeries, C_ES, liverC_i, roiColor);
        end

        %% FitSelectedReferenceRegionModel
        function varargout = FitSelectedReferenceRegionModel(this, uiModel, nthLiverRoiIndices, roiIndex, ...
                time, C_ES, liverC_i)
            kmo = uiModel.KineticsModelOptions;
            switch kmo.KineticsModelName
                case 'Linear ODE'
                    [t, fittedCi, k1, k2] = uiModel.FitSelectedLinearOdeModel(time, C_ES, liverC_i);
                    this.RecordLinearOdeModelResults(nthLiverRoiIndices, roiIndex, k1, k2, t, fittedCi);
                    varargout{3} = k1;
                    varargout{4} = k2;
                case 'Michaelis-Menten ODE'
                    [t, fittedCi, k1, kM, Vmax] = uiModel.FitSelectedMichaelisMentenOdeModel(time, C_ES, liverC_i);
                    this.RecordMichaelisMentenOdeModelResults(nthLiverRoiIndices, roiIndex, k1, kM, Vmax, ...
                        t, fittedCi);
                    varargout{3} = k1;
                    varargout{4} = kM;
                    varargout{5} = Vmax;
                case 'TRISTAN'
                    [t, fittedCi, k1, k2] = uiModel.FitSelectedTristanModel(time, C_ES, liverC_i);
                    this.RecordTristanLinearModelResults(nthLiverRoiIndices, roiIndex, k1, k2, time, fittedCi);
                    varargout{3} = k1;
                    varargout{4} = k2;
                case 'Bi-exponential Algebraic'
                    [t, fittedCi, k1, kM, Vmax] = uiModel.FitSelectedBiexponentialModel(time, C_ES, liverC_i, ...
                        kmo.OdeSolver);
                    this.RecordBiexponentialModelResults(nthLiverRoiIndices, roiIndex, k1, kM, Vmax, t, fittedCi);
                    varargout{3} = k1;
                    varargout{4} = kM;
                    varargout{5} = Vmax;
                otherwise
                    error('Unknown kinetics model');
            end
            varargout{1} = t;
            varargout{2} = fittedCi;
        end

        %% FitSelectedVascularInputModel
        function varargout = FitSelectedVascularInputModel(this, uiModel, nthLiverRoiIndices, roiIndex, ...
                time, liverCt, Ca, Cv)
            kmo = uiModel.KineticsModelOptions;
            switch kmo.KineticsModelName
                case 'Georgiou'
                    [t, fittedCt, ki, kef, Fp, vecs, fa] = ...
                        uiModel.FitSelectedGeorgiouModel(time, liverCt, Ca, Cv);
                    this.RecordGeorgiouModelResults(...
                        nthLiverRoiIndices, roiIndex, ki, kef, Fp, vecs, fa, time, fittedCt);
                    varargout{3} = ki;
                    varargout{4} = kef;
                    varargout{5} = Fp;
                    varargout{6} = vecs;
                    varargout{7} = fa;
                case 'Berks'
                    [t, fittedCt, alphaPlus, alphaMinus, betaPlus, betaMinus, fa] = ...
                        uiModel.FitSelectedBerksModel(time, liverCt, Ca, Cv);
                    this.RecordBerksModelResults(...
                        nthLiverRoiIndices, roiIndex, alphaPlus, alphaMinus, betaPlus, betaMinus, fa, ...
                        time, fittedCt);
                    varargout{3} = alphaPlus;
                    varargout{4} = alphaMinus;
                    varargout{5} = betaPlus;
                    varargout{6} = betaMinus;
                    varargout{7} = fa;
                otherwise
                    error('Unknown kinetics model');
            end
            varargout{1} = t;
            varargout{2} = fittedCt;
        end

        %% RecordLiverRoiInformation
        function RecordLiverRoiInformation(this, liverRois, liverRoiIndices)
            this.Results.liverRois = liverRois;
            this.Results.liverRoiIdxs = liverRoiIndices;
        end

        %% RecordSpleenRoiInformation
        function RecordSpleenRoiInformation(this, spleenRois, spleenRoiIndices, C_ES, index, mask, signalMu, ...
                signalSigma, R1, C_t, AucTimeSeries, color)
            this.Results.spleenRois = spleenRois;
            this.Results.spleenRoiIndices = spleenRoiIndices;
            this.Results.spleenRoiC_ES = C_ES;
            this.Results.spleenIdx = index;
            this.Results.spleenMask = mask;
            this.Results.spleenRoiSignalMu = signalMu;
            this.Results.spleenRoiSignalSigma = signalSigma;
            this.Results.spleenRoiR1 = R1;
            this.Results.spleenRoiC_t = C_t;
            this.Results.spleenRoiAucTimeSeries = AucTimeSeries;
            this.Results.spleenRoiColor = color;
        end

        %% InitializeTemporalSeries
        function InitializeTemporalSeries(this, number)
            this.Results.temporalSeries = cell(1, number);
        end

        %% RecordModelFittingPrerequisites
        function RecordModelFittingPrerequisites(this, liverRoiIndex, mask, signalMu, signalSigma, R1, C_t, ...
                AucTimeSeries, C_ES, C_i, roiColor)
            this.Results.temporalSeries{liverRoiIndex}.liverMask = mask;
            this.Results.temporalSeries{liverRoiIndex}.liverRoiSignalMu = signalMu;
            this.Results.temporalSeries{liverRoiIndex}.liverRoiSignalSigma = signalSigma;
            this.Results.temporalSeries{liverRoiIndex}.liverRoiR1 = R1;
            this.Results.temporalSeries{liverRoiIndex}.C_t = C_t;
            this.Results.temporalSeries{liverRoiIndex}.liverRoiAucTimeSeries = AucTimeSeries;
            this.Results.temporalSeries{liverRoiIndex}.C_ES = C_ES;
            this.Results.temporalSeries{liverRoiIndex}.C_i = C_i;
            this.Results.temporalSeries{liverRoiIndex}.roiColor = roiColor;
        end

        %% RecordLinearOdeModelResults
        function RecordLinearOdeModelResults(this, liverRoiIndex, index, k1, k2, t, fittedCi)
            this.Results.temporalSeries{liverRoiIndex}.roiIdx = index;
            this.Results.temporalSeries{liverRoiIndex}.modelType = 'Linear ODE';
            this.Results.temporalSeries{liverRoiIndex}.solution.k1 = k1;
            this.Results.temporalSeries{liverRoiIndex}.solution.k2 = k2;
            this.Results.temporalSeries{liverRoiIndex}.solution.t = t;
            this.Results.temporalSeries{liverRoiIndex}.solution.y = fittedCi;
        end

        %% RecordMichaelisMentenOdeModelResults
        function RecordMichaelisMentenOdeModelResults(this, liverRoiIndex, index, k1, kM, Vmax, t, fittedCi)
            this.Results.temporalSeries{liverRoiIndex}.roiIdx = index;
            this.Results.temporalSeries{liverRoiIndex}.modelType = 'Michaelis-Menten ODE';
            this.Results.temporalSeries{liverRoiIndex}.solution.k1 = k1;
            this.Results.temporalSeries{liverRoiIndex}.solution.kM = kM;
            this.Results.temporalSeries{liverRoiIndex}.solution.Vmax = Vmax;
            this.Results.temporalSeries{liverRoiIndex}.solution.t = t;
            this.Results.temporalSeries{liverRoiIndex}.solution.y = fittedCi;
        end

        %% RecordTristanLinearModelResults
        function RecordTristanLinearModelResults(this, liverRoiIndex, index, k1, k2, t, fittedCi)
            this.Results.temporalSeries{liverRoiIndex}.roiIdx = index;
            this.Results.temporalSeries{liverRoiIndex}.modelType = 'TRISTAN';
            this.Results.temporalSeries{liverRoiIndex}.solution.k1 = k1;
            this.Results.temporalSeries{liverRoiIndex}.solution.k2 = k2;
            this.Results.temporalSeries{liverRoiIndex}.solution.t = t;
            this.Results.temporalSeries{liverRoiIndex}.solution.y = fittedCi;
        end

        %% RecordGeorgiouModelResults
        function RecordGeorgiouModelResults(this, liverRoiIndex, index, ki, kef, Fp, vecs, fa, t, fittedCt)
            this.Results.temporalSeries{liverRoiIndex}.roiIdx = index;
            this.Results.temporalSeries{liverRoiIndex}.modelType = 'Georgiou';
            this.Results.temporalSeries{liverRoiIndex}.solution.ki = ki;
            this.Results.temporalSeries{liverRoiIndex}.solution.kef = kef;
            this.Results.temporalSeries{liverRoiIndex}.solution.Fp = Fp;
            this.Results.temporalSeries{liverRoiIndex}.solution.vecs = vecs;
            this.Results.temporalSeries{liverRoiIndex}.solution.fa = fa;
            this.Results.temporalSeries{liverRoiIndex}.solution.t = t;
            this.Results.temporalSeries{liverRoiIndex}.solution.y = fittedCt;
        end

        %% RecordBerksModelResults
        function RecordBerksModelResults(this, liverRoiIndex, index, alphaPlus, alphaMinus, betaPlus, betaMinus, ...
                fa, t, fittedCt)
            this.Results.temporalSeries{liverRoiIndex}.roiIdx = index;
            this.Results.temporalSeries{liverRoiIndex}.modelType = 'Berks';
            this.Results.temporalSeries{liverRoiIndex}.solution.alphaPlus = alphaPlus;
            this.Results.temporalSeries{liverRoiIndex}.solution.alphaMinus = alphaMinus;
            this.Results.temporalSeries{liverRoiIndex}.solution.betaPlus = betaPlus;
            this.Results.temporalSeries{liverRoiIndex}.solution.betaMinus = betaMinus;
            this.Results.temporalSeries{liverRoiIndex}.solution.fa = fa;
            this.Results.temporalSeries{liverRoiIndex}.solution.t = t;
            this.Results.temporalSeries{liverRoiIndex}.solution.y = fittedCt;
        end

        %% RecordBiexponentialModelResults
        function RecordBiexponentialModelResults(this, liverRoiIndex, index, k1, kM, Vmax, t, fittedCi)
            this.Results.temporalSeries{liverRoiIndex}.roiIdx = index;
            this.Results.temporalSeries{liverRoiIndex}.modelType = 'Bi-exponential Algebraic ODE';
            this.Results.temporalSeries{liverRoiIndex}.solution.k1 = k1;
            this.Results.temporalSeries{liverRoiIndex}.solution.kM = kM;
            this.Results.temporalSeries{liverRoiIndex}.solution.Vmax = Vmax;
            this.Results.temporalSeries{liverRoiIndex}.solution.t = t;
            this.Results.temporalSeries{liverRoiIndex}.solution.y = fittedCi;
        end

        %% GetResultsAsStruct
        function results = GetResultsAsStruct(this)
            results = this.Results;
        end

        %% WriteResultsToDisk
        function writeSuccessful = WriteResultsToDisk(this, path, filename)
            if (filename ~= 0)
                results = this.Results;
                save(fullfile(path, filename), 'results', '-mat', '-v7.3');
                writeSuccessful = true;
            else
                writeSuccessful = false;
            end
        end
    end

    %% Private Methods
    methods (Access = private)
    end

    %% Static Methods
    methods (Static)
        %% GetFixedParametersFromResults
        function fixedParameters = GetFixedParametersFromResults(results, pkModel)
            fixedParameters.time = results.Time;
            fixedParameters.Ci = results.temporalSeries{1}.C_i;
            fixedParameters.Ces = results.temporalSeries{1}.C_ES;
            fixedParameters.acqZero = results.AcquisitionZero;
            if(isa(pkModel, 'PharmacokineticAlgebraicModel'))
                fixedParameters.veLiver = results.LiverVolumeFractionES;
            end
        end

        %% GetBestFunctionValue
        function bestf = GetBestFunctionValue(pkModel, fixedParameters, parameterVector)
            if(isa(pkModel, 'PharmacokineticAlgebraicModel'))
                bestf = pkModel.ComputeCost(pkModel.Solution(parameterVector, fixedParameters), ...
                    fixedParameters.Ci, parameterVector);
            else
                bestf = pkModel.ComputeCost(pkModel.Solution(parameterVector, 0, fixedParameters), ...
                    fixedParameters.Ci, parameterVector);
            end
        end
    end
end