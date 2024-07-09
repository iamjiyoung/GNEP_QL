function cut = defineind(n)
%
% cut = defineind(n)
%
% For a given vector with length sum(n), find indices that
% divide the vector into N sub-vectors, where the length of each sub-vector 
% is n(1), n(2), ..., n(N), respectively.
%
% cut(i,1): The starting index of the sub-vector with length n(i)
% cut(i,2): The ending index of the sub-vector with length n(i)
%
% J. Choi, March 9, 2023
%

N = length(n);

cut = zeros(N, 2); ind = 1;
for i = 1:N
    cut(i, 1) = ind;
    for j = 1:n(i)
        ind = ind+1;
    end
    cut(i, 2) = ind-1;
end