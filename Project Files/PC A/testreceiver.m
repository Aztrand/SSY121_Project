clear all;
clc; clf;

IQ=([0 2 10 8;  1 3 11 9  ...
;5 7 15 13;  4 6 14 12]);

Q=3; I=3;

Qnorm = (Q+3)/2+1;
Inorm = (I+3)/2+1;

    
mess=IQ(Qnorm,Inorm)
messB=de2bi(mess)
mess=bi2de(messB);

