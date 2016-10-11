x=[1 0 0 1 1 0 1 0 1 1 1 0 0 1 1 1 0 1 0 1 1 1 0 1 0 1 0 0 0 1 1 1 0 0 1 1 0 1 0 1 1 1 1 0 1 1 0 0 1 0 1 0 1 0 0 0 1 1 0 1 0 1 0 1 1 1 0 1 0 1 0 0 0 0 1 1 1 0 1 0 1 1 1 0 1 0 0 1 1 0 1 0 1 0 1 0];

audioAcc=[];
%%%%%%%%%choose parameters%%%%%%%%%%%%%%
N=length(x);                            %length of data
%%%%%%%%%choose parameters%%%%%%%%%%%%%%
rb = 440;                                % bit rate [bit/sec]
fsamp = 44e3;                            %sample rate
fc= 2500;
Tsamp = 1/fsamp;                           % Number of bits per symbol
M = 16;
m = log2(M);                        % Number of bits per symbol
fsymb = rb/m;                          % Symbol rate [symb/s]
fsfd = fsamp/fsymb;                    % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity) [samples/symb]
%%%%%% frame synchronazation
s_dect=[1,0,0,1,1,0,0,1,1,0,0,1,0,0,1,1,0,0,1,1,1,0,0,1,0,0,1,1];  %%%the signal used to detection.
sos = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0,s_dect, x];
% s=zeros(1,432);
% j=28;               %%the number of bits that were used to detect.
% for i=1:N
%     s(i+j+4)=x(i);
% end
% 
% for i=1:j
%     s(i)=s_dect(i);
% end
% x=s;
% %%%QAM
% [x_qam,s] = QAM16(x,M);
% j=28;               %%the number of bits that were used to detect.
% for i=1:N
%     s(i+j+4)=x(i);
% end
% 
% for i=1:j
%     s(i)=s_dect(i);
% end

%%%QAM
[x_qam,s] = QAM16(sos,M);

xu = zeros(length(x_qam)*fsfd,1);
xu(1:fsfd:end) = x_qam ;     % Space the symbols fsfd apart, to enable pulse shaping using conv.

span = 6;                               %how many symbol times to we want of pulse 
a = 0.2;                                  % Roll off factor

[pulse, t] = rrcpulse(a,1/fsymb,fsamp,span); %RRC
%%plot rrc pulse in time and frequency domain
N1 = max(1024,length(pulse)); 
rrc_f = abs(fftshift(fft(pulse,N1)));
fvec1 = (fsamp/N1)*(-floor(N1/2):1:ceil(N1/2)-1); % For both even and odd N

pulse_train = conv(pulse,xu);  

n = (0:length(pulse_train)-1)';
realpulse = real(pulse_train).*sqrt(2).*cos(2*pi*fc*Tsamp.*n);
imagpulse = imag(pulse_train).*sqrt(2).*sin(2*pi*fc*Tsamp.*n);
pulse_train_passband = realpulse-imagpulse;


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
figure()
plot(pulse_train_passband);
audioArray = awgn(pulse_train_passband,10);
figure()
plot(audioArray);

%Create reference preamble
pre_ref = [3+1i, 3+1i, 3+1i, -3+1i, -3+1i, 3+1i, -3+1i];
xu = zeros(length(pre_ref)*floor(fsfd),1);
xu(1:fsfd:end) = pre_ref; 

audioAcc = cat(1,audioAcc,audioArray);

bb_signal = pbTObb(audioAcc, fc, Tsamp);
figure(8);
subplot(3,1,1)
plot(real(bb_signal));
subplot(3,1,2)
plot(imag(bb_signal));

lpf_signal = lpf(bb_signal);

span = 6;                               %how many symbol times to we want of pulse 
a=0.3;                                  % Roll off factor
[pulse, t] =rtrcpuls(a,1/fsymb,fsamp,span);
mf_signal = mf(pulse, lpf_signal, fsfd);

mf_signal_rz = mf_signal(2*span*fsfd:end-2*span*fsfd);
%sample to get symbols
const = mf_signal_rz(1:fsfd:end);

%realconst = real(const);
%realconst = realconst/(max(realconst))*3;
%imagconst = imag(const);
%imagconst = imagconst/(max(imagconst))*3;
%const = realconst + 1i*imagconst;
%plot(real(const))
%hold on
%plot(imag(const))

[r,lag] = xcorr(real(pre_ref), real(const));
figure();
plot(lag,r);
[V,C] = crossCorr2(pre_ref, const);

const1 = const(8: length(const));
complexValues = closest(const1);
%check = cat(2,complexValues(1:length(x_qam))',x_qam');
bit_vector = demapping(complexValues)';

[numErrors, ber] = biterr(x, bit_vector')