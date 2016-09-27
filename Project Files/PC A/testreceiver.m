clear all;
%clc;

%

%Constellation
IQ=([0 2 10 8;  1 3 11 9  ...
;5 7 15 13;  4 6 14 12]);

iq=([-3 -3; -1 -1; 1 1; 3 3]);

%Q=1; I=3;
s=[];
for i=1:length(iq)
        Qnorm = (iq(i,1)+3)/2+1;
        Inorm = (iq(i,2)+3)/2+1;
        mess=IQ(Qnorm,Inorm);
        messB(i,:)=de2bi(mess,4);
        s = [s,messB(i,:)];
end

s

%mess=IQ(Qnorm,Inorm)
%messB=de2bi(mess)
%mess=bi2de(messB)

