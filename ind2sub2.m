function [i,j] = ind2sub2(siz,lidx)
%IND2SUB2 Multiple subscripts from linear index. (2D case only)

% Zero-based linear index
zlidx = lidx-1;
clear lidx;

j = fix(zlidx./siz) + 1;
i = zlidx - siz.*(j-1) + 1; 

%i = rem(zlidx,siz)+1;
%j = fix(zlidx/siz)+1;