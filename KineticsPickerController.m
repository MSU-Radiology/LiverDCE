classdef KineticsPickerController < handle
    % KineticsPickerController  Controller class (MVC pattern) for the KineticsPicker GUI
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
        function this = KineticsPickerController(varargin)
            if (nargin < 1)
                this.Model = KineticsPickerModel();
            else
                this.Model = KineticsPickerModel(varargin{1});
            end

            this.View = KineticsPickerView(this.Model);

            this.RegisterUiEventHandlers();

            uiwait(this.View.UiControls.Figure);
            delete(this.View.UiControls.Figure);

            if (this.Model.Cancelled)
                this = KineticsPickerController.empty;
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
            set(uiControls.Figure, 'CloseRequestFcn', {@KineticsPickerController.OnFigure_CloseRequest, model});
            set(uiControls.OkButton, 'Callback', {@KineticsPickerController.OnOkButton_Press, model});
            set(uiControls.CancelButton, 'Callback', {@KineticsPickerController.OnCancelButton_Press, model});
            set(uiControls.KineticsModelButtonGroup, 'SelectionChangedFcn', ...
                {@KineticsPickerController.OnKineticsModelButtonGroup_SelectionChanged, model});
            set(uiControls.OdeSolverButtonGroup, 'SelectionChangedFcn', ...
                {@KineticsPickerController.OnOdeSolverButtonGroup_SelectionChanged, model});
            set(uiControls.UseParallelComputationCheckBox, 'Callback', ...
                {@KineticsPickerController.OnUseParallelComputationCheckBox_CheckChanged, model});
            set(uiControls.OptimizerButtonGroup, 'SelectionChangedFcn', ...
                {@KineticsPickerController.OnOptimizerButtonGroup_SelectionChanged, model});
            set(uiControls.UseRegularizationCheckBox, 'Callback', ...
                {@KineticsPickerController.OnUseRegularizationCheckBox_CheckChanged, model});
            set(uiControls.FitnessMeasureButtonGroup, 'SelectionChangedFcn', ...
                {@KineticsPickerController.OnFitnessMeasureButtonGroup_SelectionChanged, model});
            set(uiControls.LambdaEditBox, 'Callback', {@KineticsPickerController.OnLambda_Edit, model});
            set(uiControls.InitialEstimateEditBox, 'Callback', ...
                {@KineticsPickerController.OnInitialEstimate_Edit, model});
            set(uiControls.MaxIterationsEditBox, 'Callback', {@KineticsPickerController.OnMaxIterations_Edit, model});
            set(uiControls.MaxTimeEditBox, 'Callback', {@KineticsPickerController.OnMaxTime_Edit, model});
            set(uiControls.LowerBoundEditBox, 'Callback', {@KineticsPickerController.OnLowerBound_Edit, model});
            set(uiControls.UpperBoundEditBox, 'Callback', {@KineticsPickerController.OnUpperBound_Edit, model});
            set(uiControls.OptimizationDisplayPopUpMenu, 'Callback', ...
                {@KineticsPickerController.OnOptimizationDisplayPopUpMenu_SelectionChanged, model});
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

        %% OnKineticsModelButtonGroup_SelectionChanged
        function OnKineticsModelButtonGroup_SelectionChanged(~, callbackdata, model)
            kineticsModelName = callbackdata.NewValue.String;
            if (~isempty(kineticsModelName))
                model.KineticsModelName = kineticsModelName;
            end
        end

        %% OnOdeSolverButtonGroup_SelectionChanged
        function OnOdeSolverButtonGroup_SelectionChanged(~, callbackdata, model)
            odeSolver = callbackdata.NewValue.String;
            if (~isempty(odeSolver))
                model.OdeSolverName = odeSolver;
            end
        end

        %% OnOptimizerButtonGroup_SelectionChanged
        function OnOptimizerButtonGroup_SelectionChanged(~, callbackdata, model)
            optimizer = callbackdata.NewValue.String;
            if (~isempty(optimizer))
                model.OptimizerName = optimizer;
            end
        end

        %% OnUseRegularizationCheckBox_CheckChanged
        function OnUseRegularizationCheckBox_CheckChanged(uiControl, ~, model)
            val = get(uiControl, 'Value');
            model.UseRegularization = logical(val);
        end

        %% OnUseParallelComputationCheckBox_CheckChanged
        function OnUseParallelComputationCheckBox_CheckChanged(uiControl, ~, model)
            val = get(uiControl, 'Value');
            model.UseParallelComputation = logical(val);
        end

        %% OnFitnessMeasureButtonGroup_SelectionChanged
        function OnFitnessMeasureButtonGroup_SelectionChanged(~, callbackdata, model)
            fitnessMeasure = callbackdata.NewValue.Tag;
            if (~isempty(fitnessMeasure))
                model.FitnessMeasure = fitnessMeasure;
            end
        end

        %% OnLambda_Edit
        function OnLambda_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            lambda = str2double(str);
            model.Lambda = lambda;
        end

        %% OnInitialEstimate_Edit
        function OnInitialEstimate_Edit(uiControl, ~, model)
            % TODO: add code to error check for a parameter vector that is too
            % short or too long
            str = get(uiControl, 'String');
            initialEstimate = str2num(str);
            model.InitialEstimate = initialEstimate;
        end

        %% OnMaxIterations_Edit
        function OnMaxIterations_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.MaxIterations = str2double(str);
        end

        %% OnMaxTime_Edit
        function OnMaxTime_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.MaxTime = str2double(str);
        end

        %% OnLowerBound_Edit
        function OnLowerBound_Edit(uiControl, ~, model)
            % TODO: add code to check vector length
            str = get(uiControl, 'String');
            lb = str2num(str); %#ok<*ST2NM>
            model.LowerBound = lb;
        end

        %% OnUpperBound_Edit
        function OnUpperBound_Edit(uiControl, ~, model)
            % TODO: add code to check vector length
            str = get(uiControl, 'String');
            ub = str2num(str);
            model.UpperBound = ub;
        end

        %% OnOptimizationDisplayPopUpMenu_SelectionChanged
        function OnOptimizationDisplayPopUpMenu_SelectionChanged(uiControl, ~, model)
            % Display Option values
            % 1 = off
            % 2 = iter
            % 3 = diagnose
            % 4 = final

            displayOption = uiControl.Value;
            optionList = uiControl.String;

            if (~isempty(displayOption))
                assert(isnumeric(displayOption));
                assert(displayOption >= 1);
                assert(displayOption <= size(optionList,1));

                model.OptimizationDisplay = optionList{displayOption};
            end
        end
    end
end









