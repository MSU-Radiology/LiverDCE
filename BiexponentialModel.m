function F = BiexponentialModel(freeParameters, t)
    % BiexponentialModel    WIP pharmacokinetic model. This code has not been validated.
    %
    % Copyright (C) 2025    Michigan State University
    % Author:   Matt Latourette
    
    % Change to [F, J] = BiexponentialModel(freeParameters, t) if we need to
    % compute the Jacobian instead of relying on finite differences
    a = freeParameters(1);
    b = freeParameters(2);
    c = freeParameters(3);
    d = freeParameters(4);
    k1 = freeParameters(5);
    kM = freeParameters(6);
    Vmax = freeParameters(7);
    f1 = a.*exp(b.*t)+c.*exp(d.*t);
    f2 = (a.*b.*exp(b.*t)+c.*d.*exp(d.*t)+Vmax.* ...
        (a.*exp(b.*t)+c.*exp(d.*t))./(kM+a.*exp(b.*t)+c.*exp(d.*t)))./k1;
    F = [f1; f2];
 end