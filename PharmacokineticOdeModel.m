classdef (Abstract) PharmacokineticOdeModel < INumericallyIntegrable & PharmacokineticModel
    % PharmacokineticOdeModel   Abstract base class for pharmacokinetic models expressed in the form of an ordinary
    %                           differential equation that must be solved numerically
    %
    % Copyright (C) 2025   Michigan State University
    % Author:  Matt Latourette

    methods (Abstract, Access = public)
        evaluatedSignal = Evaluate(this, freeParameters, fixedParameters, varargin)
    end

    %% Public Methods
    methods
        %% Constructors
        function this = PharmacokineticOdeModel(varargin)
            this@PharmacokineticModel(varargin{:});
            fitOptions = varargin{1};
            this.OdeSolver = fitOptions.OdeSolver;
        end

        %% FitToData
        function fittedParameters = FitToData(this, fixedParameters, varargin)
            arguments
                this (1,1) PharmacokineticOdeModel
                fixedParameters (1,1) struct
            end
            arguments (Repeating)
                varargin
            end
            fittedParameters = this.FitToData@IFittable(fixedParameters, varargin{:});

            [initialEstimate, lb, ub, fitOptions, numberOfFreeParameters] = GetScaledFitOptions(this);

            odeSolver = this.OdeSolver;

            costFunction = @(parameterVector) this.ComputeCost(this.Solution(parameterVector, fixedParameters, 0), ...
                fixedParameters.Ci, parameterVector);
            valueFunction = @(parameterVector, ignore) this.Solution(parameterVector, fixedParameters, 0);
            opts = fitOptions.OptimizationOptions;
            this.SuppressSingularMatrixWarnings();
            switch fitOptions.OptimizerName
                case 'Pattern Search'
                    if(exist('mypsplotfcn', 'file'))
                        opts.PlotFcn = @(optimvalues, flag) mypsplotfcn(optimvalues, flag, fixedParameters, ...
                            odeSolver, this, numberOfFreeParameters);
                    end
                    [psolve, fval, exitflag, output] = patternsearch(costFunction, ...
                        initialEstimate, [], [], [], [], lb, ub, opts);
                case 'Gradient Descent'
                    error('Gradient Descent is not yet implemented.');
                case 'Simulated Annealing'
                    if(exist('myoptimplotfcn', 'file'))
                        opts.PlotFcn = @(~, optimvalues, flag) myoptimplotfcn(optimvalues, flag, fixedParameters, ...
                            odeSolver, this, numberOfFreeParameters);
                    end
                    [psolve, fval, exitflag, output] = simulannealbnd(costFunction, ...
                        initialEstimate, lb, ub, opts);
                case 'Particle Swarm'
                    if(exist('myoptimplotfcn', 'file'))
                        opts.PlotFcn = @(optimvalues, flag) myoptimplotfcn(optimvalues, flag, fixedParameters, ...
                            odeSolver, this, numberOfFreeParameters);
                    end
                    [psolve, fval, exitflag, output] = particleswarm(costFunction, ...
                        double(numberOfFreeParameters), lb, ub, opts);
                case 'Genetic Algorithm'
                    if(exist('mygaplotfcn', 'file'))
                        opts.PlotFcn = @(options, optimvalues, flag) mygaplotfcn(options, optimvalues, flag, ...
                            fixedParameters, odeSolver, this, numberOfFreeParameters);
                    end
                    [psolve, fval, exitflag, output, population, scores] = ga(costFunction, ...
                        double(numberOfFreeParameters), [], [], [], [], lb, ub, [], opts);
                case 'Surrogate Optimization'
                    [Xpts, Ypts] = meshgrid(5:-1:-5);
                    Xpts = 10.^Xpts;
                    Ypts = 10.^Ypts;
                    startpts = [Xpts(:), Ypts(:)];
                    % surrogateopt can't handle [] for an upper bound. It requires finite real values.
                    if(isempty(ub))
                        ub = repmat(1000.0, 1, numberOfFreeParameters);
                    end
                    opts = optimoptions('surrogateopt', 'PlotFcn', 'surrogateoptplot', ...
                        'InitialPoints', startpts, 'MaxFunctionEvaluations', 3000);
                    [psolve, fval, exitflag, output] = surrogateopt(costFunction, lb, ub, opts);
                case 'Global Search'
                    opts = optimoptions(@fmincon, 'Algorithm', 'interior-point', 'MaxIterations', 3000);
                    problem = createOptimProblem('fmincon', 'x0', initialEstimate, 'objective', ...
                        costFunction, 'lb', lb, 'ub', ub, 'options', opts);
                    gs = GlobalSearch('Display', 'iter', 'PlotFcn', @gsplotbestf);
                    [psolve, fval, exitflag, output, solutions] = run(gs, problem);
                case 'Multi-Start'
                    if(~isa(this, 'IMultiStartOptimizable'))
                        return
                    end
                    opts = optimoptions(@fmincon, 'Algorithm', 'interior-point', 'MaxIterations', 3000);
                    problem = createOptimProblem('fmincon', 'x0', initialEstimate, 'objective', ...
                        costFunction, 'lb', lb, 'ub', ub, 'options', opts);
                    ms = MultiStart('UseParallel', fitOptions.UseParallelComputation, 'StartPointsToRun', 'bounds');
                    % Choose starting points ranging over several orders of magnitude
                    points = this.GenerateStartingEstimatesForMultiStartOptimizer();
                    startPoints = CustomStartPointSet(points);
                    % points = list(startPoints, problem);
                    % disp('Starting Points:');
                    % disp(points);
                    [psolve, fval, exitflag, output, solutions] = run(ms, problem, startPoints);
                case 'Levenberg-Marquardt'
                    opts = optimoptions('lsqcurvefit', 'Algorithm', 'levenberg-marquardt', 'Display', 'iter', ...
                        'FunctionTolerance', 1e-50, 'StepTolerance', 1e-50, 'FiniteDifferenceStepSize', 1e-4, ...
                        'FiniteDifferenceType', 'central');
                    [psolve, fval, residual, exitflag, output, lambda, jacobian] = ...
                        lsqcurvefit(valueFunction, initialEstimate, fixedParameters.time, fixedParameters.Ci, ...
                        lb, ub, opts);
                case 'Trust Region Reflective'
                    opts = optimoptions('lsqcurvefit', 'Algorithm', 'trust-region-reflective', 'Display', 'iter', ...
                        'FunctionTolerance', 1e-50, 'StepTolerance', 1e-50, 'FiniteDifferenceStepSize', 1e-4, ...
                        'FiniteDifferenceType', 'central');
                    [psolve, fval, residual, exitflag, output, lambda, jacobian] = ...
                        lsqcurvefit(valueFunction, initialEstimate, fixedParameters.time, fixedParameters.Ci, ...
                        lb, ub, opts);
                otherwise
                    error('Unknown optimizer');
            end
            this.RestoreSupressedWarnings();

            if (isfield(output, 'iterations'))
                fprintf('Iterations: %d\n', output.iterations);
            end
            if (isfield(output, 'funccount'))
                fprintf('Function evals: %d\n', output.funccount);
            end
            fprintf('Best function value: %d\n', fval);
            fprintf('Exit flag: %d\n', exitflag);

            fittedParameters = DescaleParameter(psolve);
        end

        %% Solution
        function modeledSignal = Solution(this, freeParameters, fixedParameters, initialEstimate, varargin)
            arguments
                this (1,1) PharmacokineticOdeModel
                freeParameters (1,:) double
                fixedParameters(1,1) struct
                initialEstimate (1,:) double
            end
            arguments (Repeating)
                varargin
            end

            td = fixedParameters.time;
            empiricalSignal = fixedParameters.Ci;
            acqZero = fixedParameters.acqZero;

            tspan = [td(acqZero) td(end)];

            odeOpts = [];
            odeSolver = this.OdeSolver;
            sol = odeSolver(@(t,fittedCi) this.Evaluate(freeParameters, fixedParameters, ...
                t, fittedCi, varargin{:}), tspan, initialEstimate, odeOpts);

            % The ODE solver computes the modeledSignal at different values of t than the original data, so we have to 
            % interpolate it back to compute the residuals.
            modeledSignal = zeros(size(empiricalSignal));
            modeledSignal(acqZero:end) = deval(sol, td(acqZero:end));
        end
    end
end