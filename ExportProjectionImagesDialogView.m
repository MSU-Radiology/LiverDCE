classdef ExportProjectionImagesDialogView < handle
    % ExportProjectionImagesDialogView  View class (MVC pattern) for the ExportProjectionImagesDialog GUI. This GUI 
    %                                   provides functionality for exporting various temporal projections of the DCE 
    %                                   image stack to disk in a variety of image formats. The projection types 
    %                                   supported are: maximum, minimum, mean, standard deviation, median, and 
    %                                   interquartile range.
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
        function this = ExportProjectionImagesDialogView(model)
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
            this.OnChangedPath(model);
            this.OnChangedFilenamePrefix(model);
            this.OnChangedDigits(model);
        end

        %% RegisterEventListeners
        function RegisterEventListeners(this)
            model = this.Model;
            addlistener(model, 'Path', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedPath(this, uiEvent.AffectedObject));
            addlistener(model, 'FilenamePrefix', 'PostSet', @(uiControl,uiEvent) OnChangedFilenamePrefix(...
                this, uiEvent.AffectedObject));
            addlistener(model, 'Digits', 'PostSet', @(uiControl,uiEvent) OnChangedDigits(...
                this, uiEvent.AffectedObject));
        end

        %% InitializeGui
        function InitializeGui(this)
            model = this.Model;
            hFig = figure('Visible', 'on', 'Name', 'Export Temporal Projection Images', 'NumberTitle', 'off', ...
                'ToolBar', 'none', 'MenuBar', 'none', 'Position', [680 738 515 360], 'Resize', 'on', ...
                'WindowStyle', 'normal');

            % Panels for grouping UI components
            hFilenameAndPathPanel = uipanel('Parent', hFig, 'Title', 'Filename and Path', ...
                'Units', 'Pixels', 'Position', [10 210 500 140]);
            hImageFormatButtonGroup = uibuttongroup(hFig, 'Title', 'Image Format', 'Visible', 'off', ...
                'Units', 'Pixels', 'Position', [10 12 89 192]);

            % Image Format Button Group
            hBmp = uicontrol(hImageFormatButtonGroup, 'Style', 'radiobutton', 'String', 'BMP', ...
                'TooltipString', 'BMP', 'Position', [12 156 60 20]);
            hPng = uicontrol(hImageFormatButtonGroup, 'Style', 'radiobutton', 'String', 'PNG', ...
                'TooltipString', 'PNG', 'Position', [12 136 60 20]);
            hTiff = uicontrol(hImageFormatButtonGroup, 'Style', 'radiobutton', 'String', 'TIFF', ...
                'TooltipString', 'TIFF', 'Position', [12 116 60 20]);
            hJpeg = uicontrol(hImageFormatButtonGroup, 'Style', 'radiobutton', 'String', 'JPEG', ...
                'TooltipString', 'JPEG', 'Position', [12 96 60 20]);
            hPbm = uicontrol(hImageFormatButtonGroup, 'Style', 'radiobutton', 'String', 'PBM', ...
                'TooltipString', 'PBM', 'Position', [12 76 60 20]);
            hPgm = uicontrol(hImageFormatButtonGroup, 'Style', 'radiobutton', 'String', 'PGM', ...
                'TooltipString', 'PGM', 'Position', [12 56 60 20]);
            hHdf = uicontrol(hImageFormatButtonGroup, 'Style', 'radiobutton', 'String', 'HDF', ...
                'TooltipString', 'HDF', 'Position', [12 36 60 20]);
            hNifti = uicontrol(hImageFormatButtonGroup, 'Style', 'radiobutton', 'String', 'NIfTI', ...
                'TooltipString', 'NIfTI', 'Position', [12 16 60 20]);
            switch model.ImageFormatName
                case 'BMP'
                    selectedImageFormat = hBmp;
                case 'PNG'
                    selectedImageFormat = hPng;
                case 'TIFF'
                    selectedImageFormat = hTiff;
                case 'JPEG'
                    selectedImageFormat = hJpeg;
                case 'PBM'
                    selectedImageFormat = hPbm;
                case 'PGM'
                    selectedImageFormat = hPgm;
                case 'HDF'
                    selectedImageFormat = hHdf;
                case 'NIfTI'
                    selectedImageFormat = hNifti;
                otherwise
                    selectedImageFormat = hBmp;
            end
            hImageFormatButtonGroup.SelectedObject = selectedImageFormat;
            hImageFormatButtonGroup.Visible = 'on';

            % Filename And Path Panel Components
            hPathLabel = uicontrol('Parent', hFilenameAndPathPanel, 'Style', 'text', 'String', 'Path', ...
                'Units', 'Pixels', 'HorizontalAlignment', 'left', 'Position', [12 98 52 13]);
            hPathEditBox = uicontrol('Parent', hFilenameAndPathPanel, 'Style', 'edit', ...
                'String', num2str(model.Path), 'Units', 'Pixels', 'Position', [12 72 360 20]);
            hSelectFileFolderButton = uicontrol('Parent', hFilenameAndPathPanel, 'Style', 'pushbutton', ...
                'String', 'Select File Folder', 'Units', 'Pixels', 'Position', [382 72 100 20]);
            hFilenamePrefixLabel = uicontrol('Parent', hFilenameAndPathPanel, 'Style', 'text', ...
                'String', 'Filename Prefix', 'Units', 'Pixels', 'HorizontalAlignment', 'left', ...
                'Position', [12 42 86 13]);
            hFilenamePrefixEditBox = uicontrol('Parent', hFilenameAndPathPanel, 'Style', 'edit', ...
                'String', num2str(model.FilenamePrefix), 'Units', 'Pixels', 'Position', [12 16 122 20]);
            hDigitsLabel = uicontrol('Parent', hFilenameAndPathPanel, 'Style', 'text', 'String', 'Digits', ...
                'Units', 'Pixels', 'HorizontalAlignment', 'left', 'Position', [146 42 51 13]);
            hDigitsEditBox = uicontrol('Parent', hFilenameAndPathPanel, 'Style', 'edit', ...
                'String', num2str(model.Digits), 'Units', 'Pixels', 'Position', [146 16 51 20]);

            % Write Images To Disk / Cancel Buttons
            hWriteImagesToDiskButton = uicontrol('Parent', hFig, 'Style', 'pushbutton', ...
                'String', 'Write Images To Disk', 'Position', [232 20 154 20]);
            hCancelButton = uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Cancel', ...
                'Position', [411 20 70 20]);

            this.UiControls = struct(...
                'Figure', hFig, ...
                'FilenameAndPathPanel', hFilenameAndPathPanel, ...
                'ImageFormatButtonGroup', hImageFormatButtonGroup, ...
                'Bmp', hBmp, ...
                'Png', hPng, ...
                'Tiff', hTiff, ...
                'Jpeg', hJpeg, ...
                'Pbm', hPbm, ...
                'Pgm', hPgm, ...
                'Hdf', hHdf, ... 
                'Nifti', hNifti, ...
                'PathLabel', hPathLabel, ...
                'PathEditBox', hPathEditBox, ...
                'SelectFileFolderButton', hSelectFileFolderButton, ...
                'FilenamePrefixLabel', hFilenamePrefixLabel, ...
                'FilenamePrefixEditBox', hFilenamePrefixEditBox, ...
                'DigitsLabel', hDigitsLabel, ...
                'DigitsEditBox', hDigitsEditBox, ...
                'WriteImagesToDiskButton', hWriteImagesToDiskButton, ...
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

        %% OnChangedPath
        function OnChangedPath(this, uiModel)
            uiControls = this.UiControls;
            path = uiModel.Path;
            if(isvalid(uiControls.PathEditBox))
                uiControls.PathEditBox.String = path;
            end
        end

        %% OnChangedFilenamePrefix
        function OnChangedFilenamePrefix(~, ~)
        end

        %% OnChangedDigits
        function OnChangedDigits(this, uiModel)
            uiControls = this.UiControls;
            if(isvalid(uiControls.DigitsEditBox))
                uiControls.DigitsEditBox.String = num2str(uiModel.Digits);
            end
        end
    end

    %% Static Methods
    methods (Static)
    end
end
