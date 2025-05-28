classdef MainModelTest < matlab.unittest.TestCase
    % MainModelTest     Unit tests for the MainModel class
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette

    %% Properties
    properties
        DefaultMainModel
        NumericalTolerance
    end

    %% Test Class Setup Methods
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end

    %% Test Method Setup Methods
    methods(TestMethodSetup)
        function CreateDefaultMainModel(testCase)
            testCase.DefaultMainModel = MainModel();
            testCase.NumericalTolerance = 10*eps;
        end
    end

    %% Test Methods
    methods(Test)
        % Test methods

        function DefaultConstructorTest(testCase)
            testCase.verifyClass(testCase.DefaultMainModel, 'MainModel');

            actualLoadImageDataOptionsInitialized = testCase.DefaultMainModel.LoadImageDataOptionsInitialized;
            testCase.verifyFalse(actualLoadImageDataOptionsInitialized, ...
                'Default LoadImageDataOptionsInitialized is incorrect');

            actualKineticsModelOptionsInitialized = testCase.DefaultMainModel.KineticsModelOptionsInitialized;
            testCase.verifyFalse(actualKineticsModelOptionsInitialized, ...
                'Default KineticsModelOptionsInitialized is incorrect');

            actualActivePharmacokineticModelInitialized = ...
                testCase.DefaultMainModel.ActivePharmacokineticModelInitialized;
            testCase.verifyFalse(actualActivePharmacokineticModelInitialized, ...
                'Default ActivePharmacokineticModelInitialized');

%             actualImageDataInitialized = testCase.DefaultMainModel.ImageDataInitialized;
%             testCase.verifyFalse(actualImageDataInitialized, 'Default ImageDataInitialized is incorrect');

            actualSelectedImageTypeToDisplay = testCase.DefaultMainModel.SelectedImageTypeToDisplay;
            expectedSelectedImageTypeToDisplay = ImageType.DynamicContrastEnhanced;
            testCase.verifyEqual(actualSelectedImageTypeToDisplay, expectedSelectedImageTypeToDisplay, ...
                'Default SelectedImageTypeToDisplay is incorrect');

            actualUseBaselineAveraging = testCase.DefaultMainModel.UseBaselineAveraging;
            testCase.verifyTrue(actualUseBaselineAveraging, 'Default UseBaselineAveraging is incorrect');

            actualAcquisitionZero = testCase.DefaultMainModel.AcquisitionZero;
            testCase.verifyEqual(actualAcquisitionZero, uint16(1), 'Default AcquisitionZero is incorrect');

            actualLiverVolumeFractionES = testCase.DefaultMainModel.LiverVolumeFractionES;
            expectedLiverVolumeFractionES = 0.23;
            testCase.verifyEqual(actualLiverVolumeFractionES, expectedLiverVolumeFractionES, ...
                'Default LiverVolumeFractionES is incorrect');

            actualSpleenVolumeFractionES = testCase.DefaultMainModel.SpleenVolumeFractionES;
            expectedSpleenVolumeFractionES = 0.43;
            testCase.verifyEqual(actualSpleenVolumeFractionES, expectedSpleenVolumeFractionES, ...
                'Default SpleenVolumeFractionES is incorrect');

            actualKidneyVolumeFractionES = testCase.DefaultMainModel.KidneyVolumeFractionES;
            expectedKidneyVolumeFractionES = 0.5;
            testCase.verifyEqual(actualKidneyVolumeFractionES, expectedKidneyVolumeFractionES, ...
                'Default KidneyVolumeFractionES is incorrect');

            actualUseMedianFilter = testCase.DefaultMainModel.UseMedianFilter;
            testCase.verifyFalse(actualUseMedianFilter, 'Default UseMedianFilter is incorrect');

            actualFilterWindowStartSize = testCase.DefaultMainModel.FilterWindowStartSize;
            expectedFilterWindowStartSize = uint16(3);
            testCase.verifyEqual(actualFilterWindowStartSize, expectedFilterWindowStartSize, ...
                'Default FilterWindowStartSize is incorrect');

            actualFilterWindowEndSize = testCase.DefaultMainModel.FilterWindowEndSize;
            expectedFilterWindowEndSize = uint16(7);
            testCase.verifyEqual(actualFilterWindowEndSize, expectedFilterWindowEndSize, ...
                'Default FilterWindowEndSize is incorrect');

            actualTransitionStartIndex = testCase.DefaultMainModel.TransitionStartIndex;
            expectedTransitionStartIndex = double(10);
            testCase.verifyEqual(actualTransitionStartIndex, expectedTransitionStartIndex, ...
                'Default TransitionStartIndex is incorrect');

            actualTransitionEndIndex = testCase.DefaultMainModel.TransitionEndIndex;
            expectedTransitionEndIndex = double(50);
            testCase.verifyEqual(actualTransitionEndIndex, expectedTransitionEndIndex, ...
                'Default TransitionEndIndex is incorrect');

            actualHematocrit = testCase.DefaultMainModel.Hematocrit;
            expectedHematocrit = 0.45;
            testCase.verifyEqual(actualHematocrit, expectedHematocrit, 'Default Hematocrit is incorrect');

            actualSelectedSliceLocation = testCase.DefaultMainModel.SelectedSliceLocation;
            expectedSelectedSliceLocation = uint16(1);
            testCase.verifyEqual(actualSelectedSliceLocation, expectedSelectedSliceLocation, ...
                'Default SelectedSliceLocation is incorrect');

            actualPreContrastLiverT1 = testCase.DefaultMainModel.PreContrastLiverT1;
            expectedPreContrastLiverT1 = 1360.77;
            testCase.verifyEqual(actualPreContrastLiverT1, expectedPreContrastLiverT1, ...
                'Default PreContrastLiverT1 is incorrect');

            actualPreContrastSpleenT1 = testCase.DefaultMainModel.PreContrastSpleenT1;
            expectedPreContrastSpleenT1 = 1783.64;
            testCase.verifyEqual(actualPreContrastSpleenT1, expectedPreContrastSpleenT1, ...
                'Default PreContrastSpleenT1 is incorrect');

            actualPreContrastKidneyT1 = testCase.DefaultMainModel.PreContrastKidneyT1;
            expectedPreContrastKidneyT1 = 1778.28;
            testCase.verifyEqual(actualPreContrastKidneyT1, expectedPreContrastKidneyT1, ...
                'Default PreContrastKidneyT1 is incorrect');

            actualPreContrastArterialBloodT1 = testCase.DefaultMainModel.PreContrastArterialBloodT1;
            expectedPreContrastArterialBloodT1 = 2300;
            testCase.verifyEqual(actualPreContrastArterialBloodT1, expectedPreContrastArterialBloodT1, ...
                'Default PreContrastArterialBloodT1 is incorrect');

            actualPreContrastVenousBloodT1 = testCase.DefaultMainModel.PreContrastVenousBloodT1;
            expectedPreContrastVenousBloodT1 = 2300;
            testCase.verifyEqual(actualPreContrastVenousBloodT1, expectedPreContrastVenousBloodT1, ...
                'Default PreContrastVenousBloodT1 is incorrect');

%             actualImageStack = testCase.DefaultMainModel.ImageStack;
%             expectedImageStack = zeros(256, 256, 3);
%             testCase.verifyEqual(actualImageStack, expectedImageStack, 'Default ImageStack is incorrect');

            actualRoiStatsVisibility = testCase.DefaultMainModel.RoiStatsVisibility;
            testCase.verifyFalse(actualRoiStatsVisibility, 'Default RoiStatsVisibility is incorrect');

            actualLoadImageDataOptions = testCase.DefaultMainModel.LoadImageDataOptions;
            testCase.verifyEmpty(actualLoadImageDataOptions, 'Default LoadImageDataOptions is incorrect');

            actualKineticsModelOptions = testCase.DefaultMainModel.KineticsModelOptions;
            testCase.verifyEmpty(actualKineticsModelOptions, 'Default KineticsModelOptions is incorrect');
        end

        function GetPreContrastLiverR1Test(testCase)
            actual = testCase.DefaultMainModel.PreContrastLiverR1;
            expected = 1000.0./testCase.DefaultMainModel.PreContrastLiverT1;
            testCase.verifyEqual(actual, expected, 'PreContrastLiverR1 is incorrect');
        end

        function GetPreContrastSpleenR1Test(testCase)
            actual = testCase.DefaultMainModel.PreContrastSpleenR1;
            expected = 1000.0./testCase.DefaultMainModel.PreContrastSpleenT1;
            testCase.verifyEqual(actual, expected, 'PreContrastSpleenR1 is incorrect');
        end

        function GetPreContrastArterialBloodR1Test(testCase)
            actual = testCase.DefaultMainModel.PreContrastArterialBloodR1;
            expected = 1000.0./testCase.DefaultMainModel.PreContrastArterialBloodT1;
            testCase.verifyEqual(actual, expected, 'PreContrastArterialBloodR1 is incorrect');
        end

        function GetPreContrastVenousBloodR1Test(testCase)
            actual = testCase.DefaultMainModel.PreContrastVenousBloodR1;
            expected = 1000.0./testCase.DefaultMainModel.PreContrastVenousBloodT1;
            testCase.verifyEqual(actual, expected, 'PreContrastVenousBloodR1 is incorrect');
        end

%         function GetTimeTest(testCase)
%             testCase.verifyError(testCase.DefaultMainModel, @() get.Time(), ...
%                 'LiverDCE:MainModel:LoadImageDataOptionsNotInitialized')
%         end

%         % Can't test these yet because the ROI needs to be decoupled from the imtool3D package first (separate the ROI
%         % mask from the ROI data structure)
%         function GetRoiSignalDataTest(testCase)
%         end
%         
%         function GetRoiR1DataTest(testCase)
%         end
%
%         function GetRoiESConcentrationDataTest(testCase)
%         end
%
%         function GetRoiIntracellularConcentrationDataTest(testCase)
%         end
%
%         function GetRoiTotalConcentrationDataTest(testCase)
%         end
%
%         function GetRoiAucTimeSeriesTest(testCase)
%         end
%
%         function GetRoiAucTotalTest(testCase)
%         end
%
%         function GetRoiModelAucTotalTest(testCase)
%         end
%
%         function GetVolumeFractionESTest(testCase)
%         end
%
%         function GetModelVolumeFractionESTest(testCase)
%         end
%
%         function ComputeExtracellularVolumeFractionsTest(testCase)
%         end

%         % Can't test this yet because it's tightly coupled with the PharmacokineticModel classes
%         function GetKineticsParametersTest(testCase)
%         end

        function GetPreContrastR1ForTissueTest(testCase)
            actual = testCase.DefaultMainModel.GetPreContrastR1(TissueType.Liver);
            expected = testCase.DefaultMainModel.PreContrastLiverR1;
            testCase.verifyEqual(actual, expected, ...
                'GetPreContrastR1 method returns incorrect value for liver');

            actual = testCase.DefaultMainModel.GetPreContrastR1(TissueType.Spleen);
            expected = testCase.DefaultMainModel.PreContrastSpleenR1;
            testCase.verifyEqual(actual, expected, ...
                'GetPreContrastR1 method returns incorrect value for spleen');

            actual = testCase.DefaultMainModel.GetPreContrastR1(TissueType.Kidney);
            expected = testCase.DefaultMainModel.PreContrastKidneyR1;
            testCase.verifyEqual(actual, expected, ...
                'GetPreContrastR1 method returns incorrect value for kidney');

            actual = testCase.DefaultMainModel.GetPreContrastR1(TissueType.ArterialBlood);
            expected = testCase.DefaultMainModel.PreContrastArterialBloodR1;
            testCase.verifyEqual(actual, expected, ...
                'GetPreContrastR1 method returns incorrect value for arterial blood');

            actual = testCase.DefaultMainModel.GetPreContrastR1(TissueType.VenousBlood);
            expected = testCase.DefaultMainModel.PreContrastVenousBloodR1;
            testCase.verifyEqual(actual, expected, ...
                'GetPreContrastR1 method returns incorrect value for venous blood');
        end

        function GetVolumeFractionESBloodPoolAgentTest(testCase)
            actual = testCase.DefaultMainModel.GetVolumeFractionESBloodPoolAgent(TissueType.Liver);
            expected = testCase.DefaultMainModel.LiverVolumeFractionES;
            testCase.verifyEqual(actual, expected, ...
                'GetVolumeFractionESBloodPoolAgent returns incorrect value for liver');

            actual = testCase.DefaultMainModel.GetVolumeFractionESBloodPoolAgent(TissueType.Spleen);
            expected = testCase.DefaultMainModel.SpleenVolumeFractionES;
            testCase.verifyEqual(actual, expected, ...
                'GetVolumeFractionESBloodPoolAgent returns incorrect value for spleen')

            actual = testCase.DefaultMainModel.GetVolumeFractionESBloodPoolAgent(TissueType.Kidney);
            expected = testCase.DefaultMainModel.KidneyVolumeFractionES;
            testCase.verifyEqual(actual, expected, ...
                'GetVolumeFractionESBloodPoolAgent returns incorrect value for kidney')

            actual = testCase.DefaultMainModel.GetVolumeFractionESBloodPoolAgent(TissueType.ArterialBlood);
            expected = 1 - testCase.DefaultMainModel.Hematocrit;
            testCase.verifyEqual(actual, expected, ...
                'GetVolumeFractionESBloodPoolAgent returns incorrect value for arterial blood')

            actual = testCase.DefaultMainModel.GetVolumeFractionESBloodPoolAgent(TissueType.VenousBlood);
            expected = 1 - testCase.DefaultMainModel.Hematocrit;
            testCase.verifyEqual(actual, expected, ...
                'GetVolumeFractionESBloodPoolAgent returns incorrect value for venous blood')
        end

        function GetVolumeFractionESHepatobiliaryContrastAgentTest(testCase)
            actual = testCase.DefaultMainModel.GetVolumeFractionESHepatobiliaryAgent(TissueType.Spleen);
            expected = testCase.DefaultMainModel.SpleenVolumeFractionES;
            testCase.verifyEqual(actual, expected, ...
                'GetVolumeFractionESHepatobiliaryContrastAgent returns incorrect value for spleen')

            actual = testCase.DefaultMainModel.GetVolumeFractionESHepatobiliaryAgent(TissueType.Kidney);
            expected = testCase.DefaultMainModel.KidneyVolumeFractionES;
            testCase.verifyEqual(actual, expected, ...
                'GetVolumeFractionESHepatobiliaryContrastAgent returns incorrect value for kidney')

            actual = testCase.DefaultMainModel.GetVolumeFractionESHepatobiliaryAgent(TissueType.ArterialBlood);
            expected = 1 - testCase.DefaultMainModel.Hematocrit;
            testCase.verifyEqual(actual, expected, ...
                'GetVolumeFractionESHepatobiliaryContrastAgent returns incorrect value for arterial blood')

            actual = testCase.DefaultMainModel.GetVolumeFractionESHepatobiliaryAgent(TissueType.VenousBlood);
            expected = 1 - testCase.DefaultMainModel.Hematocrit;
            testCase.verifyEqual(actual, expected, ...
                'GetVolumeFractionESHepatobiliaryContrastAgent returns incorrect value for venous blood')
        end

%         % TODO: Move these tests to a unit test for the newly-created DynamicMrImageVolume class, where this
%         % functionality is now housed
%         function GetRoiR1DataFLASHTest(testCase)
%             actual = MainModel.GetR1FromFlashSignal(0.0, 23.45, 0.5235, 0.052);
%             expected = 0;
%             difference = actual - expected;
%             testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
%                 'GetR1FromFlashSignal R1_0 zero edge case computes incorrect value');
% 
%             actual = MainModel.GetR1FromFlashSignal(0.01, 23.45, 0.5235, 0.052);
%             expected = 0.255264356144695;
%             difference = actual - expected;
%             testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
%                 'GetR1FromFlashSignal test case 1 computes incorrect value');
% 
%             actual = MainModel.GetR1FromFlashSignal(0.01, 142.4, 0.223, 0.00234);
%             expected = 1.640498503860546;
%             difference = actual - expected;
%             testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
%                 'GetR1FromFlashSignal test case 2 computes incorrect value');
%         end
% 
%         function GetRoiR1DataRARETest(testCase)
%             actual = MainModel.GetR1FromRareSignal(0.0, 23.45, 0.5235, 0.052);
%             expected = 0;
%             difference = actual - expected;
%             testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
%                 'GetR1FromRareSignal R1_0 zero edge case computes incorrect value');
% 
%             actual = MainModel.GetR1FromRareSignal(0.01, 23.45, 0.5235, 0.052);
%             expected = 0.229853210798788;
%             difference = actual - expected;
%             testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
%                 'GetR1FromRareSignal test case 1 computes incorrect value');
% 
%             actual = MainModel.GetR1FromRareSignal(0.01, 142.4, 0.223, 0.00234);
%             expected = 1.325211438568278;
%             difference = actual - expected;
%             testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
%                 'GetR1FromRareSignal test case 2 computes incorrect value');
%         end

%         function computeRoiESConcentrationDataTest(testCase)
%             actual = MainModel.ComputeESConcentration(12.3, 1.2, 6.4, 0.25);
%             expected = 6.937500000000001;
%             difference = actual - expected;
%             testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
%                 'ComputeESConcentration test case 1 computes incorrect value');
% 
%             actual = MainModel.ComputeESConcentration(43.2, 43.2, 7.2, 0.0023);
%             expected = 0;
%             difference = actual - expected;
%             testCase.verifyLessThan(difference, testCase.NumericalTolerance, ...
%                 'ComputeESConcentration no R1 change test fails');
%         end
    end
end