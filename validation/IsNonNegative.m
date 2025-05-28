function bool = IsNonNegative(value)
    % IsNonNegative     Returns true if the specified value is greater than or equal to 0
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    bool = isnumeric(value) && value >= 0.0;
end