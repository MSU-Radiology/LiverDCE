classdef RoiDimensionality < uint16
    % RoiType       Enumeration type for representing the kind of regions of interest to be used in estimating the 
    %               model parameters.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    enumeration
        TwoDimensional (2)
        ThreeDimensional (3)
    end

    properties
    end

    methods
        %% Is3D
        function bool = Is3D(this)
            switch this
                case RoiDimensionality.ThreeDimensional
                    bool = true;
                otherwise
                    bool = false;
            end
        end

        %% ToDisplayName
        function imageTypeName = ToDisplayName(this)
            switch this
                case RoiDimensionality.TwoDimensional
                    imageTypeName = '2D';
                case RoiDimensionality.ThreeDimensional
                    imageTypeName = '3D';
                otherwise
                    error('Invalid RoiDimensionality enumeration value');
            end
        end

        %% ToPopUpMenuValue
        function popUpMenuValue = ToPopUpMenuValue(this)
            switch this
                case RoiDimensionality.TwoDimensional
                    popUpMenuValue = 1;
                case RoiDimensionality.ThreeDimensional
                    popUpMenuValue = 2;
                otherwise
                    error('Invalid RoiDimensionality enumeration value');
            end
        end
    end

    methods (Static)
        %% DisplayNames
        function roiTypeList = DisplayNames()
            types = [RoiDimensionality.TwoDimensional, RoiDimensionality.ThreeDimensional];
            roiTypeList = arrayfun(@ToDisplayName, types, 'UniformOutput', false);
        end

        %% FromDisplayName
        function dimensionality = FromDisplayName(displayName)
            switch displayName
                case '2D'
                    dimensionality = RoiDimensionality.TwoDimensional;
                case '3D'
                    dimensionality = RoiDimensionality.ThreeDimensional;
                otherwise
                    error('Invalid RoiDimensionality display name');
            end
        end
    end
end