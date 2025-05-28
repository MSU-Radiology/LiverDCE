classdef GroundTruthFileRegionOfInterest < RegionOfInterest3D
    % GroundTruthFileRegionOfInterest   A representation of ROI data obtained from a groundTruthMed.mat file generated
    %                                   by MATLAB's Medical Image Labeler app
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    % Observable Properties (listeners receive notification of changes)
    properties (SetObservable = true, AbortSet = true)
        Label
        LabelId
        DrawnOnProjectionType
    end

    %% Public Computable Dependent Properties
    properties (SetObservable = true, AbortSet = true, Dependent = true)
        Color
        Tissue
        Mask
        Threshold
    end

    %% Protected properties
    properties (Access = protected)
        PrivateColor
        PrivateTissueType
        PrivateOriginalMask
        PrivateRefinedMask
        PrivateThreshold
    end

    methods
        %% Constructors
        function this = GroundTruthFileRegionOfInterest(groundTruth, index)
            arguments
                groundTruth groundTruthMedical = groundTruthMedical.empty
                index (1,1) {mustBeNumeric} = NaN
            end
            this@RegionOfInterest3D();

            if (isempty(groundTruth) || isnan(index))
                return
            end
            groundTruthRow = groundTruth.LabelDefinitions(index, :);
            this.Label = groundTruthRow.Name;
            choppedLabel = split(groundTruthRow.Name, '_on_');
            tissueType = TissueType.FromString(choppedLabel(1));
            if(isempty(tissueType))
                this = GroundTruthFileRegionOfInterest.empty;
                return
            end
            this.PrivateTissueType = tissueType;
            projectionName = choppedLabel(end);
            filename = strcat(projectionName, '.nii');
            intensityProjectionType = IntensityProjectionType.FromString(projectionName);
            this.DrawnOnProjectionType = intensityProjectionType;
            roiRow = endsWith([groundTruth.DataSource.Source{:}], filename);
            if(~any(roiRow))
                this = GroundTruthFileRegionOfInterest.empty;
                return
            end
            this.PrivateColor = groundTruthRow.LabelColor;
            this.LabelId = groundTruthRow.PixelLabelID;
            imagePath = groundTruth.DataSource.Source{roiRow};
            masksPath = groundTruth.LabelData(roiRow);
            if (~isfile(imagePath) || ~isfile(masksPath))
                this = GroundTruthFileRegionOfInterest.empty;
                return
            end
            labeledMasks = niftiread(masksPath);
            mask = false(size(labeledMasks));
            mask(labeledMasks == this.LabelId) = true;
            this.PrivateOriginalMask = mask;
            this.PrivateRefinedMask = logical.empty;
            this.PrivateThreshold = NaN;
            this.Initialized = true;
        end

        %% Getters for Computable Properties
        function color = get.Color(this)
            if(isempty(this))
                color = [];
                return
            end
            color = this.PrivateColor;
        end

        function tissue = get.Tissue(this)
            if(isempty(this))
                tissue = [];
                return
            end
            tissue = this.PrivateTissueType;
        end

        function mask = get.Mask(this)
            if(isempty(this))
                mask = [];
                return
            end
            tissueType = this.Tissue;
            if(tissueType.IsVessel && ~isempty(this.PrivateRefinedMask))
                mask = this.PrivateRefinedMask;
            else
                mask = this.PrivateOriginalMask;
            end
        end

        function threshold = get.Threshold(this)
            if(isempty(this))
                threshold = NaN;
                return
            end
            threshold = this.PrivateThreshold;
        end

        %% Getters and Setters
        function label = get.Label(this)
            if(isempty(this))
                label = string.empty;
                return
            end
            label = this.Label;
        end

        function labelId = get.LabelId(this)
            if(isempty(this))
                labelId = NaN;
                return
            end
            labelId = this.LabelId;
        end

        %% Other Class Methods

        %% CompareNonuniformProperties
        function bool = CompareNonuniformProperties(this, that, propertyName)
            bool = false(size(this,2), size(this,1));
            for index = 1:size(this, 1)
                dim1 = size(this(index).(propertyName));
                dim2 = size(that(index).(propertyName));
                if (any(size(dim1) ~= size(dim2)))
                    bool(index) = false;
                elseif (dim1 ~= dim2)
                    bool(index) = false;
                else
                    bool(index) = all(this(index).(propertyName) == that(index).(propertyName), 'all');
                end
            end
        end

        %% eq (Equality operator overload)
        function bool = eq(this, that)
            tolerance = this.EqualityTestTolerance;
            bool = eq@RegionOfInterest3D(this, that);    % test equality of properties of the superclass
            bool = bool & (arrayfun(@strcmp, [this.Label], [that.Label]));
            bool = bool & ((ismissing([this.LabelId]) & ismissing([that.LabelId])) | ...
                ([this.LabelId] == [that.LabelId]));
            bool = bool & ([this.DrawnOnProjectionType] == [that.DrawnOnProjectionType]);
            bool = bool & all( ...
                reshape([this.PrivateColor], [], size(this, 1)) == ...
                reshape([that.PrivateColor], [], size(that, 1)));
            bool = bool & ([this.PrivateTissueType] == [that.PrivateTissueType]);
            bool = bool & all( ...
                reshape([this.PrivateOriginalMask], [], size(this, 1)) == ...
                reshape([that.PrivateOriginalMask], [], size(that, 1)));
            bool = bool & this.CompareNonuniformProperties(that, 'PrivateRefinedMask');
            bool = bool & ((ismissing([this.PrivateThreshold]) & ismissing([that.PrivateThreshold])) | ...
                (abs([this.PrivateThreshold] - [that.PrivateThreshold]) < tolerance));
        end

        %% GetMaskToThreshold
        function mask = GetMaskToThreshold(this, dilationRadius)
            arguments
                this GroundTruthFileRegionOfInterest
                dilationRadius double = 1
            end
            if(this.PrivateTissueType.IsVessel)
                mask = GroundTruthFileRegionOfInterest.DilateVesselMask(this.PrivateOriginalMask, dilationRadius);
            else
                error('Thresholding of non-vessel ROIs is not supported.');
            end
        end

        %% GetOriginalMask
        function mask = GetOriginalMask(this)
            mask = this.PrivateOriginalMask;
        end

        %% GetRefinedMask
        function mask = GetRefinedMask(this)
            mask = this.PrivateRefinedMask;
        end

        %% ThresholdMask
        function thresholdedMask = ThresholdMask(this, threshold, imageToThreshold, dilationRadius)
            arguments
                this GroundTruthFileRegionOfInterest
                threshold double
                imageToThreshold {mustBeNumeric} 
                dilationRadius double = 1
            end
            vesselMask = this.GetMaskToThreshold(dilationRadius);
            thresholdedMask = zeros(size(vesselMask), 'logical');
            thresholdedMask(vesselMask & imageToThreshold > threshold) = true;
            this.PrivateThreshold = threshold;
            this.PrivateRefinedMask = thresholdedMask;
        end

        %% ApplyMaskToImage
        function maskedImage = ApplyMaskToImage(this, imageToMask)
            mask = this.Mask;
            maskedImage = zeros(size(imageToMask), 'uint16');
            maskedImage(mask) = imageToMask(mask);
        end
    end

    methods (Access = protected)
    end

    %% Protected Static Methods
    methods (Static, Access = protected)
        %% DilateVesselMask
        function dilatedVesselMask = DilateVesselMask(vesselRoiMask, dilationRadius)
            se = strel('sphere', dilationRadius);
            dilatedVesselMask = imdilate(vesselRoiMask, se);
        end
    end
end