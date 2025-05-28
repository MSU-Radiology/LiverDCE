function value = ConstrainValueToRange(value, rangeMin, rangeMax)
    % ConstrainValueToRange     Returns the specified value, unchanged, if the value is between rangeMin and rangeMax. 
    %                           Otherwise, returns the value within the range that is closest to the specified value.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    value = max(rangeMin, value);
    value = min(rangeMax, value);
end