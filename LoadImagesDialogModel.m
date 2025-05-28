classdef LoadImagesDialogModel < handle
    % LoadImagesDialogModel     Model class (MVC pattern) for the LoadImagesDialog GUI. This class represents 
    %                           information about the image data set to be loaded into LiverDCE for analysis.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette

    %% Properties
    
    % Observable Properties (listeners receive notification of changes)
    properties (SetObservable = true, AbortSet = true)
        ImageFileFormat char
        UseDefaultRelaxivity(1,1) logical
        LiverRelaxivity(1,1) double
        PlasmaRelaxivity(1,1) double
        BloodRelaxivity(1,1) double
        AcquisitionInterval(1,1) double
        FlipAngle(1,1) double
        EchoTime(1,1) double
        RepetitionTime(1,1) double
        DicomFileFolderStructure char
        FilenamePrefix char
        UseLeadingZeros(1,1) logical
        DigitPlaces(1,1) uint8
        FilenameExtension char
        NumberOfSlices(1,1) uint16
        FilesystemPath char
        ImageSetIdentifier char
        BrikName char
        SavedScreenPosition
        Cancelled(1,1) logical
    end
    
    properties (SetObservable = true, AbortSet = true, Hidden = true)
        SelectedAgent(1,1) uint16
        AgentList cell
        OtherContrastAgent char
        SelectedFieldStrength(1,1) uint16
        FieldStrengthList cell
        OtherFieldStrength(1,1) double
        SelectedSpecies(1,1) uint16
        SpeciesList cell
        SelectedPulseSequence(1,1) uint16
        PulseSequenceList cell
    end
    
    % Observable Properties without the AbortSet attribute
    properties (SetObservable = true)
        FilenameFormatString char
    end
    
    % Private Properties
    properties (Access = private)
    end
        
    % Public Computable Dependent Properties
    properties (SetObservable = true, Dependent = true)
        ContrastAgentName char
        B0FieldStrength(1,1) double
        Species char
        PulseSequence char
        IsReadyToLoadImages(1,1) logical
        IsHepatobiliaryContrastAgent(1,1) logical
    end
    
    % Private Computable Dependent Properties
    properties (Dependent = true, SetAccess = private)
    end
    
    %% Events
    events
    end
    
    %% Public Constructors
    methods
        function this = LoadImagesDialogModel(varargin)
            switch nargin
                case 0
                    this.LoadImagesDialogModelNullConstructor();
                case 1
                    m = varargin{1};
                    if(~isempty(m))
                        this.LoadImagesDialogModelCopyConstructor(m);
                    else
                        this.LoadImagesDialogModelNullConstructor();
                    end
                otherwise
                    error('LoadImagesDialogModel received too many arguments');
            end
        end
    end

    %% Private Constructors
    methods (Access = private)
        %% LoadImagesDialogModelNullConstructor
        function LoadImagesDialogModelNullConstructor(this)
            this.ImageFileFormat = 'DICOM';
            this.SelectedAgent = 1;
            this.AgentList = {'Gd-EOB-DTPA', 'Gd-BOPTA', 'Gd-DTPA', 'Gd-BT-DO3A', 'Other'};
            this.OtherContrastAgent = '';
            
            % Eovist's relaxivity in blood at 7T (Ziemian et al, 2020, NMR Biomed)
            this.LiverRelaxivity = 6.2;
            this.PlasmaRelaxivity = 6.2;
            %TODO: replace the single blood relaxivity value with 2 separate values for arterial and venous blood
            %if there is sufficient data in the literature to support this
            this.BloodRelaxivity = 6.2;
            this.SelectedFieldStrength = 1;
            this.FieldStrengthList = {'1.5','3.0', '4.7', '7.0', '9.4', 'Other'};
            this.OtherFieldStrength = 0.47;
            this.SelectedSpecies = 1;
            this.SpeciesList = {'Human', 'Pig', 'Dog', 'Rat', 'Mouse'};
            % SelectedAgent, AgentList, OtherContrastAgent, SelectedFieldStrength, FieldStrengthList,
            % OtherFieldStrength, SelectedSpecies, and SpeciesList must have their values set before setting the value
            % for UseDefaultRelaxivity because the setter calls UpdateDefaultRelaxivityValues(), which depends upon
            % those properties being set
            this.UseDefaultRelaxivity = true;
            this.SelectedPulseSequence = 1;
            this.PulseSequenceList = {'FLASH', 'RARE'};
            this.AcquisitionInterval = 44.8633333333;
            this.FlipAngle = 10;
            this.EchoTime = 1.0;
            this.RepetitionTime = 1.0;
            this.DicomFileFolderStructure = 'Ordered';
            this.FilenamePrefix = 'MRIm';
            this.UseLeadingZeros = true;
            this.DigitPlaces = 4;
            this.FilenameExtension = '.dcm';
            this.UpdateFilenameFormatString();
            this.NumberOfSlices = 1;
            this.FilesystemPath = '';
            this.ImageSetIdentifier = '';
            this.BrikName = '';
            this.SavedScreenPosition = '';
        end

        %% LoadImagesDialogModelCopyConstructor
        function LoadImagesDialogModelCopyConstructor(this, modelToCopy)
            this.ImageFileFormat = modelToCopy.ImageFileFormat;
            this.SelectedAgent = modelToCopy.SelectedAgent;
            this.AgentList = modelToCopy.AgentList;
            this.OtherContrastAgent = modelToCopy.OtherContrastAgent;
            this.LiverRelaxivity = modelToCopy.LiverRelaxivity;
            this.PlasmaRelaxivity = modelToCopy.PlasmaRelaxivity;
            %TODO: replace the single blood relaxivity value with 2 separate values for arterial and venous blood
            %if there is sufficient data in the literature to support this
            this.BloodRelaxivity = modelToCopy.BloodRelaxivity;
            this.SelectedFieldStrength = modelToCopy.SelectedFieldStrength;
            this.FieldStrengthList = modelToCopy.FieldStrengthList;
            this.OtherFieldStrength = modelToCopy.OtherFieldStrength;
            this.SelectedSpecies = modelToCopy.SelectedSpecies;
            this.SpeciesList = modelToCopy.SpeciesList;
            % SelectedAgent, AgentList, OtherContrastAgent, SelectedFieldStrength, FieldStrengthList,
            % OtherFieldStrength, SelectedSpecies, and SpeciesList must have their values set before setting the value
            % for UseDefaultRelaxivity because the setter calls UpdateDefaultRelaxivityValues(), which depends upon
            % those properties being set
            this.UseDefaultRelaxivity = modelToCopy.UseDefaultRelaxivity;
            this.SelectedPulseSequence = modelToCopy.SelectedPulseSequence;
            this.PulseSequenceList = modelToCopy.PulseSequenceList;
            this.AcquisitionInterval = modelToCopy.AcquisitionInterval;
            this.FlipAngle = modelToCopy.FlipAngle;
            this.EchoTime = modelToCopy.EchoTime;
            this.RepetitionTime = modelToCopy.RepetitionTime;
            this.DicomFileFolderStructure = ...
                modelToCopy.DicomFileFolderStructure;
            this.FilenamePrefix = modelToCopy.FilenamePrefix;
            this.UseLeadingZeros = modelToCopy.UseLeadingZeros;
            this.DigitPlaces = modelToCopy.DigitPlaces;
            this.FilenameExtension = modelToCopy.FilenameExtension;
            this.UpdateFilenameFormatString();
            this.NumberOfSlices = modelToCopy.NumberOfSlices;
            this.FilesystemPath = modelToCopy.FilesystemPath;
            this.ImageSetIdentifier = modelToCopy.ImageSetIdentifier;
            this.BrikName = modelToCopy.BrikName;
            this.SavedScreenPosition = modelToCopy.SavedScreenPosition;
        end
    end

    %% Public Methods
    methods
        %% Getters for Computable Properties
        function agentName = get.ContrastAgentName(this)
            selectedAgent = this.SelectedAgent;
            optionList = this.AgentList;
            agentName = optionList{selectedAgent};
            switch(agentName)
                case 'Other'
                    agentName = this.OtherContrastAgent;
            end
        end
        
        function fieldStrength = get.B0FieldStrength(this)
            selectedFieldStrength = this.SelectedFieldStrength;
            optionList = this.FieldStrengthList;
            fieldStrength = optionList{selectedFieldStrength};
            switch(fieldStrength)
                case 'Other'
                    fieldStrength = this.OtherFieldStrength;
                otherwise
                    fieldStrength = str2double(fieldStrength);
            end
        end

        function species = get.Species(this)
            selectedSpecies = this.SelectedSpecies;
            optionList = this.SpeciesList;
            species = optionList{selectedSpecies};
        end
        
        function pulseSequence = get.PulseSequence(this)
            selectedPulseSequence = this.SelectedPulseSequence;
            optionList = this.PulseSequenceList;
            pulseSequence = optionList{selectedPulseSequence};
        end
        
        function ready = get.IsReadyToLoadImages(this)
            ready = false;
            if(isempty(this))
                return
            end
            
            filesystemPath = this.FilesystemPath;
            if(~isempty(filesystemPath) && isfolder(filesystemPath))
                switch(this.ImageFileFormat)
                    case 'DICOM'
                        ready = this.IsReadyToLoadDicomImages();
                    case 'AFNI'
                        ready = this.IsReadyToLoadAfniImages();
                    case 'NIFTI'
                        ready = this.IsReadyToLoadNiftiImages();
                    otherwise
                        return
                end
            end
        end
        
        function bool = get.IsHepatobiliaryContrastAgent(this)
            selectedAgent = this.SelectedAgent;
            optionList = this.AgentList;
            agentName = optionList{selectedAgent};
            switch(agentName)
                case 'Other'
                    % For user-specified contrast agent, assume that it could have liver uptake (if it doesn't, that 
                    % should just result in a small rate constant for the uptake in the model)
                    bool = true;
                case 'Gd-EOB-DTPA'
                    bool = true;
                case 'Gd-BOPTA'
                    bool = true;
                case 'Gd-DTPA'
                    bool = false;
                case 'Gd-BT-DO3A'
                    bool = false;
                otherwise
                    error('Invalid contrast agent selection');
            end
        end
        
        %% Getters and Setters
        function fileFormat = get.ImageFileFormat(this)
            fileFormat = this.ImageFileFormat;
        end
        
        function set.ImageFileFormat(this, str)
            switch(str)
                case 'DICOM'
                    this.ImageFileFormat = str;
                case 'AFNI'
                    this.ImageFileFormat = str;
                case 'NIFTI'
                    this.ImageFileFormat = str;
                otherwise
                    error('Invalid image file format selection');
            end
        end
        
        function agent = get.SelectedAgent(this)
            agent = this.SelectedAgent;
        end
        
        function set.SelectedAgent(this, value)
            this.SelectedAgent = value;
        end
        
        function agent = get.OtherContrastAgent(this)
            agent = this.OtherContrastAgent;
        end
        
        function set.OtherContrastAgent(this, str)
            this.OtherContrastAgent = str;
        end

        function relaxivity = get.UseDefaultRelaxivity(this)
            relaxivity = this.UseDefaultRelaxivity;
        end
        
        function set.UseDefaultRelaxivity(this, useDefaultRelaxivity)
            if(islogical(useDefaultRelaxivity))
                this.UseDefaultRelaxivity = useDefaultRelaxivity;
                this.UpdateDefaultRelaxivityValues();
            end
        end
        
        function relaxivity = get.LiverRelaxivity(this)
            relaxivity = this.LiverRelaxivity;
        end
        
        function set.LiverRelaxivity(this, relaxivity)            
            % The relaxivity must be a non-negative real number
            if(IsNonNegative(relaxivity))
                this.LiverRelaxivity = relaxivity;
            end
        end

        function relaxivity = get.PlasmaRelaxivity(this)
            relaxivity = this.PlasmaRelaxivity;
        end
        
        function set.PlasmaRelaxivity(this, relaxivity)
            % The relaxivity must be a non-negative real number
            if(IsNonNegative(relaxivity))
                this.PlasmaRelaxivity = relaxivity;
            end
        end

        %TODO: replace the single blood relaxivity value with 2 separate values for arterial and venous blood
        %if there is sufficient data in the literature to support this
        function relaxivity = get.BloodRelaxivity(this)
            relaxivity = this.BloodRelaxivity;
        end
        
        function set.BloodRelaxivity(this, relaxivity)
            % The relaxivity must be a non-negative real number
            if(IsNonNegative(relaxivity))
                this.BloodRelaxivity = relaxivity;
            end
        end
        
        function fieldStrength = get.SelectedFieldStrength(this)
            fieldStrength = this.SelectedFieldStrength;
        end
        
        function set.SelectedFieldStrength(this, value)
            this.SelectedFieldStrength = value;
        end
        
        function fieldStrength = get.OtherFieldStrength(this)
            fieldStrength = this.OtherFieldStrength;
        end
        
        function set.OtherFieldStrength(this, B0)
            if(IsNonNegative(B0))
                this.OtherFieldStrength = B0;
            end
        end

        function species = get.SelectedSpecies(this)
            species = this.SelectedSpecies;
        end

        function set.SelectedSpecies(this, value)
            this.SelectedSpecies = value;
        end
        
        function pulseSequence = get.SelectedPulseSequence(this)
            pulseSequence = this.SelectedPulseSequence;
        end
        
        function set.SelectedPulseSequence(this, value)
            this.SelectedPulseSequence = value;
        end
        
        function acquisitionInterval = get.AcquisitionInterval(this)
            acquisitionInterval = this.AcquisitionInterval;
        end
        
        function set.AcquisitionInterval(this, value)
            if(IsNonNegative(value))
                this.AcquisitionInterval = value;
            end
        end
        
        function flipAngle = get.FlipAngle(this)
            flipAngle = this.FlipAngle;
        end
        
        function set.FlipAngle(this, value)
            if(IsNonNegative(value))
                this.FlipAngle = value;
            end
        end
        
        function TE = get.EchoTime(this)
            TE = this.EchoTime;
        end
        
        function set.EchoTime(this, value)
            if(IsNonNegative(value))
                this.EchoTime = value;
            end
        end
        
        function TR = get.RepetitionTime(this)
            TR = this.RepetitionTime;
        end
        
        function set.RepetitionTime(this, value)
            if(IsNonNegative(value))
                this.RepetitionTime = value;
            end
        end
        
        function folderStructure = get.DicomFileFolderStructure(this)
            folderStructure = this.DicomFileFolderStructure;
        end
        
        function set.DicomFileFolderStructure(this, str)
            this.DicomFileFolderStructure = str;
        end
        
        function prefix = get.FilenamePrefix(this)
            prefix = this.FilenamePrefix;
        end
        
        function set.FilenamePrefix(this, str)
            this.FilenamePrefix = str;
            this.UpdateFilenameFormatString();
        end
        
        function bool = get.UseLeadingZeros(this)
            bool = this.UseLeadingZeros;
        end
        
        function set.UseLeadingZeros(this, useLeadingZeros)
            if(islogical(useLeadingZeros))
                this.UseLeadingZeros = useLeadingZeros;
                this.UpdateFilenameFormatString();
            end
        end
        
        function digits = get.DigitPlaces(this)
            digits = this.DigitPlaces;
        end
        
        function set.DigitPlaces(this, value)
            if(isnumeric(value) && value >= 1)
                this.DigitPlaces = value;
                this.UpdateFilenameFormatString();
            end
        end
        
        function extension = get.FilenameExtension(this)
            extension = this.FilenameExtension;
        end
        
        function set.FilenameExtension(this, str)
            this.FilenameExtension = str;
            this.UpdateFilenameFormatString();
        end
        
        function number = get.NumberOfSlices(this)
            number = this.NumberOfSlices;
        end
        
        function set.NumberOfSlices(this, numberOfSlices)
            if(isnumeric(numberOfSlices) && numberOfSlices >= 1)
                this.NumberOfSlices = uint16(numberOfSlices);
            end
        end
        
        function path = get.FilesystemPath(this)
            path = this.FilesystemPath;
        end
        
        function set.FilesystemPath(this, str)
            this.FilesystemPath = str;
        end

        function imageSetIdentifier = get.ImageSetIdentifier(this)
            imageSetIdentifier = this.ImageSetIdentifier;
        end

        function set.ImageSetIdentifier(this, str)
            this.ImageSetIdentifier = str;
        end
        
        function name = get.BrikName(this)
            name = this.BrikName;
        end
        
        function set.BrikName(this, str)
            this.BrikName = str;
        end
        
        function position = get.SavedScreenPosition(this)
            position = this.SavedScreenPosition;
        end
        
        function set.SavedScreenPosition(this, value)
            this.SavedScreenPosition = value;
        end
        
        %% Other Class Methods
        
        %% UpdateFilenameFormatString
        function UpdateFilenameFormatString(this)
            prefix = this.FilenamePrefix;
            useLeadingZeros = this.UseLeadingZeros;
            digitPlaces = this.DigitPlaces;
            extension = this.FilenameExtension;
            
            if (useLeadingZeros)
                format = [prefix, '%0', num2str(digitPlaces), 'd', extension];
            else
                format = [prefix, '%d', extension];
            end
            this.FilenameFormatString = format;
        end

        %% UpdateDefaultRelaxivityValues
        function UpdateDefaultRelaxivityValues(this)
            agentName = this.ContrastAgentName;
            if(isempty(agentName))
                return
            end

            fieldStrength = this.B0FieldStrength;
            if(isempty(fieldStrength) || ~isnumeric(fieldStrength))
                return
            end

            species = this.Species;
            if(isempty(species))
                return
            end

            fieldStrengthTolerance = 0.2;
            switch(agentName)
                case {'Gd-EOB-DTPA', 'Gadoxetate', 'Eovist', 'Primovist'}
                    switch(species)
                        case {'Human', 'Pig'}
                            if(IsWithinToleranceOfValue(0.47, fieldStrength, fieldStrengthTolerance))
                                % From section 12.2 of Eovist prescribing information:
                                % https://www.accessdata.fda.gov/drugsatfda_docs/label/2010/022090s004lbl.pdf
                                % and
                                % Weinmann et al, 1991, MRM, A New Lipophilic Gadolinium Chelate as a Tissue-Specific
                                % Contrast Medium for MRI
                                this.PlasmaRelaxivity = 8.7;

                                % Schumann-Giampieri et al, 1992, Radiology, Preclinical Evaluation of Gd-EOB-DTPA as a
                                % Contrast Agent in MR Imaging of the Hepatobiliary System
                                this.BloodRelaxivity = 11.2;

                                % No human liver relaxivity data available, use the value for rat liver from
                                % Schumann-Giampieri et al, 1992, Radiology
                                this.LiverRelaxivity = 16.6;
                            elseif(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
                                % Shen et al, 2015, Invest Radiol, T1 Relaxivities of Gadolinium-Based Magnetic
                                % Resonance Contrast Agents in Human Whole Blood at 1.5, 3, and 7 T
                                this.BloodRelaxivity = 7.2;

                                % No human liver or plasma data available
                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine plasma at 37 C
                                this.PlasmaRelaxivity = 6.9;

%                                 % Shuter et al, 1996, Magn Reson Imaging, The Relaxivity of Gd-EOB-DTPA and Gd-DTPA in
%                                 % Liver and Kidney of Wistar Rat
%                                 % No human data available, use rat liver
%                                 this.LiverRelaxivity = 7.5;

                                % TODO: DETERMINE WHAT IS CLOSER TO HUMAN, RAT OR GUINEA PIG?

                                % Ziemian S, Green C, Sourbron S, Jost G, Schutz G, Hines CDG, 2020, NMR Biomed, Ex vivo
                                % gadoxetate relaxivities in rat liver tissue and blood at five magnetic field strengths
                                % from 1.41 to 7 T
                                % Rat liver
                                this.LiverRelaxivity = 14.6;

%                                 % Alternately, could use guinea pig liver dat instead
%                                 % Shuter et al, 1998, JMRI, Relaxivity of Gd-EOB-DTPA in the Normal and Biliary
%                                 % Obstructed Guinea Pig
%                                 % No human data available, use guinea pig
%                                 this.LiverRelaxivity = 9.3;
                            elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 5.5;

                                % No human liver or plasma data available
                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine plasma at 37 C
                                this.PlasmaRelaxivity = 6.2;

                                % Ziemian et al, 2020, NMR Biomed
                                % Rat liver
                                this.LiverRelaxivity = 9.8;
                            elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
                                % No human plasma data available
                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine plasma at 37 C
                                this.PlasmaRelaxivity = 5.9;
                                
                                % No human liver or whole blood data available
                                % Ziemian et al, 2020, NMR Biomed
                                % wild type rat liver and Mrp2-KO rat blood
                                this.BloodRelaxivity = 6.4;
                                this.LiverRelaxivity = 7.6;
                            elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
                                % Shen et al, 2015, Invest Radiol
                                this.PlasmaRelaxivity = 4.9;

                                % No human liver or whole blood data available
                                % Ziemian et al, 2020, NMR Biomed
                                % wild type rat liver and Mrp2-KO rat blood
                                this.BloodRelaxivity = 6.2;
                                this.LiverRelaxivity = 6.0;
                            elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
                                % No Eovist relaxivity data available at 9.4 T (at least none that I was aware of in
                                % March 2017, when I compiled my spreadsheet of relaxivity reference data -- would be
                                % worth looking revisiting to see if any new studies published more recently have filled
                                % in gaps in relaxivity data)

                                % Until data becomes available, just use the 7 T numbers
                                % Shen et al, 2015, Invest Radiol (at 7 T)
                                this.PlasmaRelaxivity = 4.9;

                                % No human liver or whole blood data available
                                % Ziemian et al, 2020, NMR Biomed (at 7 T)
                                % wild type rat liver and Mrp2-KO rat blood
                                this.BloodRelaxivity = 6.2;
                                this.LiverRelaxivity = 6.0;
                            end
                            % No pig-specific relaxivity data is available (that I know of, as of March 2017)
                            % Use the same values as for human
%                         case 'Pig'
%                             if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
%                             end
                        case 'Dog'
                            if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
                                % Rohrer M, Bauer H, Mintorovitch J, Requardt M, Weinmann HJ. Comparison of Magnetic
                                % Properties of MRI Contrast Media Solutions at Different Magnetic Field Strengths,
                                % Invest Radiol, 40:715-724, 2005
                                % Measured in whole canine blood at 37 degrees C
                                this.BloodRelaxivity = 7.3;

                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 6.9;

                                % No dog liver relaxivity data available
                                % Ziemian et al, 2020, NMR Biomed
                                % Rat data
                                this.LiverRelaxivity = 14.6;
                            elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 6.2;

                                % No dog liver or whole blood relaxivity available
                                % Ziemian et al, 2020, NMR Biomed
                                % Rat data
                                this.LiverRelaxivity = 9.8;
                                this.BloodRelaxivity = 6.4;
                            elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 5.9;

                                % No dog liver or whole blood relaxivity available
                                % Ziemian et al, 2020, NMR Biomed
                                % Rat data
                                this.LiverRelaxivity = 7.6;
                                this.BloodRelaxivity = 6.4;
                            elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
                                % No dog liver, plasma, or whole blood relaxivity data available at 7 T
                                % Ziemian et al, 2020, NMR Biomed
                                % Rat data
                                this.LiverRelaxivity = 6.0;
                                this.BloodRelaxivity = 6.2;

                                % No plasma data availble, use the same value as whole blood
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
                                % No Eovist relaxivity data available at 9.4 T (at least none that I was aware of in
                                % March 2017, when I compiled my spreadsheet of relaxivity reference data -- would be
                                % worth looking revisiting to see if any new studies published more recently have filled
                                % in gaps in relaxivity data)

                                % Until data becomes available, just use the 7 T numbers
                                % Ziemian et al, 2020, NMR Biomed
                                % 7 T Rat data
                                this.LiverRelaxivity = 6.0;
                                this.BloodRelaxivity = 6.2;

                                % No plasma data availble, use the same value as whole blood
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            end
                        case {'Rat', 'Mouse'}
                            if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
                                % Ziemian S, Green C, Sourbron S, Jost G, Schutz G, Hines CDG. Ex vivo gadoxetate
                                % relaxivities in rat liver tissue and blood at five magnetic field strengths from 1.41
                                % to 7 T, NMR Biomed, 34(1):e4401, 2020
                                this.LiverRelaxivity = 14.6;
                                this.BloodRelaxivity = 8.1;

                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 6.9;
%                                 this.BloodRelaxivity = 7.3;
                            elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
                                % Ziemian et al, 2020, NMR Biomed
                                this.LiverRelaxivity = 9.8;
                                this.BloodRelaxivity = 6.4;

                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 6.2;
                            elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
                                % Ziemian et al, 2020, NMR Biomed
                                this.LiverRelaxivity = 7.6;
                                this.BloodRelaxivity = 6.4;

                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 5.9;
                            elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
                                % Ziemian et al, 2020, NMR Biomed
                                this.LiverRelaxivity = 6.0;
                                this.BloodRelaxivity = 6.2;

                                % No plasma data available at 7 T, use same value as whole blood
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
                                % No data available at 9.4 T, use 7 T values

                                % Ziemian et al, 2020, NMR Biomed (7 T)
                                this.LiverRelaxivity = 6.0;
                                this.BloodRelaxivity = 6.2;

                                % No plasma data available, use same value as whole blood
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            end
                            % No mouse-specific relaxivity data is available (that I know of, as of March 2017)
                            % Use the same values as for rat
%                         case 'Mouse'
%                             if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
%                             end
                        otherwise
                    end
                case {'Gd-BOPTA', 'Gadobenate', 'MultiHance'}
                    switch(species)
                        case 'Human'
                            % The prescribing information document for MultiHance gives a r1 relaxivity value of 9.7 for
                            % heparinized human plasma at 39 degrees C, but does not state the field strength or cite a
                            % reference for the measurement. It also gives a value of 4.9 for gadopentetate at 39
                            % degrees C.

                            if(IsWithinToleranceOfValue(0.47, fieldStrength, fieldStrengthTolerance))
                                % Rohrer, 2005, Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 9.2;

                                % No liver or whole blood data, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                                this.BloodRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
                                % Pintaske et al, 2006, Invest Radiol
                                this.PlasmaRelaxivity = 8.1;

                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 6.2;

                                % No in situ liver value given, so use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
                                % Pintaske et al, 2006, Invest Radiol
                                this.PlasmaRelaxivity = 6.3;

                                % No in situ liver value given, so use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                                this.BloodRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
                                % No human data available at 4.7 T

                                % Rohrer, 2005, Invest Radiol
                                % Bovine value, plasma at 37 C
                                this.PlasmaRelaxivity = 5.2;

                                % No liver or whole blood values available, so use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                                this.BloodRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 4.7;
                                
                                % No liver or plasma values available, so use whole blood value
                                this.LiverRelaxivity = this.BloodRelaxivity;
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
                                % No 9.4 T data availabe, use 7 T values

                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 4.7;
                                
                                % No liver or plasma values available, so use whole blood value
                                this.LiverRelaxivity = this.BloodRelaxivity;
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            end
                        case 'Pig'
                            if(IsWithinToleranceOfValue(0.47, fieldStrength, fieldStrengthTolerance))
                                % Rohrer, 2005, Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 9.2;

                                % No liver or whole blood data, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                                this.BloodRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al 2005 Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 6.3;

                                % Rohrer et al 2005 Invest Radiol
                                % Canine value, whole blood at 37 C
                                this.BloodRelaxivity = 6.7;

                                % No liver value available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al 2005 Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 5.5;

                                % No pig blood data available, substitute human value
                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 5.4;

                                % No liver value available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al 2005 Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 5.2;

                                % No pig blood data available, substitute human value
                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 4.7;

                                % No liver value available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
                                % No pig data available, substitute human value
                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 4.7;
                                
                                % No liver or plasma values available, so use whole blood value
                                this.LiverRelaxivity = this.BloodRelaxivity;
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
                                % No 9.4 T data available, substitute 7 T values
                                % Shen et al, 2015, Invest Radiol
                                % Human value
                                this.BloodRelaxivity = 4.7;
                                
                                % No liver or plasma values available, so use whole blood value
                                this.LiverRelaxivity = this.BloodRelaxivity;
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            end
                        case {'Dog', 'Rat', 'Mouse'}
                            if(IsWithinToleranceOfValue(0.47, fieldStrength, fieldStrengthTolerance))
                                % No dog data available
                                % Rohrer, 2005, Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 9.2;

                                % No liver or whole blood data, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                                this.BloodRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al 2005 Invest Radiol
                                % Canine value, whole blood at 37 C
                                this.BloodRelaxivity = 6.7;

                                % Bovine value, plasma at 37 C
                                this.PlasmaRelaxivity = 6.3;

                                % No liver value available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al 2005 Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 5.5;
                                
                                % Rohrer, 2005, Invest Radiol
                                % Measured in whole canine blood at 37 degrees C
                                this.BloodRelaxivity = 6.7;

                                % No liver value available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al 2005 Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 5.2;

                                % No liver or whole blood value available, use plasma value
                                this.BloodRelaxivity = this.PlasmaRelaxivity;
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
                                % No dog data available, substitute human value
                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 4.7;

                                % No liver or plasma data available, use whole blood value
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                                this.LiverRelaxivity = this.BloodRelaxivity;
                            elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
                                % No 9.4 T data available, use 7 T values
                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 4.7;

                                % No liver or plasma data available, use whole blood value
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                                this.LiverRelaxivity = this.BloodRelaxivity;
                            end
                            % No rodent-specific Gd-BOPTA data is available, so just use the same values as for dog
%                         case 'Rat'
%                             if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
%                             end
%                         case 'Mouse'
%                             if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
%                             end
                        otherwise
                    end
                case {'Gd-DTPA', 'Gadopentetate', 'Magnevist'}
                    switch(species)
                        case 'Human'
                            if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
                                % Pintaske et al, 2006, Invest Radiol
                                this.PlasmaRelaxivity = 3.9;

                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 4.3;

                                % No human liver data available
                                % Shuter et al, 1996, Magn Reson Imaging, "The Relaxivity of Gd-EOB-DTPA and Gd-DTPA in
                                % Liver and Kidney of the Wistar Rat"
                                this.LiverRelaxivity = 3.4;
                            elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
                                % Pintaske et al, 2006, Invest Radiol
                                this.PlasmaRelaxivity = 3.3;

                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 3.8;
                                
                                % No liver data available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 3.8;

                                % no liver or whole blood data available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                                this.BloodRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 3.1;

                                % no liver or plasma data available, use whole blood value
                                this.LiverRelaxivity = this.BloodRelaxivity;
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
                                % No 9.4 T data available, use 8.45 T values
                                % Donahue et al, 1994, Magn Reson Imaging, "Studies of Gd-DTPA Relaxivity and Proton
                                % Exchange Rates in Tissue"
                                this.PlasmaRelaxivity = 3.98;
                                this.BloodRelaxivity = 3.82;

                                % no liver data available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            end
                        case {'Pig', 'Dog', 'Rat', 'Mouse'}
                            if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine value, plasma at 37 C
                                this.PlasmaRelaxivity = 4.1;

                                % Rohrer et al, 2005, Invest Radiol
                                % Canine value, whole blood at 37 C
                                this.BloodRelaxivity = 4.3;

                                % No pig liver data available
                                % Shuter et al, 1996, Magn Reson Imaging, "The Relaxivity of Gd-EOB-DTPA and Gd-DTPA in
                                % Liver and Kidney of the Wistar Rat"
                                this.LiverRelaxivity = 3.4;
                            elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al, 2005, Invest Radiol
                                % Canine value, whole blood at 37 C
                                this.PlasmaRelaxivity = 3.7;

                                % Shen et al, 2015, Invest Radiol
                                % human data
                                this.BloodRelaxivity = 3.8;
                                
                                % No liver data available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 3.8;

                                % no liver or whole blood data available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                                this.BloodRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 3.1;

                                % no liver or plasma data available, use whole blood value
                                this.LiverRelaxivity = this.BloodRelaxivity;
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
                                % No 9.4 T data available, use 8.45 T values
                                % Donahue et al, 1994, Magn Reson Imaging, "Studies of Gd-DTPA Relaxivity and Proton
                                % Exchange Rates in Tissue"
                                this.PlasmaRelaxivity = 3.98;
                                this.BloodRelaxivity = 3.82;

                                % no liver data available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            end
                            % No dog, rat, or mouse-specific data available, use the same values as for pig
%                         case 'Dog'
%                             if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
%                             end
%                         case 'Rat'
%                             if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
%                                 % Shuter et al, 1996, Magn Reson Imaging
%                                 this.LiverRelaxivity = 3.4;
%                             elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
%                             end
%                         case 'Mouse'
%                             if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
%                             end
                        otherwise
                    end
                case {'Gd-BT-DO3A', 'Gadobutrol', 'Gadovist', 'Gadavist'}
                    switch(species)
                        % Wahsner 2018 Chem Rev
                        % Gadobutrol at 37 degrees C at 1.5 T is 5.2 1/s/mM
                        % Gadobutrol at 37 degrees C at 3.0 T is 5.0 1/s/mM
                        % Gadobutrol at 7.0 T is 4.8 1/s/mM
                        % Gadobutrol at 9.4 T is 4.7 1/s/mM
                        % reference #288 in the paper is source of this information: Fries 2015 Invest Radiol

                        case 'Human'
                            if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
                                % Pintaske et al, 2006, Invest Radiol
                                this.PlasmaRelaxivity = 4.7;

                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 4.6;

                                % No liver data available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
                                % Pintaske et al, 2006, Invest Radiol
                                this.PlasmaRelaxivity = 3.6;

                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 4.5;

                                % No liver data available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 4.7;

                                % no liver or whole blood data available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                                this.BloodRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 4.2;

                                % no liver or plasma data available, use whole blood value
                                this.LiverRelaxivity = this.BloodRelaxivity;
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
                                % no 9.4 T data available, use 7 T values
                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 4.2;

                                % no liver or plasma data available, use whole blood value
                                this.LiverRelaxivity = this.BloodRelaxivity;
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            end
                        case {'Pig', 'Dog', 'Rat', 'Mouse'}
                            if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine value, plasma at 37 C
                                this.PlasmaRelaxivity = 5.2;

                                % Rohrer et al, 2005, Invest Radiol
                                % Canine value, whole blood at 37 C
                                this.BloodRelaxivity = 5.3;

                                % No liver data available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine value, plasma at 37 C
                                this.PlasmaRelaxivity = 5.0;

                                % Shen et al, 2015, Invest Radiol
                                % human data
                                this.BloodRelaxivity = 4.5;

                                % No liver data available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
                                % Rohrer et al, 2005, Invest Radiol
                                % Bovine value, plasma at 37 degrees C
                                this.PlasmaRelaxivity = 4.7;

                                % no liver or whole blood data available, use plasma value
                                this.LiverRelaxivity = this.PlasmaRelaxivity;
                                this.BloodRelaxivity = this.PlasmaRelaxivity;
                            elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 4.2;

                                % no liver or plasma data available, use whole blood value
                                this.LiverRelaxivity = this.BloodRelaxivity;
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
                                % no 9.4 T data available, use 7 T values
                                % Shen et al, 2015, Invest Radiol
                                this.BloodRelaxivity = 4.2;

                                % no liver or plasma data available, use whole blood value
                                this.LiverRelaxivity = this.BloodRelaxivity;
                                this.PlasmaRelaxivity = this.BloodRelaxivity;
                            end
                            % no dog, rat, or mouse-specific data available, use the same values as for pig
%                         case 'Dog'
%                             if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
%                             end
%                         case 'Rat'
%                             if(IsWithinToleranceOfValue(1.41, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
%                             end
%                         case 'Mouse'
%                             if(IsWithinToleranceOfValue(1.5, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(3.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(4.7, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(7.0, fieldStrength, fieldStrengthTolerance))
%                             elseif(IsWithinToleranceOfValue(9.4, fieldStrength, fieldStrengthTolerance))
%                             end
                        otherwise
                    end
                case 'Other'
                    % Can't set a default. Do nothing.
                otherwise
                    % The contrast agent isn't one of the ones on our list, so we can't set a default value for the
                    % relaxivity. Do nothing.
            end
        end

        %% GetInSituRelaxivity
        function relaxivity = GetInSituRelaxivity(this, tissueType)
            arguments
                this (1,1) LoadImagesDialogModel
                tissueType (1,1) TissueType
            end
            if (tissueType.IsVessel)
                relaxivity = this.BloodRelaxivity;
                return
            end

            switch tissueType
                case TissueType.Liver
                    relaxivity = this.LiverRelaxivity;
                case TissueType.Spleen
                    relaxivity = this.BloodRelaxivity;
                case TissueType.Kidney
                    relaxivity = this.BloodRelaxivity;
                case TissueType.Muscle
                    relaxivity = this.BloodRelaxivity;
                case TissueType.SpinalCord
                    relaxivity = this.BloodRelaxivity;
                case TissueType.Fat
                    relaxivity = this.BloodRelaxivity;
                otherwise
                    relaxivity = this.BloodRelaxivity;
            end
        end

        %% FilesystemPathChanged
        function changed = FilesystemPathChanged(this, previous)
            arguments
                this LoadImagesDialogModel
                previous LoadImagesDialogModel
            end
            
            changed = false;
            filesystemPath = this.FilesystemPath;
            if(~isempty(filesystemPath) && ~strcmp(filesystemPath, previous.FilesystemPath))
                changed = true;
            end
        end

        %% ImageFileFormatChanged
        function changed = ImageFileFormatChanged(this, previous)
            arguments
                this LoadImagesDialogModel
                previous LoadImagesDialogModel
            end

            changed = false;
            imageFileFormat = this.ImageFileFormat;
            if(~isempty(imageFileFormat) && ~strcmp(imageFileFormat, previous.ImageFileFormat))
                changed = true;
            end
        end

        %% ContrastAgentNameChanged
        function changed = ContrastAgentNameChanged(this, previous)
            arguments
                this LoadImagesDialogModel
                previous LoadImagesDialogModel
            end

            changed = false;
            contrastAgentName = this.ContrastAgentName;
            if(~isempty(contrastAgentName) && ~strcmp(contrastAgentName, previous.ContrastAgentName))
                changed = true;
            end
        end

        % TODO: Figure out if this code is needed or should be removed. It is not currently being called anywhere.
        %% SelectedAgentChanged
        function changed = SelectedAgentChanged(this, previous)
            arguments
                this LoadImagesDialogModel
                previous LoadImagesDialogModel
            end

            changed = false;
            selectedAgent = this.SelectedAgent;
            optionList = this.AgentList;
            agentName = optionList{selectedAgent};
            if(strcmp(agentName, 'Other') && this.Relaxivity ~= previous.Relaxivity)
                changed = true;
            end
        end

        %% B0FieldStrengthChanged
        function changed = B0FieldStrengthChanged(this, previous)
            arguments
                this LoadImagesDialogModel
                previous LoadImagesDialogModel
            end

            changed = false;
            if(this.B0FieldStrength ~= previous.B0FieldStrength)
                changed = true;
            end
        end

        %% SelectedFieldStrengthChanged
        function changed = SelectedFieldStrengthChanged(this, previous)
            arguments
                this LoadImagesDialogModel
                previous LoadImagesDialogModel
            end

            changed = false;
            selectedFieldStrength = this.SelectedFieldStrength;
            optionList = this.FieldStrengthList;
            if(strcmp(optionList{selectedFieldStrength}, 'Other') && ...
                    this.OtherFieldStrength ~= previous.OtherFieldStrength)
                changed = true;
            end
        end

        %% PulseSequenceChanged
        function changed = PulseSequenceChanged(this, previous)
            arguments
                this LoadImagesDialogModel
                previous LoadImagesDialogModel
            end

            changed = false;
            if(~strcmp(this.PulseSequence, previous.PulseSequence))
                changed = true;
            end
        end

        %% AcquisitionIntervalChanged
        function changed = AcquisitionIntervalChanged(this, previous)
            arguments
                this LoadImagesDialogModel
                previous LoadImagesDialogModel
            end

            changed = false;
            if(this.AcquisitionInterval ~= previous.AcquisitionInterval)
                changed = true;
            end
        end

        %% DicomFilesChanged
        function changed = DicomFilesChanged(this, previous)
            arguments
                this LoadImagesDialogModel
                previous LoadImagesDialogModel
            end

            changed = false;
            if(~strcmp(this.DicomFileFolderStructure, previous.DicomFileFolderStructure))
                changed = true;
                return
            end

            if(strcmp(this.DicomFileFolderStructure, 'Ordered'))
                if(~strcmp(this.FilenameFormatString, previous.FilenameFormatString))
                    changed = true;
                    return
                end
                if(this.NumberOfSlices ~= previous.NumberOfSlices)
                    changed = true;
                    return
                end
            end
        end

        %% DicomFormatSelected
        function dicomIsSelected = DicomFormatSelected(this)
            dicomIsSelected = false;
            if(strcmp(this.ImageFileFormat, 'DICOM'))
                dicomIsSelected = true;
            end
        end

        %% AfniFilesChanged
        function changed = AfniFilesChanged(this, previous)
            changed = false;
            if(~strcmp(this.BrikName, previous.BrikName) || this.FlipAngle ~= previous.FlipAngle || ...
                    this.EchoTime ~= previous.EchoTime || this.RepetitionTime ~= previous.RepetitionTime)
                changed = true;
            end
        end

        %% AfniFormatSelected
        function afniIsSelected = AfniFormatSelected(this)
            afniIsSelected = false;
            if(strcmp(this.ImageFileFormat, 'AFNI'))
                afniIsSelected = true;
            end
        end

        %% NiftiFilesChanged
        function changed = NiftiFilesChanged(this, previous)
            changed = false;
            if(~strcmp(this.BrikName, previous.BrikName) || this.FlipAngle ~= previous.FlipAngle || ...
                    this.EchoTime ~= previous.EchoTime || this.RepetitionTime ~= previous.RepetitionTime)
                changed = true;
            end
        end

        %% NiftiFormatSelected
        function niftiIsSelected = NiftiFormatSelected(this)
            niftiIsSelected = false;
            if(strcmp(this.ImageFileFormat, 'NIFTI'))
                niftiIsSelected = true;
            end
        end
        
        %% ImagesToLoadChanged
        function changed = ImagesToLoadChanged(this, previous)
            arguments
                this LoadImagesDialogModel
                previous LoadImagesDialogModel
            end

            changed = false;
            if(isempty(previous) && ~isempty(this))
                changed = true;
                return
            end

            if(this.FilesystemPathChanged(previous) || this.ImageFileFormatChanged(previous) || ...
                    (this.DicomFormatSelected() && this.DicomFilesChanged(previous)) || ...
                    (this.AfniFormatSelected() && this.AfniFilesChanged(previous)) || ...
                    (this.NiftiFormatSelected() && this.NiftiFilesChanged(previous)))
                changed = true;
                return
            end
        end
        
        %% NumberOfSlicesDiffers
        function bool = NumberOfSlicesDiffers(this, previous)
            arguments
                this LoadImagesDialogModel
                previous LoadImagesDialogModel
            end

            if(~isempty(this) && isnumeric(this.NumberOfSlices))
                if(isempty(previous))
                    bool = true;
                    return
                end
                if(isnumeric(previous.NumberOfSlices) && this.NumberOfSlices ~= previous.NumberOfSlices)
                    bool = true;
                    return
                end
            end
            bool = false;
        end

        %% ContrastAgentDiffers
        function bool = ContrastAgentDiffers(this, previous)
            arguments
                this LoadImagesDialogModel
                previous LoadImagesDialogModel
            end

            if(~isempty(this) && ischar(this.ContrastAgentName))
                if(isempty(previous) || ~ischar(previous.ContrastAgentName))
                    bool = true;
                    return
                end
                if(~strcmp(this.ContrastAgentName, previous.ContrastAgentName))
                    bool = true;
                    return
                end
            end
            bool = false;
        end

        %% GetAfniBrikFullFilePath
        function brikFullFilePath = GetAfniBrikFullFilePath(this)
            brikPath = this.FilesystemPath;
            brikFile = this.BrikName;
            brikFullFilePath = fullfile(brikPath, brikFile);
        end

        %% GetNiftiFilePath
        function niftiFilePath = GetNiftiFilePath(this)
            niftiFilePath = this.GetAfniBrikFullFilePath();
        end
    end

    %% Private Methods
    methods (Access = private)
        %% IsReadyToLoadDicomImages
        function ready = IsReadyToLoadDicomImages(this)
            ready = false;
            assert(~isempty(this));
            switch(this.DicomFileFolderStructure)
                case 'Ordered'
                    formatString = this.FilenameFormatString;
                    if(~isempty(formatString))
                        %TODO: add any additional validation
                        %that is needed for the format string
                        ready = true;
                        return
                    end
                case 'Unordered'
                    ready = true;
                    return
                otherwise
                    return
            end
        end

        %% IsReadyToLoadAfniImages
        function ready = IsReadyToLoadAfniImages(this)
            ready = false;
            assert(~isempty(this));
            brikName = this.BrikName;
            if(~isempty(brikName))
                %TODO: add any additional validation that is
                %needed for the BrikName
                ready = true;
                return
            end
        end

        %% IsReadyToLoadNiftiImages
        function ready = IsReadyToLoadNiftiImages(this)
            ready = false;
            assert(~isempty(this));
            brikName = this.BrikName;
            if(~isempty(brikName))
                ready = true;
                return
            end
        end
    end
    
    %% Static Methods
    methods(Static)
    end
end