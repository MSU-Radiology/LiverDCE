classdef ThresholdExistingRegionSettings < images.automation.volume.settings.Settings
    % ThresholdExistingRegionSettings   Gathers input parameters for the ThresholdExistingRegion segmentation algorithm
    %                                   via a graphical user interface displayed to the user
    %
    % Used MATLAB's MorphologySettings.m as a template to write this code
    %
    % Modifications:  Michigan State University
    % Author:  Matt Latourette

    properties
        ThresholdLabel
        Threshold
    end

    methods
        %% initialize
        function initialize(this)
            this.Parameters = struct('Threshold', 500);
            this.Size = [300, 110];
        end

        %% createUI
        function createUI(this, hPanel)
            addLabels(this, hPanel);
            addThreshold(this, hPanel);
        end
    end

    methods (Access = protected)
        %% addLabels
        function addLabels(this, hPanel)
            positionVec = [this.ButtonSpace, 1 + this.ButtonSize(2) + this.ButtonSpace, ...
                round((this.Size(1) - (3*this.ButtonSpace))/2), this.ButtonSize(2)];
            this.ThresholdLabel = uilabel('Parent', hPanel, ...
                'Position', positionVec, ...
                'FontSize', 12, ...
                'HorizontalAlignment', 'right', ...
                'Text', 'Threshold', ...
                'Tooltip', 'Threshold');
        end

        %% addThreshold
        function addThreshold(this, hPanel)
            positionVec = [round((this.Size(1) - (3*this.ButtonSpace))/2) + (2*this.ButtonSpace), ...
                1 + this.ButtonSize(2) + this.ButtonSpace, round((this.Size(1) - (3*this.ButtonSpace))/2), ...
                this.ButtonSize(2)];
            this.Threshold = uispinner(hPanel, ...
                'Position', positionVec, ...
                'Value', this.Parameters.Threshold, ...
                'Limits', [10 Inf], ...
                'RoundFractionalValues', 'off', ...
                'Step', 10, ...
                'Tag', 'Threshold', ...
                'ValueChangedFcn', @(~, uiEvent) thresholdValueChanged(this, uiEvent));
        end

        %% thresholdValueChanged
        function thresholdValueChanged(this, uiEvent)
            this.Parameters.Threshold = uiEvent.Value;
        end
    end
end