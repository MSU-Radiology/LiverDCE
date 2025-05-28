classdef MainController < handle
    % MainController    Controller class (MVC pattern) for LiverDCE's main GUI window
    %
    % Copyright (C) 2025   Michigan State University
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
        function this = MainController()
            this.Model = MainModel();
            this.View = MainView(this.Model);

            this.RegisterUiEventHandlers();
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
            set(uiControls.ImageTypeToDisplayPopUpMenu, 'Callback', ...
                {@MainController.OnImageTypeToDisplayPopUpMenu_SelectionChanged, model});
            set(uiControls.ExportProjectionImagesButton, 'Callback', ...
                {@MainController.OnExportProjectionImagesButton_Press, model});
            set(uiControls.ExportSignalsButton, 'Callback', ...
                {@MainController.OnExportSignalsButton_Press, model});
            set(uiControls.SelectedRoi3DPopUpMenu, 'Callback', ...
                {@MainController.OnSelectedRoi3DPopUpMenu_SelectionChanged, model});
            set(uiControls.SelectedRoi3DAlphaEditBox, 'Callback', ...
                {@MainController.OnSelectedRoi3DAlphaEditBox_Edit, model});
            set(uiControls.SelectedRoi3DAlphaSlider, 'Callback', ...
                {@MainController.OnSelectedRoi3DAlphaSlider_Moved, model});
            set(uiControls.SelectedRoi3DAlphaSlider, 'ButtonDownFcn', ...
                {@MainController.OnSelectedRoi3DAlphaSlider_ButtonDown, model});
            set(uiControls.SelectedRoi3DAlphaSlider, 'KeyPressFcn', ...
                {@MainController.OnSelectedRoi3DAlphaSlider_KeyPress, model});
            set(uiControls.SelectedRoi3DAlphaSlider, 'KeyReleaseFcn', ...
                {@MainController.OnSelectedRoi3DAlphaSlider_KeyRelease, model});
            set(uiControls.OriginalOrRefinedRoi3DCheckBox, 'Callback', ...
                {@MainController.OnOriginalOrRefinedRoi3DCheckBox_CheckChanged, model});
            set(uiControls.RoiDimensionalityPopUpMenu, 'Callback', ...
                {@MainController.OnRoiDimensionalityPopUpMenu_SelectionChanged, model});
            set(uiControls.ImportRoi3DsButton, 'Callback', ...
                {@MainController.OnImportRoi3DsButton_Press, model});
            set(uiControls.LoadImageDataButton, 'Callback', {@MainController.OnLoadImageDataButton_Press, model});
            set(uiControls.KineticsModelOptionsButton, 'Callback', ...
                {@MainController.OnKineticsModelOptionsButton_Press, model});
            set(uiControls.EstimateModelParametersButton, 'Callback', ...
                {@this.OnEstimateModelParametersButton_Press});
            set(uiControls.DriftCorrectionOptionsButton, 'Callback', ...
                {@MainController.OnDriftCorrectionOptionsButton_Press, model});
            set(uiControls.PlotRoiSignalVsTimeButton, 'Callback', ...
                {@MainController.OnPlotRoiSignalVsTimeButton_Press, model});
            set(uiControls.PlotRoiR1VsTimeButton, 'Callback', ...
                {@MainController.OnPlotRoiR1VsTimeButton_Press, model});
            set(uiControls.PlotRoiAreaUnderCurveVsTimeButton, 'Callback', ...
                {@MainController.OnPlotRoiAreaUnderCurveVsTimeButton_Press, model});
            set(uiControls.PlotRoiTotalConcentrationVsTimeButton, 'Callback', ...
                {@MainController.OnPlotRoiTotalConcentrationVsTimeButton_Press, model});
            set(uiControls.PlotRoiESConcentrationVsTimeButton, 'Callback', ...
                {@MainController.OnPlotRoiESConcentrationVsTimeButton_Press, model});
            set(uiControls.PlotRoiIntracellularConcentrationVsTimeButton, 'Callback', ...
                {@MainController.OnPlotRoiIntracellularConcentrationVsTimeButton_Press, model});
            set(uiControls.SliceLocationEditBox, 'Callback', {@MainController.OnSliceLocationEditBox_Edit, model});
            set(uiControls.SliceLocationSlider, 'Callback', {@MainController.OnSliceLocationSlider_Moved, model});
            set(uiControls.SliceLocationSlider, 'ButtonDownFcn', ...
                {@MainController.OnSliceLocationSlider_ButtonDown, model});
            set(uiControls.SliceLocationSlider, 'KeyPressFcn', ...
                {@MainController.OnSliceLocationSlider_KeyPress, model});
            set(uiControls.SliceLocationSlider, 'KeyReleaseFcn', ...
                {@MainController.OnSliceLocationSlider_KeyRelease, model});
            set(uiControls.UseBaselineAveragingCheckBox, 'Callback', ...
                {@MainController.OnUseBaselineAveragingCheckBox_CheckChanged, model});
            set(uiControls.AcquisitionZeroEditBox, 'Callback', {@MainController.OnAcquisitionZero_Edit, model});
            set(uiControls.PreContrastLiverT1EditBox, 'Callback', ...
                {@MainController.OnPreContrastLiverT1_Edit, model});
            set(uiControls.PreContrastSpleenT1EditBox, 'Callback', ...
                {@MainController.OnPreContrastSpleenT1_Edit, model});
            set(uiControls.PreContrastArterialBloodT1EditBox, 'Callback', ...
                {@MainController.OnPreContrastArterialBloodT1_Edit, model});
            set(uiControls.PreContrastVenousBloodT1EditBox, 'Callback', ...
                {@MainController.OnPreContrastVenousBloodT1_Edit, model});
            set(uiControls.PreContrastKidneyT1EditBox, 'Callback', ...
                {@MainController.OnPreContrastKidneyT1_Edit, model});
            set(uiControls.PreContrastMuscleT1EditBox, 'Callback', ...
                {@MainController.OnPreContrastMuscleT1_Edit, model});
            set(uiControls.PreContrastSpinalCordT1EditBox, 'Callback', ...
                {@MainController.OnPreContrastSpinalCordT1_Edit, model});
            set(uiControls.PreContrastFatT1EditBox, 'Callback', ...
                {@MainController.OnPreContrastFatT1_Edit, model});
            set(uiControls.LiverVolumeFractionESEditBox, 'Callback', ...
                {@MainController.OnLiverVolumeFractionES_Edit, model});
            set(uiControls.SpleenVolumeFractionESEditBox, 'Callback', ...
                {@MainController.OnSpleenVolumeFractionES_Edit, model});
            set(uiControls.KidneyVolumeFractionESEditBox, 'Callback', ...
                {@MainController.OnKidneyVolumeFractionES_Edit, model});
            set(uiControls.ComputeVolumeFractionESButton, 'Callback', ...
                {@MainController.OnComputeVolumeFractionESButton_Press, model});
            set(uiControls.ShowRoiStatsCheckBox, 'Callback', ...
                {@MainController.OnShowRoiStatsCheckBox_CheckChanged, model});
            set(uiControls.MedianFilterCheckBox, 'Callback', ...
                {@MainController.OnMedianFilterCheckBox_CheckChanged, model});
            set(uiControls.TransitionStartIndexEditBox, 'Callback', ...
                {@MainController.OnTransitionStartIndex_Edit, model});
            set(uiControls.TransitionEndIndexEditBox, 'Callback', ...
                {@MainController.OnTransitionEndIndex_Edit, model});
            set(uiControls.FilterWindowStartSizeEditBox, 'Callback', ...
                {@MainController.OnFilterWindowStartSize_Edit, model});
            set(uiControls.FilterWindowEndSizeEditBox, 'Callback', ...
                {@MainController.OnFilterWindowEndSize_Edit, model});
            set(uiControls.HematocritEditBox, 'Callback', {@MainController.OnHematocrit_Edit, model});
        end

        %% OnEstimateModelParametersButton_Press
        function OnEstimateModelParametersButton_Press(this, ~, ~)
            model = this.Model;
            if (~model.IsReadyToEstimateModelParameters)
                return;
            end

            saveResultsToDisk = true;
            kmo = model.KineticsModelOptions;
            model.InitializeActivePkModel(kmo);
            if (kmo.IsReferenceRegionModel)
                this.EstimateReferenceRegionModelParameters(kmo, saveResultsToDisk);
            else
                this.EstimateVascularInputModelParameters(kmo, saveResultsToDisk);
            end
        end

        %% EstimateReferenceRegionModelParameters
        function EstimateReferenceRegionModelParameters(this, kmo, saveResultsToDisk)
            model = this.Model;
            view = this.View;
            % Clear the viewport for plotting
            if(~isvalid(view.UiControls.FitPlotAxes))
                return
            end
            axesHandle = MainView.PrepareAxesForPlotting(view.UiControls.FitPlotAxes);
            
            if(model.IsSelectedRoiDimensionality3D())
                [success, roiList, modelFitter, C_ES] = model.GetRoi3DSignalsForReferenceRegionModel();
            else
                [success, roiList, modelFitter, C_ES] = this.GetRoi2DSignalsForReferenceRegionModel();
            end
            
            if(~success)
                return
            end

            % Get the liver signal from the ROI
            [liverRois, liverRoiIndices] = MainModel.GetRoiDataForTissue(roiList, TissueType.Liver);
            % Record intermediate results for persistence to disk
            modelFitter.RecordLiverRoiInformation(liverRois, liverRoiIndices);
            modelFitter.InitializeTemporalSeries(length(liverRoiIndices));


            imageVolume = model.ImageVolume;
            time = imageVolume.Time;

            % Iterate over all of the liver ROIs and fit the selected model to each one
            for nthLiverRoiIndices = 1:length(liverRoiIndices)
                roiIndex = liverRoiIndices(nthLiverRoiIndices);
                liverRoi = roiList(roiIndex);
                [liverC_i, t, fittedCi, k1, k2] = model.FitLiverReferenceRegionModel(...
                    roiIndex, liverRoi, time, nthLiverRoiIndices, C_ES, kmo, modelFitter);

                roiColor = liverRoi.Color;
                MainView.PlotMeasuredConcentration(axesHandle, time, 's', ...
                    liverC_i, SignalType.IntracellularConcentration, roiColor);

                % Plot the fitted model concentration curve(s)
                switch kmo.KineticsModelName
                    case {'TRISTAN', 'Linear ODE'}
                        % temporary code to display what the time vs. concentration curve would be for the same
                        % k1 & k2 if computed by the other linear model (TRISTAN or Linear ODE) instead

                        % It's unclear whether the solving the ODE via the modified Rosenbrock method (MATLAB's ODE
                        % solver) is more or less accurate than solving the ODE using Laplace transforms to obtain
                        % a closed-form solution in terms of convolution and then using discrete convolution to
                        % approximate the continuous solution.
                        acqZero = model.AcquisitionZero;
                        fixedParameters.time = time;
                        fixedParameters.Ci = liverC_i;
                        fixedParameters.Ces = C_ES;
                        fixedParameters.acqZero = acqZero;
                        fixedParameters.veLiver = model.LiverVolumeFractionES;
                        switch kmo.KineticsModelName
                            case 'TRISTAN'
                                linearModel = PkLinearOdeModel(kmo);
                                [alternatet, alternatey] = ode23tb(@(t,fittedCi) linearModel.Evaluate(...
                                    ScaleParameter([k1 k2]), fixedParameters, t, fittedCi), ...
                                    [time(acqZero) time(end)], 0, []);
                            case 'Linear ODE'
                                tristanModel = PkTristanLinearModel(kmo);
                                alternatet = time;
                                alternatey = tristanModel.Evaluate([k1 k2], fixedParameters);
                        end
                        % NOTE: temporarily turned off display of the alternate model for TRISTAN and Linear ODE since
                        % we decided not to include the Linear ODE model for the paper
                        % plot(axesHandle, alternatet, alternatey, 'k:');
                        MainView.SetAxesLimitsForModelFitPlot(axesHandle, time, liverC_i, fittedCi);
                end
                plot(axesHandle, t, fittedCi, 'Color', roiColor);
            end
            hold(axesHandle, 'off');
            % Persist the results to disk as a MAT file
            if (saveResultsToDisk)
                [filename, pathname] = uiputfile({'*.mat'}, 'File to save results in', 'results.mat');
                modelFitter.WriteResultsToDisk(pathname, filename);
            end
        end

        %% EstimateVascularInputModelParameters
        function EstimateVascularInputModelParameters(this, kmo, saveResultsToDisk)
            model = this.Model;
            view = this.View;
            % Clear the viewport for plotting
            if(~isvalid(view.UiControls.FitPlotAxes))
                return
            end
            axesHandle = MainView.PrepareAxesForPlotting(view.UiControls.FitPlotAxes);

            [success, liverSignal, abdominalAortaSignal, portalVeinSignal] = ...
                model.GetRoiSignalsForVascularInputModel();
            if(~success)
                return
            end

            roiColors = liverSignal.RoiColor;
            roiTissues = {'liver'};
            modelFitter = PharmacokineticModelFitter(model, roiColors, roiTissues);

            liverRois = true;
            liverRoiIndices = 1;
            % Record intermediate results for persistence to disk
            modelFitter.RecordLiverRoiInformation(liverRois, liverRoiIndices);
            modelFitter.InitializeTemporalSeries(length(liverRoiIndices));

            imageVolume = model.ImageVolume;
            time = imageVolume.Time;            

            % Iterate over all of the liver ROIs and fit the selected model to each one
            for nthLiverRoiIndices = 1:length(liverRoiIndices)
                roiIndex = liverRoiIndices(nthLiverRoiIndices);
                roiColor = liverSignal.RoiColor;

                switch kmo.KineticsModelName
                    case 'Georgiou'
                        liverCt = liverSignal.TotalConcentration;
                        Ca = abdominalAortaSignal.TotalConcentration;
                        Cv = portalVeinSignal.TotalConcentration;
                        [t, fittedCt, ki, kef, Fp, vecs, fa] = ...
                            modelFitter.FitSelectedVascularInputModel(model, nthLiverRoiIndices, roiIndex, time, ...
                            liverCt, Ca, Cv);
                    case 'Berks'
                        liverCt = liverSignal.TotalConcentration;
                        Ca = abdominalAortaSignal.TotalConcentration;
                        Cv = portalVeinSignal.TotalConcentration;
                        [t, fittedCt, alphaPlus, alphaMinus, betaPlus, betaMinus, fa] = ...
                            modelFitter.FitSelectedVascularInputModel(model, nthLiverRoiIndices, roiIndex, time, ...
                            liverCt, Ca, Cv);
                    otherwise
                end

                % Plot the total concentration in liver
                MainView.PlotMeasuredConcentration(axesHandle, time, 's', ...
                    liverCt, SignalType.TotalConcentration, roiColor);

                % Plot the fitted model concentration curve(s)
                switch kmo.KineticsModelName
                    case {'Georgiou', 'Berks'}
                        acqZero = model.AcquisitionZero;
                        fixedParameters.time = time;
                        fixedParameters.Ct = liverCt;
                        fixedParameters.Ca = Ca;
                        fixedParameters.Cv = Cv;
                        fixedParameters.acqZero = acqZero;

                        MainView.SetAxesLimitsForModelFitPlot(axesHandle, time, liverCt, fittedCt);
                end
                plot(axesHandle, t, fittedCt, 'Color', roiColor);
            end
            hold(axesHandle, 'off');

            % Persist the results to disk as a MAT file
            if (saveResultsToDisk)
                [filename, pathname] = uiputfile({'*.mat'}, 'File to save results in', 'results.mat');
                modelFitter.WriteResultsToDisk(pathname, filename);
            end
        end

        %% GetRoi2DSignalsForReferenceRegionModel
        function varargout = GetRoi2DSignalsForReferenceRegionModel(this)
            model = this.Model;
            view = this.View;

            success = false;
            varargout = cell(1, nargout);
            for nthArgOut = 1:(nargout-1)
                varargout{nthArgOut+1} = NaN;
            end
            varargout{1} = success;

            % Get the input signal(s) for the PBPK model from the dynamic images within the ROIs the user selected
            roiList = view.GetRoi2Ds();
            roiColors = MainModel.GetRoiColors(roiList);
            roiTissues = MainModel.GetRoiTissues(roiList);
            modelFitter = PharmacokineticModelFitter(model, roiColors, roiTissues);

            [success, spleenRoi, spleenIndex, spleenRois, spleenRoiIndices] = MainView.PickSpleenRoiToUse(roiList);
            if(~success)
                return
            end

            C_ES = modelFitter.GetESConcentrationFromSpleenReferenceRegion(model, spleenRois, ...
                spleenRoiIndices, spleenRoi, spleenIndex);
            varargout = {success, roiList, modelFitter, C_ES};
        end
    end

    %% Static Methods
    methods (Static)
        %% OnImageTypeToDisplayPopUpMenu_SelectionChanged
        function OnImageTypeToDisplayPopUpMenu_SelectionChanged(uiControl, ~, model)
            selectedImageTypeToDisplay = uiControl.Value;
            optionList = uiControl.String;

            if(~isempty(selectedImageTypeToDisplay) && isnumeric(selectedImageTypeToDisplay) && ...
                    selectedImageTypeToDisplay >= 1 && selectedImageTypeToDisplay <= size(optionList, 1))
                model.SelectedImageTypeToDisplay = selectedImageTypeToDisplay;
            end
        end

        %% OnSelectedRoi3DPopUpMenu_SelectionChanged
        function OnSelectedRoi3DPopUpMenu_SelectionChanged(uiControl, ~, model)
            selectedRoi3DMaskToDisplay = TissueType(uiControl.Value);
            optionList = uiControl.String;

            if(~isempty(selectedRoi3DMaskToDisplay) && isnumeric(selectedRoi3DMaskToDisplay) && ...
                    selectedRoi3DMaskToDisplay >= 1 && selectedRoi3DMaskToDisplay <= size(optionList, 1))
                model.SelectedRoi3DMaskToDisplay = selectedRoi3DMaskToDisplay;
            end
        end

        %% OnSelectedRoi3DAlphaEditBox_Edit
        function OnSelectedRoi3DAlphaEditBox_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            alpha = str2double(str);
            
            newAlpha = MainController.ConstrainAlphaSliderValueToRange(uiControl, alpha);
            if(newAlpha ~= model.SelectedRoi3DMaskAlpha)
                model.SelectedRoi3DMaskAlpha = newAlpha;
            end
            if(newAlpha ~= alpha)
                set(uiControl, 'Value', newAlpha);
                set(uiControl, 'String', num2str(newAlpha));
            end
        end
		
        %% OnSelectedRoi3DAlphaSlider_Moved
        function OnSelectedRoi3DAlphaSlider_Moved(uiControl, ~, model)
            alpha = get(uiControl, 'Value');
            newAlpha = MainController.ConstrainAlphaSliderValueToRange(uiControl, alpha);

            model.SelectedRoi3DMaskAlpha = newAlpha;
            if(newAlpha ~= alpha)
                set(uiControl, 'Value', newAlpha);
            end
        end

        %% OnSelectedRoi3DAlphaSlider_ButtonDown
        function OnSelectedRoi3DAlphaSlider_ButtonDown(uiControl, ~, model)
            alpha = get(uiControl, 'Value');
            newAlpha = MainController.ConstrainAlphaSliderValueToRange(uiControl, alpha);
            if(newAlpha ~= alpha)
                model.SelectedRoi3DMaskAlpha = alpha;
                set(uiControl, 'Value', alpha);
            end
        end

        %% OnSelectedRoi3DAlphaSlider_KeyPress
        function OnSelectedRoi3DAlphaSlider_KeyPress(uiControl, eventdata, model)
            if(strcmp(eventdata.EventName, 'KeyPress'))
                alpha = get(uiControl, 'Value');
                switch(eventdata.Key)
                    case 'rightarrow'
                        alpha = alpha + 0.1;
                    case 'leftarrow'
                        alpha = alpha - 0.1;
                    otherwise
                end
                newAlpha = MainController.ConstrainAlphaSliderValueToRange(uiControl, alpha);
                if(newAlpha ~= alpha)
                    model.SelectedRoi3DMaskAlpha = alpha;
                    set(uiControl, 'Value', alpha);
                end
            end
        end

        %% OnSelectedRoi3DAlphaSlider_KeyRelease
        function OnSelectedRoi3DAlphaSlider_KeyRelease(uiControl, ~, ~)
            alpha = get(uiControl, 'Value');
            % %TODO: do something with it
        end

        %% OnRoiDimensionalityPopUpMenu_SelectionChanged
        function OnRoiDimensionalityPopUpMenu_SelectionChanged(uiControl, ~, model)
            selectedOption = uiControl.Value;
            optionList = uiControl.String;

            if(~isempty(selectedOption) && isnumeric(selectedOption) && ...
                    selectedOption >= 1 && selectedOption <= size(optionList, 1))
                selectedDimensionality = RoiDimensionality.FromDisplayName(optionList{selectedOption});
                model.SelectedRoiDimensionality = selectedDimensionality;
            end
        end

        %% OnUseBaselineAveragingCheckBox_CheckChanged
        function OnUseBaselineAveragingCheckBox_CheckChanged(uiControl, ~, model)
            val = get(uiControl, 'Value');
            model.UseBaselineAveraging = logical(val);
        end

        %% OnOriginalOrRefinedRoi3DCheckBox_CheckChanged
        function OnOriginalOrRefinedRoi3DCheckBox_CheckChanged(uiControl, ~, model)
            val = get(uiControl, 'Value');
            model.DisplayRoi3DMaskThresholded = logical(val);
        end

        %% OnAcquisitionZero_Edit
        function OnAcquisitionZero_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.AcquisitionZero = uint16(str2double(str));
        end

        %% OnPreContrastLiverT1_Edit
        function OnPreContrastLiverT1_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.PreContrastLiverT1 = str2double(str);
        end

        %% OnPreContrastSpleenT1_Edit
        function OnPreContrastSpleenT1_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.PreContrastSpleenT1 = str2double(str);
        end

        %% OnPreContrastArterialBloodT1_Edit
        function OnPreContrastArterialBloodT1_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.PreContrastArterialBloodT1 = str2double(str);
        end

        %% OnPreContrastVenousBloodT1_Edit
        function OnPreContrastVenousBloodT1_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.PreContrastVenousBloodT1 = str2double(str);
        end

        %% OnPreContrastKidneyT1_Edit
        function OnPreContrastKidneyT1_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.PreContrastKidneyT1 = str2double(str);
        end

        %% OnPreContrastMuscleT1_Edit
        function OnPreContrastMuscleT1_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.PreContrastMuscleT1 = str2double(str);
        end

        %% OnPreContrastSpinalCordT1_Edit
        function OnPreContrastSpinalCordT1_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.PreContrastSpinalCordT1 = str2double(str);
        end

        %% OnPreContrastFatT1_Edit
        function OnPreContrastFatT1_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.PreContrastFatT1 = str2double(str);
        end

        %% OnLiverVolumeFractionES_Edit
        function OnLiverVolumeFractionES_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.LiverVolumeFractionES = str2double(str);
        end

        %% OnSpleenVolumeFractionES_Edit
        function OnSpleenVolumeFractionES_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.SpleenVolumeFractionES = str2double(str);
        end

        %% OnKidneyVolumeFractionES_Edit
        function OnKidneyVolumeFractionES_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.KidneyVolumeFractionES = str2double(str);
        end

        %% OnHematocrit_Edit
        function OnHematocrit_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.Hematocrit = str2double(str);
        end

        %% OnExportProjectionImagesButton_Press
        function OnExportProjectionImagesButton_Press(~, ~, model)
            imageVolume = model.ImageVolume;
            if(~imageVolume.ImageDataInitialized || ~model.IsProjectionImageTypeSelected)
                return
            end

            selectedImageType = model.SelectedImageTypeToDisplay;
            initialized = model.ExportProjectionImagesOptionsInitialized;
            if (initialized)
                exportProjectionImagesOptions = ...
                    ExportProjectionImagesDialogController(selectedImageType, model.ExportProjectionImagesOptions);
            else
                exportProjectionImagesOptions = ExportProjectionImagesDialogController(selectedImageType);
            end

            if (~isempty(exportProjectionImagesOptions))
                model.ExportProjectionImagesOptions = exportProjectionImagesOptions.Model;
                projection = uint16(imageVolume.GetIntensityProjection(selectedImageType));
                exportProjectionImagesOptions.Model.WriteProjectionImagesToDisk(projection);
            end
        end

        %% OnExportSignalsButton_Press
        function OnExportSignalsButton_Press(~, ~, model)
            imageVolume = model.ImageVolume;
            if(~imageVolume.ImageDataInitialized)
                return
            end

            if(model.IsSelectedRoiDimensionality3D())
                liverRoi = model.GetRoi3DByTissueType(TissueType.Liver);
                spleenRoi = model.GetRoi3DByTissueType(TissueType.Spleen);
                abdominalAortaRoi = model.GetRoi3DByTissueType(TissueType.AbdominalAorta);
                portalVeinRoi = model.GetRoi3DByTissueType(TissueType.PortalVein);
                [unfilteredLiverMu, unfilteredLiverSigma, ~, ~] = imageVolume.GetSignalFrom3DRegion(liverRoi);
                [unfilteredSpleenMu, unfilteredSpleenSigma, ~, ~] = imageVolume.GetSignalFrom3DRegion(spleenRoi);
                [unfilteredAbdominalAortaMu, unfilteredAbdominalAortaSigma, ~, ~] = ...
                    imageVolume.GetSignalFrom3DRegion(abdominalAortaRoi);
                [unfilteredPortalVeinMu, unfilteredPortalVeinSigma, ~, ~] = ...
                    imageVolume.GetSignalFrom3DRegion(portalVeinRoi);

                if(model.UseMedianFilter)
                    filteringInUse = "Yes";
                else
                    filteringInUse = "No";
                end
                filterTransitionStartIndex = model.TransitionStartIndex;
                filterTransitionEndIndex = model.TransitionEndIndex;
                filterWindowStartSize = model.FilterWindowStartSize;
                filterWindowEndSize = model.FilterWindowEndSize;
                filteredLiverMu = model.ApplyFiltersToSignal(unfilteredLiverMu);
                filteredSpleenMu = model.ApplyFiltersToSignal(unfilteredSpleenMu);
                filteredAbdominalAortaMu = model.ApplyFiltersToSignal(unfilteredAbdominalAortaMu);
                filteredPortalVeinMu = model.ApplyFiltersToSignal(unfilteredPortalVeinMu);

                acqZero = model.AcquisitionZero;
                liverBaseline = DynamicImageVolume.GetBaseline(model.UseBaselineAveraging, ...
                    unfilteredLiverMu, acqZero);
                spleenBaseline = DynamicImageVolume.GetBaseline(model.UseBaselineAveraging, ...
                    unfilteredSpleenMu, acqZero);
                abdominalAortaBaseline = DynamicImageVolume.GetBaseline(model.UseBaselineAveraging, ...
                    unfilteredAbdominalAortaMu, acqZero);
                portalVeinBaseline = DynamicImageVolume.GetBaseline(model.UseBaselineAveraging, ...
                    unfilteredPortalVeinMu, acqZero);
                unfilteredLiverEnhancement = (unfilteredLiverMu./liverBaseline - 1)*100;
                unfilteredSpleenEnhancement = (unfilteredSpleenMu./spleenBaseline - 1)*100;
                unfilteredAbdominalAortaEnhancement = (unfilteredAbdominalAortaMu./abdominalAortaBaseline - 1)*100;
                unfilteredPortalVeinEnhancement = (unfilteredPortalVeinMu./portalVeinBaseline - 1)*100;
                filteredLiverEnhancement = (filteredLiverMu./liverBaseline - 1)*100;
                filteredSpleenEnhancement = (filteredSpleenMu./spleenBaseline - 1)*100;
                filteredAbdominalAortaEnhancement = (filteredAbdominalAortaMu./abdominalAortaBaseline - 1)*100;
                filteredPortalVeinEnhancement = (filteredPortalVeinMu./portalVeinBaseline - 1)*100;

                model.UpdateExportSignalsFilename();
                filename = model.ExportSignalsFilename;
                if(isempty(filename))
                    return
                end

                [~, ~, extension] = fileparts(filename);
                imageSetIdentifier = model.LoadImageDataOptions.ImageSetIdentifier;
                sheet1Headings = ["Time (s)", "Liver Mean (a.u.)", "Liver Mean (filtered, a.u.)", ...
                    "Liver SD (a.u.)", "Liver Baseline (a.u.)", "Liver % Enhancement", ...
                    "Liver % Enhancement (filtered)", "Spleen Mean (a.u.)", "Spleen Mean (filtered, a.u.)", ...
                    "Spleen SD (a.u.)", "Spleen Baseline (a.u.)", "Spleen % Enhancement", ...
                    "Spleen % Enhancement (filtered)", "Abdominal Aorta Mean (a.u.)", ...
                    "Abdominal Aorta Mean (filtered, a.u.)", "Abdominal Aorta SD (a.u.)", ...
                    "Abdominal Aorta Baseline (a.u.)", "Abdominal Aorta % Enhancement", ...
                    "Abdominal Aorta % Enhancement (filtered)", "Portal Vein Mean (a.u.)", ...
                    "Portal Vein Mean (filtered, a.u.)", "Portal Vein SD (a.u.)", "Portal Vein Baseline (a.u.)", ... 
                    "Portal Vein % Enhancement", "Portal Vein % Enhancement (filtered)"];
                sheet2Headings = ["Adaptive Median Filtering In Use", "Filter Transition Start Index", ...
                    "Filter Transition End Index", "Filter Window Start Size", "Filter Window End Size"];
                output = vertcat(imageVolume.Time, unfilteredLiverMu, filteredLiverMu, ...
                    unfilteredLiverSigma, liverBaseline, unfilteredLiverEnhancement, filteredLiverEnhancement, ...
                    unfilteredSpleenMu, filteredSpleenMu, unfilteredSpleenSigma, spleenBaseline, ...
                    unfilteredSpleenEnhancement, filteredSpleenEnhancement, unfilteredAbdominalAortaMu, ...
                    filteredAbdominalAortaMu, unfilteredAbdominalAortaSigma, abdominalAortaBaseline, ...
                    unfilteredAbdominalAortaEnhancement, filteredAbdominalAortaEnhancement, ...
                    unfilteredPortalVeinMu, filteredPortalVeinMu, unfilteredPortalVeinSigma, ...
                    portalVeinBaseline, unfilteredPortalVeinEnhancement, filteredPortalVeinEnhancement).';
                filterParams = horzcat(filteringInUse, filterTransitionStartIndex, filterTransitionEndIndex, ...
                    filterWindowStartSize, filterWindowEndSize);
                try
                    switch extension
                        case '.xlsx'
                            writematrix(sheet1Headings, filename, 'Sheet', [imageSetIdentifier, ' ROI Signals'], ...
                                'WriteMode', 'overwritesheet');
                            writematrix(output, filename, 'Sheet', [imageSetIdentifier, ' ROI Signals'], ...
                                'WriteMode', 'append');
                            writematrix(sheet2Headings, filename, 'Sheet', ...
                                [imageSetIdentifier, ' Filter Parameters'], 'WriteMode', 'overwritesheet');
                            writematrix(filterParams, filename, 'Sheet', ...
                                [imageSetIdentifier, ' Filter Parameters'], 'WriteMode', 'append');
                        case '.csv'
                            writematrix(sheet1Headings, filename);
                            writematrix(output, filename, 'WriteMode', 'append');
                        case '.mat'
                            time = imageVolume.Time;
                            save(filename, 'time', ...
                                'unfilteredLiverMu', ...
                                'filteredLiverMu', ...
                                'unfilteredLiverSigma', ...
                                'liverBaseline', ...
                                'unfilteredLiverEnhancement', ...
                                'filteredLiverEnhancement', ...
                                'unfilteredSpleenMu', ...
                                'filteredSpleenMu', ...
                                'unfilteredSpleenSigma', ...
                                'spleenBaseline', ...
                                'unfilteredSpleenEnhancement', ...
                                'filteredSpleenEnhancement', ...
                                'unfilteredAbdominalAortaMu', ...
                                'filteredAbdominalAortaMu', ...
                                'unfilteredAbdominalAortaSigma', ...
                                'abdominalAortaBaseline', ...
                                'unfilteredAbdominalAortaEnhancement', ...
                                'filteredAbdominalAortaEnhancement', ...
                                'unfilteredPortalVeinMu', ...
                                'filteredPortalVeinMu', ...
                                'unfilteredPortalVeinSigma', ...
                                'portalVeinBaseline', ...
                                'unfilteredPortalVeinEnhancement', ...
                                'filteredPortalVeinEnhancement', ...
                                'filteringInUse', ...
                                'filterTransitionStartIndex', ...
                                'filterTransitionEndIndex', ...
                                'filterWindowStartSize', ...
                                'filterWindowEndSize');
                        otherwise
                            error('Unknown file format');
                    end
                catch exception
                    switch exception.identifier
                        case 'MATLAB:table:write:FileOpenInAnotherProcess'
                            disp('File is locked by another application. Close the file and try again.');
                            return
                        otherwise
                            rethrow(exception);
                    end
                end
            else
                % TODO: figure out how to get the 2D ROIs (they're currently only accessible through MainView, as the
                % actual ROI data is in the 3rd party imtool3D package
                disp('2D signals export is not currently supported');
            end
        end

        %% OnImportRoi3DsButton_Press
        function OnImportRoi3DsButton_Press(~, ~, model)
            model.UpdateImportRoi3Ds();
        end

        %% OnLoadImageDataButton_Press
        function OnLoadImageDataButton_Press(~, ~, model)
            model.UpdateLoadImageDataOptions();
        end

        %% OnKineticsModelOptionsButton_Press
        function OnKineticsModelOptionsButton_Press(~, ~, model)
            model.UpdateKineticsModelOptions();
        end

        %% OnDriftCorrectionOptionsButton_Press
        function OnDriftCorrectionOptionsButton_Press(~, ~, model)
            model.UpdateCorrectSignalDrift();
        end

        %% OnPlotRoiSignalVsTimeButton_Press
        function OnPlotRoiSignalVsTimeButton_Press(~, ~, model)
            model.UpdateRoiSignalVsTimePlot();
        end

        %% OnPlotRoiR1VsTimeButton_Press
        function OnPlotRoiR1VsTimeButton_Press(~, ~, model)
            model.UpdateRoiR1VsTimePlot();
        end

        %% OnPlotRoiESConcentrationVsTimeButton_Press
        function OnPlotRoiESConcentrationVsTimeButton_Press(~, ~, model)
            model.UpdateRoiESConcentrationVsTimePlot();
        end

        %% OnPlotRoiAreaUnderCurveVsTimeButton_Press
        function OnPlotRoiAreaUnderCurveVsTimeButton_Press(~, ~, model)
            model.UpdateRoiAreaUnderCurveVsTimePlot();
        end

        %% OnPlotRoiTotalConcentrationVsTimeButton_Press
        function OnPlotRoiTotalConcentrationVsTimeButton_Press(~, ~, model)
            model.UpdateRoiTotalConcentrationVsTimePlot();
        end

        %% OnPlotRoiIntracellularConcentrationVsTimeButton_Press
        function OnPlotRoiIntracellularConcentrationVsTimeButton_Press(~, ~, model)
            model.UpdateRoiIntracellularConcentrationVsTimePlot();
        end

        %% OnComputeVolumeFractionESButton_Press
        function OnComputeVolumeFractionESButton_Press(~, ~, model)
            model.ComputeVolumeFractionES();
        end

        %% OnShowRoiStatsCheckBox_CheckChanged
        function OnShowRoiStatsCheckBox_CheckChanged(uiControl, ~, model)
            val = get(uiControl, 'Value');
            model.RoiStatsVisibility = logical(val);
        end

        %% OnMedianFilterCheckBox_CheckChanged
        function OnMedianFilterCheckBox_CheckChanged(uiControl, ~, model)
            val = get(uiControl, 'Value');
            model.UseMedianFilter = logical(val);
        end

        %% OnTransitionStartIndex_Edit
        function OnTransitionStartIndex_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            index = str2double(str);
            if(model.ImageVolume.ImageDataInitialized)
                newIndex = ConstrainValueToRange(index, 1, model.ImageVolume.NumberOfTimePoints);
            else
                newIndex = index;
            end

            if(newIndex ~= model.TransitionStartIndex)
                model.TransitionStartIndex = newIndex;
            end
            if(newIndex ~= index)
                set(uiControl, 'Value', newIndex);
                set(uiControl, 'String', num2str(newIndex));
            end
        end

        %% OnTransitionEndIndex_Edit
        function OnTransitionEndIndex_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            index = str2double(str);
            if(model.ImageVolume.ImageDataInitialized)
                newIndex = ConstrainValueToRange(index, 1, model.ImageVolume.NumberOfTimePoints);
            else
                newIndex = index;
            end

            if(newIndex ~= model.TransitionEndIndex)
                model.TransitionEndIndex = newIndex;
            end
            if(newIndex ~= index)
                set(uiControl, 'Value', newIndex);
                set(uiControl, 'String', num2str(newIndex));
            end
        end

        %% OnFilterWindowStartSize_Edit
        function OnFilterWindowStartSize_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.FilterWindowStartSize = uint16(str2double(str));
        end

        %% OnFilterWindowEndSize_Edit
        function OnFilterWindowEndSize_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            model.FilterWindowEndSize = uint16(str2double(str));
        end

        %% OnSliceLocationSlider_Moved
        function OnSliceLocationSlider_Moved(uiControl, ~, model)
            sliceLocation = get(uiControl, 'Value');
            newSliceLocation = model.ConstrainSliceLocationToRange(sliceLocation);
            model.SelectedSliceLocation = newSliceLocation;
            if(newSliceLocation ~= sliceLocation)
                set(uiControl, 'Value', newSliceLocation);
            end
        end

        %% OnSliceLocationSlider_ButtonDown
        function OnSliceLocationSlider_ButtonDown(uiControl, ~, model)
            sliceLocation = get(uiControl, 'Value');
            newSliceLocation = model.ConstrainSliceLocationToRange(sliceLocation);
            if(newSliceLocation ~= sliceLocation)
                model.SelectedSliceLocation = sliceLocation;
                set(uiControl, 'Value', sliceLocation);
            end
        end

        %% OnSliceLocationSlider_KeyPress
        function OnSliceLocationSlider_KeyPress(uiControl, eventdata, model)
            if(strcmp(eventdata.EventName, 'KeyPress'))
                sliceLocation = get(uiControl, 'Value');
                switch(eventdata.Key)
                    case 'rightarrow'
                        sliceLocation = sliceLocation + 1;
                    case 'leftarrow'
                        sliceLocation = sliceLocation - 1;
                    otherwise
                end
                newSliceLocation = model.ConstrainSliceLocationToRange(sliceLocation);
                if(newSliceLocation ~= sliceLocation)
                    model.SelectedSliceLocation = sliceLocation;
                    set(uiControl, 'Value', sliceLocation);
                end
            end
        end

        %% OnSliceLocationSlider_KeyRelease
        function OnSliceLocationSlider_KeyRelease(uiControl, ~, ~)
            sliceLocation = get(uiControl, 'Value');
            %TODO: do something with it
        end

        %% OnSliceLocationEditBox_Edit
        function OnSliceLocationEditBox_Edit(uiControl, ~, model)
            str = get(uiControl, 'String');
            sliceLocation = str2double(str);

            newSliceLocation = model.ConstrainSliceLocationToRange(sliceLocation);
            if(newSliceLocation ~= model.SelectedSliceLocation)
                model.SelectedSliceLocation = sliceLocation;
            end
            if(newSliceLocation ~= sliceLocation)
                set(uiControl, 'Value', newSliceLocation);
                set(uiControl, 'String', num2str(newSliceLocation));
            end
        end

        %% ConstrainAlphaSliderValueToRange
        function constrainedAlpha = ConstrainAlphaSliderValueToRange(uiControl, alpha)
            rangeMin = get(uiControl, 'Min');
            rangeMax = get(uiControl, 'Max');
            constrainedAlpha = ConstrainValueToRange(alpha, rangeMin, rangeMax);
        end
    end
end