% runLiverDCEtests		Runs the complete suite of unit tests
%
% Copyright (C) 2025   Michigan State University
% Author:  Matt Latourette

import matlab.unittest.TestSuite;

% Suppress the warning that I get for the ThresholdExistingRegion.m file even though it is not a unit test
warning('off', 'MATLAB:unittest:TestSuite:FileExcluded');
mainSuite = TestSuite.fromFolder('.');
validationSuite = TestSuite.fromFolder('.\validation');
imtool3DSuite = TestSuite.fromFolder('..\utils\imtool3D');
combinedSuite = [mainSuite, validationSuite, imtool3DSuite];
result = run(combinedSuite);