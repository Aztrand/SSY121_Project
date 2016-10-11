x=[1 0 0 1 1 0 1 0 1 1 1 0 0 1 1 1 0 1 0 1 1 1 0 1 0 1 0 0 0 1 1 1 0 0 1 1 0 1 0 1 1 1 1 0 1 1 0 0 1 0 1 0 1 0 0 0 1 1 0 1 0 1 0 1 1 1 0 1 0 1 0 0 0 0 1 1 1 0 1 0 1 1 1 0 1 0 0 1 1 0 1 0 1 0 1 0];
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
audioAcc = [];
%%%%%% frame synchronazation
s_dect=[1,1,0,1,1,1,0,1,1,1,0,1,0,1,0,1,0,1,0,1,1,1,0,1,0,1,0,1];  %%%the signal used to detection.
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

xu = zeros(length(x_qam)*fsfd,1);
xu(1:fsfd:end) = x_qam ;     % Space the symbols fsfd apart, to enable pulse shaping using conv.

span = 6;                               %how many symbol times to we want of pulse 
a = 0.2;                                  % Roll off factor

[pulse, t] = rrcpulse(a,1/fsymb,fsamp,span); %RRC
[pulse1, t] =rtrcpuls(a,1/fsymb,fsamp,span);%RRC
pulse_train = conv(pulse,xu);  
pulse_train1 = conv(pulse1,xu); 


n = (0:length(pulse_train)-1)';
realpulse = real(pulse_train).*sqrt(2).*cos(2*pi*fc*Tsamp.*n);
imagpulse = imag(pulse_train).*sqrt(2).*sin(2*pi*fc*Tsamp.*n);
pulse_train_passband = realpulse-imagpulse;
figure(4)
plot(pulse_train_passband);
audioArray = pulse_train;%_passband;


%Create reference preamble
pre_ref = [1+1i, 1+1i, 1+1i, -1+1i, -1+1i, 1+1i, -1+1i];
xu = zeros(length(pre_ref)*floor(fsfd),1);
xu(1:fsfd:end) = pre_ref; 

audioAcc = cat(1,audioAcc,audioArray);

bb_signal = audioAcc;%pbTObb(audioAcc, fc, Tsamp);

lpf_signal = lowpassfilter(200,0.2,20,bb_signal);

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

[V,C] = crossCorr(pre_ref, const);

complexValues = closest(const);
check = cat(2,complexValues(1:length(x_qam))',x_qam');
bit_vector = demapping(complexValues)';

[numErrors, ber] = biterr(x, bit_vector)