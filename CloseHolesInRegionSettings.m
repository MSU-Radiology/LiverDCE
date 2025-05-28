classdef CloseHolesInRegionSettings < images.automation.volume.settings.Settings
    % CloseHolesInRegionSettings    Gathers input parameters for the CloseHolesInRegion segmentation algorithm via a
    %                               graphical user interface displayed to the user
    %
    % Used MATLAB's MorphologySettings.m as a template to write this code
    % 
    % Modifications by Michigan State University
    % Author:   Matt Latourette

    properties
        SphereRadiusLabel
        SphereRadius
    end

    methods
        %% initialize
        function initialize(this)
            this.Parameters = struct('SphereRadius', 3);
            this.Size = [300, 110];
        end

        %% createUI
        function createUI(this, hPanel)
            addLabels(this, hPanel);
            addSphereRadius(this, hPanel);
        end
    end

    methods (Access = protected)
        %% addLabels
        function addLabels(this, hPanel)
            positionVec = [this.ButtonSpace, 1 + this.ButtonSize(2) + this.ButtonSpace, ...
                round((this.Size(1) - (3*this.ButtonSpace))/2), this.ButtonSize(2)];
            this.SphereRadiusLabel = uilabel('Parent', hPanel, ...
                'Position', positionVec, ...
                'FontSize', 12, ...
                'HorizontalAlignment', 'right', ...
                'Text', 'Sphere Radius', ...
                'Tooltip', 'Sphere Radius');
        end

        %% addSphereRadius
        function addSphereRadius(this, hPanel)
            positionVec = [round((this.Size(1) - (3*this.ButtonSpace))/2) + (2*this.ButtonSpace), ...
                1 + this.ButtonSize(2) + this.ButtonSpace, round((this.Size(1) - (3*this.ButtonSpace))/2), ...
                this.ButtonSize(2)];
            this.SphereRadius = uispinner(hPanel, ...
                'Position', positionVec, ...
                'Value', this.Parameters.SphereRadius, ...
                'Limits', [1 50], ...
                'RoundFractionalValues', 'on', ...
                'Step', 1, ...
                'Tag', 'Sphere Radius', ...
                'ValueChangedFcn', @(~, uiEvent) sphereRadiusValueChanged(this, uiEvent));
        end

        %% sphereRadiusValueChanged
        function sphereRadiusValueChanged(this, uiEvent)
            this.Parameters.SphereRadius = uiEvent.Value;
        end
    end
end