classdef LoadImagesDialogModelTest < matlab.unittest.TestCase
    % LoadImagesDialogModelTest     Unit tests for LoadImagesDialogModel
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette

    %% Properties
    properties
        DefaultLidm
        NumericalTolerance
    end

    %% Test Class Setup Methods
    methods(TestClassSetup)
        % Shared setup for the entire test class
    end

    %% Test Method Setup Methods
    methods(TestMethodSetup)
        function CreateDefaultLoadImagesDialogModel(testCase)
            testCase.DefaultLidm = LoadImagesDialogModel();
            testCase.NumericalTolerance = 10*eps;
        end
    end

    %% Test Methods
    methods(Test)
        % Test methods

        function DefaultConstructorTest(testCase)
            testCase.verifyClass(testCase.DefaultLidm, 'LoadImagesDialogModel');
        end

        function CopyConstructorTest(testCase)
            copy = LoadImagesDialogModel(testCase.DefaultLidm);
            testCase.verifyClass(copy, 'LoadImagesDialogModel');
        end

        function GetContrastAgentNameTest(testCase)
            actual = testCase.DefaultLidm.ContrastAgentName;
            expected = 'Gd-EOB-DTPA';
            testCase.verifyEqual(actual, expected, 'Default ContrastAgentName is incorrect');
        end

        function GetB0FieldStrengthTest(testCase)
            actual = testCase.DefaultLidm.B0FieldStrength;
            expected = 1.5;
            testCase.verifyEqual(actual, expected, 'Default B0FieldStrength is incorrect');
        end

        function GetSpeciesTest(testCase)
            actual = testCase.DefaultLidm.Species;
            expected = 'Human';
            testCase.verifyEqual(actual, expected, 'Default Species is incorrect');
        end

        function GetPulseSequenceTest(testCase)
            actual = testCase.DefaultLidm.PulseSequence;
            expected = 'FLASH';
            testCase.verifyEqual(actual, expected, 'Default PulseSequence is incorrect');
        end

        function GetIsReadyToLoadImagesTest(testCase)
            actual = testCase.DefaultLidm.IsReadyToLoadImages;
            testCase.verifyFalse(actual, 'Default IsReadyToLoadImages is incorrect');
        end

        function GetIsHepatobiliaryContrastAgentTest(testCase)
            actual = testCase.DefaultLidm.IsHepatobiliaryContrastAgent;
            testCase.verifyTrue(actual, 'Default IsHepatobiliaryContrastAgent');
        end

        function UpdateFileFormatStringTest(testCase)
            testCase.DefaultLidm.FilenamePrefix = 'test';
            testCase.DefaultLidm.UseLeadingZeros = true;
            testCase.DefaultLidm.DigitPlaces = 5;
            testCase.DefaultLidm.FilenameExtension = '.extension';

            testCase.DefaultLidm.UpdateFilenameFormatString();
            actual = testCase.DefaultLidm.FilenameFormatString;
            expected = 'test%05d.extension';
            testCase.verifyEqual(actual, expected, 'UpdateFileFormatString is incorrect');
        end

%         function UpdateDefaultRelaxivityValuesTest(testCase)
%             numAgents = length(testCase.DefaultLidm.AgentList);
%             numFieldStrengths = length(testCase.DefaultLidm.FieldStrengthList);
%             numSpecies = length(testCase.DefaultLidm.SpeciesList);
% 
% %             testCase.DefaultLidm.SelectedAgent
% %             AgentList
% %             OtherContrastAgent
% %             SelectedFieldStrength
% %             FieldStrengthList
% %             OtherFieldStrength
% %             SelectedSpecies
% %             SpeciesList
% % 
% %             testCase.DefaultLidm.SelectedAgent = 1;
% 
%             testCase.verifyFail('unimplemented test');
%         end
% 
%         function ImagesToLoadChangedTest(testCase)
%             testCase.verifyFail('unimplemented test');
%         end
% 
%         function NumberOfSlicesChangedTest(testCase)
%             testCase.verifyFail('unimplemented test');
%         end
    end
end