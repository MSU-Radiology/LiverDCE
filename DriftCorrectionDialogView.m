classdef DriftCorrectionDialogView < handle
    % DriftCorrectionDialogView       View class (MVC pattern) for the DriftCorrectionDialog GUI
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    %% Properties

    % Observable Properties (listeners receive notification of changes)
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
        function this = DriftCorrectionDialogView(model)
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
            this.OnChangedCorrectionSlope(model);
        end

        %% RegisterEventListeners
        function RegisterEventListeners(this)
            model = this.Model;
            addlistener(model, 'CorrectionSlope', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedCorrectionSlope(this, uiEvent.AffectedObject));
        end

        %% InitializeGui
        function InitializeGui(this)
            model = this.Model;
            hFig = figure('Visible', 'on', 'Name', 'Signal Drift Correction', 'NumberTitle', 'off', ...
                'ToolBar', 'none', 'MenuBar', 'none', 'Position', [680 487 330 330], 'Resize', 'on', ...
                'WindowStyle', 'normal');

            % Panels for grouping UI components
            hCurrentCorrectionPanel = uipanel('Parent', hFig, 'Title', 'Current Correction', ...
                'Units', 'Pixels', 'Position', [12 76 144 250]);
            hRoisToUsePanel = uipanel('Parent', hFig, 'Title', 'ROIs To Use', 'Units', 'Pixels', ...
                'Position', [168 60 150 266]);
            hReferenceTissuesPanel = uipanel('Parent', hRoisToUsePanel, 'Title', 'Reference Tissues', ...
                'Units', 'pixels', 'Position', [12 98 120 116]);
            hRoiDimensionalityButtonGroup = uibuttongroup('Parent', hRoisToUsePanel, 'Title', 'ROI Dimensionality', ...
                'Visible', 'off', 'Units', 'Pixels', 'Position', [12 12 120 76]);

            % Current Correction Panel
            hUseDriftCorrectionCheckBox = uicontrol('Parent', hCurrentCorrectionPanel, 'Style', 'checkbox', ...
                'String', 'Use Drift Correction', 'TooltipString', 'Use Drift Correction', ...
                'Value', model.UseDriftCorrection, 'Position', [12 210 150 20]);
            hCorrectionSlopeEditBox = uicontrol(hCurrentCorrectionPanel, 'Style', 'edit', ...
                'String', '1.0', 'TooltipString', 'Slope', 'Position', [12 180 120 22]);
            hResetCorrectionButton = uicontrol(hCurrentCorrectionPanel, 'Style', 'pushbutton', ...
                'String', 'Reset Correction', 'TooltipString', 'Reset Correction', 'Position', [12 150 120 22]);
            hNumberOfSamplesLabel = uicontrol(hCurrentCorrectionPanel, 'Style', 'text', ...
            'String', 'Number Of Samples', 'Tooltip', 'Number Of Samples', 'Units', 'pixels', ...
            'HorizontalAlignment', 'left', 'Position', [12 122 150 13]);
            hNumberOfSamplesEditBox = uicontrol(hCurrentCorrectionPanel, 'Style', 'edit', ...
                'String', model.NumberOfSamplesToUseForCorrection, 'Units', 'pixels', 'Position', [12 96 120 22]);
            hShowFitPlotsCheckBox = uicontrol(hCurrentCorrectionPanel, 'Style', 'checkbox', ...
                'String', 'Show Fit Plots', 'Tooltip', 'Show Fit Plots', 'Value', model.ShowFitPlots, ...
                'Position', [12 62 120 20]);
            hComputeCorrectionButton = uicontrol('Parent', hCurrentCorrectionPanel, 'Style', 'pushbutton', ...
                'String', 'Compute Correction', 'Position', [12 12 120 44]);

            % ROIs To Use Panel
            hUseMultipleRoisCheckBox = uicontrol('Parent', hRoisToUsePanel, 'Style', 'checkbox', ...
                'String', 'Use Multiple ROIs', 'TooltipString', 'Use Multiple ROIs For Correction', ...
                'Value', model.UseMultipleRois, 'Position', [12 224 120 20]);

            % ROI Dimensionality Panel
            hRoi2D = uicontrol(hRoiDimensionalityButtonGroup, 'Style', 'radiobutton', 'String', '2D', ...
                'Units', 'Pixels', 'Tooltip', '2D', 'HandleVisibility', 'off', 'Position', [12 32 90 20]);
            hRoi3D = uicontrol(hRoiDimensionalityButtonGroup, 'Style', 'radiobutton', 'String', '3D', ...
                'Units', 'Pixels', 'Tooltip', '3D', 'HandleVisibility', 'off', 'Position', [12 12 90 20]);
            switch(model.RoiDimensionality)
                case '2D'
                    hRoiDimensionalityButtonGroup.SelectedObject = hRoi2D;
                case '3D'
                    hRoiDimensionalityButtonGroup.SelectedObject = hRoi3D;
                otherwise
                    hRoiDimensionalityButtonGroup.SelectedObject = hRoi2D;
            end
            hRoiDimensionalityButtonGroup.Visible = 'on';

            % Reference Tissues Panel
            hMuscleCheckBox = uicontrol('Parent', hReferenceTissuesPanel, 'Style', 'checkbox', ...
                'String', 'Muscle', 'Tooltip', 'Muscle', 'Value', model.UseMuscleAsReferenceTissue, ...
                'Position', [12 72 90 20]);
            hSpinalCordCheckBox = uicontrol('Parent', hReferenceTissuesPanel, 'Style', 'checkbox', ...
                'String', 'Spinal Cord', 'Tooltip', 'Spinal Cord', 'Value', model.UseSpinalCordAsReferenceTissue, ...
                'Position', [12 52 90 20]);
            hFatCheckBox = uicontrol('Parent', hReferenceTissuesPanel, 'Style', 'checkbox', ...
                'String', 'Fat', 'Tooltip', 'Fat', 'Value', model.UseFatAsReferenceTissue, ...
                'Position', [12 32 90 20]);
            hSpleenCheckBox = uicontrol('Parent', hReferenceTissuesPanel, 'Style', 'checkbox', ...
                'String', 'Spleen', 'Tooltip', 'Spleen', 'Value', model.UseSpleenAsReferenceTissue, ...
                'Position', [12 12 90 20]);

            % Ok/Cancel Buttons
            hOkButton = uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'OK', ...
                'Position', [170 20 70 22]);
            hCancelButton = uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Cancel', ...
                'Position', [252 20 70 22]);

            this.UiControls = struct(...
                'Figure', hFig, ...
                'CurrentCorrectionPanel', hCurrentCorrectionPanel, ...
                'RoisToUsePanel', hRoisToUsePanel, ...
                'RoiDimensionalityButtonGroup', hRoiDimensionalityButtonGroup, ...
                'ReferenceTissuesPanel', hReferenceTissuesPanel, ...
                'MuscleCheckBox', hMuscleCheckBox, ...
                'SpinalCordCheckBox', hSpinalCordCheckBox, ...
                'FatCheckBox', hFatCheckBox, ...
                'SpleenCheckBox', hSpleenCheckBox, ...
                'UseDriftCorrectionCheckBox', hUseDriftCorrectionCheckBox, ...
                'CorrectionSlopeEditBox', hCorrectionSlopeEditBox, ...
                'ResetCorrectionButton', hResetCorrectionButton, ...
                'NumberOfSamplesLabel', hNumberOfSamplesLabel, ...
                'NumberOfSamplesEditBox', hNumberOfSamplesEditBox, ...
                'ShowFitPlotsCheckBox', hShowFitPlotsCheckBox, ...
                'ComputeCorrectionButton', hComputeCorrectionButton, ...
                'UseMultipleRoisCheckBox', hUseMultipleRoisCheckBox, ...
                'Roi2D', hRoi2D, ...
                'Roi3D', hRoi3D, ...
                'OkButton', hOkButton, ...
                'CancelButton', hCancelButton);

            this.NormalizeDisplayUnits();
            this.MoveToPosition();
            this.MakeVisible();
        end

        %% MakeVisible
        function MakeVisible(this)
            this.UiControls.Figure.Visible = 'on';
        end

        %% MoveToPosition
        function MoveToPosition(this)
            model = this.Model;
            savedScreenPosition = model.SavedScreenPosition;
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

        %% OnChangedCorrectionSlope
        function OnChangedCorrectionSlope(this, uiModel)
            uiControls = this.UiControls;
            uiControls.CorrectionSlopeEditBox.String = num2str(uiModel.CorrectionSlope);
        end
    end

    %% Static Methods
    methods (Static)
    end
end










