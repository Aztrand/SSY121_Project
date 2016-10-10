function [V,C] = crossCorr(x, y)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    %c=zeros(length(y),1);
%     for j=1: length(y)
%         for m=1: length(x)
%             c(j)=c(j)+x(j)*y(j+m);  
%         end;    
%     end;
    c=conv(x,y);
    [V,C] = max(c);
end

