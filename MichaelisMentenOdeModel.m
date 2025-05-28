function dydt = MichaelisMentenOdeModel(p, t, y, timevec, Ces)
    % MichaelisMentenOdeModel   Implementation of the model from Ulloa et al 2013 NMR Biomed paper, "Assessment of
    %                           gadoxetate DCE-MRI as a biomarker of hepatobiliary transporter inhibition." This
    %                           implementation is deprecated. Use the PkMichaelisMentenOdeModel class instead.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette

    Ces = interp1(timevec, Ces, t, 'pchip');
    dydt = DescaleParameter(p(1)).*Ces - (DescaleParameter(p(3)).*y)./(DescaleParameter(p(2))+y);
end

%% Documentation of the parameter ordering
%
% p(1) is k1
% p(2) is kM
% p(3) is Vmax