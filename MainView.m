classdef MainView < handle
    % MainView  View class (MVC pattern) for LiverDCE's main GUI window
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    %% Properties

    % Observable Properties (listeners receive notification of changes
    properties (SetObservable = true, AbortSet = true)
        Model
        UiControls
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
        function this = MainView(model)
            this.Model = model;

            % build the GUI
            this.InitializeGui();
            this.TriggerUiControlInitialization();
            this.RegisterEventListeners();
        end

        %% Getters for Computable Dependent Properties

        %% Getters and Setters

        %% Other Public Methods

        %% GetRoi2Ds
        function roiList = GetRoi2Ds(this)
            imageDisplay = this.UiControls.ImageDisplay;
            if(isvalid(imageDisplay))
                imtoolRois = imageDisplay.getRegionsOfInterest();
                numberOfRois = size(imtoolRois, 2);
                if (isempty(imtoolRois))
                    roiList = ImtoolRegionOfInterest.empty;
                    return
                end

                % % NOTE: The line below was commented out in order to make the program work in version R2023a after
                % % discovering that an unresolved bug in R2024a prevents me from saving the fit plots correctly. This
                % % code had to be commented out because createArray is only available in R2024a.
                % % See: https://www.mathworks.com/support/bugreports/3257717
                % roiList = createArray(size(imtoolRois), 'ImtoolRegionOfInterest');
                for index = 1:numberOfRois
                    roi = imtoolRois(index);
                    roiList(index) = ImtoolRegionOfInterest(roi);
                end
            end
        end
    end

    %% Private Methods
    methods (Access = private)
        %% TriggerUiControlInitialization
        function TriggerUiControlInitialization(this)
            model = this.Model;
            this.OnChangedSliceLocation(model);
            this.OnChangedNumberOfSlices(model);
            this.OnChangedContrastAgent(model);
            this.OnChangedAlpha(model);
            this.OnChangedImageStack(model.ImageVolume);
            this.OnChangedImageTypeToDisplay(model);
            this.OnChangedAlpha(model);
            this.OnChangedSelectedRoiDimensionality(model);
            this.OnChangedRoiStatsVisibility(model);
            this.OnChangedPreContrastT1(model, 'Liver');
            this.OnChangedPreContrastT1(model, 'Spleen');
            this.OnChangedPreContrastT1(model, 'ArterialBlood');
            this.OnChangedPreContrastT1(model, 'VenousBlood');
            this.OnChangedPreContrastT1(model, 'Kidney');
            this.OnChangedPreContrastT1(model, 'Muscle');
            this.OnChangedPreContrastT1(model, 'SpinalCord');
            this.OnChangedPreContrastT1(model, 'Fat');
            this.OnChangedAcquisitionZero(model);
            this.OnChangedVolumeFractionES(model, 'Liver');
            this.OnChangedVolumeFractionES(model, 'Spleen');
            this.OnChangedVolumeFractionES(model, 'Kidney');
            this.OnChangedTransitionStartIndex(model);
            this.OnChangedTransitionEndIndex(model);
            this.OnChangedFilterWindowStartSize(model);
            this.OnChangedFilterWindowEndSize(model);
            this.OnChangedHematocrit(model);
        end

        %% RegisterEventListeners
        function RegisterEventListeners(this)
            model = this.Model;
            addlistener(model, 'SelectedSliceLocation', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedSliceLocation(this, uiEvent.AffectedObject));
            addlistener(model, 'NumberOfSlicesChanged', @(uiControl,uiEvent) OnChangedNumberOfSlices(...
                this, uiEvent.Source));
            addlistener(model, 'ContrastAgentChanged', @(uiControl,uiEvent) OnChangedContrastAgent(...
                this, uiEvent.Source));
            addlistener(model, 'ThreeDimensionalRoiOptionsChanged', ...
                @(uiControl,uiEvent) OnThreeDimensionalRoiOptionsChanged(this, uiEvent.Source));
            addlistener(model.ImageVolume, 'ImageStack', 'PostSet', @(uiControl,uiEvent) OnChangedImageStack(...
                this, uiEvent.AffectedObject));
            addlistener(model, 'ImageLoad', @(uiControl,uiEvent) OnImageLoad(this, uiEvent.Source));
            addlistener(model, 'SetDefaultWindowWidthAndLevelRequest', ...
                @(uiControl,uiEvent) OnSetDefaultWindowWidthAndLevelRequest(this, uiEvent.Source));
            addlistener(model, 'ResetZoomAndPanRequest', ...
                @(uiControl,uiEvent) OnResetZoomAndPanRequest(this, uiEvent.Source));
            addlistener(model, 'SelectedRoi3DMaskAlpha', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedAlpha(this, uiEvent.AffectedObject));
            addlistener(model, 'SelectedRoi3DMaskToDisplay', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedRoi3DMaskToDisplay(this, uiEvent.AffectedObject));
            addlistener(model, 'DisplayRoi3DMaskThresholded', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedDisplayRoi3DMaskThresholded(this, uiEvent.AffectedObject));
            addlistener(model, 'SelectedImageTypeToDisplay', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedImageTypeToDisplay(this, uiEvent.AffectedObject));
            addlistener(model, 'SelectedRoiDimensionality', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedSelectedRoiDimensionality(this, uiEvent.AffectedObject));
            addlistener(model, 'RoiStatsVisibility', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedRoiStatsVisibility(this, uiEvent.AffectedObject));
            addlistener(model, 'LoadImageDataRequest', @(uiControl,uiEvent) OnLoadImageDataRequest(...
                this, uiEvent.Source));
            addlistener(model, 'KineticsModelOptionsRequest', @(uiControl,uiEvent) ...
                OnKineticsModelOptionsRequest(this, uiEvent.Source));
            addlistener(model, 'ImportRoi3DsRequest', ...
                @(uiControl,uiEvent) OnImportRoi3DsRequest(this, uiEvent.Source));
            addlistener(model, 'CorrectSignalDriftRequest', ...
                @(uiControl,uiEvent) OnCorrectSignalDriftRequest(this, uiEvent.Source));
            addlistener(model, 'RoiSignalPlotRequest', @(uiControl,uiEvent) ...
                OnRoiSignalPlotRequest(this, uiEvent.Source, SignalType.SignalIntensity));
            addlistener(model, 'RoiR1PlotRequest', @(uiControl,uiEvent) ...
                OnRoiSignalPlotRequest(this, uiEvent.Source, SignalType.R1Relaxation));
            addlistener(model, 'RoiAreaUnderCurvePlotRequest', ...
                @(uiControl,uiEvent) OnRoiSignalPlotRequest(this, uiEvent.Source, SignalType.AreaUnderCurve));
            addlistener(model, 'RoiTotalConcentrationPlotRequest', ...
                @(uiControl,uiEvent) OnRoiSignalPlotRequest(this, uiEvent.Source, SignalType.TotalConcentration));
            addlistener(model, 'RoiESConcentrationPlotRequest', ...
                @(uiControl,uiEvent) OnRoiSignalPlotRequest(this, uiEvent.Source, SignalType.EESConcentration));
            addlistener(model, 'RoiIntracellularConcentrationPlotRequest', ...
                @(uiControl,uiEvent) OnRoiSignalPlotRequest(this, uiEvent.Source, ...
                SignalType.IntracellularConcentration));
            addlistener(model, 'PreContrastLiverT1', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedPreContrastT1(this, uiEvent.AffectedObject, 'Liver'));
            addlistener(model, 'PreContrastSpleenT1', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedPreContrastT1(this, uiEvent.AffectedObject, 'Spleen'));
            addlistener(model, 'PreContrastArterialBloodT1', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedPreContrastT1(this, uiEvent.AffectedObject, 'ArterialBlood'));
            addlistener(model, 'PreContrastVenousBloodT1', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedPreContrastT1(this, uiEvent.AffectedObject, 'VenousBlood'));
            addlistener(model, 'PreContrastKidneyT1', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedPreContrastT1(this, uiEvent.AffectedObject, 'Kidney'));
            addlistener(model, 'PreContrastMuscleT1', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedPreContrastT1(this, uiEvent.AffectedObject, 'Muscle'));
            addlistener(model, 'PreContrastSpinalCordT1', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedPreContrastT1(this, uiEvent.AffectedObject, 'SpinalCord'));
            addlistener(model, 'PreContrastFatT1', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedPreContrastT1(this, uiEvent.AffectedObject, 'Fat'));
            addlistener(model, 'AcquisitionZero', 'PostSet', @(uiControl,uiEvent) ...
                OnChangedAcquisitionZero(this, uiEvent.AffectedObject));
            addlistener(model, 'LiverVolumeFractionES', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedVolumeFractionES(this, uiEvent.AffectedObject, 'Liver'));
            addlistener(model, 'SpleenVolumeFractionES', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedVolumeFractionES(this, uiEvent.AffectedObject, 'Spleen'));
            addlistener(model, 'KidneyVolumeFractionES', 'PostSet', ...
                @(uiControl,uiEvent) OnChangedVolumeFractionES(this, uiEvent.AffectedObject, 'Kidney'));
            addlistener(model, 'Hematocrit', 'PostSet', @(uiControl,uiEvent) ...
                OnChangedHematocrit(this, uiEvent.AffectedObject));
            addlistener(model, 'ComputeVolumeFractionESRequest', ...
                @(uiControl,uiEvent) OnComputeVolumeFractionESRequest(this, uiEvent.Source));
            addlistener(model, 'ExportSignalsFilenameRequest', ...
                @(uiControl,uiEvent) OnExportSignalsFilenameRequest(this, uiEvent.Source));
        end

        %% InitializeGui
        function InitializeGui(this)
            model = this.Model;
            hFig = figure('Visible', 'on', 'Name', 'Liver DCE', 'NumberTitle', 'off', ...
                'Position', [1 1 1124 870], 'Resize', 'on', 'WindowStyle', 'normal', 'ToolBar', 'none');

            % Panels for grouping UI components
            hLeftPanel = uipanel('Parent', hFig, 'Title', 'DCE-MRI Images', ...
                'Units', 'Pixels', 'Position', [8 174 586 690]);
            hRightPanel = uipanel('Parent', hFig, 'Title', 'Fit Plot', ...
                'Units', 'Pixels', 'Position', [598 6 522 858]);
            hBaselineOptionsSubPanel = uipanel('Parent', hRightPanel, 'Title', 'Baseline Options', ...
                'Units', 'Pixels', 'Position', [12 270 402 72]);
            hPreContrastT1SubPanel = uipanel('Parent', hRightPanel, 'Title', 'Pre-Contrast T1 (ms)', ...
                'Units', 'Pixels', 'Position', [12 108 364 154]);
            hExtracellularSpaceVolumeFractionSubPanel = uipanel(...
                'Parent', hRightPanel, 'Title', 'Extracellular Space Volume Fraction', ...
                'Units', 'Pixels', 'Position', [12 8 364 92]);
            hDataSmoothingSubPanel = uipanel('Parent', hRightPanel, 'Title', 'Data Smoothing', ...
                'Units', 'Pixels', 'Position', [382 8 130 254]);
            hRoi3DMaskToDisplayPanel = uipanel(hFig, 'Title', '3D ROI To Display', ...
                'Units', 'pixels', 'Position', [8 104 586 70]);
            hImageTypeToDisplayPanel = uipanel(hFig, 'Title', 'Image Type To Display', ...
                'Units', 'Pixels', 'Position', [224 12 204 90]);
            hRoiDimensionalityPanel = uipanel(hFig, 'Title', 'ROI Dimensionality', 'Units', 'Pixels', ...
                'Position', [8 12 206 90]);
            hLoadImageDataButton = uicontrol('Parent', hFig, 'Style', 'pushbutton', ...
                'String', 'Load Image Data', 'Position', [438 74 100 22]);
            hKineticsModelOptionsButton = uicontrol('Parent', hFig, 'Style', 'pushbutton', ...
                'String', 'Kinetics Model Options', 'Position', [438 44 128 22]);
            hEstimateModelParametersButton = uicontrol('Parent', hFig, 'Style', 'pushbutton', ...
                'String', 'Estimate Model Parameters', 'Position', [438 14 148 22]);

            % Left Panel Components
            hLiverDceDataPanel = uipanel('Parent', hLeftPanel, 'Units', 'Pixels', ...
                'Position', [8 62 570 610]);
            hImageDisplay = imtool3D([], [], hLiverDceDataPanel);
            hSliceLocationLabel = uicontrol('Parent', hLeftPanel, 'Style', 'text', 'String', 'Slice Location', ...
                'Units', 'Pixels', 'HorizontalAlignment', 'left', 'Position', [8 42 85 13]);
            hSliceLocationSlider = uicontrol(hLeftPanel, 'Style', 'slider', ...
                'Value', double(model.SelectedSliceLocation), 'Min', double(1), 'Max', double(2), ...
                'SliderStep', [0.01 0.1], 'Position', [8 11 489 24]);
            hSliceLocationEditBox = uicontrol('Parent', hLeftPanel, 'Style', 'edit', ...
                'String', num2str(model.SelectedSliceLocation), 'Units', 'Pixels', 'Position', [512 12 64 22]);
            hShowRoiStatsCheckBox = uicontrol('Parent', hLeftPanel, 'Style', 'checkbox', ...
                'String', 'Show ROI Stats', 'Value', model.RoiStatsVisibility, 'Position', [480 38 102 20]);

            % ROI 3D Mask To Display Panel Components
            hSelectedRoi3DLabel = uicontrol('Parent', hRoi3DMaskToDisplayPanel, 'Style', 'text', ...
                'String', 'Tissue', 'Units', 'pixels', 'HorizontalAlignment', 'left', ...
                'Position', [12 36 180 13]);
            hSelectedRoi3DPopUpMenu = uicontrol(hRoi3DMaskToDisplayPanel, ...
                'Style', 'popup', 'String', TissueType.DisplayNames, ...
                'TooltipString', 'ROI Tissue TYpe', 'Value', uint16(model.SelectedRoi3DMaskToDisplay), ...
                'Units', 'Pixels', 'Position', [12 10 180 20]);
            hOriginalOrRefinedRoi3DCheckBox = uicontrol('Parent', hRoi3DMaskToDisplayPanel, 'Style', 'checkbox', ...
                'String', 'Threshold 3D ROI', 'Value', model.DisplayRoi3DMaskThresholded, 'Position', [210 10 100 20]);
            hSelectedRoi3DAlphaLabel = uicontrol('Parent', hRoi3DMaskToDisplayPanel, 'Style', 'text', ...
                'String', 'Opacity', 'Units', 'Pixels', 'HorizontalAlignment', 'center', ...
                'Position', [330 36 80 13]);
            hSelectedRoi3DAlphaSlider = uicontrol('Parent', hRoi3DMaskToDisplayPanel, 'Style', 'slider', ...
                'Value', double(model.SelectedRoi3DMaskAlpha), 'Min', double(0), 'Max', double(1), ...
                'SliderStep', [0.01 0.1], 'Position', [330 10 80 22]);
            hSelectedRoi3DAlphaEditBox = uicontrol('Parent', hRoi3DMaskToDisplayPanel, 'Style', 'edit', ...
                'String', num2str(model.SelectedRoi3DMaskAlpha), 'Units', 'pixels', 'Position', [430 10 80 22]);

            % Images To Display Panel Components
            hImageTypeToDisplayPopUpMenu = uicontrol(hImageTypeToDisplayPanel, ...
                'Style', 'popup', 'String', ImageType.DisplayNames, ...
                'TooltipString', 'Image Type', 'Value', uint16(model.SelectedImageTypeToDisplay), ...
                'Units', 'Pixels', 'Position', [12 48 180 20]);
            hExportProjectionImagesButton = uicontrol('Parent', hImageTypeToDisplayPanel, 'Style', 'pushbutton', ...
                'String', 'Export Temporal Projection Images', 'Position', [12 16 180 22]);

            % Roi Type To Use Panel Components
            hRoiDimensionalityPopUpMenu = uicontrol(hRoiDimensionalityPanel, ...
                'Style', 'popup', 'String', RoiDimensionality.DisplayNames, ...
                'TooltipString', 'ROI Dimensionality', 'Value', model.SelectedRoiDimensionality.ToPopUpMenuValue(), ...
                'Units', 'Pixels', 'Position', [12 48 180 20]);
            hImportRoi3DsButton = uicontrol('Parent', hRoiDimensionalityPanel, 'Style', 'pushbutton', ...
                'String', 'Import 3D ROIs', 'Position', [12 16 180 22]);

            % Right Panel Components
            hFitPlotAxes = axes('Parent', hRightPanel, 'Units', 'Pixels', 'Box', 'on', ...
                'Color', [1 1 1], 'Position', [80 450 380 370]);
            xlabel(hFitPlotAxes, 'Time (s)');
            cdata = imread('signal-vs-time-plot-icon-48-px.png');
            xStart = 102;
            xOffset = 56;
            hExportSignalsButton = uicontrol('Parent', hRightPanel, 'Style', 'pushbutton', ...
                'String', 'Export Signals', 'Enable', 'off', 'Position', [xStart-90 363 80 22]);
            hPlotRoiSignalVsTimeButton = uicontrol('Parent', hRightPanel, 'Style', 'pushbutton', ...
                'CData', cdata, 'Position', [xStart+0*xOffset 352 54 44]);
            cdata = imread('R1-vs-time-plot-icon-48-px.png');
            hPlotRoiR1VsTimeButton = uicontrol('Parent', hRightPanel, 'Style', 'pushbutton', ...
                'CData', cdata, 'Position', [xStart+1*xOffset 352 54 44]);
            cdata = imread('area-under-curve-vs-time-plot-icon-48-px.png');
            hPlotRoiAreaUnderCurveVsTimeButton = uicontrol('Parent', hRightPanel, 'Style', 'pushbutton', ...
                'CData', cdata, 'Position', [xStart+2*xOffset 352 54 44]);
            cdata = imread('Ctotal-vs-time-plot-icon-48-px.png');
            hPlotRoiTotalConcentrationVsTimeButton = uicontrol('Parent', hRightPanel, 'Style', 'pushbutton', ...
                'CData', cdata, 'Position', [xStart+3*xOffset 352 54 44]);
            cdata = imread('Cextracellular-vs-time-plot-icon-48-px.png');
            hPlotRoiESConcentrationVsTimeButton = uicontrol('Parent', hRightPanel, 'Style', 'pushbutton', ...
                'CData', cdata, 'Position', [xStart+4*xOffset 352 54 44]);
            cdata = imread('Cintracellular-vs-time-plot-icon-48-px.png');
            hPlotRoiIntracellularConcentrationVsTimeButton = uicontrol(...
                'Parent', hRightPanel, 'Style', 'pushbutton', ...
                'CData', cdata, 'Position', [xStart+5*xOffset 352 54 44]);

            % Right Panel, Baseline Options Subpanel
            hUseBaselineAveragingCheckBox = uicontrol('Parent', hBaselineOptionsSubPanel, 'Style', 'checkbox', ...
                'String', 'Use Baseline Averaging', 'Value', model.UseBaselineAveraging, ...
                'Position', [12 14 140 20]);
            hAcquisitionZeroLabel = uicontrol('Parent', hBaselineOptionsSubPanel, 'Style', 'text', ...
                'String', 'Acquisition Zero', 'Position', [164 38 78 13]);
            hAcquisitionZeroEditBox = uicontrol('Parent', hBaselineOptionsSubPanel, 'Style', 'edit', ...
                'String', num2str(model.AcquisitionZero), 'Enable', 'on', 'Position', [164 12 78 22]);
            hDriftCorrectionOptionsButton = uicontrol('Parent', hBaselineOptionsSubPanel, 'Style', 'pushbutton', ...
                'String', 'Drift Correction Options', 'TooltipString', 'Drift Correction Options', ...
                'Enable', 'off', 'Position', [260 12 126 22]);

            % Right Panel Components - continued
            hHematocritLabel = uicontrol('Parent', hRightPanel, 'Style', 'text', ...
                'String', 'Hematocrit', 'Position', [428 310 56 13]);
            hHematocritEditBox = uicontrol('Parent', hRightPanel, 'Style', 'edit', ...
                'String', num2str(model.Hematocrit), 'Position', [428 284 56 22]);

            % Right Panel, Pre-Contrast T1 Subpanel
            xStart = 12;
            xWidth = 70;
            xGap = 18;
            xOffset = xWidth+xGap;
            yStart = 20;
            yEditBoxHeight = 22;
            yLabelHeight = 13;
            yInnerGap = 4;
            yRowGap = 21;
            yRowOffset = yEditBoxHeight + yLabelHeight + yInnerGap + yRowGap;
            yInnerOffset = yEditBoxHeight + yInnerGap;
            hPreContrastLiverT1Label = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'text', ...
                'String', 'Liver', ...
                'Position', [xStart+0*xOffset yStart+1*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hPreContrastLiverT1EditBox = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'edit', ...
                'String', num2str(model.PreContrastLiverT1), ...
                'Position', [xStart+0*xOffset yStart+1*yRowOffset xWidth yEditBoxHeight]);
            hPreContrastSpleenT1Label = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'text', ...
                'String', 'Spleen', ...
                'Position', [xStart+1*xOffset yStart+1*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hPreContrastSpleenT1EditBox = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'edit', ...
                'String', num2str(model.PreContrastSpleenT1), ...
                'Position', [xStart+1*xOffset yStart+1*yRowOffset xWidth yEditBoxHeight]);
            hPreContrastArterialBloodT1Label = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'text', ...
                'String', 'Arterial Blood', ...
                'Position', [xStart+2*xOffset yStart+1*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hPreContrastArterialBloodT1EditBox = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'edit', ...
                'String', num2str(model.PreContrastArterialBloodT1), ...
                'Position', [xStart+2*xOffset yStart+1*yRowOffset xWidth yEditBoxHeight]);
            hPreContrastVenousBloodT1Label = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'text', ...
                'String', 'Venous Blood', ...
                'Position', [xStart+3*xOffset yStart+1*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hPreContrastVenousBloodT1EditBox = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'edit', ...
                'String', num2str(model.PreContrastVenousBloodT1), ...
                'Position', [xStart+3*xOffset yStart+1*yRowOffset xWidth yEditBoxHeight]);
            hPreContrastKidneyT1Label = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'text', ...
                'String', 'Kidney', ...
                'Position', [xStart+0*xOffset yStart+0*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hPreContrastKidneyT1EditBox = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'edit', ...
                'String', num2str(model.PreContrastKidneyT1), ...
                'Position', [xStart+0*xOffset yStart+0*yRowOffset xWidth yEditBoxHeight]);
            hPreContrastMuscleT1Label = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'text', ...
                'String', 'Muscle', ...
                'Position', [xStart+1*xOffset yStart+0*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hPreContrastMuscleT1EditBox = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'edit', ...
                'String', num2str(model.PreContrastMuscleT1), ...
                'Position', [xStart+1*xOffset yStart+0*yRowOffset xWidth yEditBoxHeight]);
            hPreContrastSpinalCordT1Label = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'text', ...
                'String', 'Spinal Cord', ...
                'Position', [xStart+2*xOffset yStart+0*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hPreContrastSpinalCordT1EditBox = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'edit', ...
                'String', num2str(model.PreContrastSpinalCordT1), ...
                'Position', [xStart+2*xOffset yStart+0*yRowOffset xWidth yEditBoxHeight]);
            hPreContrastFatT1Label = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'text', ...
                'String', 'Fat', ...
                'Position', [xStart+3*xOffset yStart+0*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hPreContrastFatT1EditBox = uicontrol('Parent', hPreContrastT1SubPanel, 'Style', 'edit', ...
                'String', num2str(model.PreContrastFatT1), ...
                'Position', [xStart+3*xOffset yStart+0*yRowOffset xWidth yEditBoxHeight]);

            % Right Panel, Extracellular Space Volume Fraction Subpanel
            hLiverVolumeFractionESLabel = uicontrol(...
                'Parent', hExtracellularSpaceVolumeFractionSubPanel, 'Style', 'text', ...
                'String', 'Liver', ...
                'Position', [xStart+0*xOffset yStart+0*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hLiverVolumeFractionESEditBox = uicontrol(...
                'Parent', hExtracellularSpaceVolumeFractionSubPanel, 'Style', 'edit', ...
                'String', num2str(model.LiverVolumeFractionES), ...
                'Position', [xStart+0*xOffset yStart+0*yRowOffset xWidth yEditBoxHeight]);
            hSpleenVolumeFractionESLabel = uicontrol(...
                'Parent', hExtracellularSpaceVolumeFractionSubPanel, 'Style', 'text', ...
                'String', 'Spleen', ...
                'Position', [xStart+1*xOffset yStart+0*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hSpleenVolumeFractionESEditBox = uicontrol(...
                'Parent', hExtracellularSpaceVolumeFractionSubPanel, 'Style', 'edit', ...
                'String', num2str(model.SpleenVolumeFractionES), ...
                'Position', [xStart+1*xOffset yStart+0*yRowOffset xWidth yEditBoxHeight]);
            hKidneyVolumeFractionESLabel = uicontrol(...
                'Parent', hExtracellularSpaceVolumeFractionSubPanel, 'Style', 'text', ...
                'String', 'Kidney', ...
                'Position', [xStart+2*xOffset yStart+0*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hKidneyVolumeFractionESEditBox = uicontrol(...
                'Parent', hExtracellularSpaceVolumeFractionSubPanel, 'Style', 'edit', ...
                'String', num2str(model.KidneyVolumeFractionES), ...
                'Position', [xStart+2*xOffset yStart+0*yRowOffset xWidth yEditBoxHeight]);
            hComputeVolumeFractionESButton = uicontrol(...
                'Parent', hExtracellularSpaceVolumeFractionSubPanel, 'Style', 'pushbutton', ...
                'String', 'Compute', ...
                'Position', [xStart+3*xOffset yStart+0*yRowOffset xWidth yEditBoxHeight]);

            % Right Panel, Data Smoothing Subpanel
            xStart = 12;
            xWidth = 110;
            yStart = 12;
            yEditBoxHeight = 22;
            yLabelHeight = 13;
            yInnerGap = 4;
            yRowGap = 10;
            yRowOffset = yEditBoxHeight + yLabelHeight + yInnerGap + yRowGap;
            yInnerOffset = yEditBoxHeight + yInnerGap;
            hMedianFilterCheckBox = uicontrol('Parent', hDataSmoothingSubPanel, 'Style', 'checkbox', ...
                'String', 'Median Filter', 'Value', model.UseMedianFilter, ...
                'Position', [xStart yStart+4*yRowOffset xWidth yEditBoxHeight]);
            hTransitionStartIndexLabel = uicontrol('Parent', hDataSmoothingSubPanel, 'Style', 'text', ...
                'String', 'Transition Start Index', ...
                'Position', [xStart yStart+3*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hTransitionStartIndexEditBox = uicontrol('Parent', hDataSmoothingSubPanel, 'Style', 'edit', ...
                'String', num2str(model.TransitionStartIndex), ...
                'Position', [xStart yStart+3*yRowOffset xWidth yEditBoxHeight]);
            hTransitionEndIndexLabel = uicontrol('Parent', hDataSmoothingSubPanel, 'Style', 'text', ...
                'String', 'Transition End Index', ...
                'Position', [xStart yStart+2*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hTransitionEndIndexEditBox = uicontrol('Parent', hDataSmoothingSubPanel, 'Style', 'edit', ...
                'String', num2str(model.TransitionEndIndex), ...
                'Position', [xStart yStart+2*yRowOffset xWidth yEditBoxHeight]);
            hFilterWindowStartSizeLabel = uicontrol('Parent', hDataSmoothingSubPanel, 'Style', 'text', ...
                'String', 'Starting Window Size', ...
                'Position', [xStart yStart+1*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hFilterWindowStartSizeEditBox = uicontrol('Parent', hDataSmoothingSubPanel, 'Style', 'edit', ...
                'String', num2str(model.FilterWindowStartSize), ...
                'Position', [xStart yStart+1*yRowOffset xWidth yEditBoxHeight]);
            hFilterWindowEndSizeLabel = uicontrol('Parent', hDataSmoothingSubPanel, 'Style', 'text', ...
                'String', 'Ending Window Size', ...
                'Position', [xStart yStart+0*yRowOffset+yInnerOffset xWidth yLabelHeight]);
            hFilterWindowEndSizeEditBox = uicontrol('Parent', hDataSmoothingSubPanel, 'Style', 'edit', ...
                'String', num2str(model.FilterWindowEndSize), ...
                'Position', [xStart yStart+0*yRowOffset xWidth yEditBoxHeight]);

            this.UiControls = struct(...
                'Figure', hFig, ...
                'Roi3DMaskToDisplayPanel', hRoi3DMaskToDisplayPanel, ...
                'SelectedRoi3DLabel', hSelectedRoi3DLabel, ...
                'SelectedRoi3DPopUpMenu', hSelectedRoi3DPopUpMenu, ...
                'OriginalOrRefinedRoi3DCheckBox', hOriginalOrRefinedRoi3DCheckBox, ...
                'SelectedRoi3DAlphaLabel', hSelectedRoi3DAlphaLabel, ...
                'SelectedRoi3DAlphaSlider', hSelectedRoi3DAlphaSlider, ...
                'SelectedRoi3DAlphaEditBox', hSelectedRoi3DAlphaEditBox, ...
                'ImageTypeToDisplayPanel', hImageTypeToDisplayPanel, ...
                'ImageTypeToDisplayPopUpMenu', hImageTypeToDisplayPopUpMenu, ...
                'ExportProjectionImagesButton', hExportProjectionImagesButton, ...
                'RoiDimensionalityPanel', hRoiDimensionalityPanel, ...
                'RoiDimensionalityPopUpMenu', hRoiDimensionalityPopUpMenu, ...
                'ImportRoi3DsButton', hImportRoi3DsButton, ...
                'LoadImageDataButton', hLoadImageDataButton, ...
                'KineticsModelOptionsButton', hKineticsModelOptionsButton, ...
                'EstimateModelParametersButton', hEstimateModelParametersButton, ...
                'LeftPanel', hLeftPanel, ...
                'LiverDceDataPanel', hLiverDceDataPanel, ...
                'ImageDisplay', hImageDisplay, ...
                'SliceLocationLabel', hSliceLocationLabel, ...
                'SliceLocationSlider', hSliceLocationSlider, ...
                'SliceLocationEditBox', hSliceLocationEditBox, ...
                'ShowRoiStatsCheckBox', hShowRoiStatsCheckBox, ...
                'RightPanel', hRightPanel, ...
                'FitPlotAxes', hFitPlotAxes, ...
                'ExportSignalsButton', hExportSignalsButton, ...
                'PlotRoiSignalVsTimeButton', hPlotRoiSignalVsTimeButton, ...
                'PlotRoiR1VsTimeButton', hPlotRoiR1VsTimeButton, ...
                'PlotRoiAreaUnderCurveVsTimeButton', hPlotRoiAreaUnderCurveVsTimeButton, ...
                'PlotRoiTotalConcentrationVsTimeButton', hPlotRoiTotalConcentrationVsTimeButton, ...
                'PlotRoiESConcentrationVsTimeButton', hPlotRoiESConcentrationVsTimeButton, ...
                'PlotRoiIntracellularConcentrationVsTimeButton', hPlotRoiIntracellularConcentrationVsTimeButton, ...
                'BaselineOptionsSubPanel', hBaselineOptionsSubPanel, ...
                'UseBaselineAveragingCheckBox', hUseBaselineAveragingCheckBox, ...
                'AcquisitionZeroLabel', hAcquisitionZeroLabel, ...
                'AcquisitionZeroEditBox', hAcquisitionZeroEditBox, ...
                'DriftCorrectionOptionsButton', hDriftCorrectionOptionsButton, ...
                'HematocritLabel', hHematocritLabel, ...
                'HematocritEditBox', hHematocritEditBox, ...
                'PreContrastT1SubPanel', hPreContrastT1SubPanel, ...
                'PreContrastLiverT1Label', hPreContrastLiverT1Label, ...
                'PreContrastLiverT1EditBox', hPreContrastLiverT1EditBox, ...
                'PreContrastSpleenT1Label', hPreContrastSpleenT1Label, ...
                'PreContrastSpleenT1EditBox', hPreContrastSpleenT1EditBox, ...
                'PreContrastArterialBloodT1Label', hPreContrastArterialBloodT1Label, ...
                'PreContrastArterialBloodT1EditBox', hPreContrastArterialBloodT1EditBox, ...
                'PreContrastVenousBloodT1Label', hPreContrastVenousBloodT1Label, ...
                'PreContrastVenousBloodT1EditBox', hPreContrastVenousBloodT1EditBox, ...
                'PreContrastKidneyT1Label', hPreContrastKidneyT1Label, ...
                'PreContrastKidneyT1EditBox', hPreContrastKidneyT1EditBox, ...
                'PreContrastMuscleT1Label', hPreContrastMuscleT1Label, ...
                'PreContrastMuscleT1EditBox', hPreContrastMuscleT1EditBox, ...
                'PreContrastSpinalCordT1Label', hPreContrastSpinalCordT1Label, ...
                'PreContrastSpinalCordT1EditBox', hPreContrastSpinalCordT1EditBox, ...
                'PreContrastFatT1Label', hPreContrastFatT1Label, ...
                'PreContrastFatT1EditBox', hPreContrastFatT1EditBox, ...
                'ExtracellularSpaceVolumeFractionSubPanel', hExtracellularSpaceVolumeFractionSubPanel, ...
                'LiverVolumeFractionESLabel', hLiverVolumeFractionESLabel, ...
                'LiverVolumeFractionESEditBox', hLiverVolumeFractionESEditBox, ...
                'SpleenVolumeFractionESLabel', hSpleenVolumeFractionESLabel, ...
                'SpleenVolumeFractionESEditBox', hSpleenVolumeFractionESEditBox, ...
                'KidneyVolumeFractionESLabel', hKidneyVolumeFractionESLabel, ...
                'KidneyVolumeFractionESEditBox', hKidneyVolumeFractionESEditBox, ...
                'ComputeVolumeFractionESButton', hComputeVolumeFractionESButton, ...
                'DataSmoothingSubPanel', hDataSmoothingSubPanel, ...
                'MedianFilterCheckBox', hMedianFilterCheckBox, ...
                'TransitionStartIndexLabel', hTransitionStartIndexLabel, ...
                'TransitionStartIndexEditBox', hTransitionStartIndexEditBox, ...
                'TransitionEndIndexLabel', hTransitionEndIndexLabel, ...
                'TransitionEndIndexEditBox', hTransitionEndIndexEditBox, ...
                'FilterWindowStartSizeLabel', hFilterWindowStartSizeLabel, ...
                'FilterWindowStartSizeEditBox', hFilterWindowStartSizeEditBox, ...
                'FilterWindowEndSizeLabel', hFilterWindowEndSizeLabel, ...
                'FilterWindowEndSizeEditBox', hFilterWindowEndSizeEditBox);

            this.NormalizeDisplayUnits();
            this.MoveToPosition();
            this.MakeVisible();
        end

        %% MakeVisible
        function MakeVisible(this)
            this.UiControls.Figure.Visible = 'on';
        end

        %% MoveToPosition
        function MoveToPosition(this)
            movegui(this.UiControls.Figure, 'center');
        end

        %% NormalizeDisplayUnits
        function NormalizeDisplayUnits(this)
            controlsToExclude = {'ImageDisplay', 'PlotRoiSignalVsTimeButton', 'PlotRoiR1VsTimeButton', ...
                'PlotRoiAreaUnderCurveVsTimeButton', 'PlotRoiTotalConcentrationVsTimeButton', ...
                'PlotRoiESConcentrationVsTimeButton', 'PlotRoiIntracellularConcentrationVsTimeButton'};
            uiControlNames = fieldnames(this.UiControls);
            numberOfUiControls = numel(uiControlNames);

            if (numberOfUiControls > 0)
                for controlIndex = 1:numberOfUiControls
                    controlName = uiControlNames{controlIndex};
                    if (~any(strcmp(controlsToExclude, controlName)))
                        uiControl = getfield(this.UiControls, controlName);
                        uiControl.Units = 'normalized';
                    end
                end
            end
        end

        %% OnChangedSliceLocation
        function OnChangedSliceLocation(this, uiModel)
            uiControls = this.UiControls;
            if(isvalid(uiControls.SliceLocationSlider) && isvalid(uiControls.SliceLocationEditBox))
                uiControls.SliceLocationSlider.Value = uiModel.SelectedSliceLocation;
                uiControls.SliceLocationEditBox.String = num2str(uiModel.SelectedSliceLocation);
            end
        end

        %% OnChangedAlpha
        function OnChangedAlpha(this, uiModel)
            uiControls = this.UiControls;
            if(isvalid(uiControls.SelectedRoi3DAlphaSlider) && isvalid(uiControls.SelectedRoi3DAlphaEditBox))
                alpha = uiModel.SelectedRoi3DMaskAlpha;
                uiControls.SelectedRoi3DAlphaSlider.Value = alpha;
                uiControls.SelectedRoi3DAlphaEditBox.String = num2str(alpha);
                imageDisplay = this.UiControls.ImageDisplay;
                if(isvalid(imageDisplay))
                    setAlpha(imageDisplay, alpha);
                end
            end
        end

        %% OnChangedImageStack
        function OnChangedImageStack(this, imageVolume)
            uiModel = this.Model;
            this.SetImageStack(imageVolume);
            this.SetMaskStack();
            if(uiModel.IsProjectionImageTypeSelected)
                timePoint = 1;
            else
                timePoint = this.GetCurrentTemporalPosition();
                timePoint = ConstrainValueToRange(timePoint, 1, imageVolume.NumberOfTimePoints);
            end
            this.SetCurrentTemporalPosition(timePoint);
        end

        %% SetImageStack
        function SetImageStack(this, imageVolume)
            % Wrapper for imtool3D function
            imageDisplay = this.UiControls.ImageDisplay;
            if(isvalid(imageDisplay))
                % Keep the existing window width and level, zoom and pan settings, and 3D mask when changing the image
                % stack
                range = this.GetDisplayRange();
                [xLimits, yLimits] = this.GetDisplayAxesLimits();
                setImage(this.UiControls.ImageDisplay, imageVolume.ImageStack, range, [], {xLimits, yLimits});
            end
        end

        %% ClearMaskDisplay
        function ClearMaskDisplay(this)
            if(isvalid(this.UiControls.ImageDisplay))
                imageDisplay = this.UiControls.ImageDisplay;
                mask = getMask(imageDisplay);
                setMask(imageDisplay, zeros(size(mask)));
            end
        end

        %% SetMaskStack
        function SetMaskStack(this)
            arguments
                this(1,1) MainView
            end
            model = this.Model;
            if(isvalid(this.UiControls.ImageDisplay) && model.ThreeDimensionalRoiOptionsInitialized && ...
                    model.LoadImageDataOptionsInitialized)
                imageDisplay = this.UiControls.ImageDisplay;
                if(~model.IsSelectedRoiDimensionality3D)
                    this.ClearMaskDisplay();
                    return
                end
                
                tissueType = model.SelectedRoi3DMaskToDisplay;
                roi = model.GetRoi3DByTissueType(tissueType);
                if(isempty(roi))
                    this.ClearMaskDisplay();
                    return
                end
                color = roi.Color;
                sliceLocation = model.SelectedSliceLocation;
                if (model.DisplayRoi3DMaskThresholded)
                    mask2D = roi.Mask(:,:,sliceLocation);
                else
                    roiMask = roi.GetOriginalMask();
                    mask2D = roiMask(:,:,sliceLocation);
                end
                if(isempty(color) || isempty(mask2D))
                    this.ClearMaskDisplay();
                    return
                end
                

                numberOfTimePoints = model.ImageVolume.NumberOfTimePoints;
                mask3D = repmat(mask2D, 1, 1, numberOfTimePoints);
                alpha = model.SelectedRoi3DMaskAlpha;

                setMaskColor(imageDisplay, color);
                setMask(imageDisplay, mask3D);
                setAlpha(imageDisplay, alpha);
            end
        end

        %% GetWindowWidthAndLevel
        function [ww, wl] = GetWindowWidthAndLevel(this)
            % Wrapper for imtool3D function
            if(isvalid(this.UiControls.ImageDisplay))
                [ww, wl] = getWindowLevel(this.UiControls.ImageDisplay);
            end
        end

        %% SetWindowWidthAndLevel
        function SetWindowWidthAndLevel(this, windowWidth, windowLevel)
            % Wrapper for imtool3D function
            if(isvalid(this.UiControls.ImageDisplay))
                setWindowLevel(this.UiControls.ImageDisplay, windowWidth, windowLevel);
            end
        end

        %% GetDisplayRange
        function range = GetDisplayRange(this)
            % Wrapper for imtool3D function
            if(isvalid(this.UiControls.ImageDisplay))
                range = getDisplayRange(this.UiControls.ImageDisplay);
            end
        end

        %% SetDisplayRange
        function SetDisplayRange(this, range)
            % Wrapper for imtool3D function
            if(isvalid(this.UiControls.ImageDisplay))
                setDisplayRange(this.UiControls.ImageDisplay, range);
            end
        end

        %% GetDisplayAxesLimits
        function [xLimits, yLimits] = GetDisplayAxesLimits(this)
            imageDisplay = this.UiControls.ImageDisplay;
            if(isvalid(imageDisplay))
                handles = getHandles(imageDisplay);
                xLimits = get(handles.Axes, 'XLim');
                yLimits = get(handles.Axes, 'YLim');
            end
        end

        %% SetDisplayAxesLimits
        function SetDisplayAxesLimits(this, xLimits, yLimits)
            imageDisplay = this.UiControls.ImageDisplay;
            if(isvalid(imageDisplay))
                handles = getHandles(imageDisplay);
                set(handles.Axes, 'XLim', xLimits);
                set(handles.Axes, 'YLim', yLimits);
            end
        end

        %% ResetZoomAndPan
        function ResetZoomAndPan(this)
            imageDisplay = this.UiControls.ImageDisplay;
            if(isvalid(imageDisplay))
                handles = getHandles(imageDisplay);
                xData = get(handles.I, 'XData');
                yData = get(handles.I, 'YData');
                this.SetDisplayAxesLimits(xData, yData);
            end
        end

        %% GetCurrentTemporalPosition
        function timeIndex = GetCurrentTemporalPosition(this)
            % Wrapper for imtool3D function
            % The getCurrentSlice function is misleadingly-named for how it is used in this program. The slice is a
            % temporal position, not a spatial one.
            if(isvalid(this.UiControls.ImageDisplay))
                timeIndex = getCurrentSlice(this.UiControls.ImageDisplay);
            end
        end

        %% SetCurrentTemporalPosition
        function SetCurrentTemporalPosition(this, timeIndex)
            % Wrapper for imtool3D function
            % The setCurrentSlice function is misleadingly-named for how it is used in this program. The slice is a
            % temporal position, not a spatial one.
            if(isvalid(this.UiControls.ImageDisplay))
                setCurrentSlice(this.UiControls.ImageDisplay, timeIndex);
            end
        end

        %% OnChangedNumberOfSlices
        function OnChangedNumberOfSlices(this, uiModel)
            uiControls = this.UiControls;
            if(isvalid(uiControls.SliceLocationSlider))
                dataOptions = uiModel.LoadImageDataOptions;
                if(isempty(dataOptions) || ~isa(dataOptions, 'LoadImagesDialogModel'))
                    return
                end
                
                sliderMin = double(uiControls.SliceLocationSlider.Min);
                sliderMax = double(dataOptions.NumberOfSlices);
                value = ConstrainValueToRange(double(uiControls.SliceLocationSlider.Value), sliderMin, sliderMax);
                sliderStep = this.SliceLocationSliderStep(sliderMin, sliderMax);

                set(uiControls.SliceLocationSlider, 'Value', value);
                set(uiControls.SliceLocationSlider, 'SliderStep', sliderStep);
                set(uiControls.SliceLocationSlider, 'Min', sliderMin);
                set(uiControls.SliceLocationSlider, 'Max', sliderMax);
            end
        end

        %% OnThreeDimensionalRoiOptionsChanged
        function OnThreeDimensionalRoiOptionsChanged(this, uiModel)
            uiControls = this.UiControls;
            this.SetMaskStack();
        end

        %% SliceLocationSliderStep
        function sliderStep = SliceLocationSliderStep(~, sliderMin, sliderMax)
            valueRange = sliderMax-sliderMin;
            if(valueRange==0)
                sliderStep = [0 0];
            else
                smallSliderStep = 1/valueRange;
                largeSliderStep = min(smallSliderStep*4, 1);
                sliderStep = [smallSliderStep largeSliderStep];
            end
        end

        %% OnChangedContrastAgent
        function OnChangedContrastAgent(this, uiModel)
            initialized = uiModel.LoadImageDataOptionsInitialized;
            if(initialized)
                isHepatobiliaryContrastAgent = uiModel.LoadImageDataOptions.IsHepatobiliaryContrastAgent;
                if(isHepatobiliaryContrastAgent)
                    this.DisableComputeVolumeFractionESButton();
                else
                    this.EnableComputeVolumeFractionESButton();
                end
            end
        end

        %% OnChangedPreContrastT1
        function OnChangedPreContrastT1(this, uiModel, tissueType)
            % Capitalization in the tissueType string must match up with the Edit Box's name as well as the
            % corresponding field in MainModel
            modelFieldName = ['PreContrast', tissueType, 'T1'];
            uiControlName = [modelFieldName, 'EditBox'];
            uiControlHandle = this.UiControls.(uiControlName);

            if(isvalid(uiControlHandle))
                uiControlHandle.String = num2str(uiModel.(modelFieldName));
            end
        end

        %% OnChangedAcquisitionZero
        function OnChangedAcquisitionZero(this, uiModel)
            uiControls = this.UiControls;
            if(isvalid(uiControls.AcquisitionZeroEditBox))
                uiControls.AcquisitionZeroEditBox.String = num2str(uiModel.AcquisitionZero);
            end
        end

        %% OnChangedVolumeFractionES
        function OnChangedVolumeFractionES(this, uiModel, tissueType)
            % Capitalization in the tissueType string must match up with the Edit Box's name as well as the
            % corresponding field in MainModel
            modelFieldName = [tissueType, 'VolumeFractionES'];
            uiControlName = [modelFieldName, 'EditBox'];
            uiControlHandle = this.UiControls.(uiControlName);

            if(isvalid(uiControlHandle))
                uiControlHandle.String = num2str(uiModel.(modelFieldName));
            end
        end

        %% OnChangedTransitionStartIndex
        function OnChangedTransitionStartIndex(this, uiModel)
            uiControls = this.UiControls;
            if(isvalid(uiControls.TransitionStartIndexEditBox))
                uiControls.TransitionStartIndexEditBox.String = num2str(uiModel.TransitionStartIndex);
            end
        end

        %% OnChangedTransitionEndIndex
        function OnChangedTransitionEndIndex(this, uiModel)
            uiControls = this.UiControls;
            if(isvalid(uiControls.TransitionEndIndexEditBox))
                uiControls.TransitionEndIndexEditBox.String = num2str(uiModel.TransitionEndIndex);
            end
        end

        %% OnChangedFilterWindowStartSize
        function OnChangedFilterWindowStartSize(this, uiModel)
            uiControls = this.UiControls;
            if(isvalid(uiControls.FilterWindowStartSizeEditBox))
                uiControls.FilterWindowStartSizeEditBox.String = num2str(uiModel.FilterWindowStartSize);
            end
        end

        %% OnChangedFilterWindowEndSize
        function OnChangedFilterWindowEndSize(this, uiModel)
            uicontrols = this.UiControls;
            if(isvalid(uicontrols.FilterWindowEndSizeEditBox))
                uicontrols.FilterWindowEndSizeEditBox.String = num2str(uiModel.FilterWindowEndSize);
            end
        end

        %% OnChangedHematocrit
        function OnChangedHematocrit(this, uiModel)
            uiControls = this.UiControls;
            if(isvalid(uiControls.HematocritEditBox))
                uiControls.HematocritEditBox.String = num2str(uiModel.Hematocrit);
            end
        end

        %% OnImageLoad
        function OnImageLoad(this, uiModel)
            this.EnableDriftCorrectionOptionsButton();
            this.EnableExportSignalsButton();
        end

        %% OnSetDefaultWindowWidthAndLevelRequest
        function OnSetDefaultWindowWidthAndLevelRequest(this, uiModel)
            maxImg = uiModel.ImageVolume.GetMaximumPixelValueForImageStack();
            minImg = uiModel.ImageVolume.GetMinimumPixelValueForImageStack();
            ww = maxImg - minImg;
            ww = max(ww, 1);    % minimum window width is 1
            wl = ww./2;
            this.SetWindowWidthAndLevel(ww, wl);
        end

        %% OnResetZoomAndPanRequest
        function OnResetZoomAndPanRequest(this, uiModel)
            this.ResetZoomAndPan();
        end

        %% OnChangedRoi3DMaskToDisplay
        function OnChangedRoi3DMaskToDisplay(this, uiModel)
            this.SetMaskStack();
        end

        %% OnChangedDisplayRoi3DMaskThresholded
        function OnChangedDisplayRoi3DMaskThresholded(this, uiModel)
            this.SetMaskStack();
        end

        %% OnChangedImageTypeToDisplay
        function OnChangedImageTypeToDisplay(this, uiModel)
            imageVolume = uiModel.ImageVolume;
            if (uiModel.IsProjectionImageTypeSelected)
                if(~imageVolume.ImageDataInitialized)
                    return
                end
                this.EnableExportProjectionImagesButton();
            else
                this.DisableExportProjectionImagesButton();
            end
            imageVolume.UpdateImageStack();
            this.OnSetDefaultWindowWidthAndLevelRequest(uiModel);
        end

        %% OnChangedSelectedRoiDimensionality
        function OnChangedSelectedRoiDimensionality(this, uiModel)
            if(uiModel.IsSelectedRoiDimensionality3D)
                this.EnableImportRoi3DsButton();
            else
                this.DisableImportRoi3DsButton();
            end
            this.SetMaskStack();
        end

        %% OnChangedRoiStatsVisibility
        function OnChangedRoiStatsVisibility(this, uiModel)
            uiControls = this.UiControls;
            if(isvalid(uiControls.ImageDisplay))
                uiControls.ImageDisplay.setRoiStatsVisibility(uiModel.RoiStatsVisibility);
            end
        end

        %% OnLoadImageDataRequest
        function OnLoadImageDataRequest(~, uiModel)
            initialized = uiModel.LoadImageDataOptionsInitialized;
            if (initialized)
                loadImageDataOptions = LoadImagesDialogController(uiModel.LoadImageDataOptions);
            else
                loadImageDataOptions = LoadImagesDialogController();
            end

            if (~isempty(loadImageDataOptions))
                uiModel.LoadImageDataOptions = loadImageDataOptions.Model;
            end
        end

        %% OnKineticsModelOptionsRequest
        function OnKineticsModelOptionsRequest(~, uiModel)
            initialized = uiModel.KineticsModelOptionsInitialized;
            if (initialized)
                kineticsModelOptions = KineticsPickerController(uiModel.KineticsModelOptions);
            else
                kineticsModelOptions = KineticsPickerController();
            end

            if (~isempty(kineticsModelOptions))
                uiModel.KineticsModelOptions = kineticsModelOptions.Model;
            end
        end

        %% OnImportRoi3DsRequest
        function OnImportRoi3DsRequest(~, uiModel)
            initialized = uiModel.ThreeDimensionalRoiOptionsInitialized;
            if (initialized)
                threeDimensionalRoiOptions = LoadRoi3DsDialogController(uiModel.ThreeDimensionalRoiOptions);
            else
                threeDimensionalRoiOptions = LoadRoi3DsDialogController();
            end

            if (~isempty(threeDimensionalRoiOptions))
                uiModel.ThreeDimensionalRoiOptions = threeDimensionalRoiOptions.Model;
            end
        end
        
        %% OnCorrectSignalDriftRequest
        function OnCorrectSignalDriftRequest(this, uiModel)
            roiList = this.GetRoi2Ds();
            imageVolume = this.Model.ImageVolume;
            initialized = uiModel.DriftCorrectionOptionsInitialized;
            if (initialized)
                driftCorrectionOptions = ...
                    DriftCorrectionDialogController(roiList, imageVolume, uiModel.DriftCorrectionOptions);
            else
                driftCorrectionOptions = DriftCorrectionDialogController(roiList, imageVolume);
            end

            if (~isempty(driftCorrectionOptions))
                uiModel.DriftCorrectionOptions = driftCorrectionOptions.Model;
            end
        end

        %% OnRoiSignalPlotRequest
        function OnRoiSignalPlotRequest(this, uiModel, signalType)
            uiControls = this.UiControls;
            try
                if(~isvalid(uiControls.FitPlotAxes))
                    return
                end
                if(uiModel.IsSelectedRoiDimensionality3D())
                    roiList = uiModel.GetRoi3Ds('OrganRois');
                else
                    roiList = this.GetRoi2Ds();
                end
                if(isempty(roiList))
                    return
                end
                switch signalType
                    case SignalType.SignalIntensity
                        MainView.PlotAllRoiSignalsWithDispersion(...
                            uiControls.FitPlotAxes, uiModel, roiList, signalType);
                    case {SignalType.R1Relaxation, SignalType.AreaUnderCurve, SignalType.TotalConcentration}
                        MainView.PlotAllRoiSignals(uiControls.FitPlotAxes, uiModel, roiList, signalType);
                    case SignalType.EESConcentration
                        if(uiModel.IsSelectedRoiDimensionality3D())
                            roiList = RegionOfInterest3D.FilterBySignalType(roiList, SignalType.EESConcentration);
                            MainView.PlotAllRoiSignals(uiControls.FitPlotAxes, uiModel, ...
                                roiList, signalType);
                        else
                            [liverRois, ~] = MainModel.GetRoiDataForTissue(roiList, TissueType.Liver);
                            nonLiverRoiIndices = ~liverRois;

                            % Extracellular concentration in liver is assumed to be the same as in spleen for
                            % hepatobiliary contrast agents, so we don't need to plot the liver curve(s).
                            MainView.PlotAllRoiSignals(uiControls.FitPlotAxes, uiModel, ...
                                roiList(nonLiverRoiIndices), signalType);
                        end
                    case SignalType.IntracellularConcentration
                        if(uiModel.IsSelectedRoiDimensionality3D())
                            spleenRois = roiList([roiList(:).Tissue] == TissueType.Spleen);
                            if(isempty(spleenRois))
                                return
                            end
                            spleenRoi = spleenRois(1);
                            % TODO: implement a scheme to pick a spleen ROI if there's more than one

                            roiList = RegionOfInterest3D.FilterBySignalType(roiList, ...
                                SignalType.IntracellularConcentration);
                            C_ES = uiModel.GetESConcentrationFromSpleenRoi3D(spleenRoi);
                            if(~isempty(C_ES))
                                MainView.PlotAllRoiSignals(uiControls.FitPlotAxes, uiModel, roiList, ...
                                    signalType, C_ES);
                            end
                        else
                            [success, spleenRoi, ~, ~, ~] = MainView.PickSpleenRoiToUse(roiList);
                            if(~success)
                                return
                            end
                            C_ES = uiModel.GetESConcentrationFromSpleenRoi2D(spleenRoi);
                            if(~isempty(C_ES))
                                MainView.PlotAllRoiSignals(uiControls.FitPlotAxes, uiModel, roiList, ...
                                    signalType, C_ES);
                            end
                        end
                    otherwise
                        error('Unknown plot type');
                end
            catch errorObj
                if(strcmp(errorObj.identifier, 'LiverDCE:DynamicMrImageVolume:ImageDataNotInitialized'))
                    return
                end
                rethrow(errorObj)
            end
        end

        %% OnComputeVolumeFractionESRequest
        function OnComputeVolumeFractionESRequest(this, uiModel)
            arguments
                this MainView
                uiModel MainModel
            end

            % TODO: Finish adding support for 3D ROIs

            % if (uiModel.IsSelectedRoiDimensionality3D())
            %     roiList = uiModel.GetRoi3Ds('AllRois');
            %     [~, arterialBloodRoiIdxs] = MainModel.GetRoiDataForTissue(roiList, TissueType.AbdominalAorta);
            %     [~, venousBloodRoiIdxs] = MainModel.GetRoiDataForTissue(roiList, TissueType.PortalVein);
            % else
                roiList = this.GetRoi2Ds();
                [~, arterialBloodRoiIdxs] = MainModel.GetRoiDataForTissue(roiList, TissueType.ArterialBlood);
                [~, venousBloodRoiIdxs] = MainModel.GetRoiDataForTissue(roiList, TissueType.VenousBlood);
            % end
            [~, liverRoiIdxs] = MainModel.GetRoiDataForTissue(roiList, TissueType.Liver);
            [~, spleenRoiIdxs] = MainModel.GetRoiDataForTissue(roiList, TissueType.Spleen);
            [~, kidneyRoiIdxs] = MainModel.GetRoiDataForTissue(roiList, TissueType.Kidney);

            if (~MainView.IsReadyToComputeVolumeFractionES(liverRoiIdxs, spleenRoiIdxs, kidneyRoiIdxs, ...
                    arterialBloodRoiIdxs, venousBloodRoiIdxs))
                return;
            end

            if(~isempty(arterialBloodRoiIdxs) && ~isempty(venousBloodRoiIdxs))
                bloodTypeToUse = questdlg('Which blood region do you wish to use for the computation?', ...
                    'Blood ROI Type', 'Arterial', 'Venous', 'Arterial');
            elseif(isempty(arterialBloodRoiIdxs))
                bloodTypeToUse = 'Venous';
            else
                bloodTypeToUse = 'Arterial';
            end

            switch(bloodTypeToUse)
                case 'Arterial'
                    bloodRoi = MainView.DetermineRoiToUse(roiList, arterialBloodRoiIdxs, 'ArterialBlood');
                case 'Venous'
                    bloodRoi = MainView.DetermineRoiToUse(roiList, venousBloodRoiIdxs, 'VenousBlood');
                otherwise
                    bloodRoi = MainView.DetermineRoiToUse(roiList, arterialBloodRoiIdxs, 'ArterialBlood');
            end

            liverRoi = MainView.DetermineRoiToUse(roiList, liverRoiIdxs, 'Liver');
            spleenRoi = MainView.DetermineRoiToUse(roiList, spleenRoiIdxs, 'Spleen');
            kidneyRoi = MainView.DetermineRoiToUse(roiList, kidneyRoiIdxs, 'Kidney');
            
            uiModel.ComputeExtracellularVolumeFractions(liverRoi, spleenRoi, kidneyRoi, bloodRoi);
        end

        %% OnExportSignalsFilenameRequest
        function OnExportSignalsFilenameRequest(this, uiModel)
            fileFilter = {'*.xlsx', 'Excel files (*.xlsx)'; ...
                '*.csv' 'Comma-separated value files (*.csv)'; ...
                '*.mat', 'MAT-files (*.mat)'; ...
                '*.*', 'All files (*.*)'};
            [signalsFile, path] = uiputfile(fileFilter, 'Export Signals to File');

            if(isequal(signalsFile,0) || isequal(path,0))
                % user canceled
                return
            end
            filename = fullfile(path, signalsFile);
            uiModel.ExportSignalsFilename = filename;
        end

        %% Uicontrol Enablers/Disablers
        function EnableComputeVolumeFractionESButton(this)
            uiControls = this.UiControls;
            uiControls.ComputeVolumeFractionESButton.Enable = 'on';
        end

        function DisableComputeVolumeFractionESButton(this)
            uiControls = this.UiControls;
            uiControls.ComputeVolumeFractionESButton.Enable = 'off';
        end

        function EnableExportProjectionImagesButton(this)
            uiControls = this.UiControls;
            uiControls.ExportProjectionImagesButton.Enable = 'on';
        end

        function DisableExportProjectionImagesButton(this)
            uiControls = this.UiControls;
            uiControls.ExportProjectionImagesButton.Enable = 'off';
        end

        function EnableExportSignalsButton(this)
            uiControls = this.UiControls;
            uiControls.ExportSignalsButton.Enable = 'on';
        end

        function DisableExportSignalsButton(this)
            uiControls = this.UiControls;
            uiControls.ExportSignalsButton.Enable = 'off';
        end

        function EnableImportRoi3DsButton(this)
            uiControls = this.UiControls;
            uiControls.ImportRoi3DsButton.Enable = 'on';
        end

        function DisableImportRoi3DsButton(this)
            uiControls = this.UiControls;
            uiControls.ImportRoi3DsButton.Enable = 'off';
        end

        function EnableDriftCorrectionOptionsButton(this)
            uiControls = this.UiControls;
            uiControls.DriftCorrectionOptionsButton.Enable = 'on';
        end

        function DisableDriftCorrectionOptionsButton(this)
            uiControls = this.UiControls;
            uiControls.DriftCorrectionOptionsButton.Enable = 'off';
        end
    end

    %% Public Static Methods
    methods (Static)
        %% GetRoiIndexFromPicker
        function index = GetRoiIndexFromPicker(selectedRoiColors, tissue)
            picker = RoiPickerController(selectedRoiColors, tissue);
            if (isempty(picker))
                index = 0;
            else
                index = picker.Model.RoiSelection;
            end
        end

        %% PickSpleenRoiToUse
        function [success, spleenRoi, spleenIndex, spleenRois, spleenRoiIndices] = PickSpleenRoiToUse(roiList)
            success = false;
            spleenRoi = [];
            spleenIndex = [];
            [spleenRois, spleenRoiIndices] = MainModel.GetRoiDataForTissue(roiList, TissueType.Spleen);
            if (isempty(spleenRoiIndices))
                return
            end

            roiColors = MainModel.GetRoiColors(roiList);
            if (size(spleenRoiIndices,2) > 1)
                index = MainView.GetRoiIndexFromPicker(roiColors(:,spleenRoiIndices), 'Spleen');
            else
                index = 1;
            end

            if (index == 0)
                disp('Cannot compute Chep(t) without spleen reference region');
                return
            end
            spleenIndex = spleenRoiIndices(index);
            spleenRoi = roiList(spleenIndex);
            success = true;
        end

        %% DetermineRoiToUse
        function tissueRoi = DetermineRoiToUse(roiList, tissueRoiIdxs, tissueLabelString)
            roiColors = MainModel.GetRoiColors(roiList);
            tissueRoi = [];
            if (~isempty(tissueRoiIdxs))
                if (size(tissueRoiIdxs,2)>1)
                    idx = MainView.GetRoiIndexFromPicker(roiColors(:,tissueRoiIdxs), tissueLabelString);
                    if (idx > 0)
                        tissueIdx = tissueRoiIdxs(idx);
                        tissueRoi = roiList(tissueIdx);
                    end
                else
                    tissueRoi = roiList(tissueRoiIdxs(1));
                end
            end
        end

        %% PrepareAxesForPlotting
        function axesHandle = PrepareAxesForPlotting(varargin)
            if (nargin == 1)
                axesHandle = varargin{1};
            else
                hFig = figure;
                axesHandle = axes('Parent', hFig);
            end
            cla(axesHandle, 'reset');
            axesLabelColor = [0 0 0];
            set(axesHandle, 'XColor', axesLabelColor, 'YColor', axesLabelColor, ...
                'XMinorTick', 'on', 'YMinorTick', 'on', 'Box', 'on');
            hold(axesHandle, 'on');
        end

        %% PlotMeasuredConcentration
        function PlotMeasuredConcentration(axesHandle, time, timeUnitLabel, ...
                concentration, concentrationSignalType, color)
        	plot(axesHandle, time, concentration, 'Color', color, 'LineStyle', ':');
        	xlabel(axesHandle, ['Time (', timeUnitLabel, ')']);
        	ylabel(axesHandle, concentrationSignalType.ToAxesLabel());
        end

        %% SetAxesLimitsForModelFitPlot
        function SetAxesLimitsForModelFitPlot(axesHandle, time, measuredConcentration, fittedConcentration)
            % TODO: fix this so that when we have multiple fits plotted on the same axes, the upper limit for Y matches
            % the signal with the highest concentration
            set(axesHandle, 'xlimmode', 'manual', 'zlimmode', 'manual', 'alimmode', 'manual');
            set(axesHandle, 'xlim', [time(1), time(end)]);
            set(axesHandle, 'ylim', [0, max(max(fittedConcentration), max(measuredConcentration))*1.1]);
        end
    end

    %% Private Static Methods
    methods (Static, Access = private)
        %% PlotAllRoiSignalsWithDispersion
        function PlotAllRoiSignalsWithDispersion(axesHandle, uiModel, roiList, signalType)
            imageVolume = uiModel.ImageVolume;
            if (~imageVolume.ImageDataInitialized)
                return
            end

            MainView.PrepareAxesForPlotting(axesHandle);
            if(uiModel.IsSelectedRoiDimensionality3D())
                MainView.PlotRoi3DSignalsWithDispersion(axesHandle, uiModel, imageVolume, 'OrganRois');
                MainView.PlotRoi3DSignalsWithDispersion(axesHandle, uiModel, imageVolume, 'VesselRois');
            else
                MainView.PlotRoi2DSignalsWithDispersion(axesHandle, uiModel, roiList, imageVolume);
            end
            xlabel(axesHandle, 'Time (s)');
            ylabel(axesHandle, signalType.ToAxesLabel());
            hold(axesHandle, 'off');
        end

        %% PlotRoi2DSignalsWithDispersion
        function PlotRoi2DSignalsWithDispersion(axesHandle, uiModel, roiList, imageVolume)
            time = imageVolume.Time;
            for roi = roiList
                [unfilteredMeanSI, unfilteredStdDevSI] = imageVolume.GetSignalFrom2DRegion(roi);
                meanSI = uiModel.ApplyFiltersToSignal(unfilteredMeanSI);
                MainView.PlotSignal(axesHandle, time, roi.Color, meanSI, unfilteredStdDevSI);
            end
        end

        %% PlotRoi3DSignalsWithDispersion
        function PlotRoi3DSignalsWithDispersion(axesHandle, uiModel, imageVolume, tissueCategory)
            time = imageVolume.Time;
            roiList = uiModel.GetRoi3Ds(tissueCategory);
            numberOfRois = length(roiList);
            for roiIndex = 1:numberOfRois
                roi = roiList(roiIndex);
                [unfilteredMeanSI, unfilteredStdDevSI, ~, ~] = imageVolume.GetSignalFrom3DRegion(roi);
                meanSI = uiModel.ApplyFiltersToSignal(unfilteredMeanSI);
                MainView.PlotSignal(axesHandle, time, roi.Color, meanSI, unfilteredStdDevSI);
            end
        end

        %% PlotAllRoiSignals
        function PlotAllRoiSignals(axesHandle, uiModel, roiList, signalType, varargin)
            imageVolume = uiModel.ImageVolume;
            if (~imageVolume.ImageDataInitialized)
                return
            end

            MainView.PrepareAxesForPlotting(axesHandle);
            if(uiModel.IsSelectedRoiDimensionality3D())                
                MainView.PlotRoi3DSignals(axesHandle, uiModel, imageVolume, 'OrganRois', signalType, ...
                    varargin{:});
                switch signalType
                    case {SignalType.SignalIntensity, SignalType.R1Relaxation, SignalType.AreaUnderCurve, ...
                            SignalType.TotalConcentration}
                        MainView.PlotRoi3DSignals(axesHandle, uiModel, imageVolume, 'VesselRois', signalType, ...
                            varargin{:});
                    otherwise
                end
            else
                MainView.PlotRoi2DSignals(axesHandle, uiModel, roiList, imageVolume, signalType, varargin{:});
            end
            xlabel(axesHandle, 'Time (s)');
            ylabel(axesHandle, signalType.ToAxesLabel());
            hold(axesHandle, 'off');
        end

        %% PlotRoi2DSignals
        function PlotRoi2DSignals(axesHandle, uiModel, roiList, imageVolume, signalType, varargin)
            time = imageVolume.Time;
            for roi = roiList
                [unfilteredMeanSI, ~] = imageVolume.GetSignalFrom2DRegion(roi);
                meanSI = uiModel.ApplyFiltersToSignal(unfilteredMeanSI);

                tissueType = roi.Tissue;
                signal = uiModel.ComputeSignalToPlot(tissueType, meanSI, signalType, varargin{:});
                MainView.PlotSignal(axesHandle, time, roi.Color, signal);
            end
        end

        %% PlotRoi3DSignals
        function PlotRoi3DSignals(axesHandle, uiModel, imageVolume, tissueType, signalType, varargin)
            time = imageVolume.Time;
            roiList = uiModel.GetRoi3Ds(tissueType, signalType);
            signals = uiModel.GetSignalsFromRoi3Ds(roiList, imageVolume, signalType, varargin{:});
            numberOfSignals = size(signals, 2);
            for signalIndex = 1:numberOfSignals
                signal = signals{signalIndex}.Data;
                color = signals{signalIndex}.Color;
                MainView.PlotSignal(axesHandle, time, color, signal);
            end
        end

        %% PlotSignal
        function PlotSignal(axesHandle, time, color, mu, sigma)
            plot(axesHandle, time, mu, 'Color', color);
            hold(axesHandle, 'on');
            if(nargin == 5)
                plot(axesHandle, time, mu+sigma, 'Color', color, 'LineStyle', ':');
                plot(axesHandle, time, mu-sigma, 'Color', color, 'LineStyle', ':');
            end
        end

        %% IsReadyToComputeVolumeFractionES
        function bool = IsReadyToComputeVolumeFractionES(liverRoiIdxs, spleenRoiIdxs, kidneyRoiIdxs, ...
                arterialBloodRoiIdxs, venousBloodRoiIdxs)
            bool = false;
            if (isempty(liverRoiIdxs) && isempty(spleenRoiIdxs) && isempty(kidneyRoiIdxs))
                return;
            end

            if (isempty(arterialBloodRoiIdxs) && isempty(venousBloodRoiIdxs))
                return;
            end
            bool = true;
        end
    end
end