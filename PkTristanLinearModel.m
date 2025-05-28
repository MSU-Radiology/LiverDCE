classdef PkTristanLinearModel < PharmacokineticAlgebraicModel & IMultiStartOptimizable
    % PkTristanLinearModel  This is an implementation of the TRISTAN consortium reference region model described in 
    %                       the supplemental materials in the Ziemian et al 2021 NMR Biomed paper, "Ex vivo gadoxetate 
    %                       relaxivities in rat liver tissue and blood at five magnetic field strengths from 1.41 to 
    %                       7 T." The nomenclature here differs a bit from the supplemental materials in the Zieimian 
    %                       et al paper because it was originally based off of an earlier version obtained from 
    %                       Dr. Sourbron which used k1 and k2 as the influx and efflux parameters instead of khe and 
    %                       kbh.
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
        function this = PkTristanLinearModel(varargin)
            this@PharmacokineticAlgebraicModel(varargin{:});
            this.NumberOfFreeParameters = 2;
            this.NumberOfNarrowRangeStartPoints = 20;
            this.NumberOfWideRangeStartPoints = 80;
        end

        %% Evaluate
        function Ci = Evaluate(this, freeParameters, fixedParameters)
            arguments
                this (1,1) PkTristanLinearModel
                freeParameters (1,:) double
                fixedParameters(1,1) struct
            end

            timevec = fixedParameters.time;
            Ces = fixedParameters.Ces;
            vhLiver = 1-fixedParameters.veLiver;

            timestep = timevec(2)-timevec(1);
            descaledParameters = DescaleParameter(freeParameters);
            k1 = descaledParameters(1);
            k2 = descaledParameters(2);
            fittedCi = conv(exp(-timevec.*(k2./vhLiver)), ...
                (k1./vhLiver).*Ces, 'full') .* timestep;

            Ci = fittedCi(1:length(timevec));

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