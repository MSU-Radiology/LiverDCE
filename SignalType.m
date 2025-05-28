classdef SignalType < uint16
    % SignalType    Enumeration type for the type of signal represented. This can be the raw signal intensity, R1, 
    %               area under the curve, total concentration, concentration in the extravascular extracellular 
    %               space, or intracellular concentration.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    enumeration
        SignalIntensity (1)
        R1Relaxation (2)
        AreaUnderCurve (3)
        TotalConcentration (4)
        EESConcentration (5)
        IntracellularConcentration (6)
    end

    properties
    end

    %% Public Methods
    methods
        %% ToDisplayName
        function signalTypeName = ToDisplayName(this)
            switch this
                case SignalType.SignalIntensity
                    signalTypeName = 'Signal Intensity';
                case SignalType.R1Relaxation
                    signalTypeName = 'R_1 Relaxation';
                case SignalType.AreaUnderCurve
                    signalTypeName = 'Area Under the Curve';
                case SignalType.TotalConcentration
                    signalTypeName = 'Total Concentration';
                case SignalType.EESConcentration
                    signalTypeName = 'EES Concentration';
                case SignalType.IntracellularConcentration
                    signalTypeName = 'Intracellular Concentration';
                otherwise
                    error('Invalid SignalType enumeration value');
            end
        end

        %% GetUnits
        function units = GetUnits(this)
            switch this
                case SignalType.SignalIntensity
                    units = 'arb. units';
                case SignalType.R1Relaxation
                    units = 's^{-1}';
                case SignalType.AreaUnderCurve
                    units = 'mM\cdots';
                case SignalType.TotalConcentration
                    units = 'mM';
                case SignalType.EESConcentration
                    units = 'mM';
                case SignalType.IntracellularConcentration
                    units = 'mM';
                otherwise
                    error('Invalid SignalType enumeration value');
            end
        end

        %% ToAxesLabel
        function axesLabel = ToAxesLabel(this)
            signalTypeName = this.ToDisplayName();
            units = this.GetUnits();
            axesLabel = [signalTypeName, ' (', units, ')'];
        end
    end

    methods (Static)
        %% DisplayNames
        function SignalTypeList = DisplayNames()
            types = SignalType(1:6);
            SignalTypeList = arrayfun(@ToDisplayName, types, 'UniformOutput', false);
        end
    end
end