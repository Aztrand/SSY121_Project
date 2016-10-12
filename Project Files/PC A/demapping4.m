function [ s ] = demapping4( values )
%DEMAPPING Summary of this function goes here
%   Detailed explanation goes here

const=([3 2 ; 1 0]);

s=[];
for i=1:length(values)
        Qnorm = (real(values(i))+1)/2+1;
        Inorm = (imag(values(i))+1)/2+1;
        mess=const(Inorm,Qnorm);
        messB(i,:)=de2bi(mess,4,'left-msb');
        s = [s,messB(i,:)];
end


end

