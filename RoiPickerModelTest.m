classdef RoiPickerModelTest < matlab.unittest.TestCase
    % RoiPickerModelTest    Unit tests for the RoiPickerModel class
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    %% Properties
    properties
        DefaultRpm
    end

    %% Test Class Setup Methods
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end

    %% Test Method Setup Methods
    methods(TestMethodSetup)
        function CreateDefaultRoiPickerModel(testCase)
            roiColors = [[255; 0; 0], [0; 255; 0], [0; 0; 255], ...
                [0; 255; 255], [255; 192; 203], [222; 184; 135], ...
                [255; 140; 0], [188; 143; 143], [255; 20; 147], ...
                [139; 0; 0], [0; 100; 0], [30; 144; 255], ...
                [0; 0; 139], [128; 0; 128]];
            testCase.DefaultRpm = RoiPickerModel(roiColors);
        end
    end

    %% Test Method Teardown Methods
    methods(TestMethodTeardown)
    end

    %% Test Methods
    methods(Test)
        % Test methods

        function DefaultConstructorTest(testCase)
            testCase.verifyClass(testCase.DefaultRpm, 'RoiPickerModel');

            actualRoiSelection = testCase.DefaultRpm.RoiSelection;
            expectedRoiSelection = 1;
            testCase.verifyEqual(actualRoiSelection, expectedRoiSelection, ...
                'Default ROI selection is incorrect');

            actualCancelled = testCase.DefaultRpm.Cancelled;
            testCase.verifyTrue(actualCancelled, 'Default Cancelled property is incorrect');

            actualRoiColors = testCase.DefaultRpm.RoiColors;
            expectedRoiColors = [[255; 0; 0], [0; 255; 0], [0; 0; 255], ...
                [0; 255; 255], [255; 192; 203], [222; 184; 135], ...
                [255; 140; 0], [188; 143; 143], [255; 20; 147], ...
                [139; 0; 0], [0; 100; 0], [30; 144; 255], ...
                [0; 0; 139], [128; 0; 128]];
            testCase.verifyEqual(actualRoiColors, expectedRoiColors, 'Default ROI colors are incorrect');
        end
    end
end