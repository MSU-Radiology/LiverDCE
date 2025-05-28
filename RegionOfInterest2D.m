classdef (Abstract) RegionOfInterest2D < RegionOfInterest
    % RegionOfInterest2D    Abstract class for representing regions of a 2-dimensional image
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    %% Read-only properties
    properties (SetAccess = protected, GetAccess = public)
        Dimensionality
    end

    %% Public Methods
    methods
        %% Constructors
        function this = RegionOfInterest2D()
            this.Dimensionality = RoiDimensionality.TwoDimensional;
        end

        %% eq (Equality operator overload)
        function bool = eq(this, that)
            bool = eq@RegionOfInterest(this, that);    % test equality of properties of the superclass
        end
    end
end