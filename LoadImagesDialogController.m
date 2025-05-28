classdef LoadImagesDialogController < handle
    % LoadImagesDialogController    Controller class (MVC pattern) for the LoadImagesDialog GUI that allows the user 
    %                               to load image data into LiverDCE to be analyzed
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    %% Properties

    % Observable Properties (listeners receive notification of changes)
    properties (SetObservable = true, AbortSet = true)
        Model
        View
    end

    % Dependent properties
    properties (SetObservable = true, AbortSet = true, Dependent = true)
    end

    % Private Properties
    properties (Access = private)
    end

    % Private Computable Dependent Properties
    properties (Dependent = true, SetAccess = private)
    end

    %% Events
    events
    end

    %% Public Methods
    methods
        %% Constructors
        function this = LoadImagesDialogController(varargin)
            if (nargin<1)
                this.Model = LoadImagesDialogModel();
            else
                this.Model = LoadImagesDialogModel(varargin{1});
            end
            this.View = LoadImagesDialogView(this.Model);

            this.RegisterUiEventHandlers();

            uiwait(this.View.UiControls.Figure);
            delete(this.View.UiControls.Figure);

            if (this.Model.Cancelled)
                this = LoadImagesDialogController.empty;
            end
        end

        %% Getters for Computable Dependent Properties

        %% Getters and Setters
        function model = get.Model(this)
            model = this.Model;
        end

        function set.Model(this, value)
            this.Model = value;
        end

        function view = get.View(this)
            view = this.View;
        end

        function set.View(this, value)
            this.View = value;
        end

        %% Other Public Methods
    end

    %% Private Methods
    methods (Access = private)
        %% RegisterUiEventHandlers
        function RegisterUiEventHandlers(this)
            model = this.Model;
            uiControls = this.View.UiControls;
            
            % hook up and respond to the view's events
            set(uiControls.Figure, 'CloseRequestFcn', {@LoadImagesDialogController.OnFigure_CloseRequest, model});
            set(uiControls.ImageFileFormatButtonGroup, 'SelectionChangedFcn', ...
                {@LoadImagesDialogController.OnImageFileFormatButtonGroup_SelectionChanged, model});
            set(uiControls.DicomFileFolderStructureButtonGroup, 'SelectionChangedFcn', ...
                {@LoadImagesDialogController.OnDicomFileFolderStructureButtonGroup_SelectionChanged, model});
            set(uiControls.AgentNamePopUpMenu, 'Callback', ...
                {@LoadImagesDialogController.OnAgentNamePopUpMenu_SelectionChanged, model});
            set(uiControls.OtherContrastAgentEditBox, 'Callback', ...
                {@LoadImagesDialogController.OnOtherContrastAgent_Edit, model});
            set(uiControls.UseDefaultRelaxivityCheckBox, 'Callback', ...
                {@LoadImagesDialogController.OnUseDefaultRelaxivityCheckBox_CheckChanged, model});
            set(uiControls.LiverRelaxivityEditBox, 'Callback', ...
                {@LoadImagesDialogController.OnLiverRelaxivity_Edit, model});
            set(uiControls.PlasmaRelaxivityEditBox, 'Callback', ...
                {@LoadImagesDialogController.OnPlasmaRelaxivity_Edit, model});
            %TODO: replace the single blood relaxivity control with 2 separate controls for arterial and venous
            %blood if there is sufficient data in the literature to support treating them separately
            set(uiControls.BloodRelaxivityEditBox, 'Callback', ...
                {@LoadImagesDialogController.OnBloodRelaxivity_Edit, model});
            set(uiControls.MriFieldStrengthPopUpMenu, 'Callback', ...
                {@LoadImagesDialogController.OnMriFieldStrengthPopUpMenu_SelectionChanged, model});
            set(uiControls.OtherFieldStrengthEditBox, 'Callback', ...
                {@LoadImagesDialogController.OnOtherFieldStrength_Edit, model});
            set(uiControls.PulseSequencePopUpMenu, 'Callback', ...
                {@LoadImagesDialogController.OnPulseSequencePopUpMenu_SelectionChanged, model});
            set(uiControls.AcquisitionIntervalEditBox, 'Callback', ...
                {@LoadImagesDialogController.OnAcquisitionInterval_Edit, model});
            set(uiControls.FlipAngleEditBox, 'Callback', {@LoadImagesDialogController.OnFlipAngle_Edit, model});
            set(uiControls.SpeciesPopUpMenu, 'Callback', ...
                {@LoadImagesDialogController.OnSpeciesPopUpMenu_SelectionChanged, model});
            set(uiControls.EchoTimeEditBox, 'Callback', {@LoadImagesDialogController.OnEchoTime_Edit, model});
            set(uiControls.RepetitionTimeEditBox, 'Callback', ...
                {@LoadImagesDialogController.OnRepetitionTime_Edit, model});
            set(uiControls.FilenamePrefixEditBox, 'Callback', ...
                {@LoadImagesDialogController.OnFilenamePrefix_Edit, model});
            set(uiControls.LeadingZerosCheckBox, 'Callback', ...
                {@LoadImagesDialogController.OnLeadingZerosCheckBox_CheckChanged, model});
            set(uiControls.DigitPlacesEditBox, 'Callback', {@LoadImagesDialogController.OnDigitPlaces_Edit, model});
            set(uiControls.FilenameExtensionEditBox, 'Callback', ...
                {@LoadImagesDialogController.OnFilenameExtension_Edit, model});
            set(uiControls.NumberOfSlicesEditBox, 'Callback', ...
                {@LoadImagesDialogController.OnNumberOfSlices_Edit, model});
            set(uiControls.FilesystemPathEditBox, 'Callback', ...
                {@LoadImagesDialogController.OnFilesystemPath_Edit, model});
            set(uiControls.SelectPathButton, 'Callback', ...
                {@LoadImagesDialogController.OnSelectPathButton_Press, model});
            set(uiControls.ImageSetIdentifierEditBox, 'Callback', ...
                {@LoadImagesDialogController.OnImageSetIdentifier_Edit, model});
            set(uiControls.BrikNameEditBox, 'Callback', ...
                {@LoadImagesDialogController.OnBrikName_Edit, model});
            set(uiControls.LoadImagesButton, 'Callback', ...
                {@LoadImagesDialogController.OnLoadImagesButton_Press, model});
            set(uiControls.CancelButton, 'Callback', ...
                {@LoadImagesDialogController.OnCancelButton_Press, model});
        end
    end

    %% Static Methods
    methods (Static)
        %% OnImageFileFormatButtonGroup_SelectionChanged
        function OnImageFileFormatButtonGroup_SelectionChanged(uiControl, callbackdata, model)
            fileFormat = callbackdata.NewValue.String;
            switch(fileFormat)
                case 'DICOM'
                    model.ImageFileFormat = 'DICOM';
                case 'AFNI'
                    model.ImageFileFormat = 'AFNI';
                case 'NIFTI'
                    model.ImageFileFormat = 'NIFTI';
                otherwise
                    % restore the UI state to the last known good state
                    uiControl.SelectedObject = callbackdata.OldValue;
                    model.ImageFileFormat = callbackdata.OldValue.String;
            end
        end

        %% OnDicomFileFolderStructureButtonGroup_SelectionChanged
        function OnDicomFileFolderStructureButtonGroup_SelectionChanged(uiControl, ...
                callbackdata, model)
            dicomFileFolderStructure = callbackdata.NewValue.String;
            switch(dicomFileFolderStructure)
                case 'Ordered Images With Numbered Filenames'
                    model.DicomFileFolderStructure = 'Ordered';
                case 'Unordered Images'
                    model.DicomFileFolderStructure = 'Unordered';
                otherwise
                    % revert uicontrol to last known good state
                    uiControl.SelectedObject = callbackdata.OldValue;
                    oldDicomFileFolderStructure = callbackdata.OldValue.String;
                    switch(oldDicomFileFolderStructure)
                        case 'Ordered Images With Numbered Filenames'
                            model.DicomFileFolderStructure = 'Ordered';
                        case 'Unordered Images'
                            model.DicomFileFolderStructure = 'Unordered';
                        otherwise
                            % Can't revert because old state was invalid
                            error('Invalid DICOM File Folder Structure option');
                    end
            end
        end

        %% OnAgentNamePopUpMenu_SelectionChanged
        function OnAgentNamePopUpMenu_SelectionChanged(uiControl, ~, model)
            selectedAgent = uiControl.Value;
            optionList = uiControl.String;

            if(~isempty(selectedAgent) && isnumeric(selectedAgent) && ...
                    selectedAgent >= 1 && selectedAgent <= size(optionList, 1))
                model.SelectedAgent = selectedAgent;
                if(model.UseDefaultRelaxivity)
                    model.UpdateDefaultRelaxivityValues();
                end
            end
        end

        %% OnOtherContrastAgent_Edit
        function OnOtherContrastAgent_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            if(ischar(str))
                model.OtherContrastAgent = str;
            else
                uiControl.String = model.OtherContrastAgent;
            end
        end

        %% OnUseDefaultRelaxivityCheckBox_CheckChanged
        function OnUseDefaultRelaxivityCheckBox_CheckChanged(uiControl, ~, model)
            val = get(uiControl, 'Value');
            model.UseDefaultRelaxivity = logical(val);
        end

        %% OnLiverRelaxivity_Edit
        function OnLiverRelaxivity_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            relaxivity = str2double(str);
            if(IsNonZeroPositiveFinite(relaxivity))
                model.LiverRelaxivity = relaxivity;
            else
                % revert back to last good value
                uiControl.String = num2str(model.LiverRelaxivity);
            end
        end

        %% OnPlasmaRelaxivity_Edit
        function OnPlasmaRelaxivity_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            relaxivity = str2double(str);
            if(IsNonZeroPositiveFinite(relaxivity))
                model.PlasmaRelaxivity = relaxivity;
            else
                % revert back to last good value
                uiControl.String = num2str(model.PlasmaRelaxivity);
            end
        end

        %% OnBloodRelaxivity_Edit
        function OnBloodRelaxivity_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            relaxivity = str2double(str);
            if(IsNonZeroPositiveFinite(relaxivity))
                model.BloodRelaxivity = relaxivity;
            else
                % revert back to last good value
                uiControl.String = num2str(model.BloodRelaxivity);
            end
        end

        %% OnMriFieldStrengthPopUpMenu_SelectionChanged
        function OnMriFieldStrengthPopUpMenu_SelectionChanged(uiControl, ~, model)
            selectedField = uiControl.Value;
            optionList = uiControl.String;

            if(~isempty(selectedField))
                assert(isnumeric(selectedField));
                assert(selectedField >= 1);
                assert(selectedField <= size(optionList, 1));

                model.SelectedFieldStrength = selectedField;
                if(model.UseDefaultRelaxivity)
                    model.UpdateDefaultRelaxivityValues();
                end
            end
        end

        %% OnOtherFieldStrength_Edit
        function OnOtherFieldStrength_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            B0 = str2double(str);
            if(IsNonZeroPositiveFinite(B0))
                model.OtherFieldStrength = B0;
            else
                % revert back to last good value
                uiControl.String = num2str(model.OtherFieldStrength);
            end
        end

        %% OnSpeciesPopUpMenu_SelectionChanged
        function OnSpeciesPopUpMenu_SelectionChanged(uiControl, ~, model)
            selectedSpecies = uiControl.Value;
            optionList = uiControl.String;

            if(~isempty(selectedSpecies))
                assert(isnumeric(selectedSpecies));
                assert(selectedSpecies >= 1);
                assert(selectedSpecies <= size(optionList, 1));

                model.SelectedSpecies = selectedSpecies;
                if(model.UseDefaultRelaxivity)
                    model.UpdateDefaultRelaxivityValues();
                end
            end
        end

        %% OnPulseSequencePopUpMenu_SelectionChanged
        function OnPulseSequencePopUpMenu_SelectionChanged(uiControl, ~, model)
            selectedPulseSequence = uiControl.Value;
            optionList = uiControl.String;

            if(~isempty(selectedPulseSequence))
                assert(isnumeric(selectedPulseSequence));
                assert(selectedPulseSequence >= 1);
                assert(selectedPulseSequence <= size(optionList, 1));

                model.SelectedPulseSequence = selectedPulseSequence;
            end
        end

        %% OnAcquisitionInterval_Edit
        function OnAcquisitionInterval_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            acquisitionInterval = str2double(str);
            if(IsNonZeroPositiveFinite(acquisitionInterval))
                model.AcquisitionInterval = acquisitionInterval;
            else
                uiControl.String = num2str(model.AcquisitionInterval);
            end
        end

        %% OnFlipAngle_Edit
        function OnFlipAngle_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            flipAngle = str2double(str);
            if(IsNonZeroPositiveFinite(flipAngle))
                model.FlipAngle = flipAngle;
            else
                uiControl.String = num2str(model.FlipAngle);
            end
        end

        %% OnEchoTime_Edit
        function OnEchoTime_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            TE = str2double(str);
            if(IsNonZeroPositiveFinite(TE))
                model.EchoTime = TE;
            else
                uiControl.String = num2str(model.EchoTime);
            end
        end

        %% OnRepetitionTime_Edit
        function OnRepetitionTime_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            TR = str2double(str);
            if(IsNonZeroPositiveFinite(TR))
                model.RepetitionTime = TR;
            else
                uiControl.String = num2str(model.RepetitionTime);
            end
        end

        %% OnFilenamePrefix_Edit
        function OnFilenamePrefix_Edit(uiControl, ~, model)
            prefix = get(uiControl, 'String');
            if(ischar(prefix))
                model.FilenamePrefix = prefix;
            else
                uiControl.String = model.FilenamePrefix;
            end
        end

        %% OnLeadingZerosCheckBox_CheckChanged
        function OnLeadingZerosCheckBox_CheckChanged(uiControl, ~, model)
            val = get(uiControl, 'Value');
            model.UseLeadingZeros = logical(val);
        end

        %% OnDigitPlaces_Edit
        function OnDigitPlaces_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            digitPlaces = fix(str2double(str));
            if(IsNonZeroPositiveFinite(digitPlaces))
                model.DigitPlaces = uint8(digitPlaces);
            end
            uiControl.String = num2str(model.DigitPlaces);
        end

        %% OnFilenameExtension_Edit
        function OnFilenameExtension_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            if(ischar(str))
                model.FilenameExtension = str;
            else
                uiControl.String = model.FilenamePrefix;
            end
        end

        %% OnNumberOfSlices_Edit
        function OnNumberOfSlices_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            numberOfSlices = fix(str2double(str));
            if(IsNonZeroPositiveFinite(numberOfSlices) && numberOfSlices >= 1.0)
                model.NumberOfSlices = uint16(numberOfSlices);
            end

            % TODO: update SelectedSliceLocation

            %     if (~isnan(numberOfSlices) && numberOfSlices >= 1.0)
            %         model.NumberOfSliceLocations = numberOfSlices;
            %
            %         if (model.SelectedSliceLocation > numberOfSlices)
            %             model.SelectedSliceLocation = numberOfSlices;
            %         end
            %     end
            uiControl.String = num2str(model.NumberOfSlices);
        end

        %% OnFilesystemPath_Edit
        function OnFilesystemPath_Edit(uiControl, ~, model)
            currentPath = model.FilesystemPath;
            str = get(uiControl, 'String');

            if (isfolder(str))
                model.FilesystemPath = str;
            else
                % revert back to the last valid path
                errordlg([str ' is not a valid path'], 'Error: Invalid Path', 'modal');
                uiControl.String = currentPath;
            end
        end

        %% OnSelectPathButton_Press
        function OnSelectPathButton_Press(~, ~, model)
            currentPath = model.FilesystemPath;
            newPath = uigetdir(currentPath, 'Select the file folder for the DCE Acquisition');
            if (newPath ~= 0)
                model.FilesystemPath = newPath;
            end
        end

        %% OnImageSetIdentifier_Edit
        function OnImageSetIdentifier_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            if(ischar(str))
                model.ImageSetIdentifier = str;
            else
                uiControl.String = model.ImageSetIdentifier;
            end
        end

        %% OnBrikName_Edit
        function OnBrikName_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            if(ischar(str))
                model.BrikName = str;
            else
                uiControl.String = model.BrikName;
            end
        end

        %% OnLoadImagesButton_Press
        function OnLoadImagesButton_Press(uiControl, ~, model)
            model.Cancelled = false;
            set(uiControl.Parent, 'units', 'pixels');
            model.SavedScreenPosition = uiControl.Parent.Position(1:2);
            set(uiControl.Parent, 'units', 'normalized');
            uiresume(uiControl.Parent);
        end

        %% OnCancelButton_Press
        function OnCancelButton_Press(uiControl, ~, model)
            model.Cancelled = true;
            uiresume(uiControl.Parent);
        end

        %% OnFigure_CloseRequest
        function OnFigure_CloseRequest(uiControl, ~, model)
            model.Cancelled = true;
            uiresume(uiControl);
        end
    end
end





