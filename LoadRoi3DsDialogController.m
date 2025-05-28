classdef LoadRoi3DsDialogController < handle
    % LoadRoi3DDialogController     Controller class (MVC pattern) for the LoadRoi3DsDialog GUI, which allows the user 
    %                               to load 3D ROIs from a groundTruthMed.mat file produced by MATLAB's Medical Image 
    %                               Labeler app
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    %% Properties

    % Observable Properties (listeners receive notification of changes)
    properties (SetObservable = true, AbortSet = true)
        Model
        View
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
        function this = LoadRoi3DsDialogController(varargin)
            if (nargin<1)
                this.Model = LoadRoi3DsDialogModel();
            else
                this.Model = LoadRoi3DsDialogModel(varargin{1});
            end
            this.View = LoadRoi3DsDialogView(this.Model);

            this.RegisterUiEventHandlers();

            uiwait(this.View.UiControls.Figure);
            delete(this.View.UiControls.Figure);

            if (this.Model.Cancelled)
                this = LoadRoi3DsDialogController.empty;
            end
        end

        %% Getters for Computable Dependent Properties

        %% Getters and Setters
        function model = get.Model(this)
            model = this.Model;
        end

        function set.Model(this, value)
            this.Model = value;
        end

        function view = get.View(this)
            view = this.View;
        end

        function set.View(this, value)
            this.View = value;
        end

        %% Other Public Methods
    end

    %% Private Methods
    methods (Access = private)
        %% RegisterUiEventHandlers
        function RegisterUiEventHandlers(this)
            model = this.Model;
            uiControls = this.View.UiControls;
            
            % hook up and respond to the view's events
            set(uiControls.Figure, 'CloseRequestFcn', {@LoadRoi3DsDialogController.OnFigure_CloseRequest, model});
            set(uiControls.FullyQualifiedGroundTruthFilenameEditBox, 'Callback', ...
                {@LoadRoi3DsDialogController.OnFilenamePrefix_Edit, model});
            set(uiControls.FullyQualifiedGroundTruthFilenameEditBox, 'Callback', ...
                {@LoadRoi3DsDialogController.OnFullyQualifiedGroundTruthFilename_Edit, model});
            set(uiControls.UseExistingThresholdsCheckBox, 'Callback', ...
                {@LoadRoi3DsDialogController.OnUseExistingThresholdsCheckBox_CheckChanged, model});
            set(uiControls.DisplayExistingRoi3DThresholdsButton, 'Callback', ...
                {@LoadRoi3DsDialogController.OnDisplayExistingRoi3DThresholdsButton_Press, model});
            set(uiControls.SelectFileButton, 'Callback', ...
                {@LoadRoi3DsDialogController.OnSelectFileButton_Press, model});
            set(uiControls.Load3DRoisButton, 'Callback', ...
                {@LoadRoi3DsDialogController.OnLoad3DRoisButton_Press, model});
            set(uiControls.CancelButton, 'Callback', ...
                {@LoadRoi3DsDialogController.OnCancelButton_Press, model});
        end
    end

    %% Static Methods
    methods (Static)
        %% OnFullyQualifiedGroundTruthFilename_Edit
        function OnFullyQualifiedGroundTruthFilename_Edit(uiControl, ~, model)
            currentPath = model.FullyQualifiedGroundTruthFilename;
            str = get(uiControl, 'String');

            if (isfile(str))
                model.FullyQualifiedGroundTruthFilename = str;
            else
                % revert back to the last valid path
                errordlg([str ' is not a valid path'], 'Error: Invalid Path', ...
                    'modal');
                uiControl.String = currentPath;
            end
        end

        %% OnUseExistingThresholdsCheckBox_CheckChanged
        function OnUseExistingThresholdsCheckBox_CheckChanged(uiControl, ~, model)
            val = get(uiControl, 'Value');
            model.UseExistingThresholds = logical(val);
        end

        %% OnDisplayExistingRoi3DThresholdsButton_Press
        function OnDisplayExistingRoi3DThresholdsButton_Press(uiControl, ~, model)
            model.UpdateExisting3DRoiThresholdsDisplay();
        end

        %% OnSelectFileButton_Press
        function OnSelectFileButton_Press(~, ~, model)
            currentFullyQualifiedGroundTruthFilename = model.FullyQualifiedGroundTruthFilename;
            [newFilename, newPath] = uigetfile('*.mat', 'Select the ROI ground truth file', ...
                currentFullyQualifiedGroundTruthFilename);
            newFullyQualifiedGroundTruthFilename = fullfile(newPath, newFilename);

            if (newFullyQualifiedGroundTruthFilename ~= 0)
                model.FullyQualifiedGroundTruthFilename = newFullyQualifiedGroundTruthFilename;
            end
        end

        %% OnLoad3DRoisButton_Press
        function OnLoad3DRoisButton_Press(uiControl, ~, model)
            model.Cancelled = false;
            set(uiControl.Parent, 'units', 'pixels');
            model.LoadRois();
            model.SavedScreenPosition = uiControl.Parent.Position(1:2);
            set(uiControl.Parent, 'units', 'normalized');
            uiresume(uiControl.Parent);
        end

        %% OnCancelButton_Press
        function OnCancelButton_Press(uiControl, ~, model)
            model.Cancelled = true;
            uiresume(uiControl.Parent);
        end

        %% OnFigure_CloseRequest
        function OnFigure_CloseRequest(uiControl, ~, model)
            model.Cancelled = true;
            uiresume(uiControl);
        end
    end
end