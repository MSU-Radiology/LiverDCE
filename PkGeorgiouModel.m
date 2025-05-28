classdef PkGeorgiouModel < PharmacokineticAlgebraicModel & IMultiStartOptimizable
    % PkGeorgiouModel   This is an implementation of the model from the Georgiou et al 2017 Invest Radiol paper,
    %                   "Quantitative Assessment of Liver Function Using Gadoxetate-Enhanced Magnetic Resonance 
    %                   Imaging: Monitoring Transporter-Mediated Processes in Healthy Volunteers."
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
        function this = PkGeorgiouModel(varargin)
            this@PharmacokineticAlgebraicModel(varargin{:});
            this.NumberOfFreeParameters = 5;
            this.NumberOfNarrowRangeStartPoints = 500;
            this.NumberOfWideRangeStartPoints = 500;
        end

        %% Evaluate
        function Ct = Evaluate(this, freeParameters, fixedParameters)
            arguments
                this (1,1) PkGeorgiouModel
                freeParameters (1,:) double
                fixedParameters(1,1) struct
            end

            timevec = fixedParameters.time;
            timestep = timevec(2)-timevec(1);
            descaledParameters = DescaleParameter(freeParameters);

            ki = descaledParameters(1);
            kef = descaledParameters(2);
            Fp = descaledParameters(3);
            vecs = descaledParameters(4);
            fa = descaledParameters(5);
            fv = 1-fa;
            vi = 1-vecs;
            Te = vecs/(Fp+ki);
            Ti = vi/kef;
            Ei = ki/(Fp+ki);

            Ca = fixedParameters.Ca;
            Cv = fixedParameters.Cv;
            Hct = fixedParameters.Hct;
            Cp = (fa*Ca+fv*Cv)/(1-Hct);

            firstCoefficient = Ei/(1-Te/Ti);
            secondCoefficient = 1-firstCoefficient;
            firstExponential = exp(-timevec/Ti);
            secondExponential = exp(-timevec/Te);

            fittedCt = Fp .* conv(firstCoefficient.*firstExponential + secondCoefficient.*secondExponential, ...
                Cp, 'full') .* timestep;

            Ct = fittedCt(1:length(timevec));

            %% Documentation of the parameter ordering
            %
            % freeParameters(1) is ki  (influx)
            % freeParameters(2) is kef  (efflux)
            % freeParameters(3) is Fp (plasma flow rate)
            % freeParameters(4) is vecs (extracellular space volume fraction)
            % freeParameters(5) is fa (arterial fraction)
        end

        %% GetFixedParameters
        function fixedParameters = GetFixedParameters(this, timeData, acqZero, Ct, Ca, Cv, Hct)
            fixedParameters = GetFixedParameters@PharmacokineticModel(this, timeData, acqZero);
            fixedParameters.Ct = Ct;
            fixedParameters.Ca = Ca;
            fixedParameters.Cv = Cv;
            fixedParameters.Hct = Hct;
        end

        %% GenerateStartingEstimatesForMultiStartOptimizer
        function startPoints = GenerateStartingEstimatesForMultiStartOptimizer(this)
            numberOfNarrowRangeStartPoints = this.NumberOfNarrowRangeStartPoints;
            numberOfWideRangeStartPoints = this.NumberOfWideRangeStartPoints;
            % Use a more dense set of starting points in the expected normal range for k1 and k2
            % Narrow Range Points span the expected values of the free parameters for the normal subject group
            narrowRangekiPoints = RandomPointsInInterval(0.001, 0.05, numberOfNarrowRangeStartPoints);
            narrowRangekefPoints = RandomPointsInInterval(0.000001, 0.002, numberOfNarrowRangeStartPoints);
            narrowRangeFpPoints = RandomPointsInInterval(0.0001, 5.0, numberOfNarrowRangeStartPoints);
            narrowRangevecsPoints = RandomPointsInInterval(0.05, 0.5, numberOfNarrowRangeStartPoints);
            narrowRangefaPoints = RandomPointsInInterval(0.05, 0.5, numberOfNarrowRangeStartPoints);
            narrowRangePoints = [narrowRangekiPoints, narrowRangekefPoints, narrowRangeFpPoints, ...
                narrowRangevecsPoints, narrowRangefaPoints];
            % Wide Range Points span several orders of magnitude for the rate constants to catch abnormal cases
            wideRangeRateConstantPoints = RandomPointsSpanningOrdersOfMagnitude(-10, 3, ...
                numberOfWideRangeStartPoints, 2);
            wideRangeFpPoints = RandomPointsSpanningOrdersOfMagnitude(-10, 2, numberOfWideRangeStartPoints);
            wideRangevecsPoints = RandomPointsInInterval(0.01, 0.99, numberOfWideRangeStartPoints);
            wideRangefaPoints = RandomPointsInInterval(0.01, 0.99, numberOfWideRangeStartPoints);
            wideRangePoints = [wideRangeRateConstantPoints, wideRangeFpPoints, wideRangevecsPoints, ...
                wideRangefaPoints];
            startPoints = [narrowRangePoints; wideRangePoints];
        end
    end
end