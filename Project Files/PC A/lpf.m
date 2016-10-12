function [ filtered_signal ] = lpf( y1 )
%LPF Summary of this function goes here
%   Detailed explanation goes here
fs = 1000;
Wp = 36*2/fs;
Wr = 40*2/fs;
Ap = 1;
Ar = 5;

[N,Wc] = buttord(Wp,Wr,Ap,Ar);
[b,a] = butter(N,Wc);
[H,w] = freqz(b,a,512);
%figure(),plot(w*fs/(2*pi),abs(H));
%ʹ��FFT�õ��˲����źŵ�Ƶ��
filtered_signal = filter(b,a,y1);

end

