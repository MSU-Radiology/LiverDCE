classdef ImageType < uint16
    % ImageType     Enumeration type for representing the kind of image to be displayed, exported, etc. This can be the
    %               original dynamic contrast-enhanced image or one of several different kinds of temporal projection
    %               images.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    enumeration
        DynamicContrastEnhanced (1)
        MaximumIntensityProjection (2)
        MinimumIntensityProjection (3)
        MeanIntensityProjection (4)
        StandardDeviationIntensityProjection (5)
        MedianIntensityProjection (6)
        InterquartileRangeIntensityProjection (7)
    end

    properties
    end

    methods
        %% IsProjection
        function bool = IsProjection(this)
            switch this
                case ImageType.DynamicContrastEnhanced
                    bool = false;
                case {ImageType.MaximumIntensityProjection, ImageType.MinimumIntensityProjection, ...
                        ImageType.MeanIntensityProjection, ImageType.StandardDeviationIntensityProjection, ...
                        ImageType.MedianIntensityProjection, ImageType.InterquartileRangeIntensityProjection}
                    bool = true;
                otherwise
                    bool = false;
            end
        end

        %% ToDisplayName
        function imageTypeName = ToDisplayName(this)
            switch this
                case ImageType.DynamicContrastEnhanced
                    imageTypeName = 'Dynamic Contrast-Enhanced';
                case ImageType.MaximumIntensityProjection
                    imageTypeName = 'Maximum Intensity Projection';
                case ImageType.MinimumIntensityProjection
                    imageTypeName = 'Minimum Intensity Projection';
                case ImageType.MeanIntensityProjection
                    imageTypeName = 'Mean Intensity Projection';
                case ImageType.StandardDeviationIntensityProjection
                    imageTypeName = 'S.D. Intensity Projection';
                case ImageType.MedianIntensityProjection
                    imageTypeName = 'Median Intensity Projection';
                case ImageType.InterquartileRangeIntensityProjection
                    imageTypeName = 'IQR Intensity Projection';
                otherwise
                    error('Invalid ImageType enumeration value');
            end
        end

        %% ToFilenamePrefix
        function filenamePrefix = ToFilenamePrefix(this)
            switch this
                case ImageType.DynamicContrastEnhanced
                    filenamePrefix = 'DCE';
                case ImageType.MaximumIntensityProjection
                    filenamePrefix = 'MaxIP';
                case ImageType.MinimumIntensityProjection
                    filenamePrefix = 'MinIP';
                case ImageType.MeanIntensityProjection
                    filenamePrefix = 'MeanIP';
                case ImageType.StandardDeviationIntensityProjection
                    filenamePrefix = 'SDIP';
                case ImageType.MedianIntensityProjection
                    filenamePrefix = 'MedianIP';
                case ImageType.InterquartileRangeIntensityProjection
                    filenamePrefix = 'IQRIP';
                otherwise
                    error('Invalid ImageType enumeration value');
            end
        end
    end

    methods (Static)
        %% DisplayNames
        function imageTypeList = DisplayNames()
            types = ImageType(1:7);
            imageTypeList = arrayfun(@ToDisplayName, types, 'UniformOutput', false);
        end
    end
end