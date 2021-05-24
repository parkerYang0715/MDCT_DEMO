function y = oggwin(N)
% OGGWIN Ogg-vorbis window.
%   Used in MDCT transform for TDAC
%   The window used in Ogg-Vorbis open source codec
%
%   N: length of window to create
%   y: the window in column

% ------- oggwin.m -----------------------------------------
% Marios Athineos, marios@ee.columbia.edu
% http://www.ee.columbia.edu/~marios/
% Copyright (c) 2004 by Columbia University.
% All rights reserved.

x = (0:(N-1)).';
y = sin(0.5*pi*sin(pi*(x+0.5)/N).^2); 

end