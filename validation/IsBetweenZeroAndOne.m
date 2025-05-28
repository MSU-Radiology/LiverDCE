function bool = IsBetweenZeroAndOne(value)
    % IsBetweenZeroAndOne   Returns true if the specified value is greater than or equal to 0 and less than or equal 
    %                       to 1. If not, returns false.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    bool = isnumeric(value) && value >= 0.0 && value <= 1.0;
end