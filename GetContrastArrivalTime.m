function [arrivalTime, fitresult, gof] = GetContrastArrivalTime(time, C_t, fitModel, tissueType)
    % GetContrastArrivalTime		WIP code for fit the time delay for the bolus. This code hasn't been validated.
    %
    % Copyright (C) 2025   Michigan State University
    % Author:  Matt Latourette

    progressBarHandle = waitbar(0.0, 'Setting up starting points...');
    progressBarPatchHandle = findobj(progressBarHandle, 'Type', 'Patch');
    set(progressBarPatchHandle, 'EdgeColor', [0 0.7 0], 'FaceColor', ...
        [0 0.9 0]);
    
    truncationLimit = 10;
    trim = 3;
    
    tRangeLow = min(floor(truncationLimit/2), 1+trim);
    tRangeHigh = max(ceil(truncationLimit/2), truncationLimit-trim);
    tRange = tRangeLow:tRangeHigh;
    
    rangeSteps = size(tRange, 2);
    iterationValues = 10.^(1:-1:-3);
    numIterationValues = size(iterationValues, 2);
    switch fitModel
        case 'Monoexponential'
            % 3-parameter model
            initials = zeros(rangeSteps*25, 3);
            progressBarStepSize = 1.0/rangeSteps;
            for idx = 1:rangeSteps
                tIdx = tRange(idx);
                t0Guess = time(tIdx);
                % Total number of runs = numIterationValues^2
                initials = horzcat(repmat(iterationValues', numIterationValues, 1), ...
                    repelem(iterationValues, numIterationValues)', ...
                    repelem(t0Guess, numIterationValues^2)');
                waitbar(idx*progressBarStepSize, progressBarHandle, ...
                    'Setting up starting points...');
            end
        case 'Biexponential'
            % 5-parameter model
            initials = zeros(rangeSteps*25, 5);
            progressBarStepSize = 1.0/rangeSteps;
            for idx = 1:rangeSteps
                tIdx = tRange(idx);
                t0Guess = time(tIdx);
                useFastFit = true;
                if (useFastFit)
                    % Assume a1 and a2 are always the same order of
                    % magnitude and assume m1 and m2 are always the same
                    % order of magnitude
                    % Total number of runs = numIterationValues^2
                    initials = horzcat(repmat(repmat(iterationValues', numIterationValues, 1), 1, 2), ...
                        repmat(repelem(iterationValues, numIterationValues)', 1, 2), ...
                        repelem(t0Guess, numIterationValues^2)');
                else
                    % Allow a1, a2, m1, and m2 to all be different orders
                    % of magnitude
                    % Total number of runs = numIterationValues^4
                    initials = horzcat(...
                        repmat(repelem(iterationValues, numIterationValues^3)', numIterationValues^0, 1), ...
                        repmat(repelem(iterationValues, numIterationValues^2)', numIterationValues^1, 1), ...
                        repmat(repelem(iterationValues, numIterationValues^1)', numIterationValues^2, 1), ...
                        repmat(repelem(iterationValues, numIterationValues^0)', numIterationValues^3, 1), ...
                        repelem(t0Guess, numIterationValues^4)');
                end
                waitbar(idx*progressBarStepSize, progressBarHandle, ...
                    'Setting up starting points...');
            end
        otherwise
            error('Unrecognized fit model');
    end

    
    bestFitGof.sse = [];
    bestFitGof.rsquare = -Inf;
    bestFitGof.dfe = [];
    bestFitGof.adjrsquare = [];
    bestFitGof.rmse = [];
    bestFit = [];
    waitbar(0.0, progressBarHandle, 'Estimating contrast agent arrival time...');
    numFits = size(initials, 1);
    progressBarStepSize = 1.0/numFits;
    for nthFit = 1:numFits
        try
            [fitresult, gof] = FitContrastArrivalTime( ...
                time(1:truncationLimit), C_t(1:truncationLimit), ...
                initials(nthFit,:), tRange, fitModel);
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
        waitbar(nthFit*progressBarStepSize, progressBarHandle, ...
            'Estimating contrast agent arrival time...');
    end
    
    arrivalTime = bestFit.t0;
    fitresult = bestFit;
    gof = bestFitGof;
    
    
    % [xData, yData] = prepareCurveData( time(1:truncationLimit), C_t(1:truncationLimit) );
    % figure( 'Name', [tissueType.ToDisplayName() ' CA Arrival Time ' fitModel ' Fit'] );
    % h = plot( bestFit, xData, yData );
    % legend(h, 'Concentration vs. Time', [fitModel ' Fit'], ...
    %     'Location', 'NorthEast');
    % % Label axes
    % xlabel Time
    % ylabel Concentration
    % grid on
    
    close(progressBarHandle);
end