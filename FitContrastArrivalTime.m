function [fitresult, gof] = FitContrastArrivalTime(time, concentration, startPoint, timeRangeIdxs, fitModel)
% FitContrastArrivalTime(time, concentration, startPoint, timeRange)
%  Fit the concentration data to a biexponential model to obtain an
%  estimate of the time when the contrast agent arrives in the organ of
%  interest. This is WIP code and the model has not been validated.
%
%  Data for 'Contrast Agent Arrival Time Fit' fit:
%      X Input : time
%      Y Output: concentration
%      Initial Estimate: startPoint
%      Time Indices: timeRangeIdxs, the indices of the times to try as
%      initial estimates of t0
%  Output:
%      fitresult : a fit object representing the fit.
%      gof : structure with goodness-of fit info.
%
%  See also FIT, CFIT, SFIT.


%% Fit: 'CA Arrival Time Fit'.
[xData, yData] = prepareCurveData( time, concentration );

% Set heaviside function's value at the origin to 1 and save the original
% value for the user's MATLAB environment so we can restore it after we're
% done
origheaviside = sympref('HeavisideAtOrigin',1);

% Set up fittype and options.
opts = fitoptions( 'Method', 'NonlinearLeastSquares', 'Robust', 'LAR' );
switch fitModel
    case 'Monoexponential'
        ft = fittype( 'heaviside(t-t0)*(a1*exp(-m1*(t-t0)))', ...
            'independent', 't', 'dependent', 'y' );
        opts.Lower = [0 0 time(timeRangeIdxs(1))];
        opts.Upper = [Inf Inf time(timeRangeIdxs(end))];
    case 'Biexponential'
        ft = fittype( 'heaviside(t-t0)*(a1*exp(-m1*(t-t0))+a2*exp(-m2*(t-t0)))', ...
            'independent', 't', 'dependent', 'y' );
        opts.Lower = [0 0 0 0 time(timeRangeIdxs(1))];
        opts.Upper = [Inf Inf Inf Inf time(timeRangeIdxs(end))];
    otherwise
        error('Unrecognized fit model');
end
opts.Display = 'Off';
opts.MaxFunEvals = 3000;
opts.MaxIter = 1500;
opts.StartPoint = startPoint;

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );

% Restore the original value for the heaviside function's value at the
% origin to whatever the user had set in their MATLAB preferences
sympref('HeavisideAtOrigin', origheaviside);

% % Plot fit with data.
% figure( 'Name', 'CA Arrival Time Fit' );
% h = plot( fitresult, xData, yData );
% legend( h, 'concentration vs. time', 'CA Arrival Time Fit', 'Location', 'NorthEast' );
% % Label axes
% xlabel time10
% ylabel blood10Trunc
% grid on


