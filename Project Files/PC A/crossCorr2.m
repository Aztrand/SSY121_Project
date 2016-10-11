function [c] = crossCorr2(x, y)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    %c=zeros(length(y),1);
%     for j=1: length(y)
%         for m=1: length(x)
%             c(j)=c(j)+x(j)*y(j+m);  
%         end;    
%     end;

corrLength=length(x)+length(y)-1;



c=fftshift(ifft(fft(x,corrLength).*conj(fft(y,corrLength))));
%     [V,C] = max(c);
end

