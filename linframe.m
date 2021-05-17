function [fx,fpad] = linframe(x,fhop,flen,padtype)
% LINFRAME Splits a signal in linearly spaced frames.
%   [fx,fpad] = linframe(x,fhop,flen,padtype)
%
%   By returning a matrix version of the framed signal we enable
%   vectorized processing. It can be used for MDCT using 'sym'
%   (symmetric) padtype.
%
%   x:       input signal
%   fhop:    hop length (default 128)
%   flen:    length of frame (if empty defaults to 2*fhop)
%   padtype: how to pad start/end of signal. Values: 'trunc','pad','sym'
%            defaults to 'pad'
%   fx:      framed output signal. (frame per column)
%   fpad:    misc info for padding.unpadding
%            fpad(1): start pad
%            fpad(2): end pad
%            we use this value in linunframe() and so we return
%            equal length signal as the original. This way we can
%            calculate the difference etc.
%            fpad(3): contains the length of x (for reconstruction)
%            (added recently, i don't require pad(2) but anyway...)
%            fpad(4): frame hop
%            fpad(5): frame length (number of rows)
%            fpad(6): number of frames (number of columns)

% ------- linframe.m ---------------------------------------
% Marios Athineos, marios@ee.columbia.edu
% http://www.ee.columbia.edu/~marios/
% Copyright (c) 2002-2003 by Columbia University.
% All rights reserved.
% ----------------------------------------------------------

% Check arguments
if (nargin < 2)
    fhop = 128;
end
if (nargin < 3)
    flen = 2*fhop;
end
if (nargin < 4)
    padtype = 'pad';
end
if isempty(flen)
    flen = 2*fhop;
end

fpad = [0 0 0];
% Make column
x = x(:);
% Length of signal
xlen    = length(x);
fpad(3) = xlen;
% Number of frames
fnum = fix((xlen-flen+fhop)/fhop);
% Unframed samples
frem = rem(xlen-flen+fhop,fhop);

switch padtype
    % What should we do with the rem samples ?
case 'trunc'
    % Just discard what doesn't fit
    fpad(2) = -frem;
case 'pad'
    % Pad end with zeros (to complete extra frame)
    if (frem~=0)
        fpad(2) = fhop-frem;
        fnum    = fnum+1;
        x       = [x;ditherit(zeros(fpad(2),1))];
    end
case 'sym'
    % Pad with zeros both front and end symmetricaly (MDCT 50%) 
    if (isequal(frem,0))
        fnum    = fnum+2;
        fpad(1) = fhop;
        fpad(2) = fhop;
    else
        fnum    = fnum+3;
        fpad(1) = fix(((3*fhop)-frem)/2);
        fpad(2) = fpad(1)+1;
    end
%    x = [ditherit(zeros(fpad(1),1));x;ditherit(zeros(fpad(2),1))];
    x = [zeros(fpad(1),1); x; zeros(fpad(2),1)];
case 'sym2'
    % Pad with zeros both front and end symmetricaly (this came up for
    % feature extraction and doesn't assume 50% overlap)
    % This method is only defined for even fhop
    if rem(fhop,2)
        error('sym2 is defined only for fhop even');
    elseif fhop <= 0
        error('sym2 is defined only for possitive fhop');
    end            
    fnum = ceil(xlen/fhop);
    % Zero pad end if we need it
    if fnum*fhop > xlen
        x(fnum*fhop) = 0;
    end
    fpad(1) = (flen-fhop) / 2;
    fpad(2) = fpad(1);
    x = [zeros(fpad(1),1); x; zeros(fpad(2),1)];    
otherwise
    error('Wrong padtype.');
end

% Preallocate and store it frame per column
fx = zeros(flen,fnum);
% Index of frame start (to be added to sidx)
fidx = fhop*(0:(fnum-1));
% Make matrix of frame indexes (Tony's trick)
fidx = fidx(ones(flen,1),:);
% Index of sample ralative to frame start
sidx = (1:flen).';
% Make matrix of sample indexes
sidx = sidx(:,ones(1,fnum));
% Voila! This is as vectorized as it gets !!!
fx(:) = x(fidx+sidx);

% Put the frame length and number of frames in fpad
[fpad(5),fpad(6)] = size(fx);
fpad(4) = fhop;

% ----------------------------------------------------------
% Note:
% We used Tony's Trick (mathworks.com Tech-Note 1109)
% The following multiplication gives the same result
% but it's more expensive.
% fidx = ones(flen,1)*fidx;
% sidx = sidx*ones(1,fnum);