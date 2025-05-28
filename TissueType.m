classdef TissueType < uint16
    % TissueType    Enumeration type for representing the different kinds of biological tissues processed by the
    %               LiverDCE program. Note: some of these tissues are unused at present. AbdominalAorta, PortalVein,
    %               Liver, and Spleen are used for the pharmacokinetic analyses. Some of the other tissues are intended
    %               for use in drift correction as reference tissues that do not take up the contrast agent and,
    %               therefore, should have the same signal intensity at the end of the DCE acquisitions as they did
    %               during the precontrast baseline acquisitions.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:  Matt Latourette

    enumeration
        AbdominalAorta (1)
        PortalVein (2)
        Liver (3)
        Spleen (4)
        Kidney (5)
        Muscle (6)
        SpinalCord (7)
        Fat (8)
        ArterialBlood (9)
        VenousBlood (10)
    end

    properties
    end

    methods
        %% IsVessel
        function bool = IsVessel(this)
            if(this.IsVein || this.IsArtery)
                bool = true;
            else
                bool = false;
            end
        end

        %% IsOrgan
        function bool = IsOrgan(this)
            switch this
                case {TissueType.Liver, TissueType.Spleen, TissueType.Kidney, TissueType.Muscle, ...
                        TissueType.SpinalCord, TissueType.Fat}
                    bool = true;
                otherwise
                    bool = false;
            end
        end

        %% IsArtery
        function bool = IsArtery(this)
            switch this
                case {TissueType.AbdominalAorta, TissueType.ArterialBlood}
                    bool = true;
                otherwise
                    bool = false;
            end
        end

        %% IsVein
        function bool = IsVein(this)
            switch this
                case {TissueType.PortalVein, TissueType.VenousBlood}
                    bool = true;
                otherwise
                    bool = false;
            end
        end

        %% ToDisplayName
        function tissueTypeName = ToDisplayName(this)
            switch this
                case TissueType.AbdominalAorta
                    tissueTypeName = 'Abdominal Aorta';
                case TissueType.PortalVein
                    tissueTypeName = 'Portal Vein';
                case TissueType.Liver
                    tissueTypeName = 'Liver';
                case TissueType.Spleen
                    tissueTypeName = 'Spleen';
                case TissueType.Kidney
                    tissueTypeName = 'Kidney';
                case TissueType.Muscle
                    tissueTypeName = 'Muscle';
                case TissueType.SpinalCord
                    tissueTypeName = 'Spinal Cord';
                case TissueType.Fat
                    tissueTypeName = 'Fat';
                case TissueType.ArterialBlood
                    tissueTypeName = 'Arterial Blood';
                case TissueType.VenousBlood
                    tissueTypeName = 'Venous Blood';
                otherwise
                    error('Unknown TissueType enumeration value');
            end
        end

        %% ToShortDisplayName
        function tissueTypeName = ToShortDisplayName(this)
            switch this
                case TissueType.AbdominalAorta
                    tissueTypeName = 'AA';
                case TissueType.PortalVein
                    tissueTypeName = 'PV';
                case TissueType.Liver
                    tissueTypeName = 'Liver';
                case TissueType.Spleen
                    tissueTypeName = 'Spleen';
                case TissueType.Kidney
                    tissueTypeName = 'Kidney';
                case TissueType.Muscle
                    tissueTypeName = 'Muscle';
                case TissueType.SpinalCord
                    tissueTypeName = 'SpinalCord';
                case TissueType.Fat
                    tissueTypeName = 'Fat';
                case TissueType.ArterialBlood
                    tissueTypeName = 'ArterialBlood';
                case TissueType.VenousBlood
                    tissueTypeName = 'VenousBlood';
                otherwise
                    error('Unknown TissueType enumeration value');
            end
        end

        %% ToStructFieldName
        function tissueStructFieldName = ToStructFieldName(this)
            switch this
                case TissueType.AbdominalAorta
                    tissueStructFieldName = 'AbdominalAorta';
                case TissueType.PortalVein
                    tissueStructFieldName = 'PortalVein';
                case TissueType.Liver
                    tissueStructFieldName = 'Liver';
                case TissueType.Spleen
                    tissueStructFieldName = 'Spleen';
                case TissueType.Kidney
                    tissueStructFieldName = 'Kidney';
                case TissueType.Muscle
                    tissueStructFieldName = 'Muscle';
                case TissueType.SpinalCord
                    tissueStructFieldName = 'SpinalCord';
                case TissueType.Fat
                    tissueStructFieldName = 'Fat';
                case TissueType.ArterialBlood
                    tissueStructFieldName = 'Arterial Blood';
                case TissueType.VenousBlood
                    tissueStructFieldName = 'Venous Blood';
                otherwise
                    error('Unknown TissueType enumeration value');
            end
        end

        function roiLabel = ToGroundTruthFileRoiLabel(this)
            arguments
                this TissueType
            end
            intensityProjectionType = this.ToRoiIntensityProjectionType();
            switch this
                case TissueType.AbdominalAorta
                    prefix = "AA";
                case TissueType.PortalVein
                    prefix = "PV";
                case TissueType.Liver
                    prefix = "liver";
                case TissueType.Spleen
                    prefix = "spleen";
                case TissueType.Kidney
                    prefix = "kidney";
                case TissueType.Muscle
                    prefix = "muscle";
                case TissueType.SpinalCord
                    prefix = "spinal_cord";
                case TissueType.Fat
                    prefix = "fat";
                case TissueType.ArterialBlood
                    prefix = "arterial_blood";
                case TissueType.VenousBlood
                    prefix = "venous blood";
                otherwise
                    prefix = "";
            end
            infix = "_on_";
            suffix = intensityProjectionType.ToGroundTruthLabelSuffixName();
            roiLabel = strcat(prefix, infix, suffix);
        end

        function proj = ToRoiIntensityProjectionType(this)
            arguments
                this (1,1) TissueType
            end
            switch this
                case TissueType.AbdominalAorta
                    proj = IntensityProjectionType.Maximum;
                case TissueType.PortalVein
                    proj = IntensityProjectionType.Maximum;
                case TissueType.Liver
                    proj = IntensityProjectionType.Mean;
                case TissueType.Spleen
                    proj = IntensityProjectionType.Mean;
                case TissueType.Kidney
                    proj = IntensityProjectionType.Mean;
                case TissueType.Muscle
                    proj = IntensityProjectionType.Mean;
                case TissueType.SpinalCord
                    proj = IntensityProjectionType.Mean;
                case TissueType.Fat
                    proj = IntensityProjectionType.Mean;
                case TissueType.ArterialBlood
                    proj = IntensityProjectionType.Maximum;
                case TissueType.VenousBlood
                    proj = IntensityProjectionType.Maximum; 
                otherwise
                    proj = IntensityProjectionType.Mean;
            end
        end
    end

    methods (Static)
        %% DisplayNames
        function tissueTypeList = DisplayNames()
            types = enumeration('TissueType');
            tissueTypeList = arrayfun(@ToDisplayName, types, 'UniformOutput', false);
        end

        %% FromString
        function tissueType = FromString(tissueName)
            tissueName = lower(tissueName);
            switch tissueName
                case 'liver'
                    tissueType = TissueType.Liver;
                case 'spleen'
                    tissueType = TissueType.Spleen;
                case 'kidney'
                    tissueType = TissueType.Kidney;
                case 'muscle'
                    tissueType = TissueType.Muscle;
                case {'spinal cord', 'spinalcord'}
                    tissueType = TissueType.SpinalCord;
                case 'fat'
                    tissueType = TissueType.Fat;
                case {'abdominal aorta', 'abdominalaorta', 'aa'}
                    tissueType = TissueType.AbdominalAorta;
                case {'portal vein', 'portalvein', 'pv'}
                    tissueType = TissueType.PortalVein;
                case 'arterial blood'
                    tissueType = TissueType.ArterialBlood;
                case 'venous blood'
                    tissueType = TissueType.VenousBlood;
                otherwise
                    tissueType = TissueType.empty;
            end
        end
    end
end