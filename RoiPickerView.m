classdef RoiPickerView < handle
    % RoiPickerView     View class (MVC pattern) for the RoiPicker GUI, which allows the user to pick the ROI to use 
    %                   for an analysis from among the available ROIs for a particular tissue
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
        function this = RoiPickerView(model, tissueType)
            this.Model = model;

            % build the GUI
            this.InitializeGui(tissueType);
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
            handles = this.UiControls;
            OnChangingRoiSelection(handles, model);
            OnChangedRoiSelection(handles, model);
        end

        %% RegisterEventListeners
        function RegisterEventListeners(this)
            model = this.Model;
            handles = this.UiControls;
            addlistener(model, 'RoiSelection', 'PreSet', @(uiControl,uiEvent) OnChangingRoiSelection(...
                handles, uiEvent.AffectedObject));
            addlistener(model, 'RoiSelection', 'PostSet', @(uiControl,uiEvent) OnChangedRoiSelection(...
                handles, uiEvent.AffectedObject));
        end

        %% InitializeGui
        function InitializeGui(this, tissueType)
            hFig = figure('Visible', 'off', 'Name', [tissueType, ' ROI'], ...
                'NumberTitle', 'off', 'Position', [761 1500 220 224], ...
                'Resize', 'on', 'ToolBar', 'none', 'MenuBar', 'none', 'WindowStyle', 'modal');

            hRoiButtonGroup = this.InitializeRoiButtonGroup(hFig, tissueType);
            hOkButton = uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'OK', ...
                'Position', [65 12.2 65.6 20.8]);
            hCancelButton = uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Cancel', ...
                'Position', [142.6 12.2 65.6 20.8]);

            this.UiControls = struct(...
                'Figure', hFig, ...
                'RoiButtonGroup', hRoiButtonGroup, ...
                'OkButton', hOkButton, ...
                'CancelButton', hCancelButton);

            this.NormalizeDisplayUnits();
            this.SetWindowTitle([tissueType, ' ROI']);
            this.MoveToPosition();
            this.MakeVisible();
        end

        %% InitializeRoiButtonGroup
        function hRoiButtonGroup = InitializeRoiButtonGroup(this, parent, tissueType)
            roiColors = this.Model.RoiColors;

            hRoiButtonGroup = uibuttongroup(parent, ...
                'Title', ['Select ', tissueType, ' Region of Interest'], ...
                'Visible', 'off', 'Units', 'pixels', 'Position', [6.6 42.6 209.6 173.6]);

            numberOfButtons = size(roiColors, 2);
            for buttonIndex = 1:numberOfButtons
                [xPosition, yPosition] = RoiPickerView.NthButtonCoordinates(buttonIndex);
                cdata = this.NthButtonCData(buttonIndex);
                backgroundColor = RoiPickerView.NthButtonBackgroundColor(buttonIndex);

                hRoi = uicontrol(hRoiButtonGroup, 'Style', 'radiobutton', 'CData', cdata, ...
                    'String', num2str(buttonIndex), 'Position', [xPosition yPosition 51.2 20], ...
                    'BackgroundColor', backgroundColor, 'HandleVisibility', 'off');
                hRoi.Units = 'normalized';
            end

            hRoiButtonGroup.Visible = 'on';
        end

        %% NthButtonCData
        function cdata = NthButtonCData(this, roiIndex)
            buttonSize = 16;
            mask = RoiPickerView.SelectionMask(buttonSize);

            roiColors = this.Model.RoiColors;
            cdata = repmat(reshape(roiColors(:, roiIndex), 1, 1, 3), buttonSize, buttonSize);
            if (roiIndex == 1)
                % first ROI is selected by default
                cdata(mask) = 1;
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

        %% SetWindowTitle
        function SetWindowTitle(this, title)
            this.UiControls.Figure.Name = title;
        end

        %% MakeVisible
        function MakeVisible(this)
            this.UiControls.Figure.Visible = 'on';
        end

        %% MoveToPosition
        function MoveToPosition(this)
            movegui(this.UiControls.Figure, 'center');
        end
    end

    %% Static Methods
    methods (Static)
        %% SelectionMask
        function mask = SelectionMask(buttonSize)
            mask = false(buttonSize,buttonSize,3);
            mask(3:4,3:end-2,:) = true;
            mask(end-3:end-2,3:end-2,:) = true;
            mask(3:end-2,3:4,:) = true;
            mask(3:end-2,end-3:end-2,:) = true;
        end

        %% NthButtonCoordinates
        function [xpos, ypos] = NthButtonCoordinates(roiIndex)
            xpos = 12.2+floor((roiIndex-1)/5)*64.8;
            ypos = 133-(mod(roiIndex-1, 5)*29.6);
        end

        %% NthButtonBackgroundColor
        function color = NthButtonBackgroundColor(roiIndex)
            if (roiIndex == 1)
                color = [0.9 0.9 0.9];
            else
                color = 'w';
            end
        end
    end
end

%% OnChangingRoiSelection
function OnChangingRoiSelection(handles, model)
end

%% OnChangedRoiSelection
function OnChangedRoiSelection(handles, model)
end