function [V,C] = crossCorr2(x, y)
%UNTITLED2 Summary of this function goes here

corrLength=length(x)+length(y)-1;



c=fftshift(ifft(fft(x,corrLength).*conj(fft(y,corrLength))'));
[v,C] = max(c);
V=real(v);
figure()
plot(c)
end

