classdef (ConstructOnLoad) ThresholdVascularRoi3DRequestData < event.EventData
    % ThresholdVascularRoi3DRequestData class   Data structure that represents all of the data associated with a request
    %                                           to process an existing ROI by applying a threshold to exclude pixels
    %                                           having a signal intensity below the threshold
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    properties
        Roi RegionOfInterest3D = GroundTruthFileRegionOfInterest.empty
        MaskToThreshold(:,:,:) logical
        ImageToThreshold(:,:,:) double
        DilationRadius (1,1) double
        Threshold(1,1) double = 0
    end

    %% Public Constructor
    methods
        function data = ThresholdVascularRoi3DRequestData(roi, imageToThreshold, dilationRadius, threshold)
            arguments
                roi (1,1) GroundTruthFileRegionOfInterest
                imageToThreshold(:,:,:) double
                dilationRadius (1,1) double = 1
                threshold (1,1) double = 0
            end
            data.Roi = roi;
            data.ImageToThreshold = imageToThreshold;
            data.DilationRadius = dilationRadius;
            data.Threshold = threshold;
            maskToThreshold = roi.GetMaskToThreshold(dilationRadius);
            data.MaskToThreshold = maskToThreshold;
        end
    end
end