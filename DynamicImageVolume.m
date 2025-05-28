classdef (Abstract) DynamicImageVolume < handle & matlab.mixin.Heterogeneous
    % DynamicImageVolume    Abstract base class for dynamic image volumes. Subclass this for each imaging modality. 
    %                       Stores image data and provides associated functionality
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette

    %% Properties

    %% Abstract observable properties (listeners receive notification of changes
    properties (Abstract, SetObservable = true, AbortSet = true)
        Model
    end

    %% Abstract dependent properties
    properties (Abstract, SetObservable = true, AbortSet = true, Dependent = true)
    end

    properties (Abstract, SetObservable = true)
    end

    %% Abstract read-only, observable properties
    properties (Abstract, SetObservable = true, SetAccess = protected)
        BitDepth
    end

    %% Concrete read-only, observable properties
    properties (SetObservable = true, SetAccess = protected)
        ImageDataInitialized(1,1) logical
        ImageStack
    end

    %% Computable dependent properties
    properties (Dependent = true, SetAccess = protected)
        Time
        Rows
        Columns
        NumberOfSlices
        NumberOfTimePoints
        TotalNumberOfImages
    end

    %% Protected properties
    properties (Access = protected)
        ImageData
    end

    %% Events
    events
    end
    
    %% Public, abstract methods (must be implemented by subclasses)
    methods (Abstract, Access = public)
        C_t = GetTotalConcentrationFromSignal(this, meanSI, tissueType, varargin)
    end

    %% Protected, abstract methods (must be implemented by subclasses)
    methods (Abstract, Access = protected)
        InitializeImageVolume(this, fileFormat, metadata, dataOptions)

        success = LoadDicomImageDataSet(this, dataOptions)
    end

    %% Public, concrete methods
    methods
        %% Constructors
        function this = DynamicImageVolume(model)
            if (nargin > 0)
                this.Model = model;
                this.ImageDataInitialized = false;
                this.ImageData = zeros(256, 256, 1, 3);
                this.ImageStack = zeros(256, 256, 3);
            else
                this.Model = [];
                this.ImageDataInitialized = false;
                this.ImageData = zeros(256, 256, 1, 3);
                this.ImageStack = zeros(256, 256, 3);
            end
        end

        %% Getters for Computable Properties
        function time = get.Time(this)
            assert(this.ImageDataInitialized, 'LiverDCE:DynamicImageVolume:ImageDataNotInitialized', ...
                ['Could not get Time property because ', 'DynamicImageVolume''s ImageData not initialized'])
            numberOfTimePoints = this.NumberOfTimePoints;
            acquisitionInterval = this.Model.LoadImageDataOptions.AcquisitionInterval;
            acquisitionZero = double(this.Model.AcquisitionZero);
            time = ((1:numberOfTimePoints) - repmat(acquisitionZero, 1, numberOfTimePoints)) .* (acquisitionInterval);
        end

        function number = get.Rows(this)
            number = size(this.ImageData, 1);
        end

        function number = get.Columns(this)
            number = size(this.ImageData, 2);
        end

        function number = get.NumberOfSlices(this)
            number = size(this.ImageData, 3);
        end

        function number = get.NumberOfTimePoints(this)
            number = size(this.ImageData, 4);
        end

        function number = get.TotalNumberOfImages(this)
            number = this.NumberOfSlices .* this.NumberOfTimePoints;
        end

        %% Getters and Setters
        function imageData = get.ImageData(this)
            if (this.ImageDataInitialized)
                imageData = this.ImageData;
            else
                imageData = [];
            end
        end
        
        function imageStack = get.ImageStack(this)
            imageStack = this.ImageStack;
        end

        %% Public methods

        %% GetIntensityProjection
        function projectionImage = GetIntensityProjection(this, typeOfProjection)
            memoizeFcn = memoize(@NonMemoizedGetIntensityProjection);
            projectionImage = memoizeFcn(this, typeOfProjection);
        end

        %% GetDynamicImageStack
        function dynamicImage = GetDynamicImageStack(this)
            memoizeFcn = memoize(@NonMemoizedGetDynamicImageStack);
            dynamicImage = memoizeFcn(this, this.Model.SelectedSliceLocation);
        end

        %% GetSignalFrom2DRegion
        function [mu, sigma] = GetSignalFrom2DRegion(this, roi, varargin)
            signal = this.GetUnaggregatedSignalFrom2DRegion(roi, varargin{:});

            mu = mean(signal);
            sigma = std(signal);
        end

        %% GetUnaggregatedSignalFrom2DRegion
        function signal = GetUnaggregatedSignalFrom2DRegion(this, roi, varargin)
            switch(nargin)
                case 2
                    applyDriftCorrection = true;
                case 3
                    applyDriftCorrection = varargin{1};
                otherwise
                    error('Incorrect number of arguments for DynamicImageVolume.GetSignalFrom2DRegion');
            end

            if(applyDriftCorrection && this.Model.DriftCorrectionOptionsInitialized)
                correctionSlope = this.Model.DriftCorrectionOptions.CorrectionSlope;
            else
                correctionSlope = 0.0;
            end

            if (this.Model.IsProjectionImageTypeSelected)
                dynamicImageStack = this.GetDynamicImageStack();
            else
                dynamicImageStack = this.ImageStack;
            end
            numTimePoints = this.NumberOfTimePoints;
            
            mask = roi.Mask;
            temporalRoiMask = repmat(mask, 1, 1, numTimePoints);
            rawSignal = reshape(dynamicImageStack(temporalRoiMask), [], numTimePoints);
            signal = rawSignal - correctionSlope.*this.Time;
        end

        %% GetSignalFrom3DRegion
        function [mu, sigma, voxelWiseData, voxelCoordinates] = GetSignalFrom3DRegion(this, roi)
            % mask is expected to be 3D (rows, columns, time index)
            % to convert a 2D mask into a 3D one:
            % mask3D = zeros([size(mask2D), this.NumberOfSlices]);
            % mask3D(:,:,this.Model.SelectedSliceLocation) = mask2D;
            mask = roi.Mask;
            if(~this.ImageDataInitialized)
                mu = [];
                sigma = [];
                voxelWiseData = [];
                voxelCoordinates = [];
                return
            end
            imgdata = this.ImageData;
            numTimePoints = this.NumberOfTimePoints;
            temporalRoiMask = logical(repmat(mask, 1, 1, 1, numTimePoints));
            maskedImg = reshape(imgdata(temporalRoiMask), [], numTimePoints);
            mu = mean(maskedImg);
            sigma = std(maskedImg);
            voxelWiseData = maskedImg;
            voxelCoordinates = RoiVoxelCoordinates.GetAsFlatList(mask);
        end

        %% GetBaselineFromSignal
        function baseline = GetBaselineFromSignal(this, meanSI)
            acqZero = double(this.Model.AcquisitionZero);
            baseline = DynamicImageVolume.GetBaseline(this.Model.UseBaselineAveraging, meanSI, acqZero);
        end

        %% GetAucTimeSeriesFromConcentrationSignal
        function AUC = GetAucTimeSeriesFromConcentrationSignal(this, acqZero, C_t)
            % Computes area under the curve (AUC) as a function of time
            numTimePoints = this.NumberOfTimePoints;
            time = this.Time;
            
            % Start from acqZero+1 to avoid the degenerate case of integrating over an empty interval
            AUC = zeros(size(C_t));
            acqZero = double(acqZero);
            for t = (acqZero+1):numTimePoints
                AUC(t) = trapz(time(acqZero:t), C_t(acqZero:t));
            end
        end

        %% GetAucTimeSeriesFromSignal
        function AUC = GetAucTimeSeriesFromSignal(this, meanSI, tissueType, acqZero)
            C_t = this.GetTotalConcentrationFromSignal(meanSI, tissueType);
            AUC = this.GetAucTimeSeriesFromConcentrationSignal(acqZero, C_t);
        end

        %% GetRoiModelAucTotal
        function [AUC, arrivalTime] = GetRoiModelAucTotal(this, meanSI, tissueType, fitModel, arriveTimeMethod)
            arguments
                this (1,1) DynamicImageVolume
                meanSI {mustBeNumeric}
                tissueType (1,1) TissueType
                fitModel {mustBeTextScalar}
                arriveTimeMethod {mustBeTextScalar} 
            end
            assert(this.Model.LoadImageDataOptionsInitialized, ...
                'LiverDCE:MainModel:LoadImageDataOptionsNotInitialized', ...
                ['Could not get Time property because ', 'LoadImageDataOptions not initialized']);
            % Computes total area under the curve (AUC) using a
            % biexponential model for the concentration curve
            time = this.Time;
            C_t = this.GetTotalConcentrationFromSignal(meanSI, tissueType);
            [fitresult, gof, arrivalTime] = GetModelFitForVeEstimation(time, C_t, fitModel, arriveTimeMethod, ...
                tissueType, this.Model.LoadImageDataOptions.AcquisitionInterval); %#ok<ASGLU> 
            
            switch fitModel
                case 'Monoexponential'
                    a1 = fitresult.a1;
                    m1 = fitresult.m1;
                    
                    % % Definite integral from 0 to t = time(end)
                    % AUC = a1/m1*(1-exp(-m1*t);
                    
                    % Limit as t->Inf
                    AUC = a1/m1;
                case 'Biexponential'
                    a1 = fitresult.a1;
                    a2 = fitresult.a2;
                    m1 = fitresult.m1;
                    m2 = fitresult.m2;
                    
                    % % Definite integral from 0 to t = time(end)
                    % AUC = a1/m1*(1-exp(-m1*t))+a2/m2*(1-exp(-m2*t));
                    
                    % Limit as t->Inf
                    AUC = a1/m1+a2/m2;
                otherwise
                    error('Unrecognized fit model');
            end
        end

        %% GetAucTotalFromSignal
        function AUC = GetAucTotalFromSignal(this, meanSI, tissueType, acqZero)
            % Computes total area under the curve (AUC)
            numTimePoints = this.NumberOfTimePoints;
            time = this.Time;
            C_t = this.GetTotalConcentrationFromSignal(meanSI, tissueType);
            
            AUC = trapz(time(acqZero:numTimePoints), C_t(acqZero:numTimePoints));
        end

        %% LoadImageDataSet
        function success = LoadImageDataSet(this, dataOptions)
            imageFileFormat = dataOptions.ImageFileFormat;
            success = false;
            switch(imageFileFormat)
                case 'DICOM'
                    success = this.LoadDicomImageDataSet(dataOptions);
                case 'AFNI'
                    success = this.LoadAfniImageDataSet(dataOptions);
                case 'NIFTI'
                    success = this.LoadNiftiImageDataSet(dataOptions);
                otherwise
                    return
            end
        end

        %% GetMaximumSliceIndex
        function maxValue = GetMaximumSliceIndex(this)
            maxValue = 1;
            if (this.ImageDataInitialized)
                maxValue = this.NumberOfSlices;
            else
                % No images loaded yet, so restrict the value to the max set by the user-supplied number
                if (~isempty(this.Model) && this.Model.LoadImageDataOptionsInitialized)
                    % Conversion to double was added for consistency, so that the datatype returned is always the
                    % same. Could have gone the other way and typecast this.NumberOfSlices in the block above to
                    % uint16, but double is better supported within the MATLAB ecosystem even though an integer type
                    % is more specific.
                    maxValue = double(this.Model.LoadImageDataOptions.NumberOfSlices);
                end
            end
        end

        %% GetMaximumPixelValueForImageStack
        function value = GetMaximumPixelValueForImageStack(this)
            value = max(reshape(this.ImageStack, 1, []));
        end

        %% GetMaximumPixelValueForDynamicSeries
        function value = GetMaximumPixelValueForDynamicSeries(this)
            value = max(reshape(this.ImageData, 1, []));
        end

        %% GetMinimumPixelValueForImageStack
        function value = GetMinimumPixelValueForImageStack(this)
            value = min(reshape(this.ImageStack, 1, []));
        end

        %% GetMinimumPixelValueForDynamicSeries
        function value = GetMinimumPixelValueForDynamicSeries(this)
            value = min(reshape(this.ImageData, 1, []));
        end

        %% GetMaxFilterWindowSize
        function maxValue = GetMaxFilterWindowSize(this)
            maxValue = 10;
            if (this.ImageDataInitialized)
                maxValue = this.NumberOfTimePoints - 1;
            end
        end

        %% UpdateImageStack
        function UpdateImageStack(this)
            if (this.ImageDataInitialized)
                if (this.Model.IsProjectionImageTypeSelected)
                    projection = this.GetIntensityProjection(this.Model.SelectedImageTypeToDisplay);
                    this.ImageStack = projection(:,:,this.Model.SelectedSliceLocation);
                else
                    this.ImageStack = this.GetDynamicImageStack();
                end
                notify(this.Model, 'ImageLoad');
            end
        end
    end

    %% Protected methods
    methods (Access = protected)
        %% LoadAfniImageDataSet
        function success = LoadAfniImageDataSet(this, dataOptions)
            brikFullFilePath = dataOptions.GetAfniBrikFullFilePath();
            disp(['Loading images from ', brikFullFilePath]);

            % This conditional was added for testing the code with the large pig and dog data sets that can trigger
            % a crash of the MATLAB environment due to an unhandled memory allocation exception. I have not encountered
            % this type of crash since upgrading to a new computer with 64 GB of RAM.
            loadPartialDataSet = false;
            [success, volumeImage, metadata] = DynamicImageVolume.LoadBrikFile(brikFullFilePath, ...
                loadPartialDataSet);
            if(~success)
                disp('Failed to load images');
                return
            end
            this.InitializeImageVolume('AFNI', volumeImage, metadata, dataOptions);
            disp('Finished loading images');
        end

        %% LoadNiftiImageDataSet
        function success = LoadNiftiImageDataSet(this, dataOptions)
            niftiFilePath = dataOptions.GetNiftiFilePath();
            disp(['Loading images from ', niftiFilePath]);

            [success, volumeImage, metadata] = DynamicImageVolume.LoadNiftiFile(niftiFilePath);
            if(~success)
                disp('Failed to load images');
                return
            end
            this.InitializeImageVolume('NIFTI', volumeImage, metadata, dataOptions);
            disp('Finished loading images');
        end

        %% NonMemoizedGetIntensityProjection
        function projectionImage = NonMemoizedGetIntensityProjection(this, typeOfProjection)
            assert(this.ImageDataInitialized);
            switch(typeOfProjection)
                case ImageType.MaximumIntensityProjection
                    projectionImage = max(this.ImageData, [], 4);
                case ImageType.MinimumIntensityProjection
                    projectionImage = min(this.ImageData, [], 4);
                case ImageType.MeanIntensityProjection
                    projectionImage = mean(this.ImageData, 4);
                case ImageType.StandardDeviationIntensityProjection
                    projectionImage = std(this.ImageData, 0, 4);
                case ImageType.MedianIntensityProjection
                    projectionImage = median(this.ImageData, 4);
                case ImageType.InterquartileRangeIntensityProjection
                    projectionImage = iqr(this.ImageData, 4);
                otherwise
                    error('The specified intensity projection type is invalid.');
            end
        end

        %% NonMemoizedGetDynamicImageStack
        function dynamicImage = NonMemoizedGetDynamicImageStack(this, selectedSliceLocation)
            dynamicImage = squeeze(this.ImageData(:,:,selectedSliceLocation,:));
        end
    end

    %% Protected static methods
    methods (Static, Access = protected)
        %% LoadBrikFile
        function [success, volumeImage, info] = LoadBrikFile(brikFullFilePath, loadPartialDataSet)
            success = false;
            if(loadPartialDataSet)
                opt.Frames = 1:400;
            end
            try
                if(loadPartialDataSet)
                    [err, volumeImage, info, ~] = BrikLoad(brikFullFilePath, opt);
                else
                    [err, volumeImage, info, ~] = BrikLoad(brikFullFilePath);
                end
            catch ex
                DynamicImageVolume.HandleExceptionOnLoadingBrikFile(ex);
                return
            end
            if(err)
                return
            end
            success = true;
        end

        %% LoadNiftiFile
        function [success, volumeImage, info] = LoadNiftiFile(niftiFilePath)
            success = false;
            try
                % look for an uncompressed version
                niftiFullFilePath = [niftiFilePath, '.nii'];
                if(exist(niftiFullFilePath, 'file'))
                    volumeImage = double(niftiread(niftiFullFilePath));
                    info = niftiinfo(niftiFullFilePath);
                    success = true;
                    return
                end

                % look for a compressed version
                niftiFullFilePath = [niftiFilePath, '.nii.gz'];
                if(exist(niftiFullFilePath, 'file'))
                    volumeImage = double(niftiread(niftiFullFilePath));
                    info = niftiinfo(niftiFullFilePath);
                    success = true;
                    return
                end
            catch ex
                DynamicImageVolume.HandleExceptionOnLoadingNiftiFile(ex);
                return
            end
        end

        %% HandleExceptionOnLoadingBrikFile
        function HandleExceptionOnLoadingBrikFile(exception)
            disp('Failed to load images');
            if(strcmp(exception.identifier, 'MATLAB:unassignedOutputs'))
                disp('File Not Found');
                return
            elseif(strcmp(exception.identifier, 'MATLAB:badSwitchExpression'))
                disp('Invalid HEAD file');
                return
            elseif(strcmp(exception.identifier, 'MATLAB:getReshapeDims:notSameNumel'))
                disp('Invalid BRIK file');
                return
            else
                rethrow(exception);
            end
        end

        %% HandleExceptionOnLoadingNiftiFile
        function HandleExceptionOnLoadingNiftiFile(exception)
            disp('Failed to load images');
            if(strcmp(exception.identifier, 'images:nifti:filenameDoesNotExist'))
                disp('An error to be handled');
                return
            else
                rethrow(exception);
            end
        end

        %% HandleExceptionOnReadingDicomHeader
        function HandleExceptionOnReadingDicomHeader(exception)
            disp('Failed to load images');

            % extract last segment of exception identifier
            idSegLast = regexp(exception.identifier, '(?<=:)\w+$', 'match');

            if (strcmp(idSegLast, 'noFileOrMessagesFound'))
                disp('No File Or Messages Found');
                return;
            elseif (strcmp(idSegLast, 'fileNotFound'))
                disp('File Not Found');
                return;
            else
                rethrow(exception);
            end
        end
    end

    %% Public static methods
    methods (Static, Access = public)
        %% GetBaseline
        function baseline = GetBaseline(useBaselineAveraging, meanSI, acqZero)
            arguments
                useBaselineAveraging (1,1) logical
                meanSI (1,:) {mustBeNumeric}
                acqZero (1,1) {mustBeInteger}
            end

            numTimePoints = size(meanSI, 2);
            if(useBaselineAveraging)
                baseValue = mean(meanSI(1:acqZero));
            else
                baseValue = meanSI(acqZero);
            end
            baseline = repmat(baseValue, 1, numTimePoints);
        end

        %% ResetIntensityProjectionImageCache
        function ResetIntensityProjectionImageCache()
            memoizeFcn = memoize(@NonMemoizedGetIntensityProjection);
            memoizeFcn.CacheSize = 7;
            clearCache(memoizeFcn);
        end

        %% ResetDynamicImageStackCache
        function ResetDynamicImageStackCache()
            memoizeFcn = memoize(@NonMemoizedGetDynamicImageStack);
            memoizeFcn.CacheSize = 10;
            clearCache(memoizeFcn);
        end
    end
end