function bool = IsNonZeroPositiveFinite(value)
    % IsNonZeroPositiveFinite   Returns true if the specified value is a finite number greater than 0
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    bool = isnumeric(value) && isfinite(value) && isreal(value) && value > 0;
end