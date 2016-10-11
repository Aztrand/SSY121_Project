function transmitter(packet,fc)
%%%%%%%%%choose parameters%%%%%%%%%%%%%%
x=packet
N=length(x);                            %length of data
%%%%%%%%%choose parameters%%%%%%%%%%%%%%
rb = 440;                                % bit rate [bit/sec]
fsamp = 44e3;                            %sample rate
Tsamp = 1/fsamp;                           % Number of bits per symbol
M = 16;
m = log2(M);                        % Number of bits per symbol
fsymb = rb/m;                          % Symbol rate [symb/s]
fsfd = fsamp/fsymb;                    % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity) [samples/symb]
%%%%%% frame synchronazation
s_dect=[1,0,0,1,1,0,0,1,1,0,0,1,0,0,1,1,0,0,1,1,1,0,0,1,0,0,1,1];  %%%the signal used to detection.
s=zeros(1,432);
j=28;               %%the number of bits that were used to detect.
for i=1:N
    s(i+j+4)=x(i);
end

for i=1:j
    s(i)=s_dect(i);
end
x=s;
%%%QAM
[x_qam,s] = QAM16(x,M);
% figure(1),
% scatterplot(s); grid on;                            % Constellation visualization
% figure(2),
% scatterplot(x_qam); grid on;


xu = zeros(length(x_qam)*fsfd,1);
xu(1:fsfd:end) = x_qam ;     % Space the symbols fsfd apart, to enable pulse shaping using conv.

span = 6;                               %how many symbol times to we want of pulse 
a = 0.2;                                  % Roll off factor

[pulse, t] = rrcpulse(a,1/fsymb,fsamp,span); %RRC
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
pulse_train = conv(pulse,xu);  

n = (0:length(pulse_train)-1)';
realpulse = real(pulse_train).*sqrt(2).*cos(2*pi*fc*Tsamp.*n);
imagpulse = imag(pulse_train).*sqrt(2).*sin(2*pi*fc*Tsamp.*n);
pulse_train_passband = realpulse-imagpulse;
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
N = max(1024,length(real(pulse_train_passband))); 
P1 = fftshift(fft(pulse_train_passband,N));
fvec = (fsamp/N)*(-floor(N/2):1:ceil(N/2)-1); % For both even and odd N
%fvec = 0:1:ceil(N-1); % For both even and odd N

figure(7); 
plot(fvec,20*log10(abs(P1/max(P1))));
xlabel('Frequency in Hz');
ylabel('Power in dB');

soundsc(pulse_train_passband,fsamp);