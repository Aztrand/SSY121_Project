function [ output_args ] = lpf( input_args )
%LPF Summary of this function goes here
%   Detailed explanation goes here
fs = 1000;
Wp = 37*2/fs;
Wr = 40*2/fs;
Ap = 1;
Ar = 5;

[N,Wc] = buttord(Wp,Wr,Ap,Ar);
[b,a] = butter(N,Wc);
[H,w] = freqz(b,a,512);
figure(),plot(w*fs/(2*pi),abs(H));
%ʹ��FFT�õ��˲����źŵ�Ƶ��
y2 = filter(b,a,y1);

end

