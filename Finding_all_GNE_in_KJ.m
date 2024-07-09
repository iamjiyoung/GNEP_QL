
delta = 0.5; in_max = 1; % If we find appropriate delta, in_max = 0

while in_max == 1
    K_max = [KJ_initial; FJ <= subs(FJ, x, xJ) + delta];
    
    k = k0; sta = 0;
    while sta == 0 && k <= k_max
        PJ = msdp(max(FJ), K_max, k);
        [sta, obj_max] = msol(PJ);
        k = k+1;   
    end

    if sta >= 0

        u = double(mom(x));

        if abs(double(subs(FJ,x,u))-double(subs(FJ,x,xJ))) < 1e-4
            in_max = 0;
        else
            delta = delta/2;
        end

    else 
        fprintf('Numerical Issue!\n');
        in_max = 0;
    end
end
