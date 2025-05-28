function descaledParameters = DescaleParameter(scaledParameters)
    % DescaleParameter		Reverses any scaling of the parameter vector previously introduced using the 
    %                       ScaleParameter function. At present, no scaling is implemented.
    %
    % Copyright (C) 2025   Michigan State University
    % Author:  Matt Latourette

%     if(length(scaledParameters) == 7)
%         descaledParameters = scaledParameters.*[0.01 0.001 0.2 0.2 0.3 10 10];
%     else
        descaledParameters = scaledParameters.*1;
%     end
end