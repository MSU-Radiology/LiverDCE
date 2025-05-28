classdef KineticsPickerModelTest < matlab.unittest.TestCase
    % KineticsPickerModelTest   Unit tests for the KineticsPickerModel class
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    %% Properties
    properties
        DefaultKpm
    end

    %% Test Class Setup Methods
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end

    %% Test Method Setup Methods
    methods(TestMethodSetup)
        function CreateDefaultKineticsPickerModel(testCase)
            testCase.DefaultKpm = KineticsPickerModel();
        end
    end

    %% Test Method Teardown Methods
    methods(TestMethodTeardown)
    end

    %% Test Methods
    methods(Test)
        % Test methods

        function DefaultConstructorTest(testCase)
            testCase.verifyClass(testCase.DefaultKpm, 'KineticsPickerModel');

            actualKineticsModelName = testCase.DefaultKpm.KineticsModelName;
            expectedKineticsModelName = 'Berks';
            testCase.verifyEqual(actualKineticsModelName, expectedKineticsModelName, ...
                'Default kinetics model name is incorrect');

            actualOdeSolverName = testCase.DefaultKpm.OdeSolverName;
            expectedOdeSolverName = 'ode23s';
            testCase.verifyEqual(actualOdeSolverName, expectedOdeSolverName, 'Default ODE solver name is incorrect');

            actualOptimizerName = testCase.DefaultKpm.OptimizerName;
            expectedOptimizerName = 'Multi-Start';
            testCase.verifyEqual(actualOptimizerName, expectedOptimizerName, 'Default optimizer name is incorrect');

            actualInitialEstimate = testCase.DefaultKpm.InitialEstimate;
            expectedInitialEstimate = [0.01 0.01 0.01 0.01 0.2 10.0];
            testCase.verifyEqual(actualInitialEstimate, expectedInitialEstimate, ...
                'Default initial estimate is incorrect');

            actualMaxIterations = testCase.DefaultKpm.MaxIterations;
            expectedMaxIterations = 3000;
            testCase.verifyEqual(actualMaxIterations, expectedMaxIterations, ...
                'Default maximum iterations limit is incorrect');

            actualMaxTime = testCase.DefaultKpm.MaxTime;
            expectedMaxTime = 1200;
            testCase.verifyEqual(actualMaxTime, expectedMaxTime, 'Default maximum time limit is incorrect');

            actualMeshTolerance = testCase.DefaultKpm.MeshTolerance;
            expectedMeshTolerance = 1e-7;
            testCase.verifyEqual(actualMeshTolerance, expectedMeshTolerance, 'Default mesh tolerance is incorrect');

            actualLowerBound = testCase.DefaultKpm.LowerBound;
            expectedLowerBound = [eps eps eps eps eps 0];
            testCase.verifyEqual(actualLowerBound, expectedLowerBound, 'Default lower bound is incorrect');

            actualUpperBound = testCase.DefaultKpm.UpperBound;
            expectedUpperBound = [1 1 1 1 1 50];
            testCase.verifyEqual(actualUpperBound, expectedUpperBound, 'Default upper bound is incorrect');

            actualOptimizationDisplay = testCase.DefaultKpm.OptimizationDisplay;
            expectedOptimizationDisplay = 'iter';
            testCase.verifyEqual(actualOptimizationDisplay, expectedOptimizationDisplay, ...
                'Default optimization display is incorrect');

            actualUseRegularization = testCase.DefaultKpm.UseRegularization;
            testCase.verifyFalse(actualUseRegularization, 'Default use regularization flag is incorrect');

            actualLambda = testCase.DefaultKpm.Lambda;
            expectedLambda = 0.01;
            testCase.verifyEqual(actualLambda, expectedLambda, 'Default lambda is incorrect');

            actualFitnessMeasure = testCase.DefaultKpm.FitnessMeasure;
            expectedFitnessMeasure = 'LSQ';
            testCase.verifyEqual(actualFitnessMeasure, expectedFitnessMeasure, 'Default fitness measure is incorrect');

            actualSaveScreenPosition = testCase.DefaultKpm.SavedScreenPosition;
            testCase.verifyEmpty(actualSaveScreenPosition, 'Default save screen position is incorrect');
        end

        function CopyConstructorTest(testCase)
            original = testCase.DefaultKpm;
            copy = KineticsPickerModel(original);
            testCase.verifyClass(copy, 'KineticsPickerModel', ...
                'Copy constructor failed to construct a KineticsPickerModel object');
            testCase.verifyNotSameHandle(copy, original, 'Copy constructor failed to construct a distinct object');
        end

        function GetOdeSolverTest(testCase)
            actual = testCase.DefaultKpm.OdeSolver;
            expected = @ode23s;
            testCase.verifyEqual(actual, expected, 'OdeSolver dependent property test failed');

            testCase.DefaultKpm.OdeSolverName = 'ode15s';
            actual = testCase.DefaultKpm.OdeSolver;
            expected = @ode15s;
            testCase.verifyEqual(actual, expected, ...
                'OdeSolverName update fails to update OdeSolver dependent property');

            testCase.DefaultKpm.OdeSolverName = 'none, non-ODE model';
            actual = testCase.DefaultKpm.OdeSolver;
            testCase.verifyEmpty(actual, 'OdeSolver dependent property for non-ODE model test failed');
        end

        function GetOptimizerTest(testCase)
            actual = testCase.DefaultKpm.Optimizer;
            expected = @MultiStart;
            testCase.verifyEqual(actual, expected, 'Optimizer dependent property test failed');

            testCase.DefaultKpm.OptimizerName = 'Pattern Search';
            actual = testCase.DefaultKpm.Optimizer;
            expected = @patternsearch;
            testCase.verifyEqual(actual, expected, ...
                'OptimizerName update fails to update Optimizer dependent property')
        end

        function GetOptimizerOptionsTest(testCase)
            actual = testCase.DefaultKpm.OptimizationOptions;
            expected = optimoptions(@fmincon, 'Algorithm', 'interior-point', 'Display', 'iter', ...
                'MaxIterations', 3000, 'UseParallel', true);
            testCase.verifyEqual(actual, expected, 'Default OptimizerOptions are incorrect');
        end
    end
end