function scaledParameters = ScaleParameter(descaledParameters)
    % ScaleParameter		Scales the parameters of the specified parameter vector to obtain a rough order of 
    %                       magnitude match between parameters for the optimization procedure. Presently, no scaling is 
    %                       implemented.
    %
    % Copyright (C) 2025   Michigan State University
    % Author:  Matt Latourette

%     scaledParameters = 1.*descaledParameters;
%     if(length(descaledParameters) == 7)
%         scaledParameters = descaledParameters./[0.01 0.001 0.2 0.2 0.3 10 10];
%     else
        scaledParameters = descaledParameters./1;
%     end
end