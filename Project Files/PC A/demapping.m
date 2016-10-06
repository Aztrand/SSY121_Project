function [ s ] = demapping( values )
%DEMAPPING Summary of this function goes here
%   Detailed explanation goes here

%Constellation
%const=([0 2 10 8;  1 3 11 9  ...
%;5 7 15 13;  4 6 14 12]);
const=([2 6 14 10; 3 7 15 11     ...
;1 5 13 9 ;0 4 12 8]);
%values=([-3 -3; -1 -1; 1 1; 3 3]);
%Q=1; I=3;
s=[];
for i=1:length(values)
        Qnorm = (real(values(i))+3)/2+1;
        Inorm = (imag(values(i))+3)/2+1;
        mess=const(Inorm,Qnorm);
        messB(i,:)=de2bi(mess,4,'left-msb');
        s = [s,messB(i,:)];
end


end

