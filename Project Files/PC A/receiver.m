function [pack, psd, const, eyed] = receiver(tout,fc)
% Complete the function and remove the following lines
%Constants
M=16;                                  %Number of symbols in the constellation
rb=440;                                % bit rate [bit/sec]
fsamp=8e3;                            %sample rate
Tsamp=1/fsamp;
m=log2(M);                            % Number of bits per symbol
fsymb =rb/m;                          % Symbol rate [symb/s]
fsfd = fsamp/fsymb;                  % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity) [samples/symb]
signalTime = Tsamp*47998; %tout
count = 0;
counter = 0;
audioAcc = [];

%Create reference preamble
pre_ref = [3, 3, 3, -3, -3, 3, -3];
xu = zeros(length(pre_ref)*floor(fsfd),1);
xu(1:fsfd:end) = pre_ref; 

%Record Audio
tic;
while toc < tout
%counter = counter + 1
%if (counter == 10)
 %   audioArray = xu;
%else
audioArray = recordAudio(1, fsamp);
%end

audioAcc = cat(1,audioAcc,audioArray);
%audioAcc = [audioAcc';audioArray'];
%PB to BB
bb_signal = pbTObb(audioAcc, fc, Tsamp);

%n = (0:length(audioArray)-1)';
%pulse_train = audioArray%.*exp(-1i*2*pi*fc/fsamp*n);
%complexValues = closest(pulse_train);
%bitPackage = demapping(complexValues)
%

%Low-pass filter
lpf_signal = lpf(bb_signal);
%

%Matched Filter
span = 6;                               %how many symbol times to we want of pulse 
a=0.3;                                  % Roll off factor
[pulse, t] =rtrcpuls(a,1/fsymb,fsamp,span);
mf_signal = mf(pulse, lpf_signal, fsfd);
%

%pre_ref_sig = conv(pulse,xu); 
%remove zeros
mf_signal_rz = mf_signal(2*span*fsfd:end-2*span*fsfd);
%sample to get symbols
const = mf_signal_rz(1:fsfd:end);
figure(2)
hold on;
plot(real(const));
[r,lag] = xcorr(pre_ref, real(mf_signal));
figure(1);
hold on;
plot(lag,r);
[V, ind] = max(r);
delay = lag(ind);
V
%[V,C] = crossCorr(pre_ref, const);
if (V > 0.5)  %If the receved signal reaches a certain value of detection
    count = count+1;    %we wait and record. (Recorder still active)
end
if ( count > 6)

    
    %ML decoding
    const = const(8-delay: 108+(8-delay)-1);
    complexValues = closest(const);
    bit_vector = demapping(complexValues)';
    count = 0;
    audioAcc = [];
    tout = 0;
end;
end;
%figure(23)
%scatterplot(const); grid on;
%[numErrors, ber] = biterr(data_bin, bit_vector')

%PSD
figure()
F = fft(mf_signal_rz);
F=F(1:length(mf_signal_rz)/2+1);
psd=(1/(2*pi*length(mf_signal_rz)))*abs(F).^2;
psd(2:end-1) = 2*psd(2:end-1);
freqI=0:fsamp/length(mf_signal_rz):fsamp/2;
plot(freqI,10*log10(psd))
%disp('Complete the receiver') 
%pack = []; psd = [];  const=[]; eyed = [];


end