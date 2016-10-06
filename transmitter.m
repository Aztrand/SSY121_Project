function transmitter(packet,fc)
%%%%%%%%%choose parameters%%%%%%%%%%%%%%
x=packet;
M=16;                                  %Number of symbols in the constellation
rb=440;                                % bit rate [bit/sec]
fsamp=44e3;                            %sample rate
Tsamp=1/fsamp;
m=log2(M);                            % Number of bits per symbol
fsymb =rb/m;                          % Symbol rate [symb/s]
fsfd = fsamp/fsymb;                    % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity) [samples/symb]
%%%QAM
s=qammod((0:M-1)',M);                   %quadrature amplitude modulated (QAM) signal 
figure(1)
scatterplot(s);grid on;title('16-QAM');

x_buffer = buffer(x, m)';               % Group bits into bits per symbol
sym_idx = bi2de(x_buffer, 'left-msb')'+1;  % Bits to symbol index
y_qam= s(sym_idx);                          % Look up symbols using the indices
figure(2)
scatterplot(y_qam);grid on;

x_upsample = upsample(y_qam, fsfd);     % Space the symbols fsfd apart, to enable pulse shaping using conv.

span = 6;                               %how many symbol times to we want of pulse 
a=0.1;                                  % Roll off factor
[pulse, t] =rtrcpuls(a,1/fsymb,fsamp,span);%RRC
pulse_train = conv(pulse,x_upsample);   % Each symbol replaced by the pulse shape and added

% realpulse = real(pulse_train)*sqrt(2)*cos(2*pi*fc*t);
% imagpulse = imag(pulse_train)*sqrt(2)*sin(2*pi*fc*t);
n = (0:length(pulse_train)-1)';
pulse_train = pulse_train.*exp(1i*2*pi*fc/fsamp*n);
% pulse_train = realpulse+1i.*imagpulse;
figure(4)
plot(pulse);title('root cosin')
figure(5)
subplot(2,1,1); 
plot(Tsamp*(0:(length(pulse_train)-1)), real(pulse_train), 'b');
title('real')
xlabel('seconds')
subplot(2,1,2); 
plot(Tsamp*(0:(length(pulse_train)-1)), imag(pulse_train), 'b');
title('imag')
xlabel('seconds')

% compute DFT and scale frequency axes to represent analog frequencies
N = max(1024,length(pulse_train)); 
P1 = fft(pulse_train,N);
%fvec = (fsamp/N)*(-floor(N/2):1:ceil(N/2)-1); % For both even and odd N
fvec = 0:1:ceil(N-1); % For both even and odd N

figure(4); 
plot(fvec,20*log10(abs(P1)));
xlabel('Frequency in Hz')
ylabel('Power in dB')

soundsc(real(pulse_train),fsamp);
disp('Complete the transmitter')

end