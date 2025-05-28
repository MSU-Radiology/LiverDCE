classdef KineticsPickerView < handle
    % KineticsPickerView    View class (MVC pattern) for the KineticsPicker GUI
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
        function this = KineticsPickerView(model)
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
            this.OnChangedKineticsModelName(model);
            this.OnChangedOdeSolverName(model);
            this.OnChangedUseParallelComputation(model);
            this.OnChangedOptimizerName(model);
            this.OnChangedUseRegularization(model);
            this.OnChangedFitnessMeasure(model);
            this.OnChangedInitialEstimate(model);
            this.OnChangedMaxIterations(model);
            this.OnChangedMaxTime(model);
            this.OnChangedLowerBound(model);
            this.OnChangedUpperBound(model);
            this.OnChangedOptimizationDisplay(model);
            this.OnChangedLambda(model);
        end

        %% RegisterEventListeners
        function RegisterEventListeners(this)
            model = this.Model;
            addlistener(model, 'KineticsModelName', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedKineticsModelName(this, uiEvent.AffectedObject));
            addlistener(model, 'OdeSolverName', 'PostSet', @(uiControl,uiEvent) OnChangedOdeSolverName(...
                this, uiEvent.AffectedObject));
            addlistener(model, 'UseParallelComputation', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedUseParallelComputation(this, uiEvent.AffectedObject));
            addlistener(model, 'OptimizerName', 'PostSet', @(uiControl,uiEvent) OnChangedOptimizerName(...
                this, uiEvent.AffectedObject));
            addlistener(model, 'UseRegularization', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedUseRegularization(this, uiEvent.AffectedObject));
            addlistener(model, 'FitnessMeasure', 'PostSet', @(uiControl,uiEvent) OnChangedFitnessMeasure(...
                this, uiEvent.AffectedObject));
            addlistener(model, 'InitialEstimate', 'PostSet', @(uiControl,uiEvent) OnChangedInitialEstimate(...
                this, uiEvent.AffectedObject));
            addlistener(model, 'MaxIterations', 'PostSet', @(uiControl,uiEvent) OnChangedMaxIterations(...
                this, uiEvent.AffectedObject));
            addlistener(model, 'MaxTime', 'PostSet', @(uiControl,uiEvent) OnChangedMaxTime(...
                this, uiEvent.AffectedObject));
            addlistener(model, 'LowerBound', 'PostSet', @(uiControl,uiEvent) OnChangedLowerBound(...
                this, uiEvent.AffectedObject));
            addlistener(model, 'UpperBound', 'PostSet', @(uiControl,uiEvent) OnChangedUpperBound(...
                this, uiEvent.AffectedObject));
            addlistener(model, 'OptimizationDisplay', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedOptimizationDisplay(this, uiEvent.AffectedObject));
            addlistener(model, 'Lambda', 'PostSet', @(uiControl,uiEvent) OnChangedLambda(...
                this, uiEvent.AffectedObject));
        end

        %% InitializeGui
        function InitializeGui(this)
            model = this.Model;
            hFig = figure('Visible', 'on', 'Name', 'Kinetics Parameter Estimation', 'NumberTitle', 'off', ...
                'ToolBar', 'none', 'MenuBar', 'none', 'Position', [680 487 400 610], 'Resize', 'on', ...
                'WindowStyle', 'normal');

            % Panels for grouping UI components
            hKineticsModelButtonGroup = uibuttongroup(hFig, 'Title', 'Kinetics Model', 'Visible', 'off', ...
                'Units', 'Pixels', 'Position', [10 429 170 176]);
            hOdeSolverButtonGroup = uibuttongroup(hFig, 'Title', 'ODE Solver', 'Visible', 'off', ...
                'Units', 'Pixels', 'Position', [185 486 210 120]);
            hParallelComputationPanel = uipanel('Parent', hFig, 'Title', 'Parallel Computation', 'Visible', 'off', ...
                'Units', 'pixels', 'Position', [185 429 210 50]);
            hOptimizerButtonGroup = uibuttongroup(hFig, 'Title', 'Optimizer', 'Visible', 'off', ...
                'Units', 'Pixels', 'Position', [10 200 170 223]);
            hRegularizationPanel = uipanel('Parent', hFig, 'Title', 'Tikhonov Regularization', ...
                'Units', 'Pixels', 'Position', [185 315 210 108]);
            hFitnessMeasureButtonGroup = uibuttongroup(hFig, 'Title', 'Fitness Measure', 'Visible', 'off', ...
                'Units', 'Pixels', 'Position', [185 200 210 109]);
            hOptimizationOptionsPanel = uipanel('Parent', hFig, 'Title', 'Optimizer Options', ...
                'Units', 'Pixels', 'Position', [10 60 385 130]);

            % Kinetics Model Button Group
            hLinearOde = uicontrol(hKineticsModelButtonGroup, 'Style', 'radiobutton', 'String', 'Linear ODE', ...
                'TooltipString', 'Linear ODE', 'Position', [12 132 150 20]);
            hMichaelisMentenOde = uicontrol(hKineticsModelButtonGroup, 'Style', 'radiobutton', ...
                'String', 'Michaelis-Menten ODE', 'TooltipString', 'Michaelis-Menten ODE', ...
                'Position', [12 112 150 20]);
            hBiexponentialAlgebraic = uicontrol(hKineticsModelButtonGroup, 'Style', 'radiobutton', ...
                'String', 'Bi-exponential Algebraic', 'TooltipString', 'Bi-exponential Algebraic', ...
                'Position', [12 92 150 20]);
            hTristan = uicontrol(hKineticsModelButtonGroup, 'Style', 'radiobutton', 'String', 'TRISTAN', ...
                'TooltipString', 'TRISTAN', 'Position', [12 72 150 20]);
            hGeorgiou = uicontrol(hKineticsModelButtonGroup, 'Style', 'radiobutton', 'String', 'Georgiou', ...
                'TooltipString', 'Georgiou', 'Position', [12 52 150 20]);
            hBerks = uicontrol(hKineticsModelButtonGroup, 'Style', 'radiobutton', 'String', 'Berks', ...
                'TooltipString', 'Berks', 'Position', [12 32 150 20]);
            switch model.KineticsModelName
                case 'Linear ODE'
                    selectedModel = hLinearOde;
                case 'Michaelis-Menten ODE'
                    selectedModel = hMichaelisMentenOde;
                case 'Bi-exponential Algebraic'
                    selectedModel = hBiexponentialAlgebraic;
                case 'TRISTAN'
                    selectedModel = hTristan;
                case 'Georgiou'
                    selectedModel = hGeorgiou;
                case 'Berks'
                    selectedModel = hBerks;
                otherwise
                    selectedModel = hMichaelisMentenOde;
            end
            hKineticsModelButtonGroup.SelectedObject = selectedModel;
            hKineticsModelButtonGroup.Visible = 'on';

            % ODE Solver Button Group
            hOde15s = uicontrol(hOdeSolverButtonGroup, 'Style', 'radiobutton', 'String', 'ode15s', ...
                'TooltipString', 'ode15s', 'Position', [12 74 87 20]);
            hOde23s = uicontrol(hOdeSolverButtonGroup, 'Style', 'radiobutton', 'String', 'ode23s', ...
                'TooltipString', 'ode23s', 'Position', [12 54 87 20]);
            hOde23t = uicontrol(hOdeSolverButtonGroup, 'Style', 'radiobutton', 'String', 'ode23t', ...
                'TooltipString', 'ode23t', 'Position', [12 34 87 20]);
            hOde23tb = uicontrol(hOdeSolverButtonGroup, 'Style', 'radiobutton', 'String', 'ode23tb', ...
                'TooltipString', 'ode23tb', 'Position', [12 14 87 20]);
            switch model.OdeSolverName
                case 'ode15s'
                    selectedSolver = hOde15s;
                case 'ode23s'
                    selectedSolver = hOde23s;
                case 'ode23t'
                    selectedSolver = hOde23t;
                case 'ode23tb'
                    selectedSolver = hOde23tb;
                otherwise
                    selectedSolver = hOde15s;
            end
            hOdeSolverButtonGroup.SelectedObject = selectedSolver;
            hOdeSolverButtonGroup.Visible = 'on';

            % Parallel Computation Panel
            hUseParallelComputationCheckBox = uicontrol('Parent', hParallelComputationPanel, 'Style', 'checkbox', ...
                'String', 'Use Parallel Computation', 'Value', model.UseParallelComputation, ...
                'Position', [12 12 150 20]);
            hParallelComputationPanel.Visible = 'on';

            % Optimizer Button Group
            hPatternSearch = uicontrol(hOptimizerButtonGroup, 'Style', 'radiobutton', 'String', 'Pattern Search', ...
                'TooltipString', 'Pattern Search', 'Position', [12 185 143 20]);
            hGradientDescent = uicontrol(hOptimizerButtonGroup, 'Style', 'radiobutton', ...
                'String', 'Gradient Descent', 'TooltipString', 'Gradient Descent', 'Position', [12 165 143 20]);
            hSimulatedAnnealing = uicontrol(hOptimizerButtonGroup, 'Style', 'radiobutton', ...
                'String', 'Simulated Annealing', 'TooltipString', 'Simulated Annealing', ...
                'Position', [12 145 143 20]);
            hParticleSwarm = uicontrol(hOptimizerButtonGroup, 'Style', 'radiobutton', 'String', 'Particle Swarm', ...
                'TooltipString', 'Particle Swarm', 'Position', [12 125 143 20]);
            hGeneticAlgorithm = uicontrol(hOptimizerButtonGroup, 'Style', 'radiobutton', ...
                'String', 'Genetic Algorithm', 'TooltipString', 'Genetic Algorithm', ...
                'Position', [12 105 143 20]);
            hSurrogateOptimization = uicontrol(hOptimizerButtonGroup, 'Style','radiobutton', ...
                'String', 'Surrogate Optimization', 'TooltipString', 'Surrogate Optimization', ...
                'Position', [12 85 143 20]);
            hGlobalSearch = uicontrol(hOptimizerButtonGroup, 'Style', 'radiobutton', 'String', 'Global Search', ...
                'TooltipString', 'Global Search', 'Position', [12 65 143 20]);
            hMultiStart = uicontrol(hOptimizerButtonGroup, 'Style', 'radiobutton', 'String', 'Multi-Start', ...
                'TooltipString', 'Multi-Start', 'Position', [12 45 143 20]);
            hLevenbergMarquardt = uicontrol(hOptimizerButtonGroup, 'Style', 'radiobutton', ...
                'String', 'Levenberg-Marquardt', 'TooltipString', 'Levenberg-Marquardt', ...
                'Position', [12 25 143 20]);
            hTrustRegionReflective = uicontrol(hOptimizerButtonGroup, 'Style', 'radiobutton', ...
                'String', 'Trust Region Reflective', 'TooltipString', 'Trust Region Reflective', ...
                'Position', [12 5 143 20]);
            switch model.OptimizerName
                case 'Pattern Search'
                    selectedOptimizer = hPatternSearch;
                case 'Gradient Descent'
                    selectedOptimizer = hGradientDescent;
                case 'Simulated Annealing'
                    selectedOptimizer = hSimulatedAnnealing;
                case 'Particle Swarm'
                    selectedOptimizer = hParticleSwarm;
                case 'Genetic Algorithm'
                    selectedOptimizer = hGeneticAlgorithm;
                case 'Surrogate Optimization'
                    selectedOptimizer = hSurrogateOptimization;
                case 'Global Search'
                    selectedOptimizer = hGlobalSearch;
                case 'Multi-Start'
                    selectedOptimizer = hMultiStart;
                case 'Levenberg-Marquardt'
                    selectedOptimizer = hLevenbergMarquardt;
                case 'Trust Region Reflective'
                    selectedOptimizer = hTrustRegionReflective;
                otherwise
                    selectedOptimizer = hLevenbergMarquardt;
            end
            hOptimizerButtonGroup.SelectedObject = selectedOptimizer;
            hOptimizerButtonGroup.Visible = 'on';

            % Regularization Panel Components
            hUseRegularizationCheckBox = uicontrol('Parent', hRegularizationPanel, 'Style', 'checkbox', ...
                'String', 'Use Regularization', 'Value', model.UseRegularization, 'Position', [12 70 120 20]);
            hLambdaLabel = uicontrol('Parent', hRegularizationPanel, 'Style', 'text', 'String', 'Lambda', ...
                'Units', 'Pixels', 'HorizontalAlignment', 'left', 'Position', [24 46 52 13]);
            hLambdaEditBox = uicontrol('Parent', hRegularizationPanel, 'Style', 'edit', ...
                'String', num2str(model.Lambda), 'Units', 'Pixels', 'Position', [24 20 50 20]);

            % Fitness Measure Button Group
            hLeastSquares = uicontrol(hFitnessMeasureButtonGroup, 'Style', 'radiobutton', ...
                'String', 'Least Squares', 'Tag', 'LSQ', 'TooltipString', 'Least Squares', ...
                'Position', [12 70 190 20]);
            hLeastAbsoluteResiduals = uicontrol(hFitnessMeasureButtonGroup, 'Style', 'radiobutton', ...
                'String', 'Least Absolute Residuals', 'Tag', 'LAR', ...
                'TooltipString', 'Least Absolute Residuals', 'Position', [12 50 190 20]);
            hLeastMedianOfSquares = uicontrol(hFitnessMeasureButtonGroup, 'Style', 'radiobutton', ...
                'String', 'Least Median of Squares', 'Tag', 'MSQ', 'TooltipString', 'Least Median of Squares', ...
                'Position', [12 30 190 20]);
            hLeastMedianAbsoluteResiduals = uicontrol(hFitnessMeasureButtonGroup, 'Style', 'radiobutton', ...
                'String', 'Least Median Absolute Residuals', 'Tag', 'MAR', 'Position', [12 10 190 20]);
            switch model.FitnessMeasure
                case 'LSQ'
                    selectedFitnessMeasure = hLeastSquares;
                case 'LAR'
                    selectedFitnessMeasure = hLeastAbsoluteResiduals;
                case 'MSQ'
                    selectedFitnessMeasure = hLeastMedianOfSquares;
                case 'MAR'
                    selectedFitnessMeasure = hLeastMedianAbsoluteResiduals;
                otherwise
                    selectedFitnessMeasure = hLeastSquares;
            end
            hFitnessMeasureButtonGroup.SelectedObject = selectedFitnessMeasure;
            hFitnessMeasureButtonGroup.Visible = 'on';

            % Optimizer Options Panel Components
            hInitialEstimateLabel = uicontrol('Parent', hOptimizationOptionsPanel, 'Style', 'text', ...
                'String', 'Initial Estimate', 'Units', 'Pixels', 'HorizontalAlignment', 'left', ...
                'Position', [12 96 80 13]);
            hInitialEstimateEditBox = uicontrol('Parent', hOptimizationOptionsPanel, 'Style', 'edit', ...
                'String', mat2str(model.InitialEstimate), 'Units', 'Pixels', 'Position', [12 70 80 20]);
            hMaxIterationsLabel = uicontrol('Parent', hOptimizationOptionsPanel, 'Style', 'text', ...
                'String', 'Max. Iterations', 'Units', 'Pixels', 'HorizontalAlignment', 'left', ...
                'Position', [118 96 80 13]);
            hMaxIterationsEditBox = uicontrol('Parent', hOptimizationOptionsPanel, 'Style', 'edit', ...
                'String', num2str(model.MaxIterations), 'Units', 'Pixels', 'Position', [118 70 80 20]);
            hMaxTimeLabel = uicontrol('Parent', hOptimizationOptionsPanel, 'Style', 'text', ...
                'String', 'Max. Time', 'Units', 'Pixels', 'Position', [224 96 80 13]);
            hMaxTimeEditBox = uicontrol('Parent', hOptimizationOptionsPanel, 'Style', 'edit', ...
                'String', num2str(model.MaxTime), 'Units', 'Pixels', 'Position', [224 70 80 20]);
            hLowerBoundLabel = uicontrol('Parent', hOptimizationOptionsPanel, 'Style', 'text', ...
                'String', 'Lower Bound', 'Units', 'Pixels', 'Position', [12 40 80 13]);
            hLowerBoundEditBox = uicontrol('Parent', hOptimizationOptionsPanel, 'Style', 'edit', ...
                'String', mat2str(model.LowerBound), 'Units', 'Pixels', 'Position', [12 14 80 20]);
            hUpperBoundLabel = uicontrol('Parent', hOptimizationOptionsPanel, 'Style', 'text', ...
                'String', 'Upper Bound', 'Units', 'Pixels', 'Position', [118 40 80 13]);
            hUpperBoundEditBox = uicontrol('Parent', hOptimizationOptionsPanel, 'Style', 'edit', ...
                'String', mat2str(model.UpperBound), 'Units', 'Pixels', 'Position', [118 14 80 20]);
            hOptimizationDisplayLabel = uicontrol('Parent', hOptimizationOptionsPanel, 'Style', 'text', ...
                'String', 'Display', 'Units', 'Pixels', 'Position', [224 40 80 13]);
            hOptimizationDisplayPopUpMenu = uicontrol('Parent', hOptimizationOptionsPanel, 'Style', 'popup', ...
                'String', {'off', 'iter', 'diagnose', 'final'}, 'Units', 'Pixels', ...
                'Position', [224 14 80 20]);

            % Ok/Cancel Buttons
            hOkButton = uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'OK', ...
                'Position', [170 20 70 22]);
            hCancelButton = uicontrol('Parent', hFig, 'Style', 'pushbutton', 'String', 'Cancel', ...
                'Position', [252 20 70 22]);

            this.UiControls = struct(...
                'Figure', hFig, ...
                'KineticsModelButtonGroup', hKineticsModelButtonGroup, ...
                'OdeSolverButtonGroup', hOdeSolverButtonGroup, ...
                'ParallelComputationPanel', hParallelComputationPanel, ...
                'OptimizerButtonGroup', hOptimizerButtonGroup, ...
                'RegularizationPanel', hRegularizationPanel, ...
                'FitnessMeasureButtonGroup', hFitnessMeasureButtonGroup, ...
                'OptimizationOptionsPanel', hOptimizationOptionsPanel, ...
                'LinearOde', hLinearOde, ...
                'MichaelisMentenOde', hMichaelisMentenOde, ...
                'BiexponentialAlgebraic', hBiexponentialAlgebraic, ...
                'TRISTAN', hTristan, ...
                'Georgiou', hGeorgiou, ...
                'Berks', hBerks, ...
                'Ode15s', hOde15s, ...
                'Ode23s', hOde23s, ...
                'Ode23t', hOde23t, ...
                'Ode23tb', hOde23tb, ...
                'UseParallelComputationCheckBox', hUseParallelComputationCheckBox, ...
                'PatternSearch', hPatternSearch, ...
                'GradientDescent', hGradientDescent, ...
                'SimulatedAnnealing', hSimulatedAnnealing, ...
                'ParticleSwarm', hParticleSwarm, ...
                'GeneticAlgorithm', hGeneticAlgorithm, ...
                'SurrogateOptimization', hSurrogateOptimization, ...
                'GlobalSearch', hGlobalSearch, ...
                'MultiStart', hMultiStart, ...
                'LevenbergMarquardt', hLevenbergMarquardt, ...
                'TrustRegionReflective', hTrustRegionReflective, ...
                'UseRegularizationCheckBox', hUseRegularizationCheckBox, ...
                'LambdaLabel', hLambdaLabel, ...
                'LambdaEditBox', hLambdaEditBox, ...
                'LeastSquares', hLeastSquares, ...
                'LeastAbsoluteResiduals', hLeastAbsoluteResiduals, ...
                'LeastMedianOfSquares', hLeastMedianOfSquares, ...
                'LeastMedianAbsoluteResiduals', hLeastMedianAbsoluteResiduals, ...
                'InitialEstimateLabel', hInitialEstimateLabel, ...
                'InitialEstimateEditBox', hInitialEstimateEditBox, ...
                'MaxIterationsLabel', hMaxIterationsLabel, ...
                'MaxIterationsEditBox', hMaxIterationsEditBox, ...
                'MaxTimeLabel', hMaxTimeLabel, ...
                'MaxTimeEditBox', hMaxTimeEditBox, ...
                'LowerBoundLabel', hLowerBoundLabel, ...
                'LowerBoundEditBox', hLowerBoundEditBox, ...
                'UpperBoundLabel', hUpperBoundLabel, ...
                'UpperBoundEditBox', hUpperBoundEditBox, ...
                'OptimizationDisplayLabel', hOptimizationDisplayLabel, ...
                'OptimizationDisplayPopUpMenu', hOptimizationDisplayPopUpMenu, ...
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

        %% OnChangedKineticsModelName
        function OnChangedKineticsModelName(this, uiModel)
            % The uibuttongroup control handles selection of the appropriate radiobutton
            this.SetDefaultModelSelectionUiState(uiModel);
            switch uiModel.KineticsModelName
                case 'Linear ODE'
                    this.SetUiStateForLinearOdeModel(uiModel);
                case 'Michaelis-Menten ODE'
                    this.SetUiStateForMichaelisMentenModel(uiModel);
                case 'Bi-exponential Algebraic'
                    this.SetUiStateForBiexponentialAlgebraicModel(uiModel);
                case 'TRISTAN'
                    this.SetUiStateForTristanLinearModel(uiModel);
                case 'Georgiou'
                    this.SetUiStateForGeorgiouModel(uiModel);
                case 'Berks'
                    this.SetUiStateForBerksModel(uiModel);
                otherwise
            end
        end

        %% SetUiStateForLinearOdeModel
        function SetUiStateForLinearOdeModel(this, uiModel)
            uiControls = this.UiControls;
            uiControls.GradientDescent.Enable = 'off';
            this.SetOdeSelectionUiState(true);
        end

        %% SetUiStateForMichaelisMentenModel
        function SetUiStateForMichaelisMentenModel(this, uiModel)
            uiControls = this.UiControls;
            uiControls.GradientDescent.Enable = 'off';
            this.SetOdeSelectionUiState(true);
        end

        %% SetUiStateForTristanLinearModel
        function SetUiStateForTristanLinearModel(this, uiModel)
            uiControls = this.UiControls;
            uiControls.GradientDescent.Enable = 'off';
            this.SetOdeSelectionUiState(false);
        end

        %% SetUiStateForGeorgiouModel
        function SetUiStateForGeorgiouModel(this, uiModel)
            uiControls = this.UiControls;
            uiControls.GradientDescent.Enable = 'off';
            uiControls.SurrogateOptimization.Enable = 'off';
            this.SetOdeSelectionUiState(false);
        end

        %% SetUiStateForBerksModel
        function SetUiStateForBerksModel(this, uiModel)
            uiControls = this.UiControls;
            uiControls.GradientDescent.Enable = 'off';
            uiControls.SurrogateOptimization.Enable = 'off';
            this.SetOdeSelectionUiState(false);
        end

        %% SetUiStateForBiexponentialAlgebraicModel
        function SetUiStateForBiexponentialAlgebraicModel(this, uiModel)
            uiControls = this.UiControls;
            uiControls.PatternSearch.Enable = 'off';
            uiControls.GradientDescent.Enable = 'off';
            uiControls.SimulatedAnnealing.Enable = 'off';
            uiControls.ParticleSwarm.Enable = 'off';
            uiControls.GeneticAlgorithm.Enable = 'off';
            uiControls.SurrogateOptimization.Enable = 'off';
            uiControls.GlobalSearch.Enable = 'off';
            uiControls.MultiStart.Enable = 'off';
            switch uiModel.OptimizerName
                case 'Levenberg-Marquardt'
                case 'Trust Region Reflective'
                otherwise
                    uiControls.OptimizerButtonGroup.SelectedObject = uiControls.TrustRegionReflective;
                    uiModel.OptimizerName = 'Trust Region Reflective';
            end
            this.SetOdeSelectionUiState(false);
        end

        %% SetDefaultModelSelectionUiState
        function SetDefaultModelSelectionUiState(this, uiModel)
            uiControls = this.UiControls;
            uiControls.PatternSearch.Enable = 'on';
            uiControls.GradientDescent.Enable = 'off';
            uiControls.SimulatedAnnealing.Enable = 'on';
            uiControls.ParticleSwarm.Enable = 'on';
            uiControls.GeneticAlgorithm.Enable = 'on';
            uiControls.SurrogateOptimization.Enable = 'on';
            uiControls.GlobalSearch.Enable = 'on';
            uiControls.MultiStart.Enable = 'on';
            uiControls.LevenbergMarquardt.Enable = 'on';
            uiControls.TrustRegionReflective.Enable = 'on';
            this.SetOdeSelectionUiState(true);
            switch uiModel.OptimizerName
                case 'Pattern Search'
                case 'Simulated Annealing'
                case 'Particle Swarm'
                case 'Genetic Algorithm'
                case 'Surrogate Optimization'
                case 'Global Search'
                case 'Multi-Start'
                case 'Levenberg-Marquardt'
                case 'Trust Region Reflective'
                otherwise
                    uiControls.OptimizerButtonGroup.SelectedObject = uiControls.PatternSearch;
                    uiModel.OptimizerName = 'Pattern Search';
            end
        end

        %% SetOdeSelectionUiState
        function SetOdeSelectionUiState(this, isOdeModel)
            arguments
                this (1,1) KineticsPickerView
                isOdeModel (1,1) logical
            end

            uiControls = this.UiControls;
            if (isOdeModel)
                uiControls.Ode15s.Enable = 'on';
                uiControls.Ode23s.Enable = 'on';
                uiControls.Ode23t.Enable = 'on';
                uiControls.Ode23tb.Enable = 'on';
            else
                uiControls.Ode15s.Enable = 'off';
                uiControls.Ode23s.Enable = 'off';
                uiControls.Ode23t.Enable = 'off';
                uiControls.Ode23tb.Enable = 'off';
            end
        end

        %% OnChangedOdeSolverName
        function OnChangedOdeSolverName(~, ~)
            % The uibuttongroup control handles selection of the appropriate
            % radiobutton.
        end

        %% OnChangedUseParallelComputation
        function OnChangedUseParallelComputation(~, ~)
        end

        %% OnChangedOptimizerName
        function OnChangedOptimizerName(~, ~)
            % The uibuttongroup control handles selection of the appropriate
            % radiobutton
        end

        %% OnChangedFitnessMeasure
        function OnChangedFitnessMeasure(~, ~)
            % The uibuttongroup control handles selection of the appropriate
            % radiobutton
        end

        %% OnChangedInitialEstimate
        function OnChangedInitialEstimate(this, uiModel)
            handles = this.UiControls;
            if(~isvalid(handles.InitialEstimateEditBox))
                return
            end
            handles.InitialEstimateEditBox.String = mat2str(uiModel.InitialEstimate);
        end

        %% OnChangedMaxIterations
        function OnChangedMaxIterations(this, uiModel)
            handles = this.UiControls;
            if(~isvalid(handles.MaxIterationsEditBox))
                return
            end
            handles.MaxIterationsEditBox.String = num2str(uiModel.MaxIterations);
        end

        %% OnChangedMaxTime
        function OnChangedMaxTime(this, uiModel)
            handles = this.UiControls;
            if(~isvalid(handles.MaxTimeEditBox))
                return
            end
            handles.MaxTimeEditBox.String = num2str(uiModel.MaxTime);
        end

        %% OnChangedLowerBound
        function OnChangedLowerBound(this, uiModel)
            handles = this.UiControls;
            if(~isvalid(handles.LowerBoundEditBox))
                return
            end
            handles.LowerBoundEditBox.String = mat2str(uiModel.LowerBound);
        end

        %% OnChangedUpperBound
        function OnChangedUpperBound(this, uiModel)
            handles = this.UiControls;
            if(~isvalid(handles.UpperBoundEditBox))
                return
            end
            handles.UpperBoundEditBox.String = mat2str(uiModel.UpperBound);
        end

        %% OnChangedOptimizationDisplay
        function OnChangedOptimizationDisplay(this, uiModel)
            handles = this.UiControls;
            % Display Option Values
            % 1 = off
            % 2 = iter
            % 3 = diagnose
            % 4 = final

            if(~isvalid(handles.OptimizationDisplayPopUpMenu))
                return
            end
            optionList = handles.OptimizationDisplayPopUpMenu.String;
            displayOption = find(strcmp(uiModel.OptimizationDisplay, ...
                optionList));

            if (~isempty(displayOption))
                handles.OptimizationDisplayPopUpMenu.Value = displayOption;
            end
        end

        %% OnChangedLambda
        function OnChangedLambda(this, uiModel)
            handles = this.UiControls;
            if(~isvalid(handles.LambdaEditBox))
                return
            end
            handles.LambdaEditBox.String = num2str(uiModel.Lambda);
        end

        %% OnChangedUseRegularization
        function OnChangedUseRegularization(this, uiModel)
            handles = this.UiControls;
            if(~isvalid(handles.LambdaLabel) || ~isvalid(handles.LambdaEditBox))
                return
            end
            useRegularization = uiModel.UseRegularization;
            if (useRegularization)
                handles.LambdaLabel.Enable = 'on';
                handles.LambdaEditBox.Enable = 'on';
            else
                handles.LambdaLabel.Enable = 'off';
                handles.LambdaEditBox.Enable = 'off';
            end
        end
    end

    %% Static Methods
    methods (Static)
    end
end










