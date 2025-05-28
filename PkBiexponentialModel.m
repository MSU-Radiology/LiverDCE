classdef PkBiexponentialModel < PharmacokineticAlgebraicModel & IMultiStartOptimizable
    % PkBiexponentialModel      This is a WIP empirical model that has not been validated.
    %
    % Copyright (C) 2025   Michigan State University
    % Author:   Matt Latourette

    properties (SetAccess = protected, GetAccess = public)
        NumberOfNarrowRangeStartPoints
        NumberOfWideRangeStartPoints
    end

    %% Public Methods
    methods
        %% Constructors
        function this = PkBiexponentialModel(varargin)
            this@PharmacokineticAlgebraicModel(varargin{:});
            this.NumberOfFreeParameters = 7;
            this.NumberOfNarrowRangeStartPoints = 20;
            this.NumberOfWideRangeStartPoints = 80;
        end

        %% Evaluate
        function F = Evaluate(this, freeParameters, fixedParameters, t)
            arguments
                this (1,1) PkBiexponentialModel
                freeParameters (1,:) double
                fixedParameters (1,1) struct
                t (1,:) double
            end

            % This code is untested
            timevec = fixedParameters.time;
            Ces = fixedParameters.Ces;
            Chep = fixedParameters.Chep;

            k1 = freeParameters(1);
            kM = freeParameters(2);
            Vmax = freeParameters(3);
            a = freeParameters(4);
            b = freeParameters(5);
            c = freeParameters(6);
            d = freeParameters(7);
            f1 = a.*exp(b.*t)+c.*exp(d.*t);
            f2 = (a.*b.*exp(b.*t)+c.*d.*exp(d.*t)+Vmax.* ...
                (a.*exp(b.*t)+c.*exp(d.*t))./(kM+a.*exp(b.*t)+c.*exp(d.*t)))./k1;
            F = [f1; f2];

            %% Documentation of the parameter ordering
            %
            % freeParameters(1) is a
            % freeParameters(2) is b
            % freeParameters(3) is c
            % freeParameters(4) is d
            % freeParameters(5) is k1  (influx)
            % freeParameters(6) is kM
            % freeParameters(7) is Vmax
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
            % Use a more dense set of starting points in the expected normal range
            % Narrow Range Points span the expected values for normal subjects
            narrowRangeAThroughDPoints = power(10, 3.5*RandomPointsInInterval(-1.0, 1.0, ...
                numberOfNarrowRangeStartPoints, 4)-1);
            narrowRangek1Points = RandomPointsInInterval(0.001, 0.05, numberOfNarrowRangeStartPoints);
            narrowRangekMPoints = RandomPointsInInterval(0.1, 80.0, numberOfNarrowRangeStartPoints);
            narrowRangeVmaxPoints = RandomPointsInInterval(0.001, 0.05, numberOfNarrowRangeStartPoints);
            narrowRangePoints = [narrowRangeAThroughDPoints, narrowRangek1Points, narrowRangekMPoints, ...
                narrowRangeVmaxPoints];
            % Wide Range Points span several orders of magnitude to catch abnormal cases
            wideRangePoints = RandomPointsSpanningOrdersOfMagnitude(-5, 3, numberOfWideRangeStartPoints, ...
                this.NumberOfFreeParameters);
            startPoints = [narrowRangePoints; wideRangePoints];
        end
    end
end