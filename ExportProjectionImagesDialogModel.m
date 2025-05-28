classdef ExportProjectionImagesDialogModel < handle
    % ExportProjectionImagesDialogModel     Model class (MVC pattern) for the ExportProjectionImagesDialog GUI
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    %% Properties
    
    % Observable Properties (listeners receive notification of changes)
    properties (SetObservable = true, AbortSet = true)
        Path
        FilenamePrefix
        Digits(1,1) uint8
        ImageFormatName
        SavedScreenPosition
        Cancelled(1,1) logical
    end
    
    % Private Properties
    properties (Access = private)
    end
    
    % Computable Dependent Properties
    properties (Dependent = true, SetAccess = private)
        ImageFormat
    end
    
    %% Events
    events
    end
    
    %% Class Methods
    methods
        %% Constructors
        function this = ExportProjectionImagesDialogModel(varargin)
            switch nargin
                case 0
                    this.Path = '';
                    this.FilenamePrefix = 'projection';
                    this.Digits = 2;
                    this.ImageFormatName = 'TIFF';
                    this.SavedScreenPosition = double.empty;
                case 1
                    selectedImageType = varargin{1};
                    this.Path = '';
                    this.FilenamePrefix = selectedImageType.ToFilenamePrefix();
                    this.Digits = 2;
                    this.ImageFormatName = 'TIFF';
                    this.SavedScreenPosition = double.empty;
                case 2
                    selectedImageType = varargin{1};
                    m = varargin{2};
                    this.Path = m.Path;
                    this.FilenamePrefix = selectedImageType.ToFilenamePrefix();
                    this.Digits = m.Digits;
                    this.ImageFormatName = m.ImageFormatName;
                    this.SavedScreenPosition = m.SavedScreenPosition;
                otherwise
                    error('KineticsPickerModel received too many arguments');
            end
        end
        
        %% Getters for Computable Dependent Properties        
        function imageFormat = get.ImageFormat(this)
            switch this.ImageFormatName
                case 'BMP'
                    imageFormat = 'bmp';
                case 'PNG'
                    imageFormat = 'png';
                case 'TIFF'
                    imageFormat = 'tif';
                case 'JPEG'
                    imageFormat = 'jpg';
                case 'PBM'
                    imageFormat = 'pbm';
                case 'PGM'
                    imageFormat = 'pgm';
                case 'PNM'
                    imageFormat = 'pnm';
                case 'HDF'
                    imageFormat = 'hdf';
                case 'NIfTI'
                    imageFormat = 'nii';
                otherwise
                    error('Unknown Optimizer');
            end
        end

        %% Getters and Setters
        function position = get.SavedScreenPosition(this)
            position = this.SavedScreenPosition;
        end
        
        function set.SavedScreenPosition(this, value)
            this.SavedScreenPosition = value;
        end
        
        function path = get.Path(this)
            path = this.Path;
        end
        
        function set.Path(this, path)
            this.Path = path;
        end
        
        function filenamePrefix = get.FilenamePrefix(this)
            filenamePrefix = this.FilenamePrefix;
        end
        
        function set.FilenamePrefix(this, filenamePrefix)
            this.FilenamePrefix = filenamePrefix;
        end
        
        function Digits = get.Digits(this)
            Digits = this.Digits;
        end
        
        function set.Digits(this, Digits)
            assert(isfinite(Digits));
            this.Digits = Digits;
        end

        function name = get.ImageFormatName(this)
            name = this.ImageFormatName;
        end
        
        function set.ImageFormatName(this, name)
            this.ImageFormatName = name;
        end

        %% Other Public Methods

        %% WriteProjectionImagesToDisk
        function success = WriteProjectionImagesToDisk(this, projection)
            success = false;
            path = this.Path;
            prefix = this.FilenamePrefix;
            digits = this.Digits;
            format = this.ImageFormat;
            fileFormatString = [prefix, '%0', num2str(digits), 'd', '.', format];
            switch format
                case {'bmp', 'hdf'}
                    for(idx = 1:size(projection,3))
                        filename = fullfile(path, sprintf(fileFormatString, idx));
                        imwrite(double(projection(:,:,idx)), filename, format);
                    end
                case {'png', 'pbm', 'pgm', 'pnm'}
                    for(idx = 1:size(projection,3))
                        filename = fullfile(path, sprintf(fileFormatString, idx));
                        imwrite(projection(:,:,idx), filename, format);
                    end
                case 'jpg'
                    for(idx = 1:size(projection,3))
                        filename = fullfile(path, sprintf(fileFormatString, idx));
                        imwrite(projection(:,:,idx), filename, format, 'Mode', 'lossless', 'BitDepth', 16);
                    end
                case 'tif'
                    % Write images to disk as uncompressed 16-bit TIFF files
                    for(idx = 1:size(projection,3))
                        filename = fullfile(path, sprintf(fileFormatString, idx));
                        imwrite(projection(:,:,idx), filename, format, 'Compression', 'none');
                    end
                case 'nii'
                    filename = fullfile(path, [prefix, '.', format]);
                    niftiwrite(projection, filename);
                otherwise
                    return
            end
            success = true;
        end
    end

    %% Private Methods
    methods (Access = private)
    end

    %% Public Static Methods
    methods (Static)
    end

    %% Private Static Methods
    methods (Static, Access = private)
    end
end