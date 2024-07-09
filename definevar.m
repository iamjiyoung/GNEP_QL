% For a given vector [n(1), n(2), ..., n(N)], define variables x(1), x(2), ..., x(N), 
% where the length of each variable x(i) is n(i) for i = 1, 2, ..., N.
%
% J. Choi, March 9, 2023

total = sum(n);

mpol('x', total);

% Define x1, x2, ...
j = 1;
for i=1:length(n)
    index = int2str(i);
    var = genvarname(sprintf('%s%s','x',index));
    eval([var ' = x(j:j+n(i)-1);']); 
    j = j+n(i);
end
