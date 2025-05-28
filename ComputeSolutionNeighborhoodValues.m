function neighborhoodValues = ComputeSolutionNeighborhoodValues(parameter, overUnder, numberOfPoints)
    % ComputeSolutionNeighborhoodValues     Returns a vector of evenly-spaced floating point values, centered at the 
    %                                       specified parameter value and spanning the range from + or - the overUnder 
    %                                       value, with numberOfPoints values below the parameter value and 
    %                                       numberOfPoints values above the parameter value for a total of 
    %                                       2*numberOfPoints+1 values overall.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette

    parameterLow = parameter - overUnder;
    parameterHigh = parameter + overUnder;
    parameterStep = (parameterHigh - parameterLow) / (2 * numberOfPoints);
    neighborhoodValues = parameterLow:parameterStep:parameterHigh;
end