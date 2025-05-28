classdef IntensityProjectionType < uint16
    % ProjectionType    Enumeration type for representing a particular type of projection
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    enumeration
        Maximum (1)
        Minimum (2)
        Mean (3)
        StandardDeviation (4)
        Median (5)
        InterquartileRange (6)
    end

    properties
    end

    methods
        %% ToDisplayName
        function intensityProjectionTypeName = ToDisplayName(this)
            switch this
                case IntensityProjectionType.Maximum
                    intensityProjectionTypeName = 'Maximum';
                case IntensityProjectionType.Minimum
                    intensityProjectionTypeName = 'Minimum';
                case IntensityProjectionType.Mean
                    intensityProjectionTypeName = 'Mean';
                case IntensityProjectionType.StandardDeviation
                    intensityProjectionTypeName = 'Standard Deviation';
                case IntensityProjectionType.Median
                    intensityProjectionTypeName = 'Median';
                case IntensityProjectionType.InterquartileRange
                    intensityProjectionTypeName = 'Interquartile Range';
                otherwise
                    error('Unknown IntensityProjectionType enumeration value');
            end
        end

        %% ToShortDisplayName
        function intensityProjectionTypeName = ToShortDisplayName(this)
            switch this
                case IntensityProjectionType.Maximum
                    intensityProjectionTypeName = 'Max';
                case IntensityProjectionType.Minimum
                    intensityProjectionTypeName = 'Min';
                case IntensityProjectionType.Mean
                    intensityProjectionTypeName = 'Mean';
                case IntensityProjectionType.StandardDeviation
                    intensityProjectionTypeName = 'SD';
                case IntensityProjectionType.Median
                    intensityProjectionTypeName = 'Median';
                case IntensityProjectionType.InterquartileRange
                    intensityProjectionTypeName = 'IQR';
                otherwise
                    error('Unknown IntensityProjectionType enumeration value');
            end
        end

        %% ToGroundTruthLabelSuffixName
        function groundTruthLabelSuffixName = ToGroundTruthLabelSuffixName(this)
            % The expected format for the label definitions in a ground truth file is
            % tissue_on_groundTruthLabelSuffixName, where tissue is one of:
            % liver, spleen, AA, PV, VC
            switch this
                case IntensityProjectionType.Maximum
                    groundTruthLabelSuffixName = 'MaxIP';
                case IntensityProjectionType.Minimum
                    groundTruthLabelSuffixName = 'MinIP';
                case IntensityProjectionType.Mean
                    groundTruthLabelSuffixName = 'MeanIP';
                case IntensityProjectionType.StandardDeviation
                    groundTruthLabelSuffixName = 'SDIP';
                case IntensityProjectionType.Median
                    groundTruthLabelSuffixName = 'MedianIP';
                case IntensityProjectionType.InterquartileRange
                    groundTruthLabelSuffixName = 'IQRIP';
                otherwise
                    error('Unknown IntensityProjectionType enumeration value');
            end
        end
    end

    methods (Static)
        %% DisplayNames
        function tissueTypeList = DisplayNames()
            types = enumeration('IntensityProjectionType');
            tissueTypeList = arrayfun(@ToDisplayName, types, 'UniformOutput', false);
        end

        %% FromString
        function intensityProjectionType = FromString(intensityProjectionTypeName)
            intensityProjectionTypeName = lower(intensityProjectionTypeName);
            switch intensityProjectionTypeName
                case {'maximum', 'max', 'max.', 'maxip'}
                    intensityProjectionType = IntensityProjectionType.Maximum;
                case {'minimum', 'min', 'min.', 'minip'}
                    intensityProjectionType = IntensityProjectionType.Minimum;
                case {'mean', 'average', 'meanip'}
                    intensityProjectionType = IntensityProjectionType.Mean;
                case {'standard deviation', 'standarddeviation', 'sd', 's.d.', 'sdip'}
                    intensityProjectionType = IntensityProjectionType.StandardDeviation;
                case {'median', 'med', 'med.', 'medianip'}
                    intensityProjectionType = IntensityProjectionType.Median;
                case {'interquartile range', 'interquartilerange', 'iqr', 'i.q.r.', 'iqrip'}
                    intensityProjectionType = IntensityProjectionType.InterquartileRange;
                otherwise
                    intensityProjectionType = IntensityProjectionType.empty;
            end
        end
    end
end