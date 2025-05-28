classdef LoadRoi3DsDialogView < handle
    % LoadRoi3DsDialogView      View class (MVC pattern) for the LoadRoi3DsDialog GUI
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    %% Properties

    % Observable Properties (listeners receive notification of changes
    properties (SetObservable = true, AbortSet = true)
        Model
        UiControls
    end

    % Dependent properties
    properties (SetObservable = true, AbortSet = true, Dependent = true)
    end

    % Private Properties
    properties (Access = private)
    end

    % Private Computable Dependent Properties
    properties (Dependent = true, SetAccess = private)
    end

    %% Events
    events
    end

    %% Public Methods
    methods
        %% Constructors
        function this = LoadRoi3DsDialogView(model)
            this.Model = model;

            % build the GUI
            this.InitializeGui();
            this.TriggerUiControlInitialization();
            this.RegisterEventListeners();
        end

        %% Getters for Computable Dependent Properties

        %% Getters and Setters
        function model = get.Model(this)
            model = this.Model;
        end

        function set.Model(this, value)
            this.Model = value;
        end

        %% Other Public Methods
    end

    %% Private Methods
    methods (Access = private)
        %% TriggerUiControlInitialization
        function TriggerUiControlInitialization(this)
            model = this.Model;
            this.OnChangedFullyQualifiedGroundTruthFilename(model);
        end

        %% RegisterEventListeners
        function RegisterEventListeners(this)
            model = this.Model;
            addlistener(model, 'FullyQualifiedGroundTruthFilename', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedFullyQualifiedGroundTruthFilename(this, uiEvent.AffectedObject));
            addlistener(model, 'DisplayExistingRoi3DThresholdsRequest', @(uiControl,uiEvent) ...
                OnDisplayExistingRoi3DThresholdsRequest(this, uiEvent));
            addlistener(model, 'ThresholdVascularRoi3DRequest', @(uiControl,uiEvent) ...
                OnThresholdVascularRoi3DRequest(this, uiEvent));
        end

        %% InitializeGui
        function InitializeGui(this)
            model = this.Model;
            hFig = figure('Visible', 'off', ...
                'Name', 'Load Regions of Interest', ...
                'NumberTitle', 'off', ...
                'Position', [0 0 936 174], ...
                'Resize', 'on', ...
                'ToolBar', 'none', ...
                'MenuBar', 'none', ...
                'WindowStyle', 'normal');
            % Leaving the windowing mode at normal for now to make testing easier. May switch to modal later.
            %         'WindowStyle', 'modal');

            % Panels for grouping UI components
            hRoiFileOptionsPanel = uipanel(hFig, ...
                'Title', 'ROI File Options', ...
                'Units', 'Pixels', ...
                'Position', [8 50 920 120]);

            % ROI File Options Panel
            hFullyQualifiedGroundTruthFilenameLabel = uicontrol('Parent', hRoiFileOptionsPanel, ...
                'Style', 'text', ...
                'String', 'Filename and Path', ...
                'Units', 'Pixels', ...
                'HorizontalAlignment', 'left', ...
                'Position', [12 86 100 13]);
            hFullyQualifiedGroundTruthFilenameEditBox = uicontrol('Parent', hRoiFileOptionsPanel, ...
                'Style', 'edit', ...
                'String', model.FullyQualifiedGroundTruthFilename, ...
                'Units', 'Pixels', ...
                'Position', [12 38 896 44], ...
                'HorizontalAlignment', 'left', ...
                'Max', 2);
            hUseExistingThresholdsCheckBox = uicontrol('Parent', hRoiFileOptionsPanel, ...
                'Style', 'checkbox', ...
                'String', 'Use Existing Thresholds If Available', ...
                'Value', model.UseExistingThresholds, ...
                'Units', 'Pixels', ...
                'Position', [12 10 190 22]);
            hDisplayExistingRoi3DThresholdsButton = uicontrol('Parent', hRoiFileOptionsPanel, ...
                'Style', 'pushbutton', ...
                'String', 'Display Existing Thresholds', ...
                'Units', 'pixels', ...
                'Enable', 'off', ...
                'Position', [230 10 170 22]);
            hSelectFileButton = uicontrol('Parent', hRoiFileOptionsPanel, ...
                'Style', 'pushbutton', ...
                'String', 'Select File', ...
                'Units', 'pixels', ...
                'Position', [838 10 70 22]);

            hLoad3DRoisButton = uicontrol('Parent', hFig, ...
                'Style', 'pushbutton', ...
                'String', 'Load 3D ROIs', ...
                'Units', 'pixels', ...
                'Position', [754 20 80 22]);
            hCancelButton = uicontrol('Parent', hFig, ...
                'Style', 'pushbutton', ...
                'String', 'Cancel', ...
                'Units', 'pixels', ...
                'Position', [852 20 70 22]);

            this.UiControls = struct(...
                'Figure', hFig, ...
                'RoiFileOptionsPanel', hRoiFileOptionsPanel, ...
                'FullyQualifiedGroundTruthFilenameLabel', hFullyQualifiedGroundTruthFilenameLabel, ...
                'FullyQualifiedGroundTruthFilenameEditBox', hFullyQualifiedGroundTruthFilenameEditBox, ...
                'UseExistingThresholdsCheckBox', hUseExistingThresholdsCheckBox, ...
                'DisplayExistingRoi3DThresholdsButton', hDisplayExistingRoi3DThresholdsButton, ...
                'SelectFileButton', hSelectFileButton, ...
                'Load3DRoisButton', hLoad3DRoisButton, ...
                'CancelButton', hCancelButton);

            this.NormalizeDisplayUnits();
            this.MoveToPosition(model);
            this.MakeVisible();
        end

        %% MakeVisible
        function MakeVisible(this)
            this.UiControls.Figure.Visible = 'on';
        end

        %% MoveToPosition
        function MoveToPosition(this, uiModel)
            savedScreenPosition = uiModel.SavedScreenPosition;
            if(isempty(savedScreenPosition))
                % Move the GUI to the screen center
                movegui(this.UiControls.Figure, 'center');
            else
                movegui(this.UiControls.Figure, savedScreenPosition);
                movegui(this.UiControls.Figure, 'onscreen');
            end
        end

        %% NormalizeDisplayUnits
        function NormalizeDisplayUnits(this)
            controlsToExclude = {};
            uiControlNames = fieldnames(this.UiControls);
            numberOfUiControls = numel(uiControlNames);

            if (numberOfUiControls > 0)
                for controlIndex = 1:numberOfUiControls
                    controlName = uiControlNames{controlIndex};
                    if (~any(strcmp(controlsToExclude, controlName)))
                        uiControl = getfield(this.UiControls, controlName);
                        uiControl.Units = 'normalized';
                    end
                end
            end
        end

        %% OnChangedFullyQualifiedGroundTruthFilename
        function OnChangedFullyQualifiedGroundTruthFilename(this, uiModel)
            uiControls = this.UiControls;
            fullyQualifiedFilename = uiModel.FullyQualifiedGroundTruthFilename;
            if(isvalid(uiControls.FullyQualifiedGroundTruthFilenameEditBox))
                uiControls.FullyQualifiedGroundTruthFilenameEditBox.String = fullyQualifiedFilename;
                if(isempty(fullyQualifiedFilename))
                    this.DisableDisplayExistingRoi3DThresholdsButton();
                else
                    this.EnableDisplayExistingRoi3DThresholdsButton();
                end
            end
        end

        %% OnDisplayExistingRoi3DThresholdsRequest
        function OnDisplayExistingRoi3DThresholdsRequest(this, threshold3DVascularRoiRequestData)
            uiModel = threshold3DVascularRoiRequestData.Source;
            if (~uiModel.IsReadyToLoadRois)
                return
            end
            LoadRoi3DsDialogView.DisplayPartialVolumePixelThreshold(threshold3DVascularRoiRequestData);
        end

        %% OnThresholdVascularRoi3DRequest
        function OnThresholdVascularRoi3DRequest(this, threshold3DVascularRoiRequestData)
            uiModel = threshold3DVascularRoiRequestData.Source;
            if (~uiModel.IsReadyToLoadRois)
                return
            end

            [success, threshold] = LoadRoi3DsDialogView.DeterminePartialVolumePixelThreshold(...
                threshold3DVascularRoiRequestData);
            if(~success)
                return
            end
            roi = threshold3DVascularRoiRequestData.Roi;
            imageToThreshold = threshold3DVascularRoiRequestData.ImageToThreshold;
            dilationRadius = threshold3DVascularRoiRequestData.DilationRadius;
            thresholdedMask = roi.ThresholdMask(threshold, imageToThreshold, dilationRadius);
        end

        %% Uicontrol Enablers/Disablers
        function EnableDisplayExistingRoi3DThresholdsButton(this)
            uiControls = this.UiControls;
            uiControls.DisplayExistingRoi3DThresholdsButton.Enable = 'on';
        end

        function DisableDisplayExistingRoi3DThresholdsButton(this)
            uiControls = this.UiControls;
            uiControls.DisplayExistingRoi3DThresholdsButton.Enable = 'off';
        end
    end

    %% Static Methods
    methods (Static)
        %% DeterminePartialVolumePixelThreshold
        function [success, threshold] = DeterminePartialVolumePixelThreshold(threshold3DVascularRoiRequestData)
            arguments
                threshold3DVascularRoiRequestData (1,1) ThresholdVascularRoi3DRequestData
            end
            success = false;
            roi = threshold3DVascularRoiRequestData.Roi;
            tissueType = roi.Tissue;
            imageToThreshold = threshold3DVascularRoiRequestData.ImageToThreshold;
            maskToThreshold = threshold3DVascularRoiRequestData.MaskToThreshold;
            axesHandle = LoadRoi3DsDialogView.PlotRankedPixelIntensity(imageToThreshold(maskToThreshold), ...
                roi.Color, tissueType.ToDisplayName());
            
            threshold = NaN;
            try
                % User selects a threshold by clicking on the plot
                [~, threshold] = ginput(1);
            catch exception
                switch exception.identifier
                    case 'MATLAB:ginput:FigureDeletionPause'
                        % User closed the figure without selecting a threshold
                        return
                    otherwise
                        rethrow(exception);
                end
            end
            yline(axesHandle, threshold, 'Color', [0 0 0]);
            threshold3DVascularRoiRequestData.Threshold = threshold;
            success = true;
        end

        %% DisplayPartialVolumePixelThreshold
        function DisplayPartialVolumePixelThreshold(threshold3DVascularRoiRequestData)
            roi = threshold3DVascularRoiRequestData.Roi;
            tissueType = roi.Tissue;
            imageToThreshold = threshold3DVascularRoiRequestData.ImageToThreshold;
            maskToThreshold = threshold3DVascularRoiRequestData.MaskToThreshold;
            threshold = roi.Threshold;

            axesHandle = LoadRoi3DsDialogView.PlotRankedPixelIntensity(imageToThreshold(maskToThreshold), ...
                roi.Color, tissueType.ToDisplayName());
            yline(axesHandle, threshold, 'Color', [0 0 0]);
        end

        %% PlotRankedPixelIntensity
        function axesHandle = PlotRankedPixelIntensity(pixelValues, color, plotTitle)
            % Display a plot of the pixels of an ROI sorted by intensity so that the user can identify an inflection 
            % point separating pixels fully within the vessel lumen from those exhibiting partial volume effect
            sortedPixelValues = sort(pixelValues);
            figureHandle = figure;
            axesHandle = axes('Parent', figureHandle);
            plot(axesHandle, sortedPixelValues, 'Color', color);
            hold(axesHandle, 'on');
            title(axesHandle, plotTitle);
            xlabel(axesHandle, 'Pixel Rank');
            ylabel(axesHandle, 'Pixel Value');
        end
    end
end