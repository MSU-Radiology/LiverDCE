classdef ExportProjectionImagesDialogController < handle
    % ExportProjectionImagesDialogController    Controller class (MVC pattern) for the ExportProjectionImagesDialog GUI
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
        function this = ExportProjectionImagesDialogController(varargin)
            if (nargin < 1)
                this.Model = ExportProjectionImagesDialogModel();
            else
                this.Model = ExportProjectionImagesDialogModel(varargin{:});
            end

            this.View = ExportProjectionImagesDialogView(this.Model);

            this.RegisterUiEventHandlers();

            uiwait(this.View.UiControls.Figure);
            delete(this.View.UiControls.Figure);

            if (this.Model.Cancelled)
                this = ExportProjectionImagesDialogController.empty;
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
            % respond to the view's events
            set(uiControls.Figure, 'CloseRequestFcn', ...
                {@ExportProjectionImagesDialogController.OnFigure_CloseRequest, model});
            set(uiControls.WriteImagesToDiskButton, 'Callback', ...
                {@ExportProjectionImagesDialogController.OnWriteImagesToDiskButton_Press, model});
            set(uiControls.CancelButton, 'Callback', ...
                {@ExportProjectionImagesDialogController.OnCancelButton_Press, model});
            set(uiControls.ImageFormatButtonGroup, 'SelectionChangedFcn', ...
                {@ExportProjectionImagesDialogController.OnImageFormatButtonGroup_SelectionChanged, model});
            set(uiControls.PathEditBox, 'Callback', ...
                {@ExportProjectionImagesDialogController.OnPath_Edit, model});
            set(uiControls.SelectFileFolderButton, 'Callback', ...
                {@ExportProjectionImagesDialogController.OnSelectFileFolderButton_Press, model});
            set(uiControls.FilenamePrefixEditBox, 'Callback', ...
                {@ExportProjectionImagesDialogController.OnFilenamePrefix_Edit, model});
            set(uiControls.DigitsEditBox, 'Callback', ...
                {@ExportProjectionImagesDialogController.OnDigits_Edit, model});
        end
    end

    %% Static Methods
    methods (Static)
        %% OnWriteImagesToDiskButton_Press
        function OnWriteImagesToDiskButton_Press(uiControl, ~, model)
            model.Cancelled = false;
            set(uiControl.Parent, 'units', 'pixels');
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
            % If the user presses the upper right X button instead of the OK or
            % Cancel buttons, treat this action as a Cancel command.
            model.Cancelled = true;
            uiresume(uiControl);
        end

        %% OnImageFormatButtonGroup_SelectionChanged
        function OnImageFormatButtonGroup_SelectionChanged(~, callbackdata, model)
            str = callbackdata.NewValue.String;
            if (~isempty(str))
                model.ImageFormatName = str;
            end
        end

        %% OnPath_Edit
        function OnPath_Edit(uiControl, ~, model)
            currentPath = model.Path;
            newPath = get(uiControl, 'String');

            if (isfolder(newPath))
                model.Path = newPath;
            else
                % revert to last good value
                errordlg([newPath ' is not a valid path'], 'Error: Invalid Path', ...
                    'modal');
                uiControl.String = currentPath;
            end
        end

        %% OnFilenamePrefix_Edit
        function OnFilenamePrefix_Edit(uiControl, ~, model)
            prefix = get(uiControl, 'String');
            if(ischar(prefix))
                model.FilenamePrefix = prefix;
            else
                uiControl.String = model.FilenamePrefix;
            end
        end

        %% OnDigits_Edit
        function OnDigits_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            digits = str2double(str);
            if(~isnan(digits))
                model.Digits = uint8(digits);
            else
                % revert back to last good value
                uiControl.String = num2str(model.Digits);
            end
        end

        %% OnSelectFileFolderButton_Press
        function OnSelectFileFolderButton_Press(~, ~, model)
            currentPath = model.Path;
            newPath = uigetdir(currentPath, 'Select the file folder where the projection images will be written');

            if (newPath ~= 0)
                model.Path = newPath;
            end
        end
    end
end
