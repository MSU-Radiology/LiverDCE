function pointsVector = RandomPointsInInterval(low, high, numberOfPoints, varargin)
    % RandomPointsInInterval    Generates a matrix consisting of the desired number of random points in the specified
    %                           interval. By default, a column vector is returned. If an optional 4th argument is
    %                           provided, it specifies the number of columns in the matrix that is returned.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    if(nargin < 4)
        numberOfColumns = 1;
    else
        numberOfColumns = varargin{1};
    end

    pointsVector = low + (high - low)*rand(numberOfPoints, numberOfColumns);
end