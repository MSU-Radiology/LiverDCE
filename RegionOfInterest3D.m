classdef (Abstract) RegionOfInterest3D < RegionOfInterest
    % RegionOfInterest3D    Abstract class for representing 3-dimensional regions of an image stack
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    %% Read-only properties
    properties (SetAccess = protected, GetAccess = public)
        Dimensionality
    end

    methods
        %% Constructors
        function this = RegionOfInterest3D(varargin)
            this.Dimensionality = RoiDimensionality.ThreeDimensional;
        end

        %% eq (Equality operator overload)
        function bool = eq(this, that)
            bool = eq@RegionOfInterest(this, that);    % test equality of properties of the superclass
        end
    end

    %% Public Static Methods
    methods (Static)
        %% FilterByTissueCategory
        function filteredRoiList = FilterByTissueCategory(roiList, tissueCategory)
            arguments
                roiList RegionOfInterest3D
                tissueCategory char
            end
            if(iscolumn(roiList))
                roiList = roiList';
            end
            roiTissues = [roiList(:).Tissue];
            switch tissueCategory
                case 'OrganRois'
                    organRois = arrayfun(@IsOrgan, roiTissues);
                    filteredRoiList = roiList(organRois);
                    filteredRoiList = RegionOfInterest3D.FilterByProjectionType(filteredRoiList, ...
                        IntensityProjectionType.Mean);
                case 'VesselRois'
                    vesselRois = arrayfun(@IsVessel, roiTissues);
                    filteredRoiList = roiList(vesselRois);
                    filteredRoiList = RegionOfInterest3D.FilterByProjectionType(filteredRoiList, ...
                        IntensityProjectionType.Maximum);
                case 'AllRois'
                    organRoiList = RegionOfInterest3D.FilterByTissueCategory(roiList, 'OrganRois');
                    vesselRoiList = RegionOfInterest3D.FilterByTissueCategory(roiList, 'VesselRois');
                    filteredRoiList = horzcat(organRoiList, vesselRoiList);
                otherwise
                    organRoiList = RegionOfInterest3D.FilterByTissueCategory(roiList, 'OrganRois');
                    vesselRoiList = RegionOfInterest3D.FilterByTissueCategory(roiList, 'VesselRois');
                    filteredRoiList = horzcat(organRoiList, vesselRoiList);
            end
        end

        %% FilterByTissueType
        function filteredRoiList = FilterByTissueType(roiList, tissueType)
            arguments
                roiList RegionOfInterest3D
                tissueType TissueType
            end
            roiTissues = [roiList(:).Tissue];
            filteredRoiList = roiList(roiTissues == tissueType);
            if (tissueType.IsOrgan)
                filteredRoiList = RegionOfInterest3D.FilterByProjectionType(filteredRoiList, IntensityProjectionType.Mean);
            elseif (tissueType.IsVessel)
                filteredRoiList = RegionOfInterest3D.FilterByProjectionType(filteredRoiList, IntensityProjectionType.Maximum);
            end
        end

        %% FilterBySignalType
        function filteredRoiList = FilterBySignalType(roiList, signalType)
            arguments
                roiList RegionOfInterest3D
                signalType (1,1) SignalType
            end
            roiTissues = [roiList(:).Tissue];
            switch signalType
                case SignalType.EESConcentration
                    liverRois = roiTissues == TissueType.Liver;
                    filteredRoiList = roiList(~liverRois);
                case SignalType.IntracellularConcentration
                    spleenRois = roiTissues == TissueType.Spleen;
                    filteredRoiList = roiList(~spleenRois);
                otherwise
                    filteredRoiList = roiList;
            end
        end

        %% FilterByProjectionType
        function filteredRoiList = FilterByProjectionType(roiList, projectionType)
            arguments
                roiList RegionOfInterest3D
                projectionType (1,1) IntensityProjectionType
            end
            roiProjections = [roiList(:).DrawnOnProjectionType];
            switch projectionType
                case IntensityProjectionType.Maximum
                    maximumIpRois = roiProjections == IntensityProjectionType.Maximum;
                    filteredRoiList = roiList(maximumIpRois);
                case IntensityProjectionType.Minimum
                    minimumIpRois = roiProjections == IntensityProjectionType.Minimum;
                    filteredRoiList = roiList(minimumIpRois);
                case IntensityProjectionType.Mean
                    meanIpRois = roiProjections == IntensityProjectionType.Mean;
                    filteredRoiList = roiList(meanIpRois);
                case IntensityProjectionType.StandardDeviation
                    sdIpRois = roiProjections == IntensityProjectionType.StandardDeviation;
                    filteredRoiList = roiList(sdIpRois);
                case IntensityProjectionType.Median
                    medianIpRois = roiProjections == IntensityProjectionType.Median;
                    filteredRoiList = roiList(medianIpRois);
                case IntensityProjectionType.InterquartileRange
                    iqrIpRois = roiProjections == IntensityProjectionType.InterquartileRange;
                    filteredRoiList = roiList(iqrIpRois);
                otherwise
                    filteredRoiList = roiList;
            end
        end
    end
end