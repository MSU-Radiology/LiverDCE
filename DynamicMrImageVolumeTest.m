classdef DynamicMrImageVolumeTest < matlab.unittest.TestCase
    % DynamicMrImageVolumeTest  Unit tests for the DynamicMrImageVolume class
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette

    %% Properties
    properties
        DefaultDynamicMrImageVolume
        NumericalTolerance
    end

    methods(TestClassSetup)
        % Shared setup for the entire test class
    end

    methods(TestMethodSetup)
        function CreateDefaultDynamicMrImageVolume(testCase)
            testCase.DefaultDynamicMrImageVolume = DynamicMrImageVolume();
            testCase.NumericalTolerance = 10*eps;
        end
    end

    methods(Test)
        % Test methods

        function DefaultConstructorTest(testCase)
            actualImageDataInitialized = testCase.DefaultDynamicMrImageVolume.ImageDataInitialized;
            testCase.verifyFalse(actualImageDataInitialized, 'Default ImageDataInitialized is incorrect');

            actualImageStack = testCase.DefaultDynamicMrImageVolume.ImageStack;
            expectedImageStack = zeros(256, 256, 3);
            testCase.verifyEqual(actualImageStack, expectedImageStack, 'Default ImageStack is incorrect');
        end

        function GetTimeTest(testCase)
            testCase.verifyError(@() testCase.DefaultDynamicMrImageVolume.Time(), ...
                'LiverDCE:DynamicImageVolume:ImageDataNotInitialized', ...
                'get.Time did not throw the expected error for an uninitialized DynamicMrImageVolume object');
        end

%         function ComputeSpleenSignalsTest(testCase)
%         end
% 
%         function ComputeLiverSignalsTest(testCase)
%         end

%         function GetR1FromMrSignalTest(testCase)
%             actual = testCase.DefaultDynamicMrImageVolume.GetR1FromMrSignal([ones(1,30) 100.0.*ones(1,50)], 50.0);
%         end
% 
%         function GetTotalConcentrationFromSignalTest(testCase)
%         end
% 
%         function GetIntracellularConcentrationFromMrSignalTest(testCase)
%         end
% 
%         function GetESConcentrationFromMrSignalTest(testCase)
%         end

        function GetRoiR1DataFLASHTest(testCase)
%             actual = testCase.DefaultDynamicMrImageVolume.GetR1FromFlashSignal(0.0, 23.45);
%             testCase.verifyEmpty(actual, ['GetR1FromFlashSignal computed an incorrect value for uninitialized ', ...
%                 'DynamicMrImageVolume test object']);

            actual = DynamicMrImageVolume.GetR1FromFlashSignal(0.0, 23.45, 0.5235, 0.052);
            expected = 0;
            difference = actual - expected;
            testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
                'GetR1FromFlashSignal R1_0 zero edge case computes incorrect value');

            actual = DynamicMrImageVolume.GetR1FromFlashSignal(0.01, 23.45, 0.5235, 0.052);
            expected = 0.255264356144695;
            difference = actual - expected;
            testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
                'GetR1FromFlashSignal test case 1 computes incorrect value');

            actual = DynamicMrImageVolume.GetR1FromFlashSignal(0.01, 142.4, 0.223, 0.00234);
            expected = 1.640498503860546;
            difference = actual - expected;
            testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
                'GetR1FromFlashSignal test case 2 computes incorrect value');
        end

        function GetRoiR1DataRARETest(testCase)
%             testCase.verifyError(@() testCase.DefaultDynamicMrImageVolume.GetR1FromRareSignal(0.05, 23.45), ...
%                 'MATLAB:matrix:singleSubscriptNumelMismatch', ...
%                 'GetR1FromRareSignal computed an incorrect value for uninitialized DynamicMrImageVolume test object');

            actual = DynamicMrImageVolume.GetR1FromRareSignal(0.0, 23.45, 0.5235, 0.052);
            expected = 0;
            difference = actual - expected;
            testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
                'GetR1FromRareSignal R1_0 zero edge case computes incorrect value');

            actual = DynamicMrImageVolume.GetR1FromRareSignal(0.01, 23.45, 0.5235, 0.052);
            expected = 0.247802297985580;
            difference = actual - expected;
            testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
                'GetR1FromRareSignal test case 1 computes incorrect value');

            actual = DynamicMrImageVolume.GetR1FromRareSignal(0.01, 142.4, 0.223, 0.00234);
            expected = 1.707102287232601;
            difference = actual - expected;
            testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
                'GetR1FromRareSignal test case 2 computes incorrect value');
        end
    end
end