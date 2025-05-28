classdef PkBerksModel < PharmacokineticAlgebraicModel & IMultiStartOptimizable & ITruncatable
    % PkBerksModel  This is an implementation of the biexponential pharmacokinetic model from the Berks et al 2021
    %               Magn Reson Med paper, "A model selection framework to quantify microvascular liver function in
    %               gadoxetate-enhanced MRI: Application to healthy liver, diseased tissue, and hepatocellular
    %               carcinoma."
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    properties (SetAccess = protected, GetAccess = public)
        NumberOfNarrowRangeStartPoints
        NumberOfWideRangeStartPoints
        TruncateData
        TruncationIndex
    end

    %% Public Methods
    methods
        %% Constructors
        function this = PkBerksModel(varargin)
            this@PharmacokineticAlgebraicModel(varargin{:});
            this.NumberOfFreeParameters = 5;
            this.NumberOfNarrowRangeStartPoints = 500;
            this.NumberOfWideRangeStartPoints = 500;
            this.TruncateData = false;
            this.TruncationIndex = 1;
        end

        %% Evaluate
        function Ct = Evaluate(this, freeParameters, fixedParameters)
            arguments
                this (1,1) PkBerksModel
                freeParameters (1,:) double
                fixedParameters(1,1) struct
            end

            t = fixedParameters.time;
            timestep = t(2)-t(1);
            descaledParameters = DescaleParameter(freeParameters);

            alphaPlus = descaledParameters(1);
            alphaMinus = descaledParameters(2);
            betaPlus = descaledParameters(3);
            betaMinus = descaledParameters(4);
            fa = descaledParameters(5);

            Ca = fixedParameters.Ca;
            Cv = fixedParameters.Cv;
            Hct = fixedParameters.Hct;

            % Note: The Berks paper's equation 4 doesn't have (1 - hematocrit) in the denominator because they assume
            % that Ca and Cv are already plasma concentrations, not whole blood concentrations
            Cp = (fa.*Ca + (1-fa).*Cv)./(1-Hct);

            fittedCt = conv(alphaPlus.*exp(-betaPlus.*t)+alphaMinus.*exp(-betaMinus.*t), Cp, 'full').*timestep;
            Ct = fittedCt(1:length(t));
        end

        %% GetFixedParameters
        function fixedParameters = GetFixedParameters(this, timeData, acqZero, Ct, Ca, Cv, Hct)
            fixedParameters = GetFixedParameters@PharmacokineticModel(this, timeData, acqZero);
            if(this.TruncateData)
                truncationIndex = this.TruncationIndex;
                fixedParameters.Ct = Ct(1:truncationIndex);
                fixedParameters.Ca = Ca(1:truncationIndex);
                fixedParameters.Cv = Cv(1:truncationIndex);
            else
                fixedParameters.Ct = Ct;
                fixedParameters.Ca = Ca;
                fixedParameters.Cv = Cv;
            end
            fixedParameters.Hct = Hct;
        end

        %% GenerateStartingEstimatesForMultiStartOptimizer
        function startPoints = GenerateStartingEstimatesForMultiStartOptimizer(this)
            numberOfNarrowRangeStartPoints = this.NumberOfNarrowRangeStartPoints;
            numberOfWideRangeStartPoints = this.NumberOfWideRangeStartPoints;
            % Narrow Range Points span the expected values of the free parameters for the normal subject group
            narrowRangeAlphaPlus = RandomPointsInInterval(0.0001, 1.0, numberOfNarrowRangeStartPoints);
            narrowRangeAlphaMinus = RandomPointsInInterval(0.0001, 1.0, numberOfNarrowRangeStartPoints);
            narrowRangeBetaPlus = RandomPointsInInterval(0.0001, 1.0, numberOfNarrowRangeStartPoints);
            narrowRangeBetaMinus = RandomPointsInInterval(0.0001, 1.0, numberOfNarrowRangeStartPoints);
            narrowRangefa = RandomPointsInInterval(0.05, 0.3, numberOfNarrowRangeStartPoints);
            narrowRangePoints = [narrowRangeAlphaPlus narrowRangeAlphaMinus narrowRangeBetaPlus...
                narrowRangeBetaMinus narrowRangefa];
            % Wide Range Points span several orders of magnitude of the free parameters to catch abnormal cases
            wideRangeAlphaPlus = RandomPointsSpanningOrdersOfMagnitude(-10, 0, numberOfWideRangeStartPoints);
            wideRangeAlphaMinus = RandomPointsSpanningOrdersOfMagnitude(-10, 0, numberOfWideRangeStartPoints);
            wideRangeBetaPlus = RandomPointsSpanningOrdersOfMagnitude(-10, 0, numberOfWideRangeStartPoints);
            wideRangeBetaMinus = RandomPointsSpanningOrdersOfMagnitude(-10, 0, numberOfWideRangeStartPoints);
            wideRangefa = RandomPointsInInterval(0.0, 0.6, numberOfWideRangeStartPoints);
            wideRangePoints = [wideRangeAlphaPlus wideRangeAlphaMinus wideRangeBetaPlus wideRangeBetaMinus ...
                wideRangefa];
            startPoints = [narrowRangePoints; wideRangePoints];
        end

        %% EnableDataTruncation
        function EnableDataTruncation(this, truncationIndex)
            if(~isnumeric(truncationIndex))
                error('Invalid truncation index');
            end
            this.TruncateData = true;
            this.TruncationIndex = truncationIndex;
        end

        %% DisableDataTruncation
        function DisableDataTruncation(this)
            this.TruncateData = false;
        end
    end
end