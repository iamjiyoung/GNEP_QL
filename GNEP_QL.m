function RESULT = GNEP_QL(varargin)
% RESULT = GNEP_QL(n,F,A,b)
%
% Solve a Generalized Nash Equilibrium Problem (GNEP) with quasi-linear constraints.
%
% The quasi-linear constraint is given by A(i)x(i) >= b(x(-i)),
% where it is linear in x(i) but may be nonlinear in x(-i).
% 
% <INPUT>
% - n: A vector where the ith element corresponds to the dimensions of x(i).
% - F: A vector where the ith element corresponds to the ith player's objective.
% - A: A cell array where the ith cell corresponds to A(i).
% - b: A cell array where the ith cell corresponds to b(x(-i)).
% 
% <OUTPUT>
% RESULT is a struct array with six fields. RESULT(j) contains results extracted from K_J for some J in P.
% - J: The index J for K_J.
% - number_of_GNE: The number of Generalized Nash Equilibria (GNE) in K_J.
% - GNE: A matrix storing all GNEs in K_J. If there are no GNEs in K_J, this field is empty.
% - KKT: A matrix storing all Karush-Kuhn-Tucker (KKT) points in K_J. If there are no KKT points in K_J, this field is empty.
% - timeforJ: The computational time for K_J.
% - time: The accumulated time since executing GNEP_QL.
% 
% <Option>
% To get results for a specific K_J, use:
%    RESULT = GNEP_QL(n,F,A,b,J)
% Here, J is a cell array where J{i} indicates the working constraints for the ith player.
% Note that |J{i}| = n(i) based on the construction.
% 
% This function requires GloptiPoly, Yalmip, and Mosek to be properly installed.
% 
% J. Choi, May 19, 2024


mset('yalmip',true)
mset(sdpsettings('solver','mosek'))

% Define n 
n = varargin{1};
N = length(n);
definevar
cut = defineind(n);

% Define objective functions, constraints, and indices 
F = varargin{2};
A = varargin{3};
b = varargin{4};

df = cell(1, N);
J_all = cell(1, N);
for i = 1:N
    f(i) = F(i);
    z = x(cut(i,1):cut(i,2));
    
    % df{i}: gradient of f(i)
    df{i} = diff(f(i), z)';
    
    % J_all{i}: all indices sets for ith player
    J_all{i} = nchoosek([1:size(A{i}, 1)], n(i));
end

if nargin >= 5
    for i = 1:size(J_all,2)
        if isempty(varargin{5}{i}) == 0
            J_all{i} = varargin{5}{i};
        end
    end
end

Ji_ind = ones(1, N);
Ji_ind(N) = 0;


sum_n = sum(n);
if sum_n >= 10
    k_max = 2; % 10 <= dim(x)
elseif sum_n <= 5
    k_max = 5; % dim(x) = 1, 2, 3, 4, 5
elseif sum_n <= 7
    k_max = 4; % dim(x) = 6, 7
else
    k_max = 3; % dim(x) = 8, 9
end

dimofP = 0; % |P|

% Choose a generic positive definite Q which has largest eignvalue 1
Q = randn(length(mmon(x,1)));
Q = 0.5*(Q+Q');
Q = Q'*Q;
Q = Q/norm(Q);
FJ = mmon(x,1)'*Q*mmon(x,1);

% If P = emptyset, IN = 0
IN = 1; 

tic
while IN == 1
%%%%%%%%%% Choose J \in \mc{P}
    i = N; inc = 1;
    while i >= 1 && inc == 1
        if Ji_ind(i) < size(J_all{i},1)
            if i < N
                i = i-1;
            else
                Ji_ind(N) = Ji_ind(N)+1;
                inc = 0;
            end
        else
            j = i;
            while j~=0 && Ji_ind(j) == size(J_all{j},1)
                j = j-1;
            end
            if j == 0
                IN = 0; 
            else
                Ji_ind(j) = Ji_ind(j)+1;
                Ji_ind(j+1:i) = 1;
            end
            inc = 0;
        end
    end
    
    IN = any(arrayfun(@(x) Ji_ind(x) < size(J_all{x}, 1), 1:N));

    not_full_rank = 0; 

%%%%%%%%%% Construct pLME
    for i = 1:N
        AJ{i} = A{i}(J_all{i}(Ji_ind(i),:),:);
        if rank(AJ{i}) < rank(A{i})
            % In this case, J is not in P
            not_full_rank = 1;
            continue
        end
        bJ{i} = b{i}(J_all{i}(Ji_ind(i),:));
        lmd{i} = inv(AJ{i}*AJ{i}')*AJ{i}*df{i};
    end

    if not_full_rank == 1
        % Since J is not in P, we need to choose another J in P
        continue
    end

%%%%%%%%%% Construct KJ
    KJ_initial = [];
    k0=0;
    deg_0=0;
    for i = 1:N
        KJ_initial = [KJ_initial; A{i}*x(cut(i,1):cut(i,2))- b{i}>=0;
            lmd{i} >= 0;
            lmd{i}.*(AJ{i}*x(cut(i,1):cut(i,2)) - bJ{i}) == 0];
        deg_i = deg([A{i}*x(cut(i,1):cut(i,2))- b{i};lmd{i}.*(AJ{i}*x(cut(i,1):cut(i,2)) - bJ{i})]);
        deg_0=max(deg_0,deg_i);
    end
    dimofP = dimofP + 1;
    KJ = KJ_initial;
    SOL_all = []; % This set will store all GNE candidates in KJ
    KJ_all = [];
    t1 = toc;
    k0 = ceil(deg_0/2);

    sta_in = 1; % If we extract all KKT points in KJ, then sta_in = 0

    while sta_in == 1 
        k = k0; sta = 0;

%%%%%%%%%% Extract KKT point
        try 
            PJ = msdp(min(FJ), KJ, k);
        catch
            fprintf('Inconsistent support inequality constraint, skipped.\n');
            return
            sta = -1;
        end
        while sta == 0 && k <= k_max
            PJ = msdp(min(FJ), KJ, k);
            [sta, obj] = msol(PJ);
            k = k+1;
        end

        if sta >= 0 
            % One KKT point extracted
            xJ = double(mom(x));

            issolution = 1;
            if sta == 0
                issolution = 0;
                if abs(obj-double(subs(FJ,x,xJ))) < 1e-4
                    issolution = 1;
                end
            end
            if issolution == 1
                KJ_all = [KJ_all, xJ];
                for i = 1:N
                    y = mpol(xJ);
                    for j = cut(i,1):cut(i,2)
                        y(j) = x(j);
                    end
                    f_xu = subs(f(i), x, y);
                    f_uu = subs(f(i), x, xJ);
                    z = x(cut(i,1):cut(i,2));
                    if isempty(listvar(mpol(b{i}))) == 1
                        b_u = b{i};
                    else
                        b_u = subs(b{i}, x, xJ);
                    end
                    KK = [A{i}*z - b_u >= 0;];

                    k = k0; sta1 = 0;

                    while sta1 == 0
                        PP = msdp(min(f_xu-f_uu), KK, k);
                        [sta1, obj1(i)] = msol(PP);
                        k = k+1;
                    end
                end

                if min(obj1) >= -1e-4
                    SOL_all = [SOL_all, xJ];
                else

                end
                clear obj1;
            end
            Finding_all_GNE_in_KJ
            KJ = [KJ_initial;
                 FJ >= subs(FJ, x, xJ) + delta];
        else
            for i = 1:N
                RESULT(dimofP).J{i} = J_all{i}(Ji_ind(i),:);
            end
            RESULT(dimofP).number_of_GNE = size(SOL_all,2);
            RESULT(dimofP).GNE = SOL_all;
            RESULT(dimofP).KKT = KJ_all;
            RESULT(dimofP).timeforJ = toc-t1;
            RESULT(dimofP).time = toc;
            sta_in = 0;
       end
    end
end
toc
