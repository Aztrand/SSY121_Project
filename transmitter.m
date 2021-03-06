function transmitter(packet,fc)
%%%%%%%%%choose parameters%%%%%%%%%%%%%%
x=packet;
x';
N=length(x); %length of data


%%%%%%%%%choose parameters%%%%%%%%%%%%%%
rb = 440;                                % bit rate [bit/sec]
fsamp = 44e3;                            %sample rate
Tsamp = 1/fsamp;                           % Number of bits per symbol
M = 4;
m = log2(M);                        % Number of bits per symbol
fsymb = rb/m;                          % Symbol rate [symb/s]
fsfd = fsamp/fsymb;                    % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity) [samples/symb]
%%%%%% frame synchronazation
%s_dect=[1,1, 1,1, 1,1, 1,1, 1,1, 0,0, 0,0, 1,1, 1,1, 0,0, 1,1, 0,0, 1,1]; %4QAM, but only using real -> BPSK
%s_dect=[0,0, 0,0, 0,0, 0,0, 0,0, 1,1, 1,1, 0,0, 0,0, 1,1, 0,0, 1,1, 0,0];
%s_dect=[1,0,0,1 1,0,0,1 1,0,0,1 1,0,0,1 1,0,0,1 0,0,1,1 0,0,1,1 1,0,0,1 1,0,0,1 0,0,1,1 1,0,0,1 0,0,1,1 1,0,0,1];  %%%the signal used to detection.
xv=[];
extr=zeros(1,13*9);
extr1 = zeros(1,30);
extr2 = zeros(1,8);
%xv=[s_dect,s_dect,s_dect,x'];
%xv=[s_dect,s_dect,x',s_dect,x'];
s_dect = [1 1 1 1 1 -1 -1 1 1 -1 1 -1 1];
%%%QAM
[x_qam,s] = QAM4(x',M);
x_qam = cat(2,s_dect ,s_dect , s_dect, extr, s_dect, extr1, x_qam);
% scatterplot(x_qam);
x_qamasd = x_qam';
%[x_qam,s] = QAM16(xv,M);
% figure(1),

% scatterplot(s); grid on;                            % Constellation visualization
% figure(1)
% scatterplot(x_qam); grid on;


xu = zeros(length(x_qam)*fsfd,1);
xu(1:fsfd:end) = x_qam ;     % Space the symbols fsfd apart, to enable pulse shaping using conv.
%xu = upsample(x_qam,fsfd);
span = 6;                               %how many symbol times to we want of pulse 
a = 0.2;                                  % Roll off factor

[pulse, t] = rtrcpuls(a,1/fsymb,fsamp,span); %RRC
%%plot rrc pulse in time and frequency domain
N1 = max(1024,length(pulse)); 
rrc_f = abs(fftshift(fft(pulse,N1)));
fvec1 = (fsamp/N1)*(-floor(N1/2):1:ceil(N1/2)-1); % For both even and odd N
% figure(3),
% subplot(211),
% plot(pulse);title('RRC in time domain');
% subplot(212),
% plot(fvec1,20*log10(rrc_f));title('RRC in frequency domain');
% xlabel('Frequency in Hz');
% ylabel('Power in dB');

% Each symbol replaced by the pulse shape and added
pulse_train = conv(xu,pulse);  
% figure(1);
% plot(real(pulse_train));

n = (0:length(pulse_train)-1)';
realpulse = real(pulse_train).*sqrt(2).*cos(2*pi*fc*Tsamp.*n);
imagpulse = imag(pulse_train).*sqrt(2).*sin(2*pi*fc*Tsamp.*n);
pulse_train_passband = realpulse+imagpulse;
pulse_train_passband = pulse_train_passband/max(pulse_train_passband);
%%soundsc automatically normalizes the sound.

% %ADDED phase sync
% % 
% bb_signal = pbTObb(pulse_train_passband, fc, Tsamp);
% 
% lpf_signal = lpf(bb_signal);
% 
% mf_signal = mf(pulse, lpf_signal, fsfd);
% 
% mf_signal_rz = mf_signal(2*span*fsfd:end-2*span*fsfd);

% 
% const = mf_signal_rz(1:fsfd:end)/3
% figure(2)
% scatterplot(const)
% title('After MF')
% 
% const=exp(i*pi/3).*const %Added phase shift.
% figure(3)
% scatterplot(const); grid on
% title('through mf and extra distorted')
% %phase shift - USE THIS BEFORE REMOVING BARKER SEQUENCE.
% Const=[-1+1i]; %First barker set (2 BITS FOR 4QAM AND 4 BITS FOR 16QAM)
% b=angle(Const)-angle(const(1)) %const(1) IS THE FIRST SYMBOL IN THE RECEIVED MESSAGE
% const=exp(i*b).*const; %const IS NOW PHASED SHIFTED TO ORIGINAL.
% 
% figure(4)
% scatterplot(const); grid on
% title('Fixed')

%

%pulse_train_passband = realpulse+1i.*imagpulse;
%pulse_train_passband = pulse_train_passband.*exp(1i*2*pi*fc/fsamp.*n);

% figure(5)
% subplot(3,1,1); 
% plot(Tsamp*(0:(length(pulse_train)-1)), real(pulse_train), 'b');
% title('real');
% xlabel('seconds');
% subplot(3,1,2); 
% plot(Tsamp*(0:(length(pulse_train)-1)), imag(pulse_train), 'b');
% title('imag');
% xlabel('seconds');
% subplot(3,1,3); 
% plot(Tsamp*(0:(length(pulse_train)-1)), pulse_train, 'b');
% title('baseband signal');
% xlabel('seconds');
% figure(6)
% subplot(3,1,1); 
% plot(Tsamp*(0:(length(pulse_train_passband)-1)), real(pulse_train_passband), 'b');
% title('real');
% xlabel('seconds');
% subplot(3,1,2); 
% plot(Tsamp*(0:(length(pulse_train_passband)-1)), imag(pulse_train_passband), 'b');
% title('imag');
% xlabel('seconds');
% subplot(3,1,3); 
% plot(Tsamp*(0:(length(pulse_train_passband)-1)), pulse_train_passband, 'b');
% title('passband signal');
% xlabel('seconds');
% compute DFT and scale frequency axes to represent analog frequencies
% N = max(1024,length(real(pulse_train_passband))); 
% P1 = fftshift(fft(pulse_train_passband,N));
% fvec = (fsamp/N)*(-floor(N/2):1:ceil(N/2)-1); % For both even and odd N
% fvec = 0:1:ceil(N-1); % For both even and odd N
% 
% figure(7); 
% plot(pulse_train_passband)
% [Pxx,w] = pwelch(pulse_train_passband);
% figure(8)
% plot(w,Pxx)
% N = max(1024,length(pulse_train_passband)); 
% fvec = (fsamp/N)*(-floor(N/2):1:ceil(N/2)-1); % For both even and odd N
% P1 = fftshift(fft(pulse_train_passband,N));
% P1 = P1(end/2:end);
% fvec = fvec(end/2:end);
% % figure(9)
% plot(fvec-fc,20*log10(abs(P1/max(P1))));

% plot(fvec,20*log10(abs(P1/max(P1))));
% xlabel('Frequency in Hz');
% ylabel('Power in dB');

wavplay(pulse_train_passband,fsamp); %does not normalize the sound
%soundsc(pulse_train_passband,fsamp);