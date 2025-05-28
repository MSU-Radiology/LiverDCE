function fitResults = FitBiexponentialModel(time_original, Chep_original, Ces_original, acqZero, kmo)
    % FitBiexponentialModel     WIP biexponential model fitting code. This model hasn't been validated.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette

    % warning off MATLAB:singularMatrix;
    % warning off MATLAB:nearlySingularMatrix;
    % warning off MATLAB:divideByZero;
    
    time = time_original(acqZero:end);    % Truncated time vector
    Chep = Chep_original(acqZero:end);
    Ces = Ces_original(acqZero:end);

    concentrationSignals = zeros(2, length(time));
    concentrationSignals(1,:) = Chep;
    concentrationSignals(2,:) = Ces;
    
    switch size(kmo.InitialEstimate, 2)
        case 3
            initialEstimate = horzcat([0.5 -0.0005 -0.5 -0.005], kmo.InitialEstimate);
        case 7
            initialEstimate = kmo.InitialEstimate;
        otherwise
            initialEstimate = horzcat([0.5 -0.0005 -0.5 -0.005], kmo.InitialEstimate);
            [success, initialEstimate] = MatchParameterVectorSizeToFitBiexponentialModel(7, initialEstimate);
            if(~success)
                error('Initial estimate has the wrong number of parameters');
            end
    end
    
    switch size(kmo.LowerBound, 2)
        case 0
            lb = -Inf*ones(7);
        case 3
            lb = horzcat([-Inf -Inf -Inf -Inf], kmo.LowerBound);
        case 7
            lb = kmo.LowerBound;
        otherwise
            lb = horzcat([-Inf -Inf -Inf -Inf], kmo.LowerBound);
            [success, lb] = MatchBoundsVectorSizeToFitBiexponentialModel(7, lb);
            if(~success)
                error('Lower bound has the wrong number of parameters');
            end
    end
    
    switch size(kmo.UpperBound, 2)
        case 0
            ub = [];
        case 3
            ub = horzcat([Inf Inf Inf Inf], kmo.UpperBound);
        case 7
            ub = kmo.UpperBound;
        otherwise
            ub = horzcat([Inf Inf Inf Inf], kmo.UpperBound);
            [success, ub] = MatchBoundsVectorSizeToFitBiexponentialModel(7, ub);
            if(~success)
                error('Upper bound has the wrong number of parameters');
            end
    end
    
    opts = kmo.OptimizationOptions;
    switch kmo.OptimizerName
        case 'Levenberg-Marquardt'
            [freeParameters, resnorm, residual, exitflag, output] = lsqcurvefit(...
                @BiexponentialModel, initialEstimate, time, concentrationSignals, lb, ub, opts);
        case 'Trust Region Reflective'
            [freeParameters, resnorm, residual, exitflag, output] = lsqcurvefit(...
                @BiexponentialModel, initialEstimate, time, concentrationSignals, lb, ub, opts);
        otherwise
            error('Unknown optimizer');
    end

    a = freeParameters(1);
    b = freeParameters(2);
    c = freeParameters(3);
    d = freeParameters(4);
    k1 = freeParameters(5);
    kM = freeParameters(6);
    Vmax = freeParameters(7);
    
    figure
    plot(time, Chep, 'b.');
    hold on
    plot(time, a.*exp(b.*time)+c.*exp(d.*time), 'g');
    
    figure
    plot(time, Ces, 'b.');
    hold on
    plot(time, (a.*b.*exp(b.*time)+c.*d.*exp(d.*time)+ ...
        Vmax.*(a.*exp(b.*time)+c.*exp(d.*time))./ ...
        (kM+a.*exp(b.*time)+c.*exp(d.*time)))./k1, 'g');
    
    fitResults.a = a;
    fitResults.b = b;
    fitResults.c = c;
    fitResults.d = d;
    fitResults.k1 = k1;
    fitResults.kM = kM;
    fitResults.Vmax = Vmax;
    fitResults.resnorm = resnorm;
    fitResults.residual = residual;
    fitResults.exitflag = exitflag;
    fitResults.output = output;
end

%% MatchParameterVectorSizeToFitModel
function [matchSuccessful, sizeMatchedParameterVector] = MatchParameterVectorSizeToFitBiexponentialModel(...
        numberOfFreeParameters, parameterVector)
    % TODO: eliminate this duplicated code
    % This functionality is a duplicate of methods in the PharmacokineticModel class, placed here temporarily to make
    % the biexponential model work for now. Ultimately, the biexponential model should be reimplemented as a subclass of
    % PharmacokineticAlgebraicModel and this duplicated code eliminated.
    parameterVectorSize = length(parameterVector);
    if (parameterVectorSize < numberOfFreeParameters)
        sizeMatchedParameterVector = parameterVector;
        matchSuccessful = false;
        return
    end
    sizeMatchedParameterVector = parameterVector(1:numberOfFreeParameters);
    matchSuccessful = true;
end

%% MatchBoundsVectorSizeToFitModel
function [matchSuccessful, sizeMatchedBoundsVector] = MatchBoundsVectorSizeToFitBiexponentialModel(...
        numberOfBounds, boundsVector)
    % TODO: eliminate this duplicated code
    % This functionality is a duplicate of methods in the PharmacokineticModel class, placed here temporarily to make
    % the biexponential model work for now. Ultimately, the biexponential model should be reimplemented as a subclass of
    % PharmacokineticAlgebraicModel and this duplicated code eliminated.
    if(isempty(boundsVector))
        matchSuccessful = true;
        sizeMatchedBoundsVector = boundsVector;
        return
    end
    [matchSuccessful, sizeMatchedBoundsVector] = MatchParameterVectorSizeToFitBiexponentialModel(...
        numberOfBounds, boundsVector);
end