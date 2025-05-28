%% ReviewSavedAnalysis
function ReviewSavedAnalysis(resultsFile)
    % ReviewSavedAnalysis		Loads information from a previously saved results.mat file and displays plots of the 
    %                           MR signal intensity, R1 relaxation, area under the curve, total concentration, 
    %                           extracellular space concentration, intracellular space concentration, and the 
    %                           pharmacokinetic model fit
    %
    % Copyright (C) 2025   Michigan State University
    % Author:  Matt Latourette

    load(resultsFile, 'results');
    frameToShowForRoiOverlays = 1;   
    img = GetImageFromResults(results, frameToShowForRoiOverlays);

    overlayOpacity = 0.3;
    DisplayImageWithRegionOverlays(results, img, overlayOpacity);
    
    PlotMrSignalVsTime(results);
    PlotR1SignalVsTime(results);
    PlotAucVsTime(results);
    PlotTotalConcentrationVsTime(results);
    PlotESConcentrationVsTime(results);
    PlotIntracellularConcentrationVsTime(results);
    PlotPkModelFit(results);
end

%% GetImageFromResults
function img = GetImageFromResults(results, frameToShowForRoiOverlays)
    % Organization of the 4D image that is returned by this method is:
    %     1st dimension = row
    %     2nd dimension = column
    %     3rd dimension = slice number
    %     4th dimension = temporal sample number
    switch(results.LoadImageDataOptions.ImageFileFormat)
        case 'DICOM'
            % grab an image of the appropriate slice to show the ROI overlays on
        case 'AFNI'
            opt.Frames = frameToShowForRoiOverlays;
            brikPath = results.LoadImageDataOptions.FilesystemPath;
            brikFile = results.LoadImageDataOptions.BrikName;
            brikFullFilePath = fullfile(brikPath, brikFile);
            [err, volumeImage, info, errMessage] = BrikLoad(brikFullFilePath, opt);
            volumeImage = flip(flipud(permute(volumeImage, [2 1 3 4])), 3);
            img = volumeImage(:,:,results.SelectedSliceLocation);
        case 'NIFTI'
            niftiPath = results.LoadImageDataOptions.FilesystemPath;
            niftiFile = results.LoadImageDataOptions.BrikName;
            niftiFilePath = fullfile(niftiPath, niftiFile);
            volumeImage = double(niftiread(niftiFilePath));
            volumeImage = flip(flipud(permute(volumeImage, [2 1 3 4])), 3);
            img = volumeImage(:,:,results.SelectedSliceLocation);
        otherwise
    end
end

%% DisplayImageWithRegionOverlays
function DisplayImageWithRegionOverlays(results, img, overlayOpacity)
    hFig = figure;
    hAxes = axes(hFig);
    imshow(img, [], 'Parent', hAxes, 'InitialMagnification', 200, 'Border', 'loose');
    hold on
    title(hAxes, 'DCE-MRI Image with ROI Overlays');
    spleenOverlay = zeros([size(results.spleenMask), 3]);
    for rgbIdx = 1:3
        spleenOverlay(:,:,rgbIdx) = results.spleenMask*results.spleenRoiColor(rgbIdx);
    end
    image(spleenOverlay, 'AlphaData', results.spleenMask*overlayOpacity);
    
    for liverIdx = 1:length(results.temporalSeries)
        liverMask = results.temporalSeries{liverIdx}.liverMask;
        liverRoiColor = results.temporalSeries{liverIdx}.roiColor;
        liverOverlay = zeros([size(liverMask), 3]);
        for rgbIdx = 1:3
            liverOverlay(:,:,rgbIdx) = liverMask*liverRoiColor(rgbIdx);
        end
        image(liverOverlay, 'AlphaData', liverMask*overlayOpacity);
    end
end

%% PlotMrSignalVsTime
function PlotMrSignalVsTime(results)
    figure;
    plot(results.Time, results.spleenRoiSignalMu, '-', 'Color', results.spleenRoiColor);
    title('MRI Signal (a.u.) vs. Time (s)');
    xlabel('Time (s)');
    ylabel('MRI Signal (a.u.)');
    hold on
    plot(results.Time, results.spleenRoiSignalMu+results.spleenRoiSignalSigma, ':', 'Color', results.spleenRoiColor);
    plot(results.Time, results.spleenRoiSignalMu-results.spleenRoiSignalSigma, ':', 'Color', results.spleenRoiColor);
    for n = 1:length(results.temporalSeries)
        liverResults = results.temporalSeries{n};
        plot(results.Time, liverResults.liverRoiSignalMu, '-', 'Color', liverResults.roiColor);
        plot(results.Time, liverResults.liverRoiSignalMu+liverResults.liverRoiSignalSigma, ':', ...
            'Color', liverResults.roiColor);
        plot(results.Time, liverResults.liverRoiSignalMu-liverResults.liverRoiSignalSigma, ':', ...
            'Color', liverResults.roiColor);
    end
    hold off
end

%% PlotR1SignalVsTime
function PlotR1SignalVsTime(results)
    figure;
    plot(results.Time, results.spleenRoiR1, '-', 'Color', results.spleenRoiColor);
    title('R_1 (s^-^1) vs. Time (s)');
    xlabel('Time (s)');
    ylabel('R_1 (s^-^1)');
    hold on
    for n = 1:length(results.temporalSeries)
        liverResults = results.temporalSeries{n};
        plot(results.Time, liverResults.liverRoiR1, '-', 'Color', liverResults.roiColor);
    end
end

%% PlotAucVsTime
function PlotAucVsTime(results)
    figure;
    plot(results.Time, results.spleenRoiAucTimeSeries, '-', 'Color', results.spleenRoiColor);
    title('AUC (mM\cdots) vs. Time (s)');
    xlabel('Time (s)');
    ylabel('AUC (mM\cdots)');
    hold on
    for n = 1:length(results.temporalSeries)
        liverResults = results.temporalSeries{n};
        plot(results.Time, liverResults.liverRoiAucTimeSeries, '-', 'Color', liverResults.roiColor);
    end
end

%% PlotTotalConcentrationVsTime
function PlotTotalConcentrationVsTime(results)
    figure;
    plot(results.Time, results.spleenRoiC_t, '-', 'Color', results.spleenRoiColor);
    title('C_t (mM) vs. Time (s)');
    xlabel('Time (s)');
    ylabel('C_t (mM)');
    hold on
    for n = 1:length(results.temporalSeries)
        liverResults = results.temporalSeries{n};
        plot(results.Time, liverResults.C_t, '-', 'Color', liverResults.roiColor);
    end
end

%% PlotESConcentrationVsTime
function PlotESConcentrationVsTime(results)
    figure;
    plot(results.Time, results.spleenRoiC_ES, '-', 'Color', results.spleenRoiColor);
    title('C_E_S (mM) vs. Time (s)');
    xlabel('Time (s)');
    ylabel('C_E_S (mM)');
end

%% PlotIntracellularConcentrationVsTime
function PlotIntracellularConcentrationVsTime(results)
    figure;
    title('C_i (mM) vs. Time (s)');
    xlabel('Time (s)');
    ylabel('C_i (mM)');
    hold on
    for n = 1:length(results.temporalSeries)
        liverResults = results.temporalSeries{n};
        plot(results.Time, liverResults.C_i, '-', 'Color', liverResults.roiColor);
    end
end

%% PlotPkModelFit
function PlotPkModelFit(results)
    figure;
    title('Model Fit');
    xlabel('Time (s)');
    ylabel('C_i (mM)');
    hold on
    for n = 1:length(results.temporalSeries)
        liverResults = results.temporalSeries{n};
        legendText = sprintf('ROI %s data', num2str(n));
        plot(results.Time, liverResults.C_i, ':', 'Color', liverResults.roiColor, 'DisplayName', legendText);
        switch(liverResults.modelType)
            case 'Linear ODE'
                legendText = sprintf('ROI %g model fit', n);
                plot(liverResults.solution.t, liverResults.solution.y, '-', 'Color', liverResults.roiColor, ...
                    'DisplayName', legendText);
                fprintf('ROI %g model parameters:\nk1 = %g (1/s)\nk2 = %g (1/s)\n\n', ...
                    n, ...
                    liverResults.solution.k1, ...
                    liverResults.solution.k2);
            case 'Michaelis-Menten ODE'
                legendText = sprintf('ROI %g model fit', n);
                plot(liverResults.solution.t, liverResults.solution.y, '-', 'Color', liverResults.roiColor, ...
                    'DisplayName', legendText);
                fprintf('ROI %g model parameters:\nk1 = %g (1/s)\nkM = %g (mM)\nVmax = %g (mM/s)\n\n', ...
                    n, ...
                    liverResults.solution.k1, ...
                    liverResults.solution.kM, ...
                    liverResults.solution.Vmax);
            otherwise
        end
    end
    legend('Location', 'southeast');
end