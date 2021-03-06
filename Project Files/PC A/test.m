%clc;clear all;close all;
%Chat_PC_A_Tx;       
data_bin = [1 0 0 1 1 0 1 0 1 1 1 0 0 1 1 1 0 1 0 1 1 1 0 1 0 1 0 0 0 1 1 1 0 0 1 1 0 1 0 1 1 1 1 0 1 1 0 0 1 0 1 0 1 0 0 0 1 1 0 1 0 1 0 1 1 1 0 1 0 1 0 0 0 0 1 1 1 0 1 0 1 1 1 0 1 0 0 1 1 0 1 0 1 0 1 0];

x=data_bin; 
N=length(x);                            %length of data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%transmiter%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%choose parameters%%%%%%%%%%%%%%
rb=440;                                % bit rate [bit/sec]
fsamp=44e3;                            %sample rate
fc=2500;
Tsamp=1/fsamp;                           % Number of bits per symbol
M=16;
m = log2(M);                        % Number of bits per symbol
fsymb =rb/m;                          % Symbol rate [symb/s]
fsfd = fsamp/fsymb;                    % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity) [samples/symb]

%%%QAM
[x_qam,s]=QAM16(x,M);
figure(1),
scatterplot(s); grid on;                            % Constellation visualization
figure(2)
scatterplot(x_qam); grid on;

x_upsample = upsample(x_qam, fsfd);     % Space the symbols fsfd apart, to enable pulse shaping using conv.

span = 6;                               %how many symbol times to we want of pulse 
a=0.3;                                  % Roll off factor
[pulse, t] =rtrcpuls(a,1/fsymb,fsamp,span);%RRC
%%plot rrc pulse in time and frequency domain
N1= max(1024,length(pulse)); 
rrc_f= abs(fftshift(fft(pulse,N1)));
fvec1 = (fsamp/N1)*(-floor(N1/2):1:ceil(N1/2)-1); % For both even and odd N

figure(4),
subplot(211),
plot(pulse);title('RRC in time domain');
subplot(212),
plot(fvec1,20*log10(rrc_f));title('RRC in frequency domain');
xlabel('Frequency in Hz');
ylabel('Power in dB');

pulse_train = conv(pulse,x_upsample);   % Each symbol replaced by the pulse shape and added

n = (0:length(pulse_train)-1);
realpulse = real(pulse_train).*sqrt(2).*cos(2*pi*fc*Tsamp.*n);
imagpulse = imag(pulse_train).*sqrt(2).*sin(2*pi*fc*Tsamp.*n);
pulse_train_passband = realpulse+1i.*imagpulse;
%pulse_train_passband = pulse_train_passband.*exp(1i*2*pi*fc/fsamp.*n);

figure(5)
subplot(3,1,1); 
plot(Tsamp*(0:(length(pulse_train)-1)), real(pulse_train), 'b');
title('real');
xlabel('seconds');
subplot(3,1,2); 
plot(Tsamp*(0:(length(pulse_train)-1)), imag(pulse_train), 'b');
title('imag');
xlabel('seconds');
subplot(3,1,3); 
plot(Tsamp*(0:(length(pulse_train)-1)), pulse_train, 'b');
title('baseband signal');
xlabel('seconds');
figure(6)
subplot(3,1,1); 
plot(Tsamp*(0:(length(pulse_train_passband)-1)), real(pulse_train_passband), 'b');
title('real');
xlabel('seconds');
subplot(3,1,2); 
plot(Tsamp*(0:(length(pulse_train_passband)-1)), imag(pulse_train_passband), 'b');
title('imag');
xlabel('seconds');
subplot(3,1,3); 
plot(Tsamp*(0:(length(pulse_train_passband)-1)), pulse_train_passband, 'b');
title('passband signal');
xlabel('seconds');
% compute DFT and scale frequency axes to represent analog frequencies
N = max(1024,length(pulse_train_passband)); 
P1 = fftshift(fft(pulse_train_passband,N));
fvec = (fsamp/N)*(-floor(N/2):1:ceil(N/2)-1); % For both even and odd N
%fvec = 0:1:ceil(N-1); % For both even and odd N

figure(7); 
plot(fvec,20*log10(abs(P1)));
xlabel('Frequency in Hz')
ylabel('Power in dB')
% axis([2000 3000 -100 100]);
%soundsc(real(pulse_train_passband),fsamp);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%reciver%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%add noise
snr = 20;
y = awgn(pulse_train_passband,snr,'measured');

%plot our signal with noise
figure(10); 
subplot(3,1,1); 
plot(Tsamp*(0:(length(y)-1)), real(y), 'b');
title('real')
xlabel('seconds')
subplot(3,1,2); 
plot(Tsamp*(0:(length(y)-1)), imag(y), 'b');
title('imag')
xlabel('seconds')
subplot(3,1,3); 
plot(Tsamp*(0:(length(y)-1)), y, 'b');
title('whole signal')
xlabel('seconds')


%----------------------------------------------
%r 去载波 实部cos 虚部sin(lecture#6)
n = (0:length(pulse_train_passband)-1);
y_real = real(y).*sqrt(2).*cos(2*pi*fc*Tsamp.*n);
y_image = imag(y).*sqrt(2).*sin(2*pi*fc*Tsamp.*n);
y1 = y_real+1i.*y_image;
N_y1 = max(1024,length(y1)); 
y1_fft = abs(fftshift(fft(y1,N_y1)));
w = (fsamp/N_y1)*(-floor(N_y1/2):1:ceil(N_y1/2)-1);
figure(11),
plot(w,20*log10(y1_fft));title('frequency domain');
xlabel('Frequency in Hz');
ylabel('Power in dB');
%----------------------------------------------
%LPF(low pass filter)
fs = 1000;
Wp = 37*2/fs;
Wr = 40*2/fs;
Ap = 1;
Ar = 5;

[N,Wc] = buttord(Wp,Wr,Ap,Ar);
[b,a] = butter(N,Wc);
[H,w] = freqz(b,a,512);
figure(),plot(w*fs/(2*pi),abs(H));
%使用FFT得到滤波后信号的频谱
y2 = filter(b,a,y1);
nfft = length(y2);
w1 = (fsamp/nfft)*(-floor(nfft/2):1:ceil(nfft/2)-1);
y2_fft = abs(fftshift(fft(y2,nfft)));
figure(12),
subplot(211),plot(w*fs/(2*pi),abs(H));
title('filter');grid
subplot(212),
plot(w1,20*log10(y2_fft));title('after LPF');
xlabel('Frequency in Hz');
ylabel('Power in dB');

% Create a Mached filter 
matched_filter = fliplr(pulse); %%%pulse is the RRCpulse
mf_output = conv(y2, matched_filter)/fsfd; %using convolution to remove RRCpulse

figure(13); 
subplot(2,1,1); 
plot(Tsamp*(0:(length(mf_output)-1)), real(mf_output), 'b');
title('real')
xlabel('seconds')
subplot(2,1,2); 
plot(Tsamp*(0:(length(mf_output)-1)), imag(mf_output), 'b');
title('imag')
xlabel('seconds')

%-------------------------------------------
%%%%Downsampling

%remove zeros
mf_output_rz = mf_output(2*span*fsfd:end-2*span*fsfd);
%sample to get symbols
x_hat = mf_output_rz(1:fsfd:end);

%ML decoding
complexValues = closest(x_hat);
bit_vector = demapping(complexValues)';

figure(23)
scatterplot(x_hat); grid on;
[numErrors, ber] = biterr(bit_vector, data_bin')

