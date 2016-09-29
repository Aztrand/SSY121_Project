function [ y1 ] = pbTObb( y )
%PBTOBB Summary of this function goes here
%   y is the received signal
n = (0:length(pulse_train_passband)-1);
y_real = real(y).*sqrt(2).*cos(2*pi*fc*Tsamp.*n);
y_image = imag(y).*sqrt(2).*sin(2*pi*fc*Tsamp.*n);
y1 = y_real+1i.*y_image;
%N_y1 = max(1024,length(y1)); 
%y1_fft = abs(fftshift(fft(y1,N_y1)));
%w = (fsamp/N_y1)*(-floor(N_y1/2):1:ceil(N_y1/2)-1);

end

