classdef ValidationFunctionsTest < matlab.unittest.TestCase
    % ValidationFunctionsTest class     Units tests for input validation utility functions
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette

    methods(TestClassSetup)
        % Shared setup for the entire test class
    end

    methods(TestMethodSetup)
        % Setup for each test
    end

    methods(Test)
        % Test methods
        function IsBetweenZeroAndOneTest(testCase)
            actual = IsBetweenZeroAndOne(-1.2);
            testCase.verifyFalse(actual, 'IsBetweenZeroAndOne negative value test fails');

            actual = IsBetweenZeroAndOne(1.00001);
            testCase.verifyFalse(actual, 'IsBetweenZeroAndOne positive value out of range test fails');

            actual = IsBetweenZeroAndOne(0.000001);
            testCase.verifyTrue(actual, 'IsBetweenZeroAndOne small nonzero value in range test fails');

            actual = IsBetweenZeroAndOne(0.999999999);
            testCase.verifyTrue(actual, 'IsBetweenZeroAndOne a little less than one value in range test fails');

            actual = IsBetweenZeroAndOne(0.0);
            testCase.verifyTrue(actual, 'IsBetweenZeroAndOne zero-inclusive edge case test fails');

            actual = IsBetweenZeroAndOne(1.0);
            testCase.verifyTrue(actual, 'IsBetweenZeroAndOne one-inclusive edge case test fails');
        end

        function IsNonNegativeTest(testCase)
            actual = IsNonNegative(-10.234);
            testCase.verifyFalse(actual, 'IsNonNegative negative value test fails');

            actual = IsNonNegative(0.0);
            testCase.verifyTrue(actual, 'IsNonNegative zero-inclusive edge case test fails');

            actual = IsNonNegative(100.1234890);
            testCase.verifyTrue(actual, 'IsNonNegative positive value test fails');
        end

        function ConstrainValueToRangeTest(testCase)
            actual = ConstrainValueToRange(0, 1, 10);
            expected = 1;
            testCase.verifyEqual(actual, expected, 'ConstrainValueToRange returns incorrect value for test case 1');

            actual = ConstrainValueToRange(-9, 1, 10);
            expected = 1;
            testCase.verifyEqual(actual, expected, 'ConstrainValueToRange returns incorrect value for test case 2');

            actual = ConstrainValueToRange(11, 1, 10);
            expected = 10;
            testCase.verifyEqual(actual, expected, 'ConstrainValueToRange returns incorrect value for test case 3');

            actual = ConstrainValueToRange(1, 1, 10);
            expected = 1;
            testCase.verifyEqual(actual, expected, 'ConstrainValueToRange returns incorrect value for test case 4');

            actual = ConstrainValueToRange(10, 1, 10);
            expected = 10;
            testCase.verifyEqual(actual, expected, 'ConstrainValueToRange returns incorrect value for test case 5');

            actual = ConstrainValueToRange(5.2, 1, 10);
            expected = 5.2;
            testCase.verifyEqual(actual, expected, 'ConstrainValueToRange returns incorrect value for test case 6');
        end

		function IsWithinToleranceOfValue(testCase)
            actual = IsWithinToleranceOfValue(-123.3242, -123.3241999999, 0.00001);
            testCase.verifyTrue(actual, 'IsWithinToleranceOfValue negative values in tolerance test fails');

            actual = IsWithinToleranceOfValue(-123.3242, -123.3241999999, 0.0000000000001);
            testCase.verifyFalse(actual, 'IsWithinToleranceOfValue negative values out of tolerance test fails');

            actual = IsWithinToleranceOfValue(-0.0001, 0.01, 0.1);
            testCase.verifyTrue(actual, 'IsWithinToleranceOfValue values spanning zero in tolerance test fails');

            actual = IsWithinToleranceOfValue(-0.0001, 0.01, 0.0001);
            testCase.verifyFalse(actual, 'IsWithinToleranceOfValue values spanning zero out of tolerance test fails');

            actual = IsWithinToleranceOfValue(978.23, 970.9, 10.0);
            testCase.verifyTrue(actual, 'IsWithinToleranceOfValue positive values in tolerance test fails');

            actual = IsWithinToleranceOfValue(978.23, 970.9, 1.0);
            testCase.verifyFalse(actual, 'IsWithinToleranceOfValue positive values out of tolerance test fails');
        end
    end

end