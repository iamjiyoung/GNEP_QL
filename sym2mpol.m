function [varargout] = sym2mpol(n, varargin)
%
% [B1, B2, ...] = sym2mpol(n, A1, A2, ...)
%
% n: a vector with ith element indicates dimension of xi
% Ai: n by m real symbolic polynomial data
%
% Bi: n by m mpol data each Bi(j,k) corresponds to Ai(j,k)

% J.Choi, 4 April, 2023
% X.Tang, 11 April, 2023
% J.Choi, 17 April, 2023
% J.Choi, 18 May, 2025

total = sum(n);

mpol('x', total);

for i = 1:length(n)
    ni_str = string(1:n(i));
    xi_str = ['x', int2str(i)];
    xi_vec = strcat(xi_str, ni_str);
    mpol_index = string(sum(n(1:i-1)) + 1 : sum(n(1:i)));
    mpol_vec = strcat('x(', mpol_index, ')');
    
    to_eval = strcat(xi_vec, '=', mpol_vec, ';');
    eval(strjoin(to_eval, ' '));
    
    full_vec_assign = xi_str + " = x(" + mpol_index(1) + ":" + mpol_index(end) + ");";
    eval(full_vec_assign);
end


for i = 1:nargin-1
    [r, c] = size(varargin{i});
    A = mpol(zeros(r,c));
    Ai_sym = varargin{i};
    Ai_str_mat = reshape(string(Ai_sym), size(Ai_sym));  
    [row, col] = size(Ai_str_mat);
    row_strs = strings(row,1);
    for r = 1:row
        row_strs(r) = strjoin(Ai_str_mat(r,:), ', ');  
    end
    Ai_str = strjoin(row_strs, '; ');  
    to_eval_Ai = 'A = [' + Ai_str + '];';
    eval(to_eval_Ai);

    varargout{i} = A;
end

for i = 1:nargin-1
    if isa(varargout{i}, 'double') == 1
        varargout{i} = mpol(varargout{i});
    else

    end 
end

