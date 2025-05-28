classdef (Abstract) IMultiStartOptimizable < handle
    % IMultiStartOptimizable    Interface that defines the common functionality and data shared by model classes that 
    %                           make use of the MultiStart global optimization algorithm for fitting the model's
    %                           parameters to empirical data
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette

    %% Abstract properties
    properties (Abstract, SetAccess = protected, GetAccess = public)
        NumberOfNarrowRangeStartPoints
        NumberOfWideRangeStartPoints
    end

    %% Read-only concrete properties
    properties (SetAccess = immutable, GetAccess = public)
        IsMultiStartOptimizable (1,1) logical = true;
    end

    %% Abstract methods
    methods (Abstract, Access = public)
        startingEstimates = GenerateStartingEstimatesForMultiStartOptimizer(this);
    end
end