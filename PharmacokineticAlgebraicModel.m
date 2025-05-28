classdef (Abstract) PharmacokineticAlgebraicModel < PharmacokineticModel
    % PharmacokineticAlgebraicModel		Abstract base class for pharmacokinetic models expressed in the form of an 
    %                                   algebraic equation (typically in the form of a discrete convolution)
    %
    % Copyright (C) 2025   Michigan State University
    % Author:  Matt Latourette

    properties (Abstract)
    end

    properties
    end

    methods (Abstract, Access = public)
        evaluatedSignal = Evaluate(this, freeParameters, fixedParameters, varargin)
    end

    methods
        function this = PharmacokineticAlgebraicModel(varargin)
            this@PharmacokineticModel(varargin{:});
        end

        function fittedParameters = FitToData(this, fixedParameters, varargin)
            arguments
                this (1,1) PharmacokineticAlgebraicModel
                fixedParameters (1,1) struct
            end
            arguments (Repeating)
                varargin
            end
            fittedParameters = this.FitToData@IFittable(fixedParameters, varargin{:});

            [initialEstimate, lb, ub, fitOptions, numberOfFreeParameters] = GetScaledFitOptions(this);

            if(this.FitOptions.IsReferenceRegionModel)
                costFunction = @(freeParameters) this.ComputeCost(this.Solution(...
                    freeParameters, fixedParameters), fixedParameters.Ci, freeParameters);
            else
                costFunction = @(freeParameters) this.ComputeCost(this.Solution(...
                    freeParameters, fixedParameters), fixedParameters.Ct, freeParameters);
            end

            valueFunction = @(freeParameters, ignore) this.Solution(freeParameters, fixedParameters);
            opts = fitOptions.OptimizationOptions;
            this.SuppressSingularMatrixWarnings();
            switch fitOptions.OptimizerName
                case 'Pattern Search'
                    if(this.FitOptions.IsReferenceRegionModel && exist('mypsplotfcn', 'file'))
                        opts.PlotFcn = @(optimvalues, flag) mypsplotfcn(optimvalues, flag, fixedParameters, [], ...
                            this, numberOfFreeParameters);
                    end
                    [psolve, fval, exitflag, output] = patternsearch(costFunction, ...
                        initialEstimate, [], [], [], [], lb, ub, opts);
                case 'Gradient Descent'
                    error('Gradient Descent is not yet implemented.');
                case 'Simulated Annealing'
                    if(this.FitOptions.IsReferenceRegionModel && exist('myoptimplotfcn', 'file'))
                        opts.PlotFcn = @(~, optimvalues, flag) myoptimplotfcn(optimvalues, flag, fixedParameters, ...
                            [], this, numberOfFreeParameters);
                    end
                    [psolve, fval, exitflag, output] = simulannealbnd(costFunction, initialEstimate, lb, ub, opts);
                case 'Particle Swarm'
                    if(this.FitOptions.IsReferenceRegionModel && exist('myoptimplotfcn', 'file'))
                        opts.PlotFcn = @(optimvalues, flag) myoptimplotfcn(optimvalues, flag, fixedParameters, ...
                            [], this, double(numberOfFreeParameters));
                    end
                    [psolve, fval, exitflag, output] = particleswarm(costFunction, ...
                        double(numberOfFreeParameters), lb, ub, opts);
                case 'Genetic Algorithm'
                    if(this.FitOptions.IsReferenceRegionModel && exist('mygaplotfcn', 'file'))
                        opts.PlotFcn = @(options, optimvalues, flag) mygaplotfcn(options, optimvalues, flag, ...
                            fixedParameters, [], this, numberOfFreeParameters);
                    else
                    end
                    [psolve, fval, exitflag, output, population, scores] = ga(costFunction, ...
                        double(numberOfFreeParameters), [], [], [], [], lb, ub, [], opts);
                case 'Surrogate Optimization'
                    [Xpts, Ypts] = meshgrid(5:-1:-5);
                    Xpts = 10.^Xpts;
                    Ypts = 10.^Ypts;
                    startpts = [Xpts(:), Ypts(:)];
                    opts = optimoptions('surrogateopt', 'PlotFcn', 'surrogateoptplot', ...
                        'InitialPoints', startpts, 'MaxFunctionEvaluations', 3000);
                    [psolve, fval, exitflag, output] = surrogateopt(costFunction, lb, ub, opts);
                case 'Global Search'
                    opts = optimoptions(@fmincon, 'Algorithm', 'interior-point', 'MaxIterations', 3000);
                    problem = createOptimProblem('fmincon', 'x0', initialEstimate, 'objective', costFunction, ...
                        'lb', lb, 'ub', ub, 'options', opts);
                    gs = GlobalSearch('Display', 'iter', 'PlotFcn', @gsplotbestf);
                    [psolve, fval, exitflag, output, solutions] = run(gs, problem);
                case 'Multi-Start'
                    if(~isa(this, 'IMultiStartOptimizable'))
                        return
                    end
                    opts = optimoptions(@fmincon, 'Algorithm', 'interior-point', 'MaxIterations', 3000);
                    problem = createOptimProblem('fmincon', 'x0', initialEstimate, 'objective', costFunction, ...
                        'lb', lb, 'ub', ub, 'options', opts);
                    ms = MultiStart('UseParallel', fitOptions.UseParallelComputation, 'StartPointsToRun', 'bounds');
                    points = this.GenerateStartingEstimatesForMultiStartOptimizer();
                    startPoints = CustomStartPointSet(points);
                    [psolve, fval, exitflag, output, solutions] = run(ms, problem, startPoints);
                case 'Levenberg-Marquardt'
                    opts = optimoptions('lsqcurvefit', 'Algorithm', 'levenberg-marquardt', 'Display', 'iter', ...
                        'FunctionTolerance', 1e-50, 'StepTolerance', 1e-50, 'FiniteDifferenceStepSize', 1e-4, ...
                        'FiniteDifferenceType', 'central');
                    if(this.FitOptions.IsReferenceRegionModel)
                        [psolve, fval, residual, exitflag, output, lambda, jacobian] = ...
                            lsqcurvefit(valueFunction, initialEstimate, fixedParameters.time, fixedParameters.Ci, ...
                            lb, ub, opts);
                    else
                        [psolve, fval, residual, exitflag, output, lambda, jacobian] = ...
                            lsqcurvefit(valueFunction, initialEstimate, fixedParameters.time, fixedParameters.Ct, ...
                            lb, ub, opts);
                    end
                case 'Trust Region Reflective'
                    opts = optimoptions('lsqcurvefit', 'Algorithm', 'trust-region-reflective', ...
                        'Display', 'iter', 'FunctionTolerance', 1e-50, 'StepTolerance', 1e-50, ...
                        'FiniteDifferenceStepSize', 1e-4, 'FiniteDifferenceType', 'central');
                    if(this.FitOptions.IsReferenceRegionModel)
                        [psolve, fval, residual, exitflag, output, lambda, jacobian] = ...
                            lsqcurvefit(valueFunction, initialEstimate, fixedParameters.time, fixedParameters.Ci, ...
                            lb, ub, opts);
                    else
                        [psolve, fval, residual, exitflag, output, lambda, jacobian] = ...
                            lsqcurvefit(valueFunction, initialEstimate, fixedParameters.time, fixedParameters.Ct, ...
                            lb, ub, opts);
                    end
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

        function modeledSignal = Solution(this, freeParameters, fixedParameters, varargin)
            arguments
                this (1,1) PharmacokineticAlgebraicModel
                freeParameters (1,:) double
                fixedParameters(1,1) struct
            end
            arguments (Repeating)
                varargin
            end

            if(this.FitOptions.IsReferenceRegionModel)
                empiricalSignal = fixedParameters.Ci;
            else
                empiricalSignal = fixedParameters.Ct;
            end
            acqZero = fixedParameters.acqZero;

            fittedSignal = this.Evaluate(freeParameters, fixedParameters, varargin{:});

            modeledSignal = zeros(size(empiricalSignal));
            modeledSignal(acqZero:end) = fittedSignal(acqZero:end);
        end
    end
end