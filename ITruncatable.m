classdef (Abstract) ITruncatable < handle
    % ITruncatable  Interface class that represents the common data and functionality for a parameterized model that
    %               supports optionally truncating the time series data to simulate model fits with a shorter
    %               experimental timeframe or for using only a partial data set to fit certain model parameters that
    %               may be fit more accurately by excluding late time points and then treating those model parameters 
    %               as fixed for a second optimization using the complete time series
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    %% Abstract properties
    properties (Abstract, SetAccess = protected, GetAccess = public)
        TruncateData(1,1) logical
        TruncationIndex(1,1) double
    end

    %% Read-only concrete properties
    properties (SetAccess = immutable, GetAccess = public)
        IsTruncatable (1,1) logical = true;
    end

    %% Abstract methods
    methods (Abstract, Access = public)
        EnableDataTruncation(this, truncationIndex);

        DisableDataTruncation(this);
    end
end