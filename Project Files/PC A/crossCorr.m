function [ C ] = crossCorr(x, y)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    
    for j < length(y)
        for m < length(x)
            c(j)=c(j)+x(j)*y(j+m);  
        end;    
    end;
    [V,C] = max(c);
end

