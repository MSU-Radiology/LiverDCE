classdef (Abstract) RegionOfInterest < handle
    % RegionOfInterest      Abstract base class for representing bounded regions of an image
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    % TODO: determine if this abstract class should be matlab.mixin.Heterogeneous

    %% Abstract properties
    properties (Abstract, SetAccess = protected, GetAccess = public)
        Dimensionality RoiDimensionality
    end

    %% Abstract, dependent properties
    properties (Abstract, SetObservable = true, AbortSet = true, Dependent = true)
        Color(1,3) single
        Tissue TissueType
        Mask
    end

    %% Concrete, dependent properties
    properties (SetObservable = true, AbortSet = true, Dependent = true)
        PixelCount
    end

    %% Protected, observable properties
    properties (SetObservable = true, SetAccess = protected)
        Initialized(1,1) logical
    end

    %% Constants
    properties (Constant, Access = protected)
        EqualityTestTolerance(1,1) double = 1E-20
    end

    %% Public, abstract methods (must be implemented by subclasses)
    methods (Abstract, Access = public)
    end

    %% Public, concrete methods
    methods
        %% eq (Equality operator overload)
        function bool = eq(this, that)
            if(size(this) ~= size(that))
                error('Arrays have incompatible sizes for this operation.');
            end
            bool = ([this.Dimensionality] == [that.Dimensionality]);
            bool = bool & ([this.Initialized] == [that.Initialized]);
            bool = bool & ([this.PixelCount] == [that.PixelCount]);
        end

        function count = get.PixelCount(this)
            mask = this.Mask;
            count = size(mask(mask == true), 1);
        end
    end
end