classdef ImtoolRegionOfInterest < RegionOfInterest2D
    % ImtoolRegionOfInterest    Wrapper class that hides implementation details of the imtool3D package, presenting 
    %                           data in the form of a RegionOfInterest2D class, thus decoupling code that depends upon 
    %                           2D ROIs from the specific implementation
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    %% Public Computable Dependent Properties
    properties (SetObservable = true, AbortSet = true, Dependent = true)
        Color
        Tissue
        Mask
    end

    %% Protected properties
    properties (Access = protected)
        PrivateRoi    % this class is a facade for 2D ROIs in the imtool3D package
    end

    methods
        %% Constructors
        function this = ImtoolRegionOfInterest(varargin)
            this@RegionOfInterest2D();
            if (nargin > 0)
                % wrapper for imtool3DROI objects (each 2D ROI is an instance of a subclass of imtool3DROI)
                roi = varargin{1};
                this.PrivateRoi = roi;
                this.Initialized = true;
            end
        end

        %% Getters for Computable Properties
        function mask = get.Mask(this)
            mask = this.PrivateRoi.getMeasurements().mask;
        end

        function color = get.Color(this)
            color = this.PrivateRoi.roiColor;
        end

        function tissueType = get.Tissue(this)
            tissue = this.PrivateRoi.roiTissue;
            tissueType = TissueType.FromString(tissue);
        end

        %% Other Class Methods

        %% eq (Equality operator overload)
        function bool = eq(this, that)
            bool = eq@RegionOfInterest2D(this, that);    % test equality of properties of the superclass
            bool = bool & ([this.PrivateRoi] == [that.PrivateRoi]);
        end
    end
end