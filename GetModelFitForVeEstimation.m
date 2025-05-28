function [bestFit, bestFitGof, arrivalTime] = GetModelFitForVeEstimation(time, C_t, ...
    fitModel, arriveTimeMethod, tissueType, timeInterval)
    % GetModelFitForVeEstimation		WIP code for estimating the EES volume fraction. This code hasn't been 
    %                                   validated and may not work as intended. 
    %
    % Copyright (C) 2025   Michigan State University
    % Author:  Matt Latourette

    switch arriveTimeMethod
        case 'Variable'
            [arrivalTime, ~, ~] = GetContrastArrivalTime(time, C_t, fitModel, tissueType);
        case 'Fixed'
            arrivalTime = 0;
        otherwise
    end
    
    iterationValues = 10.^(1:-1:-3);
    numIterationValues = size(iterationValues, 2);
    switch fitModel
        case 'Monoexponential'
            % Total number of runs = numIterationValues^2
            initials = horzcat(repmat(iterationValues', numIterationValues, 1), ...
                repelem(iterationValues, numIterationValues)', ...
                repelem(arrivalTime, numIterationValues^2)');
        case 'Biexponential'
            useFastFit = true;
            if (useFastFit)
                % Assume a1 and a2 are always the same order of magnitude
                % and assume m1 and m2 are always the same order of
                % magnitude
                % Total number of runs = numIterationValues^2
                initials = horzcat(repmat(repmat(iterationValues', numIterationValues, 1), 1, 2), ...
                    repmat(repelem(iterationValues, numIterationValues)', 1, 2), ...
                    repelem(arrivalTime, numIterationValues^2)');
            else
                % Allow a1, a2, m1, and m2 to all be different orders of
                % magnitude
                % Total number of runs = numIterationValues^4
                initials = horzcat(...
                    repmat(repelem(iterationValues, numIterationValues^3)', numIterationValues^0, 1), ...
                    repmat(repelem(iterationValues, numIterationValues^2)', numIterationValues^1, 1), ...
                    repmat(repelem(iterationValues, numIterationValues^1)', numIterationValues^2, 1), ...
                    repmat(repelem(iterationValues, numIterationValues^0)', numIterationValues^3, 1), ...
                    repelem(arrivalTime, numIterationValues^4)');
            end
        otherwise
            error('Unrecognized fit model');
    end
    
    progressBarHandle = waitbar(0.0, 'Fitting model...');
    progressBarPatchHandle = findobj(progressBarHandle, 'Type', 'Patch');
    set(progressBarPatchHandle, 'EdgeColor', [0 0.7 0], 'FaceColor', ...
        [0 0.9 0]);
    
    bestFitGof.sse = [];
    bestFitGof.rsquare = -Inf;
    bestFitGof.dfe = [];
    bestFitGof.adjrsquare = [];
    bestFitGof.rmse = [];
    bestFit = [];
    numFits = size(initials, 1);
    progressBarStepSize = 1.0/numFits;
    for nthFit = 1:numFits
        try
            [fitresult, gof] = FitModelForVeEstimation( ...
                time, C_t, initials(nthFit,:), arrivalTime, fitModel);
            if (gof.rsquare > bestFitGof.rsquare)
                bestFitGof = gof;
                bestFit = fitresult;
            end
        catch ex
            % extract the last segment of the exception identifier
            idSegLast = regexp(ex.identifier, '(?<=:)\w+$', 'match');
            
            if (strcmp(idSegLast, 'nanComputed'))
            else
                rethrow(ex);
            end
        end
        waitbar(nthFit*progressBarStepSize, progressBarHandle, 'Fitting model...');
    end
    
    [tData, yData] = prepareCurveData( time, C_t );
    figure( 'Name', [tissueType.ToDisplayName() ' ' fitModel ' Fit ' arriveTimeMethod] );
    h = plot( bestFit, tData, yData );
    legend(h, 'Concentration vs. Time', [fitModel ' Fit'], 'Location', 'NorthEast');
    % Label axes
    xlabel Time
    ylabel Concentration
    grid on
    
    close(progressBarHandle);
end