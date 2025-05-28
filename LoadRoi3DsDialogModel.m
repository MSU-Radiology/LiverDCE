classdef LoadRoi3DsDialogModel < handle
    % LoadRoi3DsDialogModel     Model class (MVC pattern) for the LoadRoi3DsDialog GUI, which represents information 
    %                           about the 3D ROIs to be loaded into LiverDCE for analysis
    %
    % Copyright (C) 2025    Michigan State University
    % Author: Matt Latourette

    %% Properties
    
    % Observable Properties (listeners receive notification of changes)
    properties (SetObservable = true, AbortSet = true)
        FullyQualifiedGroundTruthFilename
        UseExistingThresholds(1,1) logical
        IntensityProjectionData struct
        RoiList RegionOfInterest3D = GroundTruthFileRegionOfInterest.empty
        GroundTruthData
        SavedScreenPosition
        Cancelled(1,1) logical
    end
    
    properties (SetObservable = true, AbortSet = true, Hidden = true)
    end
    
    % Observable Properties without the AbortSet attribute
    properties (SetObservable = true)
    end
    
    % Private Properties
    properties (Access = private)
    end
        
    % Public Computable Dependent Properties
    properties (SetObservable = true, Dependent = true)
        IsReadyToLoadRois(1,1) logical
        GroundTruthFilePath
    end
    
    % Private Computable Dependent Properties
    properties (Dependent = true, SetAccess = private)
    end
    
    %% Events
    events
        DisplayExistingRoi3DThresholdsRequest
        ThresholdVascularRoi3DRequest
    end
    
    %% Public Constructors
    methods
        function this = LoadRoi3DsDialogModel(varargin)
            switch nargin
                case 0
                    this.LoadRoi3DsDialogModelNullConstructor();
                case 1
                    m = varargin{1};
                    if(~isempty(m))
                        this.LoadRoi3DsDialogModelCopyConstructor(m);
                    else
                        this.LoadRoi3DsDialogModelNullConstructor();
                    end
                otherwise
                    error('LoadRoi3DsDialogModel received too many arguments');
            end
        end
    end

    %% Private Constructors
    methods (Access = private)
        %% LoadRoi3DsDialogModelNullConstructor
        function LoadRoi3DsDialogModelNullConstructor(this)
            this.FullyQualifiedGroundTruthFilename = '';
            this.UseExistingThresholds = true;
            this.IntensityProjectionData = struct;
            this.RoiList = GroundTruthFileRegionOfInterest.empty;
            this.GroundTruthData = [];
            this.SavedScreenPosition = '';
        end

        %% LoadRoi3DsDialogModelCopyConstructor
        function LoadRoi3DsDialogModelCopyConstructor(this, modelToCopy)
            this.FullyQualifiedGroundTruthFilename = modelToCopy.FullyQualifiedGroundTruthFilename;
            this.UseExistingThresholds = modelToCopy.UseExistingThresholds;
            this.IntensityProjectionData = modelToCopy.IntensityProjectionData;
            this.RoiList = modelToCopy.RoiList;
            this.GroundTruthData = modelToCopy.GroundTruthData;
            this.SavedScreenPosition = modelToCopy.SavedScreenPosition;
        end
    end

    %% Public Methods
    methods
        %% Getters for Computable Properties
        function ready = get.IsReadyToLoadRois(this)
            ready = false;
            if(isempty(this))
                return
            end
            
            fullyQualifiedFilename = this.FullyQualifiedGroundTruthFilename;
            if(~isempty(fullyQualifiedFilename) && isfile(fullyQualifiedFilename) && ...
                    endsWith(fullyQualifiedFilename, '.mat', 'IgnoreCase', true))
                ready = true;
            end
        end

        function path = get.GroundTruthFilePath(this)
            [path, ~, ~] = fileparts(this.FullyQualifiedGroundTruthFilename);
        end
        
        %% Getters and Setters
        function path = get.FullyQualifiedGroundTruthFilename(this)
            path = this.FullyQualifiedGroundTruthFilename;
        end
        
        function set.FullyQualifiedGroundTruthFilename(this, str)
            this.FullyQualifiedGroundTruthFilename = str;
        end

        function bool = get.UseExistingThresholds(this)
            bool = this.UseExistingThresholds;
        end
        
        function set.UseExistingThresholds(this, value)
            if(islogical(value))
                this.UseExistingThresholds = value;
            end
        end

        function roiData = get.IntensityProjectionData(this)
            roiData = this.IntensityProjectionData;
        end

        function set.IntensityProjectionData(this, roiData)
            this.IntensityProjectionData = roiData;
        end

        function roiList = get.RoiList(this)
            roiList = this.RoiList;
        end

        function set.RoiList(this, roiList)
            arguments
                this LoadRoi3DsDialogModel
                roiList RegionOfInterest3D
            end
            this.RoiList = roiList;
        end
        
        function position = get.SavedScreenPosition(this)
            position = this.SavedScreenPosition;
        end
        
        function set.SavedScreenPosition(this, value)
            this.SavedScreenPosition = value;
        end
        
        %% Other Class Methods

        %% FullyQualifiedGroundTruthFilenameDiffers
        function bool = FullyQualifiedGroundTruthFilenameDiffers(this, previous)
            arguments
                this LoadRoi3DsDialogModel
                previous LoadRoi3DsDialogModel
            end
            
            bool = false;
            fullyQualifiedFilename = this.FullyQualifiedGroundTruthFilename;
            if(isempty(fullyQualifiedFilename))
                return
            end
            if(isempty(previous) || ~strcmp(fullyQualifiedFilename, previous.FullyQualifiedGroundTruthFilename))
                bool = true;
            end
        end

        %% UseExistingThresholdsDiffers
        function bool = UseExistingThresholdsDiffers(this, previous)
            arguments
                this LoadRoi3DsDialogModel
                previous LoadRoi3DsDialogModel
            end

            bool = false;
            if(~isempty(previous))
                bool = this.UseExistingThresholds ~= previous.UseExistingThresholds;
            end
        end

        %% LoadRois
        function success = LoadRois(this)
            arguments
                this LoadRoi3DsDialogModel
            end

            success = false;
            if(~this.IsReadyToLoadRois)
                return
            end
            load(this.FullyQualifiedGroundTruthFilename, 'gTruthMed');
            this.GroundTruthData = gTruthMed;
            this.ExtractRoi3DData();
            success = true;
        end

        %% UpdateExisting3DRoiThresholdsDisplay
        function UpdateExisting3DRoiThresholdsDisplay(this)
            temp = this.UseExistingThresholds;
            this.UseExistingThresholds = true;
            this.LoadRois();
            this.UseExistingThresholds = temp;

            maximumIntensityProjectionImage = this.IntensityProjectionData.Maximum.Image;

            % TODO: should actually save these masks instead of regenerating them
            dilationRadius = 1;

            roiList = this.RoiList;
            roiTissues = [roiList(:).Tissue];
            abdominalAortaRois = roiList(roiTissues == TissueType.AbdominalAorta);
            abdominalAortaRoiDrawnOnProjectionTypes = [abdominalAortaRois(:).DrawnOnProjectionType];
            abdominalAortaRoiToUse = abdominalAortaRois(abdominalAortaRoiDrawnOnProjectionTypes == ...
                IntensityProjectionType.Maximum);

            abdominalAortaThresholdRequestData = ThresholdVascularRoi3DRequestData(abdominalAortaRoiToUse, ...
                maximumIntensityProjectionImage, dilationRadius);
            notify(this, 'DisplayExistingRoi3DThresholdsRequest', abdominalAortaThresholdRequestData);

            portalVeinRois = roiList(roiTissues == TissueType.PortalVein);
            portalVeinRoiDrawnOnProjectionTypes = [portalVeinRois(:).DrawnOnProjectionType];
            portalVeinRoiToUse = portalVeinRois(portalVeinRoiDrawnOnProjectionTypes == ...
                IntensityProjectionType.Maximum);

            portalVeinThresholdRequestData = ThresholdVascularRoi3DRequestData(portalVeinRoiToUse, ...
                maximumIntensityProjectionImage, dilationRadius);
            notify(this, 'DisplayExistingRoi3DThresholdsRequest', portalVeinThresholdRequestData);
        end

        %% UpdateThreshold3DVascularRois
        function UpdateThreshold3DVascularRois(this, abdominalAortaRoi,  portalVeinRoi, ...
                maximumIntensityProjectionImage, dilationRadius)
            AAThresholdRequestData = ThresholdVascularRoi3DRequestData(abdominalAortaRoi, ...
                maximumIntensityProjectionImage, dilationRadius);
            notify(this, 'ThresholdVascularRoi3DRequest', AAThresholdRequestData);

            PVThresholdRequestData = ThresholdVascularRoi3DRequestData(portalVeinRoi, ...
                maximumIntensityProjectionImage, dilationRadius);
            notify(this, 'ThresholdVascularRoi3DRequest', PVThresholdRequestData);
        end

        %% LoadRoisWithThresholdsAndMasks
        function success = LoadRoisWithThresholdsAndMasks(this, path, filename)
            arguments
                this(1,1) LoadRoi3DsDialogModel 
                path {mustBeTextScalar} = this.GroundTruthFilePath;
                filename {mustBeTextScalar} = 'RoisWithThresholdsAndMasks.mat';
            end
            success = false;
            fullyQualifiedFilename = fullfile(path, filename);
            if(~exist(fullyQualifiedFilename, 'file'))
                return
            end
            variables = {'RoiList'};
            load(fullyQualifiedFilename, variables{:});
            this.RoiList = RoiList; %#ok<CPROPLC>
            success = true;
        end
    end

    %% Private Methods
    methods (Access = private)
        %% ExtractAllTissueRois
        function ExtractAllTissueRois(this)
            % Gets the data for each ROI from the ground truth file and creates an instance of a
            % GroundTruthFileRegionOfInterest (a subclass of RegionOfInterest3D) to represent it

            groundTruth = this.GroundTruthData;
            numberOfRois = size(groundTruth.LabelDefinitions, 1);
            % % NOTE: The line below was commented out in order to make the program work in version R2023a after
            % % discovering that an unresolved bug in R2024a prevents me from saving the fit plots correctly. This
            % % code had to be commented out because createArray is only available in R2024a.
            % % See: https://www.mathworks.com/support/bugreports/3257717
            % roiList = createArray(1, numberOfRois, 'GroundTruthFileRegionOfInterest');
            for index = 1:numberOfRois
                roi = GroundTruthFileRegionOfInterest(groundTruth, index);
                if (~isempty(roi))
                    roiList(index) = roi;
                end
            end
            roiList = roiList([roiList(:).Initialized]);
            this.RoiList = roiList;
        end

        %% ExtractTemporalIntensityProjectionData
        function [imagePath, image, masksPath, labeledMasks] = ExtractTemporalIntensityProjectionData(this, ...
                filename)
            groundTruth = this.GroundTruthData;
            index = endsWith([groundTruth.DataSource.Source{:}], filename);
            imagePath = groundTruth.DataSource.Source{index};
            masksPath = groundTruth.LabelData(index);
            image = niftiread(imagePath);
            labeledMasks = niftiread(masksPath);
        end

        %% ExtractMaximumIntensityProjectionData
        function ExtractMaximumIntensityProjectionData(this, filename)
            [imagePath, image, masksPath, ~] = this.ExtractTemporalIntensityProjectionData(filename);
            this.IntensityProjectionData.Maximum.ImagePaths = imagePath;
            this.IntensityProjectionData.Maximum.MaskPaths = masksPath;
            this.IntensityProjectionData.Maximum.Image = image;
        end

        %% ExtractMeanIntensityProjectionData
        function ExtractMeanIntensityProjectionData(this, filename)
            [imagePath, image, masksPath, ~] = this.ExtractTemporalIntensityProjectionData(filename);
            this.IntensityProjectionData.Mean.ImagePaths = imagePath;
            this.IntensityProjectionData.Mean.MaskPaths = masksPath;
            this.IntensityProjectionData.Mean.Image = image;
        end

        %% PickNewVascularRoiThresholds
        function PickNewVascularRoiThresholds(this)
            dilationRadius = 1;
            roiList = this.RoiList;
            roiTissues = [roiList(:).Tissue];
            abdominalAortaRois = roiList(roiTissues == TissueType.AbdominalAorta);
            abdominalAortaRoiDrawnOnProjectionTypes = [abdominalAortaRois(:).DrawnOnProjectionType];
            abdominalAortaRoiToUse = abdominalAortaRois(abdominalAortaRoiDrawnOnProjectionTypes == ...
                IntensityProjectionType.Maximum);

            portalVeinRois = roiList(roiTissues == TissueType.PortalVein);
            portalVeinRoiDrawnOnProjectionTypes = [portalVeinRois(:).DrawnOnProjectionType];
            portalVeinRoiToUse = portalVeinRois(portalVeinRoiDrawnOnProjectionTypes == ...
                IntensityProjectionType.Maximum);

            maximumIntensityProjectionImage = this.IntensityProjectionData.Maximum.Image;
            this.UpdateThreshold3DVascularRois(abdominalAortaRoiToUse, portalVeinRoiToUse, ...
                maximumIntensityProjectionImage, dilationRadius);
            this.SaveRoisWithThresholdsAndMasks();
        end

        %% ExtractRoi3DData
        function ExtractRoi3DData(this)
            this.ExtractMaximumIntensityProjectionData('MaxIP.nii');
            this.ExtractMeanIntensityProjectionData('MeanIP.nii');
            this.ExtractAllTissueRois();           

            if(~(this.UseExistingThresholds && this.LoadRoisWithThresholdsAndMasks()) || ...
                    ~this.UseExistingThresholds)
                this.PickNewVascularRoiThresholds();
            end
        end

        %% SaveRoisWithThresholdsAndMasks
        function SaveRoisWithThresholdsAndMasks(this)
            path = this.GroundTruthFilePath;
            filename = 'RoisWithThresholdsAndMasks.mat';
            fullyQualifiedFilename = fullfile(path, filename);
            RoiList = this.RoiList; %#ok<NASGU,PROP>
            variables = {'RoiList'};
            save(fullyQualifiedFilename, variables{:});
        end
    end
    
    %% Static Methods
    methods(Static)
    end

    methods (Static, Access = protected)
    end
end