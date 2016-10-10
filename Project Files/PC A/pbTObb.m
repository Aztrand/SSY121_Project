function [ y1 ] = pbTObb( y,fc,Tsamp )
%PBTOBB Summary of this function goes here
%   y is the received signal
n = (0:length(y)-1); %changed to '
y_real = sqrt(2)*real(y).*cos(2*pi*fc*Tsamp.*n');
y_image = sqrt(2)*imag(y).*sin(2*pi*fc*Tsamp.*n');
y1 = y_real+1i.*y_image;
%N_y1 = max(1024,length(y1)); 
%y1_fft = abs(fftshift(fft(y1,N_y1)));
%w = (fsamp/N_y1)*(-floor(N_y1/2):1:ceil(N_y1/2)-1);

end

