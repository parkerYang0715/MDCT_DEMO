function x = linunframe(fx,fhop,pad)
% LINUNFRAME Linearly unframes signal back to vector form (OLA).
%   x = linunframe(fx,fhop,unpad)
%
%   fx:   input signal (frame per column)
%   fhop: hop length
%   pad:  parameters on how to unpad (returned by linframe())
%   x:    output signal (vector)

% ------- linunframe.m -------------------------------------
% Marios Athineos, marios@ee.columbia.edu
% http://www.ee.columbia.edu/~marios/
% Copyright (c) 2002 by Columbia University.
% All rights reserved.
% ----------------------------------------------------------

[flen,fnum] = size(fx);

% Check arguments
if (nargin < 2)
    fhop = fix(flen/2);
end
if (nargin < 3)
    pad = [0 0 0];
end

% Length of final vector
xlen = fnum*fhop + flen - fhop;
% Advance length used in the sparse() trick
adv  = fnum*fhop;
% Sample index
sidx = (1:(fnum*flen)).';
% Frame index
fidx = adv*(0:(fnum-1));
fidx = fidx(ones(flen,1),:);
% Collapse into column vector
fidx = fidx(:);

% This is our linear index
lidx = sidx + fidx;
clear sidx fidx;
% Create 2D subscripts based on xlen
[i,j] = ind2sub2(xlen,lidx); %(my version is faster)
%[i,j] = ind2sub(xlen,lidx); %(built-in)
clear lidx;

% Don't try this with full matrices !!! :)
sp = sparse(i,j,fx,xlen,fnum);

% This, believe or not, is overlap add (OLA) !!!
x = full(sum(sp,2));

% Unpad
if (pad(2)<0)
    % It was truncated so pad it
    x(end-pad(2)) = 0;
elseif (pad(1)==0)
    % It was padded so truncate it
    x = x(1:end-pad(2));
%    x = x(1:pad(3));
else
    % 'sym' truncate both sides
%    x = x(1+pad(1):end-pad(2)+1);
    x = x(1+pad(1):(pad(1)+pad(3)));
end

end