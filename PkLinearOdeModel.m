classdef PkLinearOdeModel < PharmacokineticOdeModel & IMultiStartOptimizable
    % PkLinearOdeModel      Fit a differential equation model with linear kinetics instead of the Michaelis-Menten 
    %                       kinetics that were in the original model described in the Ulloa et al paper.
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
        function this = PkLinearOdeModel(varargin)
            this@PharmacokineticOdeModel(varargin{:});
            this.NumberOfFreeParameters = 2;
            this.NumberOfNarrowRangeStartPoints = 20;
            this.NumberOfWideRangeStartPoints = 80;
        end

        %% Evaluate
        function dCidt = Evaluate(this, freeParameters, fixedParameters, t, fittedCi)
            arguments
                this (1,1) PkLinearOdeModel
                freeParameters (1,:) double
                fixedParameters(1,1) struct
                t (1,:) double
                fittedCi (1,:) double
            end

            timevec = fixedParameters.time;
            Ces = fixedParameters.Ces;
            vhLiver = 1-fixedParameters.veLiver;  % 0.77 = 1.0 - 0.23

            if (size(timevec,2)==1)
                disp('break here');
            end
%             disp(['timevec size: ', num2str(size(timevec)), '   Ces size: ', num2str(size(Ces)), ...
%                 '   t:', num2str(t)]);
            Ces = interp1(timevec, Ces, t, 'pchip');
            descaledParameters = DescaleParameter(freeParameters);
            dCidt = (descaledParameters(1).*Ces - descaledParameters(2).*fittedCi)./vhLiver;

            %% Documentation of the parameter ordering
            %
            % freeParameters(1) is k1  (influx)
            % freeParameters(2) is k2  (efflux)
        end

        %% GetFixedParameters
        function fixedParameters = GetFixedParameters(this, timeData, acqZero, Ci, Ces, veLiver)
            fixedParameters = GetFixedParameters@PharmacokineticModel(this, timeData, acqZero);
            fixedParameters.Ci = Ci;
            fixedParameters.Ces = Ces;
            fixedParameters.veLiver = veLiver;
        end

        %% GenerateStartingEstimatesForMultiStartOptimizer
        function startPoints = GenerateStartingEstimatesForMultiStartOptimizer(this)
            numberOfNarrowRangeStartPoints = this.NumberOfNarrowRangeStartPoints;
            numberOfWideRangeStartPoints = this.NumberOfWideRangeStartPoints;
            % Use a more dense set of starting points in the expected normal range for k1 and k2
            % Narrow Range Points span the expected values for normal k1 and k2
            narrowRangek1Points = RandomPointsInInterval(0.001, 0.05, numberOfNarrowRangeStartPoints);
            narrowRangek2Points = RandomPointsInInterval(0.00001, 0.002, numberOfNarrowRangeStartPoints);
            narrowRangePoints = [narrowRangek1Points, narrowRangek2Points];
            % Wide Range Points span several orders of magnitude to catch abnormal cases
            wideRangePoints = RandomPointsSpanningOrdersOfMagnitude(-10, 0, numberOfWideRangeStartPoints, ...
                this.NumberOfFreeParameters);
            startPoints = [narrowRangePoints; wideRangePoints];
        end
    end
end