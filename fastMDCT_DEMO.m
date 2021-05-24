% ref: https://www.ee.columbia.edu/~marios/mdct/mdct_giraffe.html
clear;
[x_in,Fs] = audioread('Queen-AnotherOneBitestheDust_CUT.wav');
x_in=x_in(:,1);
hop=256;
win=2*hop;
[fx,fpad] = linframe(x_in,hop,win,'sym'); % thus 50% overlap
%fx = winit(fx,'kbdwin'); % kbd win is TDAC
%fx = winit(fx,'hann'); 
fx = winit(fx,'sinewin'); 
FX = mdct4(fx);
fy = imdct4(FX);
%fy = winit(fy,'kbdwin'); % rewindow
%fy = winit(fy,'hann'); % rewindow
fy = winit(fy,'sinewin'); % rewindow
y_out  = linunframe(fy,hop,fpad); % OLA
err  = mean((x_in-y_out).^2) % so our error for mdct4

sound(y_out,Fs)

%sound(x_in,Fs)
