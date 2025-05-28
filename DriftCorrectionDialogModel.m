classdef DriftCorrectionDialogModel < handle
    % DriftCorrectionDialogModel        Model class (MVC pattern) for the DriftCorrectionDialog GUI. Provides 
    %                                   functionality for correcting signal drift over the course of a dynamic 
    %                                   contrast-enhanced acquisition. This is currently a WIP feature.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    %% Properties
    
    % Observable Properties (listeners receive notification of changes)
    properties (SetObservable = true, AbortSet = true)
        RoiList
        ImageVolume(1,1) DynamicImageVolume = DynamicMrImageVolume()
        UseDriftCorrection(1,1) logical
        ShowFitPlots(1,1) logical
        NumberOfSamplesToUseForCorrection(1,1) double
        CorrectionSlope(1,1) double
        UseMultipleRois(1,1) logical
        RoiDimensionality
        UseMuscleAsReferenceTissue(1,1) logical
        UseSpinalCordAsReferenceTissue(1,1) logical
        UseFatAsReferenceTissue(1,1) logical
        UseSpleenAsReferenceTissue(1,1) logical
        SavedScreenPosition
        Cancelled(1,1) logical
    end
    
    % Private Properties
    properties (Access = private)
    end
    
    % Computable Dependent Properties
    properties (Dependent = true, SetAccess = private)
    end
    
    %% Events
    events
    end
    
    %% Class Methods
    methods
        %% Constructors
        function this = DriftCorrectionDialogModel(varargin)
            switch nargin
                case 0
                    this.DriftCorrectionDialogModelNullConstructor();
                case 2
                    this.RoiList = varargin{1};
                    this.ImageVolume = varargin{2};
                    this.DriftCorrectionDialogModelNullConstructor();
                case 3
                    this.RoiList = varargin{1};
                    this.ImageVolume = varargin{2};
                    modelToCopy = varargin{3};
                    this.DriftCorrectionDialogModelCopyConstructor(modelToCopy);
                otherwise
                    error('DriftCorrectionDialogModel received an incorrect number of arguments');
            end
        end
        
        %% Getters for Computable Dependent Properties

        %% Getters and Setters
        function position = get.SavedScreenPosition(this)
            position = this.SavedScreenPosition;
        end
        
        function set.SavedScreenPosition(this, value)
            this.SavedScreenPosition = value;
        end

        function slope = get.CorrectionSlope(this)
            slope = this.CorrectionSlope;
        end

        function set.CorrectionSlope(this, slope)
            assert(isfinite(slope));

            this.CorrectionSlope = slope;
        end

        function roiDimensionality = get.RoiDimensionality(this)
            roiDimensionality = this.RoiDimensionality;
        end
        
        function set.RoiDimensionality(this, str)
            switch(str)
                case '2D'
                    this.RoiDimensionality = str;
                case '3D'
                    this.RoiDimensionality = str;
                otherwise
                    error('Invalid image file format selection');
            end
        end

        function numberOfSamples = get.NumberOfSamplesToUseForCorrection(this)
            numberOfSamples = this.NumberOfSamplesToUseForCorrection;
        end

        function set.NumberOfSamplesToUseForCorrection(this, number)
            assert(isfinite(number));

            this.NumberOfSamplesToUseForCorrection = number;
        end

        %% Other Public Methods

        %% SelectRoisToUse
        function roisToUse = SelectRoisToUse(this)
            roiList = this.RoiList;
            roisToUse = false(size(roiList));
            if(isempty(roiList))
                return
            end

            if(this.UseMuscleAsReferenceTissue)
                [muscleRois, ~] = MainModel.GetRoiDataForTissue(roiList, TissueType.Muscle);
                roisToUse = roisToUse | muscleRois;
            end
            if(this.UseSpinalCordAsReferenceTissue)
                [spinalCordRois, ~] = MainModel.GetRoiDataForTissue(roiList, TissueType.SpinalCord);
                roisToUse = roisToUse | spinalCordRois;
            end
            if(this.UseFatAsReferenceTissue)
                [fatRois, ~] = MainModel.GetRoiDataForTissue(roiList, TissueType.Fat);
                roisToUse = roisToUse | fatRois;
            end
            if(this.UseSpleenAsReferenceTissue)
                [spleenRois, ~] = MainModel.GetRoiDataForTissue(roiList, TissueType.Spleen);
                roisToUse = roisToUse | spleenRois;
            end
        end

        %% ComputeCorrectionUsingRoi2Ds
        function slope = ComputeCorrectionUsingRoi2Ds(this)
            % Based on:
            %   Georgiou, L. DCE-MRI assessment of hepatic uptake and efflux of the contrast agent, gadoxetate, to 
            %       monitor transporter-mediated processes and drug-drug interactions: in vitro and in vivo studies. 
            %       University of Manchester School of Medicine (2014).

            roisToUse = this.SelectRoisToUse();
            roiList = this.RoiList;
            selectedRoiList = roiList(roisToUse);
            slope = zeros(length(selectedRoiList), 1);
            imageVolume = this.ImageVolume;
            time = imageVolume.Time;
            model = imageVolume.Model;
            numberOfSamplesForCorrection = this.NumberOfSamplesToUseForCorrection;
            for idx = 1:size(selectedRoiList,2)
                roi = selectedRoiList(idx);
                signal = imageVolume.GetUnaggregatedSignalFrom2DRegion(roi, false);
                [unfilteredMeanSI, ~] = imageVolume.GetSignalFrom2DRegion(roi, false);
                meanSI = model.ApplyFiltersToSignal(unfilteredMeanSI);
                firstIdx = 1;
                lastIdx = size(signal, 2);
                firstNIdxs = firstIdx:(firstIdx+numberOfSamplesForCorrection-1);
                lastNIdxs = (lastIdx-numberOfSamplesForCorrection+1):lastIdx;
                p = polyfit(time([firstNIdxs, lastNIdxs]), meanSI([firstNIdxs, lastNIdxs]), 1);
                x = time(firstIdx:lastIdx);
                y = p(1)*x + p(2);
                slope(idx) = p(1);
                if(this.ShowFitPlots)
                    figure
                    plot(time, signal, '.', 'Color', [0.6 0.6 0.6], 'MarkerSize', 3);
                    hold on
                    plot(time, meanSI, 'Color', roi.Color);
                    plot(time([firstNIdxs, lastNIdxs]), meanSI([firstNIdxs, lastNIdxs]), 'k.')
                    plot(x, y, 'Color', [0.4 0.4 0.4]);
                end
            end
        end

        %% ComputeCorrectionUsingRoi3Ds
        function slope = ComputeCorrectionUsingRoi3Ds(this)
            slope = 0;
            warning('Support for drift corrections with 3D ROIs is not yet implemented.');
        end
    end

    %% Private Methods
    methods (Access = private)
        %% DriftCorrectionDialogModelNullConstructor
        function DriftCorrectionDialogModelNullConstructor(this)
            this.UseDriftCorrection = true;
            this.ShowFitPlots = false;
            this.NumberOfSamplesToUseForCorrection = 20;
            this.CorrectionSlope = 0.0;
            this.UseMultipleRois = true;
            this.RoiDimensionality = '2D';
            this.UseMuscleAsReferenceTissue = true;
            this.UseSpinalCordAsReferenceTissue = false;
            this.UseFatAsReferenceTissue = false;
            this.UseSpleenAsReferenceTissue = false;
            this.SavedScreenPosition = double.empty;
        end

        %% DriftCorrectionDialogModelCopyConstructor
        function DriftCorrectionDialogModelCopyConstructor(this, modelToCopy)
            this.UseDriftCorrection = modelToCopy.UseDriftCorrection;
            this.ShowFitPlots = modelToCopy.ShowFitPlots;
            this.NumberOfSamplesToUseForCorrection = modelToCopy.NumberOfSamplesToUseForCorrection;
            this.CorrectionSlope = modelToCopy.CorrectionSlope;
            this.UseMultipleRois = modelToCopy.UseMultipleRois;
            this.RoiDimensionality = modelToCopy.RoiDimensionality;
            this.UseMuscleAsReferenceTissue = modelToCopy.UseMuscleAsReferenceTissue;
            this.UseSpinalCordAsReferenceTissue = modelToCopy.UseSpinalCordAsReferenceTissue;
            this.UseFatAsReferenceTissue = modelToCopy.UseFatAsReferenceTissue;
            this.UseSpleenAsReferenceTissue = modelToCopy.UseSpleenAsReferenceTissue;
            this.SavedScreenPosition = modelToCopy.SavedScreenPosition;
        end
    end

    %% Public Static Methods
    methods (Static)
    end

    %% Private Static Methods
    methods (Static, Access = private)
    end
end