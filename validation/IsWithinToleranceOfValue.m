function bool = IsWithinToleranceOfValue(targetValue, value, tolerance)
    % IsWithinToleranceOfValue  Returns true if the difference between specified value and the target value is less 
    %                           than or equal to the specified tolerance
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    bool = abs(targetValue - value) <= tolerance;
end