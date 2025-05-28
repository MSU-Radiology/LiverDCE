classdef DynamicMrImageVolume < DynamicImageVolume
    % DynamicMrImageVolume    Stores dynamic MR image data and provides associated functionality
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette

    %% Properties
    
    % Observable Properties (listeners receive notification of changes)
    properties (SetObservable = true, AbortSet = true)
        Model
    end

    % Dependent properties
    properties (SetObservable = true, AbortSet = true, Dependent = true)
    end

    properties (SetObservable = true)
    end
    
    % Read-only, observable properties
    properties (SetObservable = true, SetAccess = protected)
        BitDepth
        theta(1,1) double
        TR(1,1) double
        TE(1,1) double
    end

    % Computable Dependent Properties
    properties (Dependent = true, SetAccess = protected)
    end

    % Private Properties
    properties (Access = protected)
    end
    
    %% Events
    events
    end

    %% Public Class Methods
    methods
        %% Constructors
        function this = DynamicMrImageVolume(varargin)
            this@DynamicImageVolume(varargin{:});
        end

        %% Getters for Computable Properties

        %% Getters and Setters

        function bitDepth = get.BitDepth(this)
            bitDepth = this.BitDepth;
        end

        function theta = get.theta(this)
            theta = this.theta;
        end

        function TR = get.TR(this)
            TR = this.TR;
        end

        function TE = get.TE(this)
            TE = this.TE;
        end

        %% Other Class Methods

        %% ComputeSpleenSignals
        function [mask, roiSignalMu, roiSignalSigma, R1, C_ES, C_t, AucTimeSeries] = ComputeSpleenSignals(this, roi)
            tissueType = TissueType.Spleen;
            [mask, roiSignalMu, roiSignalSigma, R1, C_t, AucTimeSeries] = ComputeOrganSignals(this, roi, tissueType);
            C_ES = this.GetESConcentrationFromMrSignal(roiSignalMu, tissueType);
        end

        %% ComputeLiverSignals
        function [mask, roiSignalMu, roiSignalSigma, R1, C_i, C_t, AucTimeSeries] = ...
                ComputeLiverSignals(this, roi, C_ES)
            tissueType = TissueType.Liver;
            [mask, roiSignalMu, roiSignalSigma, R1, C_t, AucTimeSeries] = ComputeOrganSignals(this, roi, tissueType);
            C_i = this.GetIntracellularConcentrationFromMrSignal(roiSignalMu, tissueType, C_ES);
        end

        %% GetR1FromMrSignal
        function R1 = GetR1FromMrSignal(this, meanSI, R1_0)
            assert(~isempty(this) && this.ImageDataInitialized);
            baseline = this.GetBaselineFromSignal(meanSI);
            R1 = DynamicMrImageVolume.GetR1(baseline, meanSI, this.Model.LoadImageDataOptions.PulseSequence, ...
                R1_0, this.TR, this.TE, this.theta);
        end

        %% GetTotalConcentrationFromSignal
        function C_t = GetTotalConcentrationFromSignal(this, meanSI, tissueType)
            R1_0 = this.Model.GetPreContrastR1(tissueType);
            R1 = this.GetR1FromMrSignal(meanSI, R1_0);
            relaxivity = this.Model.LoadImageDataOptions.GetInSituRelaxivity(tissueType);
            C_t = (R1 - R1_0)./relaxivity;
        end

        %% GetIntracellularConcentrationFromMrSignal
        function C_i = GetIntracellularConcentrationFromMrSignal(this, meanSI, tissueType, C_ES)
            if (this.Model.LoadImageDataOptions.IsHepatobiliaryContrastAgent())
                switch tissueType
                    case TissueType.Liver
                        liverC_t = this.GetTotalConcentrationFromSignal(meanSI, tissueType);
                        liverVolumeFractionES = this.Model.LiverVolumeFractionES;
                        C_i = (liverC_t-liverVolumeFractionES.*C_ES) ./ (1-liverVolumeFractionES);
                    otherwise
                        C_i = zeros(size(this.Time));
                end
            else
                C_i = zeros(size(this.Time));
            end
        end

        %% GetESConcentrationFromMrSignal
        function C_ES = GetESConcentrationFromMrSignal(this, meanSI, tissueType)
            arguments
                this (1,1) DynamicMrImageVolume
                meanSI {mustBeNumeric}
                tissueType TissueType
            end
            assert(this.Model.LoadImageDataOptionsInitialized, ...
                'LiverDCE:MainModel:LoadImageDataOptionsNotInitialized', ...
                ['Could not get Time property because ', 'LoadImageDataOptions not initialized']);

            tissueR1_0 = this.Model.GetPreContrastR1(tissueType);
            R1Signal = this.GetR1FromMrSignal(meanSI, tissueR1_0);
            volumeFractionES = this.Model.GetVolumeFractionES(tissueType);

            relaxivity = this.Model.LoadImageDataOptions.GetInSituRelaxivity(tissueType);
            C_ES = DynamicMrImageVolume.ComputeESConcentration(R1Signal, tissueR1_0, relaxivity, volumeFractionES);
        end
    end

    %% Protected Methods
    methods (Access = protected)
        %% InitializeImageVolume
        function InitializeImageVolume(this, fileFormat, volumeImage, metadata, dataOptions)
            switch fileFormat
                case {'AFNI', 'NIFTI'}
                    reorientedVolumeImage = DynamicMrImageVolume.ReorientBrikVolumeImage(volumeImage);
                    this.ImageData = reorientedVolumeImage;
                    volumeDimensions = size(reorientedVolumeImage);
                    dataOptions.NumberOfSlices = volumeDimensions(3);
                    switch fileFormat
                        case 'AFNI'
                            this.BitDepth = DynamicMrImageVolume.GetBrikBitDepth(metadata);
                        case 'NIFTI'
                            this.BitDepth = DynamicMrImageVolume.GetNiftiBitDepth(metadata);
                        otherwise
                    end
                case 'DICOM'
                    this.ImageData = volumeImage;
                    this.BitDepth = uint8(metadata.BitsAllocated);
                otherwise
            end
            DynamicImageVolume.ResetIntensityProjectionImageCache();
            DynamicImageVolume.ResetDynamicImageStackCache();

            assert(this.BitDepth == 16);   % Other bit depths are not supported at this time

            this.TR = dataOptions.RepetitionTime ./ 1000.0;
            this.TE = dataOptions.EchoTime ./ 1000.0;
            FA = dataOptions.FlipAngle;
            this.theta = FA .* pi ./ 180.0;
            this.ImageDataInitialized = true;
        end

        %% LoadDicomImageDataSet
        function success = LoadDicomImageDataSet(this, dataOptions)
            success = false;
            path = dataOptions.FilesystemPath;
            formatString = dataOptions.FilenameFormatString;
            try
                % Use the first image for the DICOM header information
                imageHeader = dicominfo(fullfile(path, sprintf(formatString, 1)));
            catch ex
                DynamicImageVolume.HandleExceptionOnReadingDicomHeader(ex);
                return
            end

            sopClassUid = imageHeader.SOPClassUID;
            if (strcmp(sopClassUid, '1.2.840.10008.5.1.4.1.1.4'))
                success = this.LoadMrDicomImageDataSetUsingSingleFrameSopClass(dataOptions, imageHeader);
            elseif (strcmp(sopClassUid, '1.2.840.10008.5.1.4.1.1.4.1'))
                disp('Multi-frame Enhanced MR SOP Class');
                disp('Image type is not yet supported in this software');
            else
                disp('Cannot load the images: Unrecognized SOP Class');
            end
        end

        %% LoadMrDicomImageDataSetUsingSingleFrameSopClass
        function success = LoadMrDicomImageDataSetUsingSingleFrameSopClass(this, dataOptions, imageHeader)
            disp('Single-frame MR SOP Class');

            acquisitionType = imageHeader.MRAcquisitionType;
            sequenceName = imageHeader.SequenceName;
            protocolName = imageHeader.ProtocolName;

            numberOfAcquisitions = uint16(imageHeader.ImagesInAcquisition);
            numberOfSlices = dataOptions.NumberOfSlices;

            if (strcmp(acquisitionType, '3D') && strcmp(sequenceName, 'Bruker:IgFLASH') && ...
                    strcmp(protocolName, 'IgFLASH'))
                disp('3D FLASH pulse sequence');
                % Interpret ImagesInAcquisition as the number of times the 3D volume was acquired
                numberOfTimePoints = numberOfAcquisitions;
            elseif (strcmp(acquisitionType, '2D') && strcmp(sequenceName, 'Bruker:IgFLASH') && ...
                    strcmp(protocolName, 'T1_IG_FLASH'))
                disp('2D FLASH pulse sequence');
                % Interpret ImagesInAcquisition as the total number of images acquired overall over all slice
                % locations and acquisition times
                numberOfTimePoints = idivide(numberOfAcquisitions, numberOfSlices);
            else
                % Default processing behavior (same as for 2D IntraGate FLASH acquisition)
                disp('Pulse sequence unknown; assuming 2D acquisition');
                numberOfTimePoints = idivide(numberOfAcquisitions, numberOfSlices);
            end

            repetitionTime = imageHeader.RepetitionTime;   % repetition time in ms
            dataOptions.RepetitionTime = repetitionTime;

            echoTime = imageHeader.EchoTime;   % echo time in ms
            dataOptions.EchoTime = echoTime;

            FA = imageHeader.FlipAngle;    % flip angle in degrees
            dataOptions.FlipAngle = FA;

            volumeImage = DynamicMrImageVolume.LoadSingleFrameDicomFiles(dataOptions, imageHeader, ...
                numberOfTimePoints);
            this.InitializeImageVolume('DICOM', volumeImage, imageHeader, dataOptions);
            success = true;
        end

        %% ComputeOrganSignals
        function [mask, roiSignalMu, roiSignalSigma, R1, C_t, AucTimeSeries] = ComputeOrganSignals(this, roi, ...
                tissueType)
            mask = roi.Mask;
            if (this.Model.IsSelectedRoiDimensionality3D())
                [unfilteredRoiSignalMu, roiSignalSigma, ~, ~] = this.GetSignalFrom3DRegion(roi);
            else
                [unfilteredRoiSignalMu, roiSignalSigma] = this.GetSignalFrom2DRegion(roi);
            end
            roiSignalMu = this.Model.ApplyFiltersToSignal(unfilteredRoiSignalMu);
            R1_0 = this.Model.GetPreContrastR1(tissueType);
            R1 = this.GetR1FromMrSignal(roiSignalMu, R1_0);
            C_t = this.GetTotalConcentrationFromSignal(roiSignalMu, tissueType);
            acqZero = this.Model.AcquisitionZero;
            AucTimeSeries = this.GetAucTimeSeriesFromConcentrationSignal(acqZero, C_t);
        end
    end

    %% Public Static Methods
    methods (Static)
        %% GetR1
        function R1 = GetR1(baseline, meanSI, pulseSequence, R1_0, TR, TE, theta)
            normalizedSI = meanSI./baseline;
            switch pulseSequence
                case 'FLASH'
                    R1 = DynamicMrImageVolume.GetR1FromFlashSignal(R1_0, normalizedSI, TR, theta);
                case 'RARE'
                    R1 = DynamicMrImageVolume.GetR1FromRareSignal(R1_0, normalizedSI, TR, TE);
                otherwise
                    error('Unknown pulse sequence');
            end
        end

        %% GetR1FromFlashSignal
        function R1 = GetR1FromFlashSignal(R1_0, relativeSI, TR, theta)
            e10 = exp(-TR .* R1_0);
            b = (1 - e10) ./ (1 - cos(theta) .* e10);
            a = b .* relativeSI;
            c = (1 - a) ./ (1 - cos(theta) .* a);
            c(sign(c)<0) = NaN;    % instead of allowing complex values in noisy data, set nonsense data points to NaN
            R1 = -log(c) ./ TR;
        end

        %% GetR1FromRareSignal
        function R1 = GetR1FromRareSignal(R1_0, relativeSI, TR, TE)
            x = 1 - 2 .* exp(-(TR - TE ./ 2) .* R1_0) + exp(-TR .* R1_0);

            R1 = zeros(size(relativeSI));
            syms R1_t
            assume(R1_t, 'real');
            numTimePoints = size(relativeSI, 2);
            for idx = 1:numTimePoints
                eqn = relativeSI(idx) .* x == 1 - 2 .* exp(-(TR - TE ./ 2) .* R1_t) + exp(-TR .* R1_t);
                R1(idx) = vpasolve(eqn, R1_t);
            end
        end

        %% ComputeESConcentration
        function C_ES = ComputeESConcentration(R1, R1_0, relaxivity, volumeFractionES)
            C_ES = (R1 - R1_0)./(relaxivity.*volumeFractionES);
        end
    end

    %% Private Static Methods
    methods (Static, Access=private)
        %% ReorientBrikVolumeImage
        function reorientedVolumeImage = ReorientBrikVolumeImage(volumeImage)
            % The volumes Jie created in AFNI show up oriented incorrectly unless they are flipped around
            reorientedVolumeImage = flip(flipud(permute(volumeImage, [2 1 3 4])), 3);
            % The above is equivalent to:
            % rot90(flip(volumeImage, 3));
            % but ~10 times faster
        end

        %% GetBrikBitDepth
        function bitDepth = GetBrikBitDepth(metadata)
            % TODO: figure out how to read this from the HEAD or BRIK file
            switch (metadata.TypeBytes)
                case 1
                    bitDepth = uint8(8);
                case 2
                    bitDepth = uint8(16);
                case 3
                    bitDepth = uint8(24);
                case 4
                    bitDepth = uint8(32);
                otherwise
                    error('Unsupported bit depth');
            end
        end

        %% GetNiftiBitDepth
        function bitDepth = GetNiftiBitDepth(metadata)
            bitDepth = uint8(metadata.BitsPerPixel);
        end

        %% LoadSingleFrameDicomFiles
        function volumeImage = LoadSingleFrameDicomFiles(dataOptions, imageHeader, numberOfTimePoints)
            path = dataOptions.FilesystemPath;
            formatString = dataOptions.FilenameFormatString;
            numberOfSlices = dataOptions.NumberOfSlices;

            rows = uint16(imageHeader.Rows);
            columns = uint16(imageHeader.Columns);
            volumeImage = zeros(rows, columns, numberOfSlices, numberOfTimePoints, 'double');
            for timeIndex = 1:numberOfTimePoints
                for sliceIndex = 1:numberOfSlices
                    filename = sprintf(formatString, (timeIndex-1)*numberOfSlices+sliceIndex);
                    disp(filename);
                    volumeImage(:,:,sliceIndex,timeIndex) = dicomread(fullfile(path,filename));
                end
            end
        end
    end
end