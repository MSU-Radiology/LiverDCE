classdef RoiPickerController < handle
    % RoiPickerController   Controller class (MVC pattern) for the RoiPicker GUI, which allows the user to pick the 
    %                       ROI to use for an analysis from among the available ROIs for a particular tissue
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
        function this = RoiPickerController(roiColors, tissueType)
            this.Model = RoiPickerModel(roiColors);
            this.View = RoiPickerView(this.Model, tissueType);

            this.RegisterUiEventHandlers();
            
            uiwait(this.View.UiControls.Figure);
            close(this.View.UiControls.Figure);

            if (this.Model.Cancelled)
                this = RoiPickerController.empty;
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

        %% Other Public Methods
    end

    %% Private Methods
    methods (Access = private)
        %% RegisterUiEventHandlers
        function RegisterUiEventHandlers(this)
            model = this.Model;
            uiControls = this.View.UiControls;

            % respond to the view's events
            set(uiControls.OkButton, 'Callback', {@RoiPickerController.OnOkButton_Press, model});
            set(uiControls.CancelButton, 'Callback', {@RoiPickerController.OnCancelButton_Press, model});
            set(uiControls.RoiButtonGroup, 'SelectionChangedFcn', ...
                {@RoiPickerController.OnRoiButtonGroup_SelectionChanged, model});
        end
    end

    %% Static Methods
    methods (Static)
    end

    %% Static, Protected Methods
    methods (Static, Access = protected)
        %% OnOkButton_Press
        function OnOkButton_Press(uiControl, ~, model)
            model.Cancelled = false;
            uiresume(uiControl.Parent);
        end

        %% OnCancelButton_Press
        function OnCancelButton_Press(uiControl, ~, ~)
            uiresume(uiControl.Parent);
        end

        %% OnRoiButtonGroup_SelectionChanged
        function OnRoiButtonGroup_SelectionChanged(~, callbackdata, model)
            callbackdata.OldValue.CData = RoiPickerController.MakeSwatch(callbackdata, 'old', false);
            callbackdata.NewValue.CData = RoiPickerController.MakeSwatch(callbackdata, 'new', true);

            callbackdata.OldValue.BackgroundColor = 'w';
            callbackdata.NewValue.BackgroundColor = [0.9 0.9 0.9];
            model.RoiSelection = str2double(callbackdata.NewValue.String);
        end

        %% GetSwatchColor
        function color = GetSwatchColor(callbackdata, whichSwatch)
            switch lower(whichSwatch)
                case 'old'
                    cdata = callbackdata.OldValue.CData;
                case 'new'
                    cdata = callbackdata.NewValue.CData;
                otherwise
                    error('Value not recognized');
            end
            color = squeeze(cdata(1,1,:))';
        end

        %% MakeSwatch
        function swatch = MakeSwatch(callbackdata, whichSwatch, isSelected)
            % TODO: Resolve the redundancy between this code and some code in RoiPickerView that also makes a swatch
            [sizeX, sizeY] = RoiPickerController.GetSwatchSize(callbackdata, whichSwatch);
            swatchColor = RoiPickerController.GetSwatchColor(callbackdata, whichSwatch);

            swatch = repmat(reshape(swatchColor, 1, 1, 3), sizeX, sizeY);
            if (isSelected)
                mask = RoiPickerController.GetSwatchHighlightMask(sizeX, sizeY);
                swatch(mask) = 1;
            end
        end

        %% GetSwatchHighlightMask
        function mask = GetSwatchHighlightMask(sizeX, sizeY)
            % TODO: Resolve the redundancy between this code and the code in RoiPickerView that also creates a mask for
            % the picker
            mask = false(sizeX,sizeY,3);
            mask(3:4,3:end-2,:) = true;
            mask(end-3:end-2,3:end-2,:) = true;
            mask(3:end-2,3:4,:) = true;
            mask(3:end-2,end-3:end-2,:) = true;
        end

        %% GetSwatchSize
        function [sx, sy] = GetSwatchSize(callbackdata, whichSwatch)
            switch lower(whichSwatch)
                case 'old'
                    cdata = callbackdata.OldValue.CData;
                case 'new'
                    cdata = callbackdata.NewValue.CData;
                otherwise
                    error('Value not recognized');
            end
            sx = size(cdata,1);
            sy = size(cdata,2);
        end
    end
end