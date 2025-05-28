classdef MainModel < handle
    % MainModel     Model class (MVC pattern) for LiverDCE's main GUI window
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    %% Properties
    
    % Observable Properties (listeners receive notification of changes)
    properties (SetObservable = true, AbortSet = true)
        PreContrastLiverT1(1,1) double
        PreContrastSpleenT1(1,1) double
        PreContrastKidneyT1(1,1) double
        PreContrastArterialBloodT1(1,1) double
        PreContrastVenousBloodT1(1,1) double
        PreContrastMuscleT1(1,1) double
        PreContrastSpinalCordT1(1,1) double
        PreContrastFatT1(1,1) double
        UseBaselineAveraging(1,1) logical
        AcquisitionZero(1,1) uint16
        LiverVolumeFractionES(1,1) double
        SpleenVolumeFractionES(1,1) double
        KidneyVolumeFractionES(1,1) double
        DisplayRoi3DMaskThresholded(1,1) logical
        RoiStatsVisibility(1,1) logical
        UseMedianFilter(1,1) logical
        Hematocrit(1,1) double
        ImageVolume(1,1) DynamicImageVolume = DynamicMrImageVolume()
        ExportSignalsFilename char
    end

    properties (SetObservable = true, AbortSet = true, Hidden = true)
        SelectedImageTypeToDisplay(1,1) ImageType = ImageType.DynamicContrastEnhanced;
        SelectedRoi3DMaskToDisplay(1,1) TissueType = TissueType.AbdominalAorta;
        SelectedRoiDimensionality(1,1) RoiDimensionality = RoiDimensionality.TwoDimensional;
    end
    
    % Dependent properties
    properties (SetObservable = true, AbortSet = true, Dependent = true)
        LoadImageDataOptions LoadImagesDialogModel
        KineticsModelOptions KineticsPickerModel
        ExportProjectionImagesOptions ExportProjectionImagesDialogModel
        SelectedRoi3DMaskAlpha(1,1) double
        SelectedSliceLocation(1,1) uint16
        TransitionStartIndex(1,1) double
        TransitionEndIndex(1,1) double
        FilterWindowStartSize(1,1) uint16
        FilterWindowEndSize(1,1) uint16
        ActivePharmacokineticModel PharmacokineticModel
        DriftCorrectionOptions DriftCorrectionDialogModel
        ThreeDimensionalRoiOptions LoadRoi3DsDialogModel
    end
    
    properties (SetObservable = true)
    end
    
    properties (SetObservable = true, SetAccess = private)
        LoadImageDataOptionsInitialized(1,1) logical
        KineticsModelOptionsInitialized(1,1) logical
        ExportProjectionImagesOptionsInitialized(1,1) logical
        ActivePharmacokineticModelInitialized(1,1) logical
        DriftCorrectionOptionsInitialized(1,1) logical
        ThreeDimensionalRoiOptionsInitialized(1,1) logical
    end
    
    % Private Properties
    properties (Access = private)
        PrivateLoadImageDataOptions LoadImagesDialogModel
        PrivateKineticsModelOptions KineticsPickerModel
        PrivateExportProjectionImagesOptions ExportProjectionImagesDialogModel
        PrivateSelectedRoi3DMaskAlpha(1,1) double = 0.4;
        PrivateSelectedSliceLocation(1,1) uint16
        PrivateTransitionStartIndex(1,1) double
        PrivateTransitionEndIndex(1,1) double
        PrivateFilterWindowStartSize(1,1) uint16
        PrivateFilterWindowEndSize(1,1) uint16
        PrivateActivePharmacokineticModel PharmacokineticModel
        PrivateDriftCorrectionOptions DriftCorrectionDialogModel
        PrivateThreeDimensionalRoiOptions LoadRoi3DsDialogModel
    end
    
    % Private Computable Dependent Properties
    properties (Dependent = true, SetAccess = private)
        PreContrastLiverR1          % pre-contrast R1 in s^-1 units
        PreContrastSpleenR1         % pre-contrast R1 in s^-1 units
        PreContrastKidneyR1         % pre-contrast R1 in s^-1 units
        PreContrastArterialBloodR1  % pre-contrast R1 in s^-1 units
        PreContrastVenousBloodR1    % pre-contrast R1 in s^-1 units
        PreContrastMuscleR1         % pre-contrast R1 in s^-1 units
        PreContrastSpinalCordR1     % pre-contrast R1 in s^-1 units
        PreContrastFatR1            % pre-contrast R1 in s^-1 units
    end
    
    %% Events
    events
        ImageLoad
        SetDefaultWindowWidthAndLevelRequest
        ResetZoomAndPanRequest
        NumberOfSlicesChanged
        ContrastAgentChanged
        ThreeDimensionalRoiOptionsChanged
        LoadImageDataRequest
        KineticsModelOptionsRequest
        EstimateModelParametersRequest
        ImportRoi3DsRequest
        CorrectSignalDriftRequest
        RoiSignalPlotRequest
        RoiR1PlotRequest
        RoiAreaUnderCurvePlotRequest
        RoiTotalConcentrationPlotRequest
        RoiESConcentrationPlotRequest
        RoiIntracellularConcentrationPlotRequest
        ComputeVolumeFractionESRequest
        ExportSignalsFilenameRequest
    end
    
    %% Public Class Methods
    methods
        %% Constructors
        function this = MainModel()
            % Constructor
            this.LoadImageDataOptionsInitialized = false;
            this.KineticsModelOptionsInitialized = false;
            this.ExportProjectionImagesOptionsInitialized = false;
            this.ActivePharmacokineticModelInitialized = false;
            this.DriftCorrectionOptionsInitialized = false;
            this.ThreeDimensionalRoiOptionsInitialized = false;
            this.UseBaselineAveraging = true;
            this.AcquisitionZero = uint16(1);
            % The default extracellular space volume fraction comes from
            % Ulloa et al, 2013, NMR Biomed paper and is for rat liver
            this.LiverVolumeFractionES = 0.23;
            this.SpleenVolumeFractionES = 0.43;
            this.KidneyVolumeFractionES = 0.5;
            this.UseMedianFilter = false;
            this.TransitionStartIndex = 10.0;
            this.TransitionEndIndex = 50.0;
            this.FilterWindowStartSize = uint16(3);
            this.FilterWindowEndSize = uint16(7);
            this.Hematocrit = 0.45;
            this.SelectedSliceLocation = uint16(1);
            this.PreContrastLiverT1 = 1360.77;
            this.PreContrastSpleenT1 = 1783.64;
            this.PreContrastKidneyT1 = 1778.28;
            this.PreContrastArterialBloodT1 = 2300;
            this.PreContrastVenousBloodT1 = 2300;
            this.PreContrastMuscleT1 = 0;
            this.PreContrastSpinalCordT1 = 0;
            this.PreContrastFatT1 = 0;
            this.DisplayRoi3DMaskThresholded = true;   % display the "refined" ROI by default
            this.RoiStatsVisibility = false;
            this.ImageVolume = DynamicMrImageVolume(this);
            this.LoadImageDataOptions = LoadImagesDialogModel.empty;
            this.KineticsModelOptions = KineticsPickerModel.empty;
            this.ExportProjectionImagesOptions = ExportProjectionImagesDialogModel.empty;
            this.ActivePharmacokineticModel = PharmacokineticModel.empty;
            this.DriftCorrectionOptions = DriftCorrectionDialogModel.empty;
            this.ThreeDimensionalRoiOptions = LoadRoi3DsDialogModel.empty;
            this.ExportSignalsFilename = [];
        end

        %% Getters for Computable Properties
        function liverR1_0 = get.PreContrastLiverR1(this)
            % compute pre-contrast R1 in s^-1 units from T1 in ms
            liverR1_0 = 1000.0./this.PreContrastLiverT1;
        end

        function spleenR1_0 = get.PreContrastSpleenR1(this)
            % compute pre-contrast R1 in s^-1 units from T1 in ms
            spleenR1_0 = 1000.0./this.PreContrastSpleenT1;
        end

        function kidneyR1_0 = get.PreContrastKidneyR1(this)
            % compute pre-contrast R1 in s^-1 units from T1 in ms
            kidneyR1_0 = 1000.0./this.PreContrastKidneyT1;
        end

        function arterialBloodR1_0 = get.PreContrastArterialBloodR1(this)
            % compute pre-contrast R1 in s^-1 units from T1 in ms
            arterialBloodR1_0 = 1000.0./this.PreContrastArterialBloodT1;
        end

        function venousBloodR1_0 = get.PreContrastVenousBloodR1(this)
            % compute pre-contrast R1 in s^-1 units from T1 in ms
            venousBloodR1_0 = 1000.0./this.PreContrastVenousBloodT1;
        end

        function muscleR1_0 = get.PreContrastMuscleR1(this)
            % compute pre-contrast R1 in s^-1 units from T1 in ms
            muscleR1_0 = 1000.0/this.PreContrastMuscleT1;
        end

        function spinalCordR1_0 = get.PreContrastSpinalCordR1(this)
            % compute pre-contrast R1 in s^-1 units from T1 in ms
            spinalCordR1_0 = 1000.0/this.PreContrastSpinalCordT1;
        end

        function fatR1_0 = get.PreContrastFatR1(this)
            % compute pre-contrast R1 in s^-1 units from T1 in ms
            fatR1_0 = 1000.0/this.PreContrastFatT1;
        end

        function dataOptions = get.LoadImageDataOptions(this)
            if(this.LoadImageDataOptionsInitialized)
                dataOptions = this.PrivateLoadImageDataOptions;
            else
                dataOptions = LoadImagesDialogModel.empty;
            end
        end

        function set.LoadImageDataOptions(this, dataOptions)
            arguments
                this (1,1) MainModel
                dataOptions LoadImagesDialogModel
            end
            imageStackLoaded = false;
            if(~isempty(dataOptions))
                previousOptions = this.PrivateLoadImageDataOptions;
                this.PrivateLoadImageDataOptions = dataOptions;
                this.LoadImageDataOptionsInitialized = true;

                if(dataOptions.ImagesToLoadChanged(previousOptions) && dataOptions.IsReadyToLoadImages)
                    imageStackLoaded = this.ImageVolume.LoadImageDataSet(dataOptions);
                end
                this.UpdateOnLoadImageDataOptionsChanged(dataOptions, previousOptions);
            end

            if(imageStackLoaded)
                sliceLocation = this.SelectedSliceLocation;
                newSliceLocation = this.ConstrainSliceLocationToRange(sliceLocation);
                this.SelectedSliceLocation = newSliceLocation;

                % The setter method does not get called if the newSliceLocation is the same as the existing value in
                % this.SelectedSliceLocation, so the call to UpdateImageStack is duplicated here to ensure it gets
                % called when images are loaded without changing the existing SelectedSliceLocation
                this.ImageVolume.UpdateImageStack();
                notify(this, 'SetDefaultWindowWidthAndLevelRequest');
                notify(this, 'ResetZoomAndPanRequest')
            end
        end

        function kineticsModelOptions = get.KineticsModelOptions(this)
            if(this.KineticsModelOptionsInitialized)
                kineticsModelOptions = this.PrivateKineticsModelOptions;
            else
                kineticsModelOptions = KineticsPickerModel.empty;
            end
        end

        function set.KineticsModelOptions(this, kineticsModelOptions)
            arguments
                this(1,1) MainModel
                kineticsModelOptions KineticsPickerModel
            end
            initialized = this.KineticsModelOptionsInitialized;
            if(~isempty(kineticsModelOptions))
                this.PrivateKineticsModelOptions = kineticsModelOptions;
                if(~initialized)
                    this.KineticsModelOptionsInitialized = true;
                end
            end
        end

        function exportProjectionImagesOptions = get.ExportProjectionImagesOptions(this)
            if(this.ExportProjectionImagesOptionsInitialized)
                exportProjectionImagesOptions = this.PrivateExportProjectionImagesOptions;
            else
                exportProjectionImagesOptions = ExportProjectionImagesDialogModel.empty;
            end
        end

        function set.ExportProjectionImagesOptions(this, exportProjectionImagesOptions)
            arguments
                this (1,1) MainModel
                exportProjectionImagesOptions ExportProjectionImagesDialogModel
            end
            initialized = this.ExportProjectionImagesOptionsInitialized;
            if(~isempty(exportProjectionImagesOptions))
                this.PrivateExportProjectionImagesOptions = exportProjectionImagesOptions;
                if(~initialized)
                    this.ExportProjectionImagesOptionsInitialized = true;
                end
            end
        end

        function pkModel = get.ActivePharmacokineticModel(this)
            if(this.ActivePharmacokineticModelInitialized)
                pkModel = this.PrivateActivePharmacokineticModel;
            else
                pkModel = PharmacokineticModel.empty;
            end
        end

        function set.ActivePharmacokineticModel(this, activePharmacokineticModel)
            arguments
                this (1,1) MainModel
                activePharmacokineticModel PharmacokineticModel
            end
            initialized = this.ActivePharmacokineticModelInitialized;
            if(~isempty(activePharmacokineticModel))
                this.PrivateActivePharmacokineticModel = activePharmacokineticModel;
                if(~initialized)
                    this.ActivePharmacokineticModelInitialized = true;
                end
            end
        end

        function driftCorrectionOptions = get.DriftCorrectionOptions(this)
            if(this.DriftCorrectionOptionsInitialized)
                driftCorrectionOptions = this.PrivateDriftCorrectionOptions;
            else
                driftCorrectionOptions = DriftCorrectionDialogModel.empty;
            end
        end

        function set.DriftCorrectionOptions(this, driftCorrectionOptions)
            arguments
                this (1,1) MainModel
                driftCorrectionOptions DriftCorrectionDialogModel
            end
            if(~isempty(driftCorrectionOptions))
                previousOptions = this.PrivateDriftCorrectionOptions;
                this.PrivateDriftCorrectionOptions = driftCorrectionOptions;
                this.DriftCorrectionOptionsInitialized = true;
                this.UpdateOnDriftCorrectionOptionsChanged(driftCorrectionOptions, previousOptions);
            end
        end

        function threeDimensionalRoiOptions = get.ThreeDimensionalRoiOptions(this)
            if(this.ThreeDimensionalRoiOptionsInitialized)
                threeDimensionalRoiOptions = this.PrivateThreeDimensionalRoiOptions;
            else
                threeDimensionalRoiOptions = LoadRoi3DsDialogModel.empty;
            end
        end

        function set.ThreeDimensionalRoiOptions(this, threeDimensionalRoiOptions)
            arguments
                this (1,1) MainModel
                threeDimensionalRoiOptions LoadRoi3DsDialogModel
            end
            if(~isempty(threeDimensionalRoiOptions))
                previousOptions = this.PrivateThreeDimensionalRoiOptions;
                this.PrivateThreeDimensionalRoiOptions = threeDimensionalRoiOptions;
                this.ThreeDimensionalRoiOptionsInitialized = true;
                this.UpdateOnThreeDimensionalRoiOptionsChanged(threeDimensionalRoiOptions, previousOptions);
            end
        end

        function sliceLocation = get.SelectedSliceLocation(this)
            sliceLocation = this.PrivateSelectedSliceLocation;
        end

        function set.SelectedSliceLocation(this, sliceLocation)
            currentSliceLocation = this.SelectedSliceLocation;
            newSliceLocation = this.ConstrainSliceLocationToRange(sliceLocation);
            if(newSliceLocation ~= currentSliceLocation)
                this.PrivateSelectedSliceLocation = newSliceLocation;
            end
            this.ImageVolume.UpdateImageStack();
        end

        function transitionStartIndex = get.TransitionStartIndex(this)
            transitionStartIndex = this.PrivateTransitionStartIndex;
        end

        function set.TransitionStartIndex(this, index)
            currentStartIndex = this.TransitionStartIndex;
            if(index ~= currentStartIndex)
                this.PrivateTransitionStartIndex = index;
            end

            if(this.UseMedianFilter)
                % TODO: Ideally, the application should remember what plot is currently being displayed and update
                % that specific plot instead of always updating the signal vs. time plot
                this.UpdateRoiSignalVsTimePlot();
            end
        end

        function transitionEndIndex = get.TransitionEndIndex(this)
            transitionEndIndex = this.PrivateTransitionEndIndex;
        end

        function set.TransitionEndIndex(this, index)
            currentEndIndex = this.TransitionEndIndex;
            if(index ~= currentEndIndex)
                this.PrivateTransitionEndIndex = index;
            end

            if(this.UseMedianFilter)
                % TODO: Ideally, the application should remember what plot is currently being displayed and update
                % that specific plot instead of always updating the signal vs. time plot
                this.UpdateRoiSignalVsTimePlot();
            end
        end

        function filterWindowStartSize = get.FilterWindowStartSize(this)
            filterWindowStartSize = this.PrivateFilterWindowStartSize;
        end

        function set.FilterWindowStartSize(this, filterWindowSize)
            currentFilterWindowStartSize = this.FilterWindowStartSize;
            newFilterWindowStartSize = this.ConstrainFilterWindowSizeToRange(filterWindowSize);
            if(newFilterWindowStartSize ~= currentFilterWindowStartSize)
                this.PrivateFilterWindowStartSize = newFilterWindowStartSize;
            end

            if(this.UseMedianFilter)
                % TODO: Ideally, the application should remember what plot is currently being displayed and update
                % that specific plot instead of always updating the signal vs. time plot
                this.UpdateRoiSignalVsTimePlot();
            end
        end

        function filterWindowSize = get.FilterWindowEndSize(this)
            filterWindowSize = this.PrivateFilterWindowEndSize;
        end

        function set.FilterWindowEndSize(this, filterWindowSize)
            currentFilterWindowEndSize = this.FilterWindowEndSize;
            newFilterWindowEndSize = this.ConstrainFilterWindowSizeToRange(filterWindowSize);
            if(newFilterWindowEndSize ~= currentFilterWindowEndSize)
                this.PrivateFilterWindowEndSize = newFilterWindowEndSize;
            end

            if(this.UseMedianFilter)
                % TODO: Ideally, the application should remember what plot is currently being displayed and update
                % that specific plot instead of always updating the signal vs. time plot
                this.UpdateRoiSignalVsTimePlot();
            end
        end

        %% Getters and Setters
        function bool = get.LoadImageDataOptionsInitialized(this)
            bool = this.LoadImageDataOptionsInitialized;
        end

        function set.LoadImageDataOptionsInitialized(this, value)
            this.LoadImageDataOptionsInitialized = value;
        end

        function bool = get.DriftCorrectionOptionsInitialized(this)
            bool = this.DriftCorrectionOptionsInitialized;
        end

        function set.DriftCorrectionOptionsInitialized(this, value)
            this.DriftCorrectionOptionsInitialized = value;
        end

        function bool = get.ExportProjectionImagesOptionsInitialized(this)
            bool = this.ExportProjectionImagesOptionsInitialized;
        end

        function set.ExportProjectionImagesOptionsInitialized(this, value)
            this.ExportProjectionImagesOptionsInitialized = value;
        end

        function imageType = get.SelectedImageTypeToDisplay(this)
            imageType = this.SelectedImageTypeToDisplay;
        end

        function set.SelectedImageTypeToDisplay(this, value)
            this.SelectedImageTypeToDisplay = value;
        end

        function selectedRoi3DMaskToDisplay = get.SelectedRoi3DMaskToDisplay(this)
            selectedRoi3DMaskToDisplay = this.SelectedRoi3DMaskToDisplay;
        end

        function set.SelectedRoi3DMaskToDisplay(this, value)
            this.SelectedRoi3DMaskToDisplay = value;
        end

        function alpha = get.SelectedRoi3DMaskAlpha(this)
            alpha = this.PrivateSelectedRoi3DMaskAlpha;
        end

        function set.SelectedRoi3DMaskAlpha(this, alpha)
            arguments
                this(1,1) MainModel
                alpha(1,1) {mustBeNumeric}
            end
            currentAlpha = this.SelectedRoi3DMaskAlpha;
            newAlpha = this.ConstrainAlphaToRange(alpha);
            if(newAlpha ~= currentAlpha)
                this.PrivateSelectedRoi3DMaskAlpha = newAlpha;
            end
        end

        function roiDimensionality = get.SelectedRoiDimensionality(this)
            roiDimensionality = this.SelectedRoiDimensionality;
        end

        function set.SelectedRoiDimensionality(this, value)
            arguments
                this(1,1) MainModel
                value(1,1) RoiDimensionality
            end
            this.SelectedRoiDimensionality =  value;
        end

        function preContrastT1 = get.PreContrastLiverT1(this)
            preContrastT1 = this.PreContrastLiverT1;
        end

        function set.PreContrastLiverT1(this, preContrastT1)
            if(IsNonNegative(preContrastT1))
                this.PreContrastLiverT1 = preContrastT1;
            end
        end

        function preContrastT1 = get.PreContrastSpleenT1(this)
            preContrastT1 = this.PreContrastSpleenT1;
        end

        function set.PreContrastSpleenT1(this, preContrastT1)
            if(IsNonNegative(preContrastT1))
                this.PreContrastSpleenT1 = preContrastT1;
            end
        end

        function preContrastT1 = get.PreContrastKidneyT1(this)
            preContrastT1 = this.PreContrastKidneyT1;
        end

        function set.PreContrastKidneyT1(this, preContrastT1)
            if(IsNonNegative(preContrastT1))
                this.PreContrastKidneyT1 = preContrastT1;
            end
        end

        function preContrastT1 = get.PreContrastArterialBloodT1(this)
            preContrastT1 = this.PreContrastArterialBloodT1;
        end

        function set.PreContrastArterialBloodT1(this, preContrastT1)
            if(IsNonNegative(preContrastT1))
                this.PreContrastArterialBloodT1 = preContrastT1;
            end
        end

        function preContrastT1 = get.PreContrastVenousBloodT1(this)
            preContrastT1 = this.PreContrastVenousBloodT1;
        end

        function set.PreContrastVenousBloodT1(this, preContrastT1)
            if(IsNonNegative(preContrastT1))
                this.PreContrastVenousBloodT1 = preContrastT1;
            end
        end

        function preContrastT1 = get.PreContrastMuscleT1(this)
            preContrastT1 = this.PreContrastMuscleT1;
        end

        function set.PreContrastMuscleT1(this, preContrastT1)
            if(IsNonNegative(preContrastT1))
                this.PreContrastMuscleT1 = preContrastT1;
            end
        end

        function preContrastT1 = get.PreContrastSpinalCordT1(this)
            preContrastT1 = this.PreContrastSpinalCordT1;
        end

        function set.PreContrastSpinalCordT1(this, preContrastT1)
            if(IsNonNegative(preContrastT1))
                this.PreContrastSpinalCordT1 = preContrastT1;
            end
        end

        function preContrastT1 = get.PreContrastFatT1(this)
            preContrastT1 = this.PreContrastFatT1;
        end

        function set.PreContrastFatT1(this, preContrastT1)
            if(IsNonNegative(preContrastT1))
                this.PreContrastFatT1 = preContrastT1;
            end
        end

        function acqZero = get.AcquisitionZero(this)
            acqZero = this.AcquisitionZero;
        end

        function set.AcquisitionZero(this, acqZero)
            if(isnumeric(acqZero) && acqZero >= 1)
                this.AcquisitionZero = acqZero;
            end

            % TODO: Ideally, the application should remember what plot is currently being displayed and update that
            % specific plot instead of always updating the signal vs. time plot
            this.UpdateRoiSignalVsTimePlot();
        end

        function veLiver = get.LiverVolumeFractionES(this)
            veLiver = this.LiverVolumeFractionES;
        end

        function set.LiverVolumeFractionES(this, volFracES)
            if(IsBetweenZeroAndOne(volFracES))
                this.LiverVolumeFractionES = volFracES;
            end
        end

        function veSpleen = get.SpleenVolumeFractionES(this)
            veSpleen = this.SpleenVolumeFractionES;
        end

        function set.SpleenVolumeFractionES(this, volFracES)
            if(IsBetweenZeroAndOne(volFracES))
                this.SpleenVolumeFractionES = volFracES;
            end
        end

        function veKidney = get.KidneyVolumeFractionES(this)
            veKidney = this.KidneyVolumeFractionES;
        end

        function set.KidneyVolumeFractionES(this, volFracES)
            if(IsBetweenZeroAndOne(volFracES))
                this.KidneyVolumeFractionES = volFracES;
            end
        end

        function bool = get.UseMedianFilter(this)
            bool = this.UseMedianFilter;
        end

        function set.UseMedianFilter(this, value)
            if(islogical(value))
                this.UseMedianFilter = value;
            end

            % TODO: Ideally, the application should remember what plot is currently being displayed and update that
            % specific plot instead of always updating the signal vs. time plot
            this.UpdateRoiSignalVsTimePlot();
        end

        function bool = get.UseBaselineAveraging(this)
            bool = this.UseBaselineAveraging;
        end

        function set.UseBaselineAveraging(this, value)
            if(islogical(value))
                this.UseBaselineAveraging = value;
            end

            % TODO: Ideally, the application should remember what plot is currently being displayed and update that
            % specific plot instead of always updating the signal vs. time plot
            this.UpdateRoiSignalVsTimePlot();
        end

        function bool = get.DisplayRoi3DMaskThresholded(this)
            bool = this.DisplayRoi3DMaskThresholded;
        end

        function set.DisplayRoi3DMaskThresholded(this, value)
            if(islogical(value))
                this.DisplayRoi3DMaskThresholded = value;
            end
        end

        function hematocrit = get.Hematocrit(this)
            hematocrit = this.Hematocrit;
        end

        function set.Hematocrit(this, hematocrit)
            if(IsBetweenZeroAndOne(hematocrit))
                this.Hematocrit = hematocrit;
            end
        end

        function filename = get.ExportSignalsFilename(this)
            filename = this.ExportSignalsFilename;
        end

        function set.ExportSignalsFilename(this, filename)
            % Note: We're not doing any validation besides making sure the input is a char array
            if(ischar(filename))
                this.ExportSignalsFilename = filename;
            end
        end

        %% Other Class Methods

        %% GetRoiList3D
        function [success, roiList] = GetRoiList3D(this)
            success = false;
            if(~this.ThreeDimensionalRoiOptionsInitialized)
                roiList = GroundTruthFileRegionOfInterest.empty;
                return
            end
            roiList = this.ThreeDimensionalRoiOptions.RoiList;
            success = true;
        end

        %% GetRoi3DByTissueType
        function tissueRoiList = GetRoi3DByTissueType(this, tissueType)
            arguments
                this(1,1) MainModel
                tissueType(1,1) TissueType
            end

            [success, roiList] = this.GetRoiList3D();
            if(~success)
                tissueRoiList = GroundTruthFileRegionOfInterest.empty;
                return
            end
            tissueRoiList = RegionOfInterest3D.FilterByTissueType(roiList, tissueType);
        end

        %% GetRoi3Ds
        function roiList = GetRoi3Ds(this, tissueCategory, signalType)
            arguments
                this (1,1) MainModel
                tissueCategory {mustBeTextScalar}
                signalType (1,1) SignalType = SignalType.SignalIntensity;
            end
            
            [success, roiList] = this.GetRoiList3D();
            if(~success)
                return
            end
            roiList = RegionOfInterest3D.FilterByTissueCategory(roiList, tissueCategory);
            roiList = RegionOfInterest3D.FilterBySignalType(roiList, signalType);
        end

        %% ComputeSignalToPlotFromRoi3D
        function signal = ComputeSignalToPlotFromRoi3D(this, tissueType, meanSI, signalType, varargin)
            arguments
                this (1,1) MainModel
                tissueType TissueType
                meanSI {mustBeNumeric}
                signalType SignalType
            end
            arguments (Repeating)
                varargin {mustBeNumeric}
            end
            if (nargin == 5)
                C_ES = varargin{1};
            end

            imageVolume = this.ImageVolume;
            switch signalType
                case SignalType.R1Relaxation
                    R1_0 = this.GetPreContrastR1(tissueType);
                    signal = imageVolume.GetR1FromMrSignal(meanSI, R1_0);
                case SignalType.AreaUnderCurve
                    acqZero = this.AcquisitionZero;
                    signal = imageVolume.GetAucTimeSeriesFromSignal(meanSI, tissueType, acqZero);
                case SignalType.TotalConcentration
                    signal = imageVolume.GetTotalConcentrationFromSignal(meanSI, tissueType);
                case SignalType.EESConcentration
                    signal = imageVolume.GetESConcentrationFromMrSignal(meanSI, tissueType);
                case SignalType.IntracellularConcentration
                    signal = imageVolume.GetIntracellularConcentrationFromMrSignal(meanSI, tissueType, C_ES);
                otherwise
                    error('Unknown plot type');
            end
        end

        %% GetSignalsFromRoi3Ds
        function signals = GetSignalsFromRoi3Ds(this, roiList, imageVolume, signalType, varargin)
            arguments
                this (1,1) MainModel
                roiList 
                imageVolume (1,1) DynamicImageVolume
                signalType SignalType
            end
            arguments (Repeating)
                varargin {mustBeNumeric}
            end

            numberOfRois = length(roiList);
            signals = cell(1, numberOfRois);
            for roiIndex = 1:numberOfRois
                roi = roiList(roiIndex);
                [unfilteredMeanSI, ~, ~, ~] = imageVolume.GetSignalFrom3DRegion(roi);
                meanSI = this.ApplyFiltersToSignal(unfilteredMeanSI);
                signals{roiIndex}.Data = this.ComputeSignalToPlotFromRoi3D(roi.Tissue, meanSI, ...
                    signalType, varargin{:});
                signals{roiIndex}.Color = roi.Color;
            end
        end

        %% ComputeSignalToPlot
        function signal = ComputeSignalToPlot(model, tissueType, meanSI, signalType, varargin)
            arguments
                model (1,1) MainModel
                tissueType TissueType
                meanSI {mustBeNumeric}
                signalType SignalType
            end
            arguments (Repeating)
                varargin {mustBeNumeric}
            end
            if (nargin == 5)
                C_ES = varargin{1};
            end

            imageVolume = model.ImageVolume;
            switch signalType
                case SignalType.R1Relaxation
                    R1_0 = model.GetPreContrastR1(tissueType);
                    signal = imageVolume.GetR1FromMrSignal(meanSI, R1_0);
                case SignalType.AreaUnderCurve
                    acqZero = model.AcquisitionZero;
                    signal = imageVolume.GetAucTimeSeriesFromSignal(meanSI, tissueType, acqZero);
                case SignalType.TotalConcentration
                    signal = imageVolume.GetTotalConcentrationFromSignal(meanSI, tissueType);
                case SignalType.EESConcentration
                    signal = imageVolume.GetESConcentrationFromMrSignal(meanSI, tissueType);
                case SignalType.IntracellularConcentration
                    signal = imageVolume.GetIntracellularConcentrationFromMrSignal(meanSI, tissueType, C_ES);
                otherwise
                    error('Unknown plot type');
            end
        end

        %% FitLiverReferenceRegionModel
        function varargout = FitLiverReferenceRegionModel(this, roiIndex, liverRoi, time, nthLiverRoiIndices, ...
                C_ES, kmo, modelFitter)
            liverC_i = modelFitter.GetIntracellularConcentrationForLiver(this, nthLiverRoiIndices, ...
                liverRoi, C_ES);

        	varargout = cell(1, nargout);
            for nthArgOut = 1:(nargout-1)
                varargout{nthArgOut+1} = NaN;
            end
            varargout{1} = liverC_i;

            if(strcmpi(kmo.KineticsModelName, 'TRISTAN'))
                [t, fittedCi, k1, k2] = modelFitter.FitSelectedReferenceRegionModel(this, ...
                    nthLiverRoiIndices, roiIndex, time, C_ES, liverC_i);
        		varargout{2} = t;
        		varargout{3} = fittedCi;
        		varargout{4} = k1;
        		varargout{5} = k2;
            elseif(strcmpi(kmo.KineticsModelName, 'Linear ODE'))
                [t, fittedCi, k1, k2] = modelFitter.FitSelectedReferenceRegionModel(this, ...
                    nthLiverRoiIndices, roiIndex, time, C_ES, liverC_i);
        		varargout{2} = t;
        		varargout{3} = fittedCi;
        		varargout{4} = k1;
        		varargout{5} = k2;
            else
                [t, fittedCi] = modelFitter.FitSelectedReferenceRegionModel(this, ...
                    nthLiverRoiIndices, roiIndex, time, C_ES, liverC_i);
        		varargout{2} = t;
        		varargout{3} = fittedCi;
            end
        end

        %% FitSelectedLinearOdeModel
        function [t, Ci, k1, k2] = FitSelectedLinearOdeModel(this, time, C_ES, liverC_i)
            liverVolumeFractionES = this.LiverVolumeFractionES;
            [k1, k2] = this.GetLinearOdeKineticsParameters(liverC_i, C_ES, liverVolumeFractionES);

            pkModel = this.ActivePharmacokineticModel;
            odeSolver = pkModel.OdeSolver;

            acqZero = this.AcquisitionZero;

            fixedParameters.time = time;
            fixedParameters.Ci = liverC_i;
            fixedParameters.Ces = C_ES;
            fixedParameters.acqZero = acqZero;
            fixedParameters.veLiver = liverVolumeFractionES;

            [t, Ci] = odeSolver(@(t,Ci) pkModel.Evaluate(ScaleParameter([k1 k2]), fixedParameters, t, Ci), ...
                [time(acqZero) time(end)], 0, []);
        end

        %% FitSelectedMichaelisMentenOdeModel
        function [t, Ci, k1, kM, Vmax] = FitSelectedMichaelisMentenOdeModel(this, time, C_ES, liverC_i)
            [k1, kM, Vmax] = ...
                this.GetMichaelisMentenOdeKineticsParameters(liverC_i, C_ES);

            pkModel = this.ActivePharmacokineticModel;
            odeSolver = pkModel.OdeSolver;

            acqZero = this.AcquisitionZero;

            fixedParameters.time = time;
            fixedParameters.Ci = liverC_i;
            fixedParameters.Ces = C_ES;
            fixedParameters.acqZero = acqZero;

            [t,Ci] = odeSolver(@(t,Ci) pkModel.Evaluate(ScaleParameter([k1 kM Vmax]), fixedParameters, t, Ci), ...
                [time(acqZero) time(end)], 0, []);
        end

        %% FitSelectedTristanModel
        function [t, Ci, k1, k2] = FitSelectedTristanModel(this, time, C_ES, liverC_i)
            liverVolumeFractionES = this.LiverVolumeFractionES;
            [k1, k2] = this.GetTristanLinearKineticsParameters(liverC_i, C_ES, liverVolumeFractionES);

            t = time;
            pkModel = this.ActivePharmacokineticModel;
            acqZero = this.AcquisitionZero;
            fixedParameters.time = time;
            fixedParameters.Ci = liverC_i;
            fixedParameters.Ces = C_ES;
            fixedParameters.acqZero = acqZero;
            fixedParameters.veLiver = liverVolumeFractionES;

            Ci = pkModel.Evaluate(ScaleParameter([k1 k2]), fixedParameters);
        end

        %% FitSelectedGeorgiouModel
        function [t, Ct, ki, kef, Fp, vecs, fa] = FitSelectedGeorgiouModel(this, time, liverC_t, Ca, Cv)
            [ki, kef, Fp, vecs, fa] = this.GetGeorgiouKineticsModelParameters(liverC_t, Ca, Cv);

            t = time;
            pkModel = this.ActivePharmacokineticModel;
            fixedParameters.time = time;
            fixedParameters.Ct = liverC_t;
            fixedParameters.Ca = Ca;
            fixedParameters.Cv = Cv;
            fixedParameters.Hct = this.Hematocrit;

            Ct = pkModel.Evaluate(ScaleParameter([ki, kef, Fp, vecs, fa]), fixedParameters);
        end

        %% FitSelectedBerksModel
        function [t, Ct, alphaPlus, alphaMinus, betaPlus, betaMinus, fa] = FitSelectedBerksModel(this, ...
                time, liverC_t, Ca, Cv)
            [alphaPlus, alphaMinus, betaPlus, betaMinus, fa] = this.GetBerksKineticsModelParameters(...
                liverC_t, Ca, Cv);

            t = time;
            pkModel = this.ActivePharmacokineticModel;
            fixedParameters.time = time;
            fixedParameters.Ct = liverC_t;
            fixedParameters.Ca = Ca;
            fixedParameters.Cv = Cv;
            fixedParameters.Hct = this.Hematocrit;

            Ct = pkModel.Evaluate(ScaleParameter([alphaPlus, alphaMinus, betaPlus, betaMinus, fa]), ...
                fixedParameters);
        end

        %% FitSelectedBiexponentialModel
        function [t, Ci, k1, kM, Vmax] = FitSelectedBiexponentialModel(this, time, C_ES, liverC_i, odeSolver)
            [k1, kM, Vmax] = this.GetBiexponentialKineticsParameters(liverC_i, C_ES);

            acqZero = this.AcquisitionZero;
            [t,Ci] = odeSolver(@(t,Ci) MichaelisMentenOdeModel(...
                ScaleParameter([k1 kM Vmax]), t, Ci, time, C_ES), [time(acqZero) time(end)], 0, []);
        end

        %% GetVolumeFractionES
        function volumeFractionES = GetVolumeFractionES(this, tissueType)
            arguments
                this (1,1) MainModel
                tissueType TissueType 
            end
            if(isempty(this.LoadImageDataOptions) || this.LoadImageDataOptions.IsHepatobiliaryContrastAgent)
                volumeFractionES = GetVolumeFractionESHepatobiliaryAgent(this, tissueType);
            else
                volumeFractionES = GetVolumeFractionESBloodPoolAgent(this, tissueType);
            end
        end

        %% GetVolumeFractionESBloodPoolAgent
        function volumeFractionES = GetVolumeFractionESBloodPoolAgent(this, tissueType)
            arguments
                this (1,1) MainModel
                tissueType (1,1) TissueType
            end
            if (tissueType.IsVessel)
                volumeFractionES = 1 - this.Hematocrit;
            else
                switch tissueType
                    case TissueType.Liver
                        volumeFractionES = this.LiverVolumeFractionES;
                    case TissueType.Spleen
                        volumeFractionES = this.SpleenVolumeFractionES;
                    case TissueType.Kidney
                        volumeFractionES = this.KidneyVolumeFractionES;
                    otherwise
                        volumeFractionES = 1;
                end
            end
        end

        %% GetVolumeFractionESHepatobiliaryAgent
        function volumeFractionES = GetVolumeFractionESHepatobiliaryAgent(this, tissueType)
            arguments
                this (1,1) MainModel
                tissueType (1,1) TissueType
            end
            if (tissueType.IsVessel)
                volumeFractionES = 1 - this.Hematocrit;
            else
                switch tissueType
                    case TissueType.Liver
                        error('Unexpected tissue type');
                        % The spleen is used as a reference region, which means that liverC_ES is assumed to be equal 
                        % to spleenC_ES. Therefore, it can't be computed without additional information. The spleen 
                        % ROI to be used is also required.
                    case TissueType.Spleen
                        volumeFractionES = this.SpleenVolumeFractionES;
                    case TissueType.Kidney
                        volumeFractionES = this.KidneyVolumeFractionES;
                    otherwise
                        volumeFractionES = 1;
                end
            end
        end

        %% ApplyFiltersToSignal
        function filteredSignal = ApplyFiltersToSignal(this, unfilteredSignal)
            arguments
                this MainModel
                unfilteredSignal {mustBeNumeric} 
            end
            if(this.UseMedianFilter)
                filterWindowStartSize = this.FilterWindowStartSize; % kernel size at the initialTransitionIndex
                filterWindowEndSize = this.FilterWindowEndSize;     % kernel size at the finalTransitionIndex
                initialTransitionIndex = this.TransitionStartIndex; % the index at which to begin adapting the filter
                finalTransitionIndex = this.TransitionEndIndex;     % the index at which the filter adaptation ceases
                filteredSignal = AdaptiveMedianFilter(unfilteredSignal, filterWindowStartSize, ...
                    filterWindowEndSize, initialTransitionIndex, finalTransitionIndex);
            else
                filteredSignal = unfilteredSignal;
            end
        end

        %% GetPreContrastR1
        function R1_0 = GetPreContrastR1(this, tissueType)
            arguments
                this(1,1) MainModel
                tissueType(1,1) TissueType 
            end
            if (tissueType.IsVessel)
                if (tissueType.IsArtery)
                    R1_0 = this.PreContrastArterialBloodR1;
                elseif (tissueType.IsVein)
                    R1_0 = this.PreContrastVenousBloodR1;
                end
                return
            end
            switch tissueType
                case TissueType.Liver
                    R1_0 = this.PreContrastLiverR1;
                case TissueType.Spleen
                    R1_0 = this.PreContrastSpleenR1;
                case TissueType.Kidney
                    R1_0 = this.PreContrastKidneyR1;
                case TissueType.Muscle
                    R1_0 = this.PreContrastMuscleR1;
                case TissueType.SpinalCord
                    R1_0 = this.PreContrastSpinalCordR1;
                case TissueType.Fat
                    R1_0 = this.PreContrastFatR1;
                otherwise
                    R1_0 = this.PreContrastLiverR1;
            end
        end

        %% GetKineticsParameters
        % TODO: Right now, this code isn't being called from anywhere. WIP - refactoring of
        % GetLinearOdeKineticsParameters, GetTristanLinearKineticsParameters, etc. - attempting to factor out common
        % functionality and consolidate into a general method that handles multiple kinetics models
        function varargout = GetKineticsParameters(this, varargin)
            % Order of optional input arguments
            % For reference region models:
            %   C_i     intracellular concentration time series
            %   C_ES    extracellular space concentration time series
            %
            % For vascular input models:
            %   liverC_t    total liver concentration time series
            %   Ca          arterial input function (concentration time series in artery)
            %   Cv          venous input function (concentration time series in portal vein)
            %
            % Order of output arguments
            % For linear influx, linear efflux models:
            %   k1      influx rate constant
            %   k2      efflux rate constant
            %
            % For linear influx, Michaelis-Menten efflux models:
            %   k1      influx rate constant
            %   kM      concentration when the efflux rate is half of Vmax
            %   Vmax    maximum rate of efflux
            %
            % For Georgiou model:
            %   ki      influx rate constant
            %   kef     efflux rate constant
            %   Fp      plasma flow rate
            %   vecs    volume fraction of extravascular extracellular space
            %   fa      fraction of the vascular input that is arterial blood
            %
            % For Berks model:
            %   alphaPlus   coefficient of the first exponential term
            %   alphaMinus  coefficient of the second exponential term
            %   betaPlus    exponent in the first term
            %   betaMinus   exponent in the second term
            %   fa          fraction of the vascular input that is arterial blood
            %   tau        delay time for the AIF and VIF

            assert(this.KineticsModelOptionsInitialized);
            kmo = this.KineticsModelOptions;

            disp('Starting to compute kinetics parameters...');

            time = this.ImageVolume.Time;
            acqZero = this.AcquisitionZero;

            % this.ActivePharmacokineticModel needs to already have a valid instance of the appropriate
            % PharmacokineticModel
            assert(this.ActivePharmacokineticModelInitialized);
            this.ActivePharmacokineticModel.FitOptions = kmo;

            tic
            pkModel = this.ActivePharmacokineticModel;
            fixedParameters = pkModel.GetFixedParameters(time, acqZero, varargin);
            pkModelParameters = pkModel.FitToData(fixedParameters, varargin);
            toc

            % TODO: create a polymorphic method for handling the display of the output parameters with appropriate
            % output for all the different individual models
            varargout = pkModelParameters;
        end

        %% GetLinearOdeKineticsParameters
        function [k1, k2] = GetLinearOdeKineticsParameters(this, C_i, C_ES, liverVolumeFractionES)
            assert(this.KineticsModelOptionsInitialized);
            disp('Starting to compute kinetics parameters...');

            time = this.ImageVolume.Time;
            acqZero = this.AcquisitionZero;
            tic
            pkModel = this.ActivePharmacokineticModel;
            fixedParameters = pkModel.GetFixedParameters(time, acqZero, C_i, C_ES, liverVolumeFractionES);
            pkModelParameters = pkModel.FitToData(fixedParameters);
            toc

            k1 = pkModelParameters(1);
            k2 = pkModelParameters(2);

            % TODO: Separate the computations from the display of results - the display should be in the view class, 
            % not the model
            disp('Linear ODE model results:');
            disp(['k1: ', num2str(k1), ' s^-1']);
            disp(['k2: ', num2str(k2), ' s^-1']);
            disp('Done computing kinetics.');
        end

        %% GetTristanLinearKineticsParameters
        function [k1, k2] = GetTristanLinearKineticsParameters(this, C_i, C_ES, liverVolumeFractionES)
            assert(this.KineticsModelOptionsInitialized);
            disp('Starting to compute kinetics parameters...');

            time = this.ImageVolume.Time;
            acqZero = this.AcquisitionZero;
            tic
            pkModel = this.ActivePharmacokineticModel;
            fixedParameters = pkModel.GetFixedParameters(time, acqZero, C_i, C_ES, liverVolumeFractionES);
            pkModelParameters = pkModel.FitToData(fixedParameters);
            toc

            k1 = pkModelParameters(1);
            k2 = pkModelParameters(2);

            % TODO: Separate the computations from the display of results - the display should be in the view class,
            % not the model
            disp('TRISTAN Linear model results:');
            disp(['k1: ', num2str(k1), ' s^-1']);
            disp(['k2: ', num2str(k2), ' s^-1']);
            disp('Done computing kinetics.');
        end

        %% GetGeorgiouKineticsModelParameters
        function [ki, kef, Fp, vecs, fa] = GetGeorgiouKineticsModelParameters(this, liverC_t, Ca, Cv)
            assert(this.KineticsModelOptionsInitialized);
            disp('Starting to compute kinetics parameters...');

            time = this.ImageVolume.Time;
            acqZero = this.AcquisitionZero;
            tic
            pkModel = this.ActivePharmacokineticModel;
            fixedParameters = pkModel.GetFixedParameters(time, acqZero, liverC_t, Ca, Cv, this.Hematocrit);
            pkModelParameters = pkModel.FitToData(fixedParameters);
            toc

            ki = pkModelParameters(1);
            kef = pkModelParameters(2);
            Fp = pkModelParameters(3);
            vecs = pkModelParameters(4);
            fa = pkModelParameters(5);

            % TODO: Separate the computations from the display of results - the display should be in the view class,
            % not the model
            disp('Georgiou model results:');
            disp(['ki: ', num2str(ki), ' s^-1']);
            disp(['kef: ', num2str(kef), ' s^-1']);
            disp(['Fp: ', num2str(Fp), ' s^-1']);
            disp(['vecs: ', num2str(vecs), ' mL/mL']);
            disp(['fa: ', num2str(fa), ' unitless']);
            disp('Done computing kinetics.');
        end

        %% GetBerksKineticsModelParameters
        function [alphaPlus, alphaMinus, betaPlus, betaMinus, fa] = GetBerksKineticsModelParameters(this, ...
                liverC_t, Ca, Cv)
            assert(this.KineticsModelOptionsInitialized);
            disp('Starting to compute kinetics parameters...');

            time = this.ImageVolume.Time;
            acqZero = this.AcquisitionZero;
            tic
            pkModel = this.ActivePharmacokineticModel;
            %             pkModel.EnableDataTruncation(100);
            % Use truncated data for the first fit to determine tau
            %             fixedParameters = pkModel.GetFixedParameters(time, acqZero, liverC_t, Ca, Cv, ...
            %                   this.Hematocrit);
            %             pkModelParameters = pkModel.FitToData(fixedParameters);
            %             toc

            % Use original, untruncated data for the second fit, but treat tau as a fixed parameter
            %             tau = pkModelParameters(6);
            pkModel.DisableDataTruncation();
            %             initialEstimate = pkModel.FitOptions.InitialEstimate;
            %             initialEstimate(6) = tau;
            %             lb = pkModel.FitOptions.LowerBound;
            %             lb(6) = tau;
            %             ub = pkModel.FitOptions.UpperBound;
            %             ub(6) = tau;
            %             pkModel.FitOptions.InitialEstimate = initialEstimate;
            %             pkModel.FitOptions.LowerBound = lb;
            %             pkModel.FitOptions.UpperBound = ub;

            fixedParameters = pkModel.GetFixedParameters(time, acqZero, liverC_t, Ca, Cv, this.Hematocrit);
            pkModelParameters = pkModel.FitToData(fixedParameters);
            toc

            alphaPlus = pkModelParameters(1);
            alphaMinus = pkModelParameters(2);
            betaPlus = pkModelParameters(3);
            betaMinus = pkModelParameters(4);
            fa = pkModelParameters(5);
            % tau = pkModelParameters(6);

            if(betaPlus > betaMinus)
                % swap the alphas and betas prior to computing Fp, vecs, ki, kef
                tempAlpha = alphaPlus;
                alphaPlus = alphaMinus;
                alphaMinus = tempAlpha;
                tempBeta = betaPlus;
                betaPlus = betaMinus;
                betaMinus = tempBeta;
            end

            % TODO: Separate the computations from the display of results - the display should be in the view class,
            % not the model
            disp('Berks model results:');
            disp(['alpha+: ', num2str(alphaPlus), ' s^-1']);
            disp(['alpha-: ', num2str(alphaMinus), ' s^-1']);
            disp(['beta+: ', num2str(betaPlus), ' s^-1']);
            disp(['beta-: ', num2str(betaMinus), ' s^-1']);
            disp(['fa: ', num2str(fa), ' unitless']);
            % disp(['tau: ', num2str(tau), ' s']);

            % Constraint tests
            %             disp(['beta+ >= 0: ', num2str(betaPlus>=0)]);
            %             disp(['alpha+ + alpha- > 0: ', num2str(alphaPlus+alphaMinus>0)]);
            %             disp(['alpha+*beta+ + alpha-*beta- > 0: ', ...
            %                 num2str(alphaPlus*betaPlus+alphaMinus*betaMinus > 0)]);
            %             disp(['(alpha+ + alpha-)^2 < alpha+*beta+ +alpha-*beta-: ', ...
            %                 num2str((alphaPlus+alphaMinus)^2 < alphaPlus*betaPlus + alphaMinus*betaMinus)]);
            %             disp(['alpha+*beta+ <= alpha+*beta-: ', num2str(alphaPlus*betaPlus <= alphaPlus*betaMinus)]);
            %             disp(['(alpha+ + alpha-)^2/(alpha+*beta+ + alpha-*beta-) < 1: ', ...
            %                 num2str((alphaPlus+alphaMinus)^2/(alphaPlus*betaPlus + alphaMinus*betaMinus) < 1)]);

            % Active uptake interpretation
            Fp = alphaPlus + alphaMinus;
            vecs = (alphaPlus + alphaMinus).^2./(alphaPlus.*betaPlus + alphaMinus.*betaMinus);
            ki = alphaPlus.*(alphaPlus + alphaMinus).*(betaMinus - betaPlus) ./ ...
                (alphaPlus.*betaPlus + alphaMinus.*betaMinus);
            kef = betaPlus.*(1 - (alphaPlus + alphaMinus).^2./(alphaPlus.*betaPlus + alphaMinus.*betaMinus));

            disp(' ');
            disp('Active Uptake Model interpretation:');
            disp(['Fp: ', num2str(Fp), ' s^-1']);
            disp(['vecs: ', num2str(vecs), ' mL/mL']);
            disp(['ki: ', num2str(ki), ' s^-1']);
            disp(['kef: ', num2str(kef), ' s^-1']);

            % Passive exchange interpretation
            Fp = alphaPlus + alphaMinus;
            PS = alphaPlus.*alphaMinus.*(alphaPlus + alphaMinus).*(betaPlus - betaMinus).^2 ./ ...
                (alphaPlus.*betaPlus + alphaMinus.*betaMinus).^2;
            ve = alphaPlus.*alphaMinus.*(betaPlus - betaMinus).^2 ./ ...
                (betaPlus.*betaMinus.*(alphaPlus.*betaPlus + alphaMinus.*betaMinus));
            vp = (alphaPlus + alphaMinus).^2./(alphaPlus.*betaPlus + alphaMinus.*betaMinus);

            disp(' ');
            disp('Passive Exchange Model interpretation:');
            disp(['Fp: ', num2str(Fp), ' s^-1']);
            disp(['PS: ', num2str(PS), ' s^-1']);
            disp(['ve: ', num2str(ve), ' mL/mL']);
            disp(['vp: ', num2str(vp), ' mL/mL']);
        end

        %% GetMichaelisMentenOdeKineticsParameters
        function [k1, kM, Vmax] = GetMichaelisMentenOdeKineticsParameters(this, C_i, C_ES)
            assert(this.KineticsModelOptionsInitialized);
            disp('Starting to compute kinetics parameters...');

            time = this.ImageVolume.Time;
            acqZero = this.AcquisitionZero;
            tic
            pkModel = this.ActivePharmacokineticModel;
            fixedParameters = pkModel.GetFixedParameters(time, acqZero, C_i, C_ES);
            pkModelParameters = pkModel.FitToData(fixedParameters);
            toc

            k1 = pkModelParameters(1);
            kM = pkModelParameters(2);
            Vmax = pkModelParameters(3);

            % TODO: Separate the computations from the display of results - the display should be in the view class,
            % not the model
            disp('Michaelis-Menten ODE model results:');
            disp(['k1: ', num2str(k1), ' s^-1']);
            disp(['kM: ', num2str(kM), ' mM']);
            disp(['Vmax: ', num2str(Vmax), ' mM/s']);
            disp('Done computing kinetics.');
        end

        %% GetBiexponentialKineticsParameters
        function [k1, kM, Vmax] = GetBiexponentialKineticsParameters(this, C_i, C_ES)
            arguments
                this MainModel
                C_i {mustBeNumeric}
                C_ES {mustBeNumeric}
            end
            assert(this.KineticsModelOptionsInitialized);
            kmo = this.KineticsModelOptions;

            disp('Starting to compute kinetics parameters...');

            time = this.ImageVolume.Time;
            acqZero = this.AcquisitionZero;

            % Fit the biexponential model to obtain a good initial estimate of the parameters
            tic
            %             pkModel = this.ActivePharmacokineticModel;
            %             fixedParameters = pkModel.GetFixedParameters(time, acqZero, C_i, C_ES);
            %             pkModelParameters = pkModel.FitToData(fixedParameters);
            biexponential = FitBiexponentialModel(time, C_i, C_ES, acqZero, kmo);
            toc

            k1 = biexponential.k1;
            kM = biexponential.kM;
            Vmax = biexponential.Vmax;

            % TODO: Separate the computations from the display of results - the display should be in the view class,
            % not the model
            disp('Bi-exponential algebraic model results:');
            disp(['k1: ', num2str(k1), ' s^-1']);
            disp(['kM: ', num2str(kM), ' mM']);
            disp(['Vmax: ', num2str(Vmax), ' mM/s']);
            disp(['resnorm: ', num2str(biexponential.resnorm)]);
            disp('Done computing kinetics.');
        end

        %% EstimateVolumeFractionESFromMrSignal
        function volfrac = EstimateVolumeFractionESFromMrSignal(this, meanSI, tissueType, bloodAUC)
            verbose = true;
            acqZero = double(this.AcquisitionZero);
            tissueAUC = this.ImageVolume.GetAucTotalFromSignal(meanSI, tissueType, acqZero);
            volfrac = (tissueAUC./bloodAUC).*(1-this.Hematocrit);

            % TODO: Separate the computations from the display of results - the display should be in the view class, 
            % not the model
            if (verbose)
                fprintf('=============================\n');
                fprintf('Fit Model: Ulloa et al, Trapezoid Rule\n');
                fprintf('Tissue: %s\n', tissueType.ToDisplayName);
                fprintf('-----------------------------\n');
                fprintf('ve = %s\n', num2str(volfrac));
                fprintf('=============================\n');
            end
        end

        %% GetModelVolumeFractionESFromMrSignal
        function volfrac = GetModelVolumeFractionESFromMrSignal(this, meanSI, tissueType, bloodAUC, ...
                bloodArrivalTime, fitModel, arriveTimeMethod)
            arguments
                this (1,1) MainModel
                meanSI {mustBeNumeric}
                tissueType (1,1) TissueType
                bloodAUC {mustBeNumeric}
                bloodArrivalTime {mustBeNumeric}
                fitModel {mustBeTextScalar}
                arriveTimeMethod {mustBeTextScalar} 
            end
            verbose = true;

            [tissueAUC, tissueArrivalTime] = this.ImageVolume.GetRoiModelAucTotal(meanSI, tissueType, fitModel, ...
                arriveTimeMethod);
            volfrac = (tissueAUC./bloodAUC).*(1-this.Hematocrit);

            % TODO: Separate the computations from the display of results - the display should be in the view class, 
            % not the model
            if (verbose)
                fprintf('=============================\n');
                fprintf('Fit Model: Ulloa et al, %s fit, %s tarrive\n', fitModel, arriveTimeMethod);
                fprintf('Tissue: %s\n', tissueType.ToDisplayName);
                fprintf('-----------------------------\n');
                fprintf('ve = %s\n', num2str(volfrac));
                fprintf('Blood tarrive = %s\n', num2str(bloodArrivalTime));
                fprintf('Tissue tarrive = %s\n', num2str(tissueArrivalTime));
                fprintf('=============================\n');
            end
        end

        %% ComputeExtracellularVolumeFractions
        function ComputeExtracellularVolumeFractions(this, liverRoi, spleenRoi, kidneyRoi, bloodRoi)
            arguments
                this MainModel
                liverRoi RegionOfInterest
                spleenRoi RegionOfInterest
                kidneyRoi RegionOfInterest
                bloodRoi RegionOfInterest
            end
            this.LiverVolumeFractionES = ComputeTissueVolumeFractionES(this, liverRoi, bloodRoi, 'trapezoid');
            this.LiverVolumeFractionES = ComputeTissueVolumeFractionES(this, liverRoi, bloodRoi, 'monoexp');
            this.LiverVolumeFractionES = ComputeTissueVolumeFractionES(this, liverRoi, bloodRoi, 'biexp');

            this.SpleenVolumeFractionES = ComputeTissueVolumeFractionES(this, spleenRoi, bloodRoi, 'trapezoid');
            this.SpleenVolumeFractionES = ComputeTissueVolumeFractionES(this, spleenRoi, bloodRoi, 'monoexp');
            this.SpleenVolumeFractionES = ComputeTissueVolumeFractionES(this, spleenRoi, bloodRoi, 'biexp');

            this.KidneyVolumeFractionES = ComputeTissueVolumeFractionES(this, kidneyRoi, bloodRoi, 'trapezoid');
            this.KidneyVolumeFractionES = ComputeTissueVolumeFractionES(this, kidneyRoi, bloodRoi, 'monoexp');
            this.KidneyVolumeFractionES = ComputeTissueVolumeFractionES(this, kidneyRoi, bloodRoi, 'biexp');
        end

        %% ComputeTissueVolumeFractionES
        function volumeFractionES = ComputeTissueVolumeFractionES(this, tissueRoi, bloodRoi, method)
            [unfilteredBloodRoiSignalMu, ~] = this.ImageVolume.GetSignalFrom2DRegion(bloodRoi);
            bloodRoiSignalMu = this.ApplyFiltersToSignal(unfilteredBloodRoiSignalMu);

            if (~isempty(tissueRoi))
                tissueType = tissueRoi.Tissue;
                bloodRoiTissueType = bloodRoi.Tissue;
                [unfilteredRoiSignalMu, ~] = this.ImageVolume.GetSignalFrom2DRegion(tissueRoi);
                roiSignalMu = this.ApplyFiltersToSignal(unfilteredRoiSignalMu);
                switch method
                    case 'trapezoid'
                        acqZero = double(this.AcquisitionZero);
                        bloodAuc = this.ImageVolume.GetAucTotalFromSignal( ...
                            bloodRoiSignalMu, bloodRoiTissueType, acqZero);
                        volumeFractionES = this.EstimateVolumeFractionESFromMrSignal(roiSignalMu, tissueType, ...
                            bloodAuc);
                    case 'monoexp'
                        [monoexpBloodAuc, monoexpBloodArrivalTime] = ...
                            this.ImageVolume.GetRoiModelAucTotal(bloodRoiSignalMu, bloodRoiTissueType, ...
                            'Monoexponential', 'Fixed');
                        volumeFractionES = this.GetModelVolumeFractionESFromMrSignal(roiSignalMu, tissueType, ...
                            monoexpBloodAuc, monoexpBloodArrivalTime, 'Monoexponential', 'Fixed');
                    case 'biexp'
                        [biexpBloodAuc, biexpBloodArrivalTime] = ...
                            this.ImageVolume.GetRoiModelAucTotal(bloodRoiSignalMu, bloodRoiTissueType, ...
                            'Biexponential', 'Fixed');
                        volumeFractionES = this.GetModelVolumeFractionESFromMrSignal(roiSignalMu, tissueType, ...
                            biexpBloodAuc, biexpBloodArrivalTime, 'Biexponential', 'Fixed');
                    otherwise
                        error('Unknown extracellular volume fraction estimation method');
                end
            end
        end

        %% IsReadyToEstimateModelParameters
        function bool = IsReadyToEstimateModelParameters(this)
            if (~this.ImageVolume.ImageDataInitialized || ~this.KineticsModelOptionsInitialized)
                bool = false;
                return;
            end
            bool = true;
        end

        %% IsProjectionImageTypeSelected
        function bool = IsProjectionImageTypeSelected(this)
            selectedImageTypeToDisplay = this.SelectedImageTypeToDisplay;
            bool = selectedImageTypeToDisplay.IsProjection();
        end

        %% IsSelectedRoiDimensionality3D
        function bool = IsSelectedRoiDimensionality3D(this)
            selectedRoiDimensionality = this.SelectedRoiDimensionality;
            bool = selectedRoiDimensionality.Is3D();
        end

        %% GetESConcentrationFromSpleenRoi2D
        function C_ES = GetESConcentrationFromSpleenRoi2D(this, spleenRoi)
            arguments
                this (1,1) MainModel
                spleenRoi RegionOfInterest
            end
            if(isempty(spleenRoi))
                C_ES = [];
                return
            end

            imageVolume = this.ImageVolume;
            [unfilteredSpleenSI, ~] = imageVolume.GetSignalFrom2DRegion(spleenRoi);
            spleenSI = this.ApplyFiltersToSignal(unfilteredSpleenSI);
            C_ES = imageVolume.GetESConcentrationFromMrSignal(spleenSI, TissueType.Spleen);
        end

        %% GetESConcentrationFromSpleenRoi3D
        function C_ES = GetESConcentrationFromSpleenRoi3D(this, spleenRoi)
            arguments
                this (1,1) MainModel
                spleenRoi RegionOfInterest3D
            end
            imageVolume = this.ImageVolume;
            if(isempty(spleenRoi) || ~imageVolume.ImageDataInitialized)
                C_ES = [];
                return
            end
            [unfilteredSpleenSI, ~] = imageVolume.GetSignalFrom3DRegion(spleenRoi);
            spleenSI = this.ApplyFiltersToSignal(unfilteredSpleenSI);
            C_ES = imageVolume.GetESConcentrationFromMrSignal(spleenSI, TissueType.Spleen);
        end

        %% InitializeActivePkModel
        function InitializeActivePkModel(this, kmo)
            arguments
                this MainModel
                kmo(1,1) KineticsPickerModel
            end

            this.ActivePharmacokineticModel = kmo.GetPkModel();
            if(isa(this.ActivePharmacokineticModel, 'INumericallyIntegrable'))
                this.ActivePharmacokineticModel.OdeSolver = kmo.OdeSolver;
            end
        end

        %% GetTissueDataFrom3DRegion
        function signal = GetTissueDataFrom3DRegion(this, tissueType)
            arguments
                this(1,1) MainModel
                tissueType(1,1) TissueType
            end
            signal = struct;
            imageVolume = this.ImageVolume;
            if(~imageVolume.ImageDataInitialized)
                return
            end

            roiList = this.GetRoi3DByTissueType(tissueType);
            roi = roiList(1);
            roiColor = roi.Color;
            roiMask = roi.Mask;

            [unfilteredSignalMu, unfilteredSignalSigma, voxelWiseData, voxelCoordinates] = ...
                imageVolume.GetSignalFrom3DRegion(roi);
            filteredSignalMu = this.ApplyFiltersToSignal(unfilteredSignalMu);
            R1_0 = this.GetPreContrastR1(tissueType);
            R1 = imageVolume.GetR1FromMrSignal(filteredSignalMu, R1_0);
            totalConcentration = imageVolume.GetTotalConcentrationFromSignal(filteredSignalMu, tissueType);

            signal.RoiColor = roiColor;
            signal.RoiMask = roiMask;
            signal.UnfilteredRoiMean = unfilteredSignalMu;
            signal.UnfilteredRoiSD = unfilteredSignalSigma;
            signal.UnfilteredVoxelWiseData = voxelWiseData;
            signal.VoxelCoordinates = voxelCoordinates;
            signal.FilteredRoiMean = filteredSignalMu;
            signal.PreContrastR1 = R1_0;
            signal.R1 = R1;
            signal.TotalConcentration = totalConcentration;
        end

        %% GetRoi3DSignalsForReferenceRegionModel
        function varargout = GetRoi3DSignalsForReferenceRegionModel(this)
            success = false;
            varargout = cell(1, nargout);
            for nthArgOut = 1:(nargout-1)
                varargout{nthArgOut+1} = NaN;
            end
            varargout{1} = success;

            % Get the input signal(s) for the PBPK model from the dynamic images within the ROIs the user selected
            roiList = this.GetRoi3Ds('OrganRois');
            roiColors = MainModel.GetRoiColors(roiList);
            roiTissues = MainModel.GetRoiTissues(roiList);
            modelFitter = PharmacokineticModelFitter(this, roiColors, roiTissues);

            [success, spleenRoi, spleenIndex, spleenRois, spleenRoiIndices] = MainView.PickSpleenRoiToUse(roiList);
            if(~success)
                return
            end

            C_ES = modelFitter.GetESConcentrationFromSpleenReferenceRegion(this, spleenRois, ...
                spleenRoiIndices, spleenRoi, spleenIndex);
            varargout = {success, roiList, modelFitter, C_ES};
        end

        %% GetRoiSignalsForVascularInputModel
        function varargout = GetRoiSignalsForVascularInputModel(this)
            success = false;
            varargout = cell(1, nargout);
            for nthArgOut = 1:(nargout-1)
                varargout{nthArgOut} = NaN;
            end
            varargout{1} = success;

            if (~this.IsSelectedRoiDimensionality3D())
                disp('Use of 2D ROIs with non-reference-region models is not supported.');
                return
            end

            if(~this.ThreeDimensionalRoiOptionsInitialized || ...
                    ~this.ThreeDimensionalRoiOptions.IsReadyToLoadRois)
                return
            end
            
            liverSignal = this.GetTissueDataFrom3DRegion(TissueType.Liver);
            abdominalAortaSignal = this.GetTissueDataFrom3DRegion(TissueType.AbdominalAorta);
            portalVeinSignal = this.GetTissueDataFrom3DRegion(TissueType.PortalVein);

            success = true;
            varargout = {success, liverSignal, abdominalAortaSignal, portalVeinSignal};
        end

        %% UpdateExportSignalsFilename
        function UpdateExportSignalsFilename(this)
            notify(this, 'ExportSignalsFilenameRequest');
        end

        %% UpdateLoadImageDataOptions
        function UpdateLoadImageDataOptions(this)
            notify(this, 'LoadImageDataRequest');
        end

        %% UpdateKineticsModelOptions
        function UpdateKineticsModelOptions(this)
            notify(this, 'KineticsModelOptionsRequest');
        end

        %% UpdateImportRoi3Ds
        function UpdateImportRoi3Ds(this)
            notify(this, 'ImportRoi3DsRequest');
        end

        %% UpdateCorrectSignalDrift
        function UpdateCorrectSignalDrift(this)
            notify(this, 'CorrectSignalDriftRequest');
        end

        %% UpdateRoiSignalVsTimePlot
        function UpdateRoiSignalVsTimePlot(this)
            notify(this, 'RoiSignalPlotRequest');
        end

        %% UpdateRoiR1VsTimePlot
        function UpdateRoiR1VsTimePlot(this)
            notify(this, 'RoiR1PlotRequest');
        end

        %% UpdateRoiAreaUnderCurveVsTimePlot
        function UpdateRoiAreaUnderCurveVsTimePlot(this)
            notify(this, 'RoiAreaUnderCurvePlotRequest');
        end

        %% UpdateRoiTotalConcentrationVsTimePlot
        function UpdateRoiTotalConcentrationVsTimePlot(this)
            notify(this, 'RoiTotalConcentrationPlotRequest');
        end

        %% UpdateRoiESConcentrationVsTimePlot
        function UpdateRoiESConcentrationVsTimePlot(this)
            notify(this, 'RoiESConcentrationPlotRequest');
        end

        %% UpdateRoiIntracellularConcentrationVsTimePlot
        function UpdateRoiIntracellularConcentrationVsTimePlot(this)
            notify(this, 'RoiIntracellularConcentrationPlotRequest');
        end

        %% ComputeVolumeFractionES
        function ComputeVolumeFractionES(this)
            notify(this, 'ComputeVolumeFractionESRequest');
        end

        %% ConstrainAlphaToRange
        function value = ConstrainAlphaToRange(this, alpha)
            arguments
                this (1,1) MainModel
                alpha {mustBeNumeric}
            end
            value = ConstrainValueToRange(alpha, 0, 1);
        end

        %% ConstrainSliceLocationToRange
        function value = ConstrainSliceLocationToRange(this, sliceLocation)
            arguments
                this (1,1) MainModel
                sliceLocation {mustBeNumeric}
            end
            % Selects the nearest valid slice location to the one specified
            value = ConstrainValueToRange(round(sliceLocation), 1, this.ImageVolume.GetMaximumSliceIndex());
            value = uint16(value);
        end

        %% ConstrainFilterWindowSizeToRange
        function value = ConstrainFilterWindowSizeToRange(this, filterWindowSize)
            arguments
                this (1,1) MainModel
                filterWindowSize {mustBeNumeric}
            end
            % Ensure that the filter's window size makes sense with respect to the size of the DCE time series

            value = ConstrainValueToRange(round(filterWindowSize), 1, this.ImageVolume.GetMaxFilterWindowSize());
            value = uint16(value);
        end
    end

    %% Private Methods (not accessible outside the class)
    methods (Access = private)
        %% UpdateOnLoadImageDataOptionsChanged
        function UpdateOnLoadImageDataOptionsChanged(this, current, previous)
            if(current.NumberOfSlicesDiffers(previous))
                notify(this, 'NumberOfSlicesChanged');
            end

            if(current.ContrastAgentDiffers(previous))
                notify(this, 'ContrastAgentChanged');
            end
        end

        %% UpdateOnDriftCorrectionOptionsChanged
        function UpdateOnDriftCorrectionOptionsChanged(this, current, previous)
        end

        %% UpdateOnThreeDimensionalRoiOptionsChanged
        function UpdateOnThreeDimensionalRoiOptionsChanged(this, current, previous)
            arguments
                this (1,1) MainModel
                current LoadRoi3DsDialogModel
                previous LoadRoi3DsDialogModel
            end
            if(current.FullyQualifiedGroundTruthFilenameDiffers(previous) || ...
                    current.UseExistingThresholdsDiffers(previous))
                notify(this, 'ThreeDimensionalRoiOptionsChanged');
            end
        end
    end

    %% Public Static Methods
    methods (Static)
        %% GetMaskFromRoi3D
        function [success, mask] = GetMaskFromRoi3D(roi3D, tissueCategory)
            arguments
                roi3D 
                tissueCategory {mustBeTextScalar}
            end
            success = false;
            switch tissueCategory
                case 'OrganRois'
                    roiToUse = 'OriginalRoi';
                case 'VesselRois'
                    roiToUse = 'RefinedRoi';
                otherwise
                    error('Unknown tissue type');
            end
            if(~isfield(roi3D, roiToUse) || ~isfield(roi3D.(roiToUse), 'Mask'))
                return
            end
            mask = roi3D.(roiToUse).Mask;
            success = true;
        end

        %% GetRoiDataForTissue
        function [rois, roiIndices] = GetRoiDataForTissue(roiList, tissueType)
            arguments
                roiList RegionOfInterest
                tissueType TissueType
            end
            if(~isempty(roiList))
                roiTissues = MainModel.GetRoiTissues(roiList);
                rois = false(size(roiList));
                rois(roiTissues == tissueType) = true;
                roiIndices = find(rois);
            else
                rois = tissueType.empty;
                roiIndices = double.empty;
            end
        end

        %% GetRoiTissues
        function roiTissues = GetRoiTissues(roiList)
            arguments
                roiList RegionOfInterest
            end
            if(isempty(roiList))
                roiTissues = TissueType.empty;
                return
            end
            roiTissues = reshape([roiList.Tissue], size(roiList));   % array of the TissueType enumeration
        end

        %% GetRoiColors
        function roiColors = GetRoiColors(roiList)
            arguments
                roiList RegionOfInterest
            end
            % Note: RGB triples are organized in columns
            sz = size(roiList);
            sz(1) = sz(1)*3;
            roiColors = reshape([roiList.Color], sz);
        end
    end

    %% Private Static Methods
    methods (Static, Access = private)
    end
end