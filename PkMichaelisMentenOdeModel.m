classdef PkMichaelisMentenOdeModel < PharmacokineticOdeModel & IMultiStartOptimizable
    % PkMichaelisMentenOdeModel     Fit the differential equation given as equation 8 subject to the constraints given 
    %                               in equation 9 of Ulloa et al 2013 NMR Biomed paper, "Assessment of gadoxetate 
    %                               DCE-MRI as a biomarker of hepatobiliary transporter inhibition."
    %
    % Copyright (C) 2025   Michigan State University
    % Author:  Matt Latourette

    properties (SetAccess = protected, GetAccess = public)
        NumberOfNarrowRangeStartPoints
        NumberOfWideRangeStartPoints
    end

    %% Public Methods
    methods
        %% Constructors
        function this = PkMichaelisMentenOdeModel(varargin)
            this@PharmacokineticOdeModel(varargin{:});
            this.NumberOfFreeParameters = 3;
            this.NumberOfNarrowRangeStartPoints = 20;
            this.NumberOfWideRangeStartPoints = 80;
        end

        %% Evaluate
        function dCidt = Evaluate(this, freeParameters, fixedParameters, t, fittedCi)
            arguments
                this (1,1) PkMichaelisMentenOdeModel
                freeParameters (1,:) double
                fixedParameters(1,1) struct
                t (1,:) double
                fittedCi (1,:) double
            end

            timevec = fixedParameters.time;
            Ces = fixedParameters.Ces;

            if (size(timevec,2)==1)
                disp('break here');
            end

            Ces = interp1(timevec, Ces, t, 'pchip');
            descaledParameters = DescaleParameter(freeParameters);
            dCidt = descaledParameters(1).*Ces - (descaledParameters(3).*fittedCi)./(descaledParameters(2)+fittedCi);

            %% Documentation of the parameter ordering
            %
            % freeParameters(1) is k1
            % freeParameters(2) is kM
            % freeParameters(3) is Vmax
        end

        %% GetFixedParameters
        function fixedParameters = GetFixedParameters(this, timeData, acqZero, Ci, Ces)
            fixedParameters = GetFixedParameters@PharmacokineticModel(this, timeData, acqZero);
            fixedParameters.Ci = Ci;
            fixedParameters.Ces = Ces;
        end

        %% GenerateStartingEstimatesForMultiStartOptimizer
        function startPoints = GenerateStartingEstimatesForMultiStartOptimizer(this)
            numberOfNarrowRangeStartPoints = this.NumberOfNarrowRangeStartPoints;
            numberOfWideRangeStartPoints = this.NumberOfWideRangeStartPoints;
            % We don't really known the normal range for Ulloa model parameters, so this is just my current best guess

            % Use a more dense set of starting points in the expected normal range for k1, kM, Vmax
            % Narrow Range Points span the expected values for normal k1, kM, and Vmax
            narrowRangek1Points = RandomPointsInInterval(0.001, 0.05, numberOfNarrowRangeStartPoints);
            narrowRangekMPoints = RandomPointsInInterval(0.1, 80.0, numberOfNarrowRangeStartPoints);
            narrowRangeVmaxPoints = RandomPointsInInterval(0.001, 0.05, numberOfNarrowRangeStartPoints);
            narrowRangePoints = [narrowRangek1Points, narrowRangekMPoints, narrowRangeVmaxPoints];
            % Wide Range Points span several orders of magnitude to catch abnormal cases
            wideRangePoints = RandomPointsSpanningOrdersOfMagnitude(-5, 3, numberOfWideRangeStartPoints, ...
                this.NumberOfFreeParameters);
            startPoints = [narrowRangePoints; wideRangePoints];
        end
    end
end