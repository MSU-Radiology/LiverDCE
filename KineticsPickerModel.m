classdef KineticsPickerModel < handle
    % KineticsPickerModel   Model class (MVC pattern) for the KineticsPicker GUI that allows the user to select the
    %                       optimization algorithm to use, bounds for the model parameters, ODE solver (if applicable),
    %                       choice of fitness criterion, etc.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    %% Properties
    
    % Observable Properties (listeners receive notification of changes)
    properties (SetObservable = true, AbortSet = true)
        KineticsModelName
        OdeSolverName
        UseParallelComputation(1,1) logical
        OptimizerName
        InitialEstimate
        MaxIterations(1,1) double
        MaxTime(1,1) double
        MeshTolerance(1,1) double
        LowerBound
        UpperBound
        OptimizationDisplay
        UseRegularization(1,1) logical
        Lambda
        FitnessMeasure
        SavedScreenPosition
        Cancelled(1,1) logical
    end
    
    % Private Properties
    properties (Access = private)
    end
    
    % Computable Dependent Properties
    properties (Dependent = true, SetAccess = private)
        OdeSolver
        Optimizer
        OptimizationOptions
        IsReferenceRegionModel(1,1) logical
    end
    
    %% Events
    events
    end
    
    %% Class Methods
    methods
        %% Constructors
        function this = KineticsPickerModel(varargin)
            switch nargin
                case 0
                    this.KineticsModelName = 'Berks';
                    this.OdeSolverName = 'ode23s';
                    this.UseParallelComputation = true;
                    this.OptimizerName = 'Multi-Start';
                    this.InitialEstimate = [ones(1,4)*0.01 0.2 10];
                    this.MaxIterations = 3000;
                    this.MaxTime = 1200;
                    this.MeshTolerance = 1e-7;
                    this.LowerBound = [eps*ones(1,5) 0];
                    this.UpperBound = [ones(1,5) 50];
                    this.OptimizationDisplay = 'iter';
                    this.UseRegularization = false;
                    this.Lambda = 0.01;
                    this.FitnessMeasure = 'LSQ';
                    this.SavedScreenPosition = double.empty;
                case 1
                    m = varargin{1};
                    this.KineticsModelName = m.KineticsModelName;
                    this.OdeSolverName = m.OdeSolverName;
                    this.UseParallelComputation = m.UseParallelComputation;
                    this.OptimizerName = m.OptimizerName;
                    this.InitialEstimate = m.InitialEstimate;
                    this.MaxIterations = m.MaxIterations;
                    this.MaxTime = m.MaxTime;
                    this.MeshTolerance = m.MeshTolerance;
                    this.LowerBound = m.LowerBound;
                    this.UpperBound = m.UpperBound;
                    this.OptimizationDisplay = m.OptimizationDisplay;
                    this.UseRegularization = m.UseRegularization;
                    this.Lambda = m.Lambda;
                    this.FitnessMeasure = m.FitnessMeasure;
                    this.SavedScreenPosition = m.SavedScreenPosition;
                otherwise
                    error('KineticsPickerModel received too many arguments');
            end
        end
        
        %% Getters for Computable Dependent Properties
        function f = get.OdeSolver(this)
            switch this.OdeSolverName
                case 'ode15s'
                    f = @ode15s;
                case 'ode23s'
                    f = @ode23s;
                case 'ode23t'
                    f = @ode23t;
                case 'ode23tb'
                    f = @ode23tb;
                case 'none, non-ODE model'
                    f = [];
                otherwise
                    error('Unknown ODE Solver');
            end
        end
        
        function f = get.Optimizer(this)
            switch this.OptimizerName
                case 'Pattern Search'
                    f = @patternsearch;
                case 'Gradient Descent'
                    error('Gradient Descent is not yet implemented');
                case 'Simulated Annealing'
                    f = @simulannealbnd;
                case 'Particle Swarm'
                    f = @particleswarm;
                case 'Genetic Algorithm'
                    f = @ga;
                case 'Surrogate Optimization'
                    f = @surrogateopt;
                case 'Global Search'
                    f = @GlobalSearch;
                case 'Multi-Start'
                    f = @MultiStart;
                case 'Levenberg-Marquardt'
                    f = @lsqcurvefit;
                case 'Trust Region Reflective'
                    f = @lsqcurvefit;
                otherwise
                    error('Unknown Optimizer');
            end
        end
        
        function opts = get.OptimizationOptions(this)
            switch this.OptimizerName
                case 'Pattern Search'
                    opts = this.GetPatternSearchOptions();
                case 'Gradient Descent'
                    error('Gradient Descent is not yet implemented');
                case 'Simulated Annealing'
                    opts = this.GetSimulatedAnnealingOptions();
                case 'Particle Swarm'
                    opts = this.GetParticleSwarmOptions();
                case 'Genetic Algorithm'
                    opts = this.GetGeneticAlgorithmOptions();
                case 'Surrogate Optimization'
                    opts = this.GetSurrogateOptimizationOptions();
                case 'Global Search'
                    opts = this.GetGlobalSearchOptions();
                case 'Multi-Start'
                    opts = this.GetMultiStartOptions();
                case 'Levenberg-Marquardt'
                    opts = this.GetLevenbergMarquardtOptions();
                case 'Trust Region Reflective'
                    opts = this.GetTrustRegionReflectiveOptions();
                otherwise
                    error('Unknown Optimizer');
            end
        end

        function bool = get.IsReferenceRegionModel(this)
            switch this.KineticsModelName
                case {'Linear ODE', 'Michaelis-Menten ODE', 'Bi-exponential Algebraic', 'TRISTAN'}
                    bool = true;
                case {'Georgiou', 'Berks'}
                    bool = false;
                otherwise
                    error('Unknown pharmacokinetic model');
            end
        end

        %% Getters and Setters
        function position = get.SavedScreenPosition(this)
            position = this.SavedScreenPosition;
        end
        
        function set.SavedScreenPosition(this, value)
            this.SavedScreenPosition = value;
        end
        
        function name = get.KineticsModelName(this)
            name = this.KineticsModelName;
        end
        
        function set.KineticsModelName(this, kmodel)
            this.KineticsModelName = kmodel;
        end
        
        function name = get.OdeSolverName(this)
            name = this.OdeSolverName;
        end
        
        function set.OdeSolverName(this, odeSolver)
            this.OdeSolverName = odeSolver;
        end
        
        function name = get.OptimizerName(this)
            name = this.OptimizerName;
        end
        
        function set.OptimizerName(this, optim)
            this.OptimizerName = optim;
        end
        
        function fitnessMeasure = get.FitnessMeasure(this)
            fitnessMeasure = this.FitnessMeasure;
        end
        
        function set.FitnessMeasure(this, kmodel)
            this.FitnessMeasure = kmodel;
        end
        
        function initialEstimate = get.InitialEstimate(this)
            initialEstimate = this.InitialEstimate;
        end
        
        function set.InitialEstimate(this, initialEstimate)
            assert(all(isfinite(initialEstimate)));
            
            this.InitialEstimate = initialEstimate;
        end
        
        function maxIterations = get.MaxIterations(this)
            maxIterations = this.MaxIterations;
        end
        
        function set.MaxIterations(this, iterations)
            assert(isfinite(iterations));
            
            this.MaxIterations = iterations;
        end
        
        function maxTime = get.MaxTime(this)
            maxTime = this.MaxTime;
        end
        
        function set.MaxTime(this, timeInSeconds)
            assert(isfinite(timeInSeconds));
            
            this.MaxTime = timeInSeconds;
        end
        
        function lb = get.LowerBound(this)
            lb = this.LowerBound;
        end
        
        function set.LowerBound(this, lb)
            assert(all(isfinite(lb)));
            
            this.LowerBound = lb;
        end
        
        function ub = get.UpperBound(this)
            ub = this.UpperBound;
        end
        
        function set.UpperBound(this, ub)
            assert(all(isfinite(ub)));
            
            this.UpperBound = ub;
        end
        
        function optimizationDisplay = get.OptimizationDisplay(this)
            optimizationDisplay = this.OptimizationDisplay;
        end
        
        function set.OptimizationDisplay(this, str)
            this.OptimizationDisplay = str;
        end

        %% Other Public Methods

        %% GetPatternSearchOptions
        function options = GetPatternSearchOptions(this)
            options = optimoptions('patternsearch', 'MaxTime', this.MaxTime, 'MaxIterations', this.MaxIterations, ...
                'Display', this.OptimizationDisplay, 'MeshTolerance', this.MeshTolerance);
            if(this.UseParallelComputation)
                options = optimoptions(options, 'UseParallel', this.UseParallelComputation);
            end
            switch this.KineticsModelName
                case {'Linear ODE', 'Michaelis-Menten ODE', 'Georgiou', 'Berks'}
                    options = optimoptions(options, 'InitialMeshSize', 0.1);
                case 'Bi-exponential Algebraic'
                    error('Not yet implemented');
                case 'TRISTAN'
                    % turn off parallelism until the model code is fully tested
                    options = optimoptions(options, 'InitialMeshSize', 0.1);
                otherwise
                    error('Unknown kinetics model');
            end
        end

        %% GetSimulatedAnnealingOptions
        function options = GetSimulatedAnnealingOptions(this)
            options = optimoptions('simulannealbnd', 'MaxTime', this.MaxTime, 'MaxIterations', this.MaxIterations, ...
                'Display', this.OptimizationDisplay);
            switch this.KineticsModelName
                case {'Linear ODE', 'Michaelis-Menten ODE', 'TRISTAN', 'Georgiou', 'Berks'}
                    % no special options
                case 'Bi-exponential Algebraic'
                    error('Not implemented');
                otherwise
                    error('Unknown kinetics model');
            end
        end

        %% GetParticleSwarmOptions
        function options = GetParticleSwarmOptions(this)
            options = optimoptions('particleswarm', 'MaxTime', this.MaxTime, 'MaxIterations', this.MaxIterations, ...
                'Display', this.OptimizationDisplay, 'FunctionTolerance', 1.0e-7);
            if(this.UseParallelComputation)
                options = optimoptions(options, 'UseParallel', this.UseParallelComputation);
            end
            switch this.KineticsModelName
                case {'Linear ODE', 'Michaelis-Menten ODE', 'TRISTAN', 'Georgiou', 'Berks'}
                    % no special options
                case 'Bi-exponential Algebraic'
                    error('Not implemented');
                otherwise
                    error('Unknown kinetics model');
            end
        end

        %% GetGeneticAlgorithmOptions
        function options = GetGeneticAlgorithmOptions(this)
            % MaxIterations is not an allowed option for ga
            options = optimoptions('ga', 'MaxTime', this.MaxTime, 'Display', this.OptimizationDisplay);
            if(this.UseParallelComputation)
                options = optimoptions(options, 'UseParallel', this.UseParallelComputation);
            end
            switch this.KineticsModelName
                case {'Linear ODE', 'TRISTAN', 'Georgiou', 'Berks'}
                    % no special options
                case 'Michaelis-Menten ODE'
                    options = optimoptions(options, 'MaxGenerations', 1000, 'PopulationSize', 200);
                case 'Bi-exponential Algebraic'
                    error('Not implemented');
                otherwise
                    error('Unknown kinetics model');
            end
        end

        %% GetSurrogateOptimizationOptions
        function options = GetSurrogateOptimizationOptions(this)
            % MaxIterations is not an allowed option for surrogateopt
            options = optimoptions('surrogateopt', 'MaxTime', this.MaxTime, 'Display', this.OptimizationDisplay);
            if(this.UseParallelComputation)
                options = optimoptions(options, 'UseParallel', this.UseParallelComputation);
            end
            switch this.KineticsModelName
                case {'Linear ODE', 'TRISTAN', 'Georgiou', 'Berks'}
                    % No special options
                case 'Michaelis-Menten ODE'
                    % No special options
                case 'Bi-exponential Algebraic'
                    error('Not implemented');
                otherwise
                    error('Unknown kinetics model');
            end
        end

        %% GetGlobalSearchOptions
        function options = GetGlobalSearchOptions(this) %#ok<MANU> 
            options = optimoptions(@fmincon, 'Algorithm', 'interior-point', 'MaxIterations', 3000);
        end

        %% GetMultiStartOptions
        function options = GetMultiStartOptions(this)
            options = optimoptions(@fmincon, 'Algorithm', 'interior-point', 'Display', 'iter', 'MaxIterations', 3000);
            if(this.UseParallelComputation)
                options = optimoptions(options, 'UseParallel', this.UseParallelComputation);
            end
        end

        %% GetLevenbergMarquardtOptions
        function options = GetLevenbergMarquardtOptions(this)
            options = optimoptions('lsqcurvefit', 'Algorithm', 'levenberg-marquardt', ...
                'Display', this.OptimizationDisplay);
            if(this.UseParallelComputation)
                options = optimoptions(options, 'UseParallel', this.UseParallelComputation);
            end
            switch this.KineticsModelName
                case {'Linear ODE', 'Michaelis-Menten ODE', 'Bi-exponential Algebraic', 'TRISTAN', 'Georgiou', 'Berks'}
                    options = optimoptions(options, 'MaxIterations', this.MaxIterations, ...
                        'MaxFunctionEvaluations', 4000);
                otherwise
                    error('Unknown kinetics model');
            end
        end

        %% GetTrustRegionReflectiveOptions
        function options = GetTrustRegionReflectiveOptions(this)
            options = optimoptions('lsqcurvefit', 'Algorithm', 'trust-region-reflective', ...
                'Display', this.OptimizationDisplay);
            if(this.UseParallelComputation)
                options = optimoptions(options, 'UseParallel', this.UseParallelComputation);
            end
            switch this.KineticsModelName
                case {'Linear ODE', 'Michaelis-Menten ODE', 'Bi-exponential Algebraic', 'TRISTAN', 'Georgiou', 'Berks'}
                    options = optimoptions(options, 'MaxIterations', this.MaxIterations, ...
                        'MaxFunctionEvaluations', 4000);
                otherwise
                    error('Unknown kinetics model');
            end
        end

        %% GetPkModel
        function pkModel = GetPkModel(this)
            arguments
                this(1,1) KineticsPickerModel
            end

            name = this.KineticsModelName;
            switch name
                case 'Linear ODE'
                    pkModel = PkLinearOdeModel(this);
                case 'Michaelis-Menten ODE'
                    pkModel = PkMichaelisMentenOdeModel(this);
                case 'Bi-exponential Algebraic'
%                     pkModel = PkBiexponentialModel(this);
                    error('Model not yet implemented as subclass of PharmacokineticModel');
                case 'TRISTAN'
                    pkModel = PkTristanLinearModel(this);
                case 'Georgiou'
                    pkModel = PkGeorgiouModel(this);
                case 'Berks'
                    pkModel = PkBerksModel(this);
                otherwise
                    error('Unknown PBPK model');
            end
        end
    end

    %% Private Methods
    methods (Access = private)
    end

    %% Public Static Methods
    methods (Static)
    end

    %% Private Static Methods
    methods (Static, Access = private)
    end
end