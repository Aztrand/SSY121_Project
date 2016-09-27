function [ s ] = demapping( values )
%DEMAPPING Summary of this function goes here
%   Detailed explanation goes here

%Constellation
const=([0 2 10 8;  1 3 11 9  ...
;5 7 15 13;  4 6 14 12]);
%values=([-3 -3; -1 -1; 1 1; 3 3]);
%Q=1; I=3;
s=[];
for i=1:length(values)
        Qnorm = (values(i,1)+3)/2+1;
        Inorm = (values(i,2)+3)/2+1;
        mess=const(Qnorm,Inorm);
        messB(i,:)=de2bi(mess,4);
        s = [s,messB(i,:)];
end


end

