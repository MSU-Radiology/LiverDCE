classdef RoiPickerModel < handle
    % RoiPickerModel    Model class (MVC pattern) for the RoiPicker GUI, which allows the user to pick the ROI to use 
    %                   for an analysis from among the available ROIs for a particular tissue
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    %% Properties
    
    % Observables (listeners receive notification of changes)
    properties (SetObservable = true, AbortSet = true)
        RoiSelection
        Cancelled(1,1) logical
    end
    
    % Read-only properties
    properties (SetAccess = private)
        RoiColors
    end
    
    % Private properties
    properties (Access = private)
    end
    
    % Computable dependent properties
    properties (Dependent = true, SetAccess = private)
    end
    
    %% Events
    events
    end
    
    %% Public Methods
    methods
        %% Constructors
        function this = RoiPickerModel(roiColors)
            % Constructor
            assert(ismatrix(roiColors), ...
                'LiverDCE:RoiPickerModel:argumentNotAMatrix', ...
                'Expected a matrix');
            assert(size(roiColors, 1) == 3, ...
                'LiverDCE:RoiPickerModel:nonRgbData', ...
                'Expected an 3 by N matrix of RGB color components');
            
            this.RoiColors = roiColors;
            this.RoiSelection = 1;
            this.Cancelled = true;
        end
        
        %% Getters and Setters
        function roiSelection = get.RoiSelection(this)
            roiSelection = this.RoiSelection;
        end
        
        function set.RoiSelection(this, value)
            this.RoiSelection = value;
        end
        
        function roiColors = get.RoiColors(this)
            roiColors = this.RoiColors;
        end
    end

    %% Private Methods
    methods (Access = private)
    end

    %% Static Methods
    methods (Static)
    end
end