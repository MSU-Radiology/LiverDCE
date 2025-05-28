classdef DriftCorrectionDialogController < handle
    % DriftCorrectionDialogController       Controller class (MVC pattern) for the DriftCorrectionDialog GUI
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
        function this = DriftCorrectionDialogController(varargin)
            if (nargin < 2)
                this.Model = DriftCorrectionDialogModel();
            else
                this.Model = DriftCorrectionDialogModel(varargin{:});
            end

            this.View = DriftCorrectionDialogView(this.Model);

            this.RegisterUiEventHandlers();

            uiwait(this.View.UiControls.Figure);
            delete(this.View.UiControls.Figure);

            if (this.Model.Cancelled)
                this = DriftCorrectionDialogController.empty;
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
            set(uiControls.UseDriftCorrectionCheckBox, 'Callback', ...
                {@DriftCorrectionDialogController.OnUseDriftCorrectionCheckBox_CheckChanged, model});
            set(uiControls.ShowFitPlotsCheckBox, 'Callback', ...
                {@DriftCorrectionDialogController.OnShowFitPlotsCheckBox_CheckChanged, model});
            set(uiControls.CorrectionSlopeEditBox, 'Callback', ...
                {@DriftCorrectionDialogController.OnCorrectionSlope_Edit, model});
            set(uiControls.ResetCorrectionButton, 'Callback', ...
                {@DriftCorrectionDialogController.OnResetCorrectionButton_Press, model});
            set(uiControls.NumberOfSamplesEditBox, 'Callback', ...
                {@DriftCorrectionDialogController.OnNumberOfSamples_Edit, model});
            set(uiControls.UseMultipleRoisCheckBox, 'Callback', ...
                {@DriftCorrectionDialogController.OnUseMultipleRoisCheckBox_CheckChanged, model});
            set(uiControls.MuscleCheckBox, 'Callback', ...
                {@DriftCorrectionDialogController.OnReferenceTissueCheckBox_CheckChanged, model, TissueType.Muscle});
            set(uiControls.SpinalCordCheckBox, 'Callback', ...
                {@DriftCorrectionDialogController.OnReferenceTissueCheckBox_CheckChanged, model, ...
                TissueType.SpinalCord});
            set(uiControls.FatCheckBox, 'Callback', ...
                {@DriftCorrectionDialogController.OnReferenceTissueCheckBox_CheckChanged, model, TissueType.Fat});
            set(uiControls.SpleenCheckBox, 'Callback', ...
                {@DriftCorrectionDialogController.OnReferenceTissueCheckBox_CheckChanged, model, TissueType.Spleen});
            set(uiControls.RoiDimensionalityButtonGroup, 'SelectionChangedFcn', ...
                {@DriftCorrectionDialogController.OnRoiDimensionalityButtonGroup_SelectionChanged, model});
            set(uiControls.ComputeCorrectionButton, 'Callback', ...
                {@DriftCorrectionDialogController.OnComputeCorrectionButton_Press, model});
            set(uiControls.Figure, 'CloseRequestFcn', {@DriftCorrectionDialogController.OnFigure_CloseRequest, model});
            set(uiControls.OkButton, 'Callback', {@DriftCorrectionDialogController.OnOkButton_Press, model});
            set(uiControls.CancelButton, 'Callback', {@DriftCorrectionDialogController.OnCancelButton_Press, model});
        end
    end

    %% Static Methods
    methods (Static)
        %% OnOkButton_Press
        function OnOkButton_Press(uiControl, ~, model)
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

        %% OnResetCorrectionButton_Press
        function OnResetCorrectionButton_Press(~, ~, model)
            model.CorrectionSlope = 0.0;
        end

        %% OnUseDriftCorrectionCheckBox_CheckChanged
        function OnUseDriftCorrectionCheckBox_CheckChanged(uiControl, ~, model)
            value = get(uiControl, 'Value');
            model.UseDriftCorrection = logical(value);
        end

        %% OnShowFitPlotsCheckBox_CheckChanged
        function OnShowFitPlotsCheckBox_CheckChanged(uiControl, ~, model)
            value = get(uiControl, 'Value');
            model.ShowFitPlots = logical(value);
        end

        %% OnCorrectionSlope_Edit
        function OnCorrectionSlope_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.CorrectionSlope = str2double(str);
        end

        %% OnNumberOfSamples_Edit
        function OnNumberOfSamples_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            numberOfSamples = round(str2double(str));
            if(IsNonZeroPositiveFinite(numberOfSamples))
                model.NumberOfSamplesToUseForCorrection = numberOfSamples;
            end
            uiControl.String = num2str(model.NumberOfSamplesToUseForCorrection);
        end

        %% OnUseMultipleRoisCheckBox_CheckChanged
        function OnUseMultipleRoisCheckBox_CheckChanged(uiControl, ~, model)
            value = get(uiControl, 'Value');
            model.UseMultipleRois = logical(value);
        end

        %% OnReferenceTissueCheckBox_CheckChanged
        function OnReferenceTissueCheckBox_CheckChanged(uiControl, ~, model, tissueType)
            value = logical(get(uiControl, 'Value'));
            switch(tissueType)
                case TissueType.Muscle
                    model.UseMuscleAsReferenceTissue = value;
                case TissueType.SpinalCord
                    model.UseSpinalCordAsReferenceTissue = value;
                case TissueType.Fat
                    model.UseFatAsReferenceTissue = value;
                case TissueType.Spleen
                    model.UseSpleenAsReferenceTissue = value;
                otherwise
                    error('Unknown reference tissue type');
            end
        end

        %% OnhRoiDimensionalityButtonGroup_SelectionChanged
        function OnRoiDimensionalityButtonGroup_SelectionChanged(uiControl, callbackdata, model)
            roiDimensionality = callbackdata.NewValue.String;
            switch(roiDimensionality)
                case '2D'
                    model.RoiDimensionality = '2D';
                case '3D'
                    model.RoiDimensionality = '3D';
                otherwise
                    % restore the UI state to the last known good state
                    uiControl.SelectedObject = callbackdata.OldValue;
                    model.RoiDimensionality = callbackdata.OldValue.String;
            end
        end
        
        %% OnComputeCorrectionButton_Press
        function OnComputeCorrectionButton_Press(~, ~, model)
            if(~model.ImageVolume.ImageDataInitialized)
                return
            end

            if(model.UseMultipleRois)
                % Compute an average for the signal drift correction
                switch(model.RoiDimensionality)
                    case '2D'
                        correctionSlope = model.ComputeCorrectionUsingRoi2Ds();
                        averageSlope = mean(correctionSlope);
                        if(isfinite(averageSlope))
                            model.CorrectionSlope = averageSlope;
                        end
                    case '3D'
                        correctionSlope = model.ComputeCorrectionUsingRoi3Ds();
                        averageSlope = mean(correctionSlope);
                        if(isfinite(averageSlope))
                            model.CorrectionSlope = averageSlope;
                        end
                    otherwise
                        error('Unknown ROI dimensionality');
                end
            else
                % Select one ROI to use for computing the signal drift correction
                switch(model.RoiDimensionality)
                    case '2D'
                        % TODO: implement a way to select just one ROI to use
                        correctionSlope = model.ComputeCorrectionUsingRoi2Ds();
                        averageSlope = mean(correctionSlope);
                        if(~isnan(averageSlope))
                            model.CorrectionSlope = averageSlope;
                        end
                    case '3D'
                        correctionSlope = model.ComputeCorrectionUsingRoi3Ds();
                        averageSlope = mean(correctionSlope);
                        if(isfinite(averageSlope))
                            model.CorrectionSlope = averageSlope;
                        end
                    otherwise
                        error('Unknown ROI dimensionality');
                end
            end
        end
    end
end









