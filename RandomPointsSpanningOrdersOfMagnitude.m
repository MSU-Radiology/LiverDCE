function pointsVector = RandomPointsSpanningOrdersOfMagnitude(lowExponent, highExponent, numberOfPoints, varargin)
    % RandomPointsInInterval    Generates a matrix consisting of the desired number of random points in the interval
    %                           between 10^lowExponent and 10^highExponent. By default, a column vector is returned. 
    %                           If an optional 4th argument is provided, it specifies the number of columns in the 
    %                           matrix that is returned.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    if(nargin < 4)
        numberOfColumns = 1;
    else
        numberOfColumns = varargin{1};
    end

    exponentRange = abs(lowExponent) + abs(highExponent);
    exponentOverUnder = exponentRange/2;
    exponentMidpoint = lowExponent + exponentOverUnder;
    pointsVector = power(10, exponentOverUnder*RandomPointsInInterval(-1.0, 1.0, numberOfPoints, ...
        numberOfColumns)+exponentMidpoint);
end