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
%Record Audio
tic;
while toc < tout
audioArray = recordAudio(0.2, fsamp);
%
audioAcc = cat(2,audioAcc,audioArray);
%PB to BB
bb_signal = pbTObb(audioAcc, fc, Tsamp);

%n = (0:length(audioArray)-1)';
%pulse_train = audioArray%.*exp(-1i*2*pi*fc/fsamp*n);
%complexValues = closest(pulse_train);
%bitPackage = demapping(complexValues)
%

%Low-pass filter
lpf_signal = lowpassfilter(200,0.2,20,bb_signal);
%

%Matched Filter
span = 6;                               %how many symbol times to we want of pulse 
a=0.3;                                  % Roll off factor
[pulse, t] =rtrcpuls(a,1/fsymb,fsamp,span);
mf_signal = mf(pulse, lpf_signal, fsfd);
%
%Create reference preamble
Pre_ref = [1+1i, 1+1i, 1+1i, -1+1i, -1+1i, 1+1i, -1+1i];
xu = zeros(length(pre_ref)*fsfd,1);
xu(1:fsfd:end) = pre_ref; 
Pre_ref_sig = conv(pulse,xu); 

[V,C] = crossCorr(pre_ref_sig, mf_signal);
if (V > 5)  %If the receved signal reaches a certain value of detection
    Count = Count++;    %we wait and record. (Recorder still active)
end
if ( Count >= 5)
    mf_signal = mf_signal[C: C+7854];   %fetching the whole message.
    %Downsampling

    %remove zeros
    mf_signal_rz = mf_signal(2*span*fsfd:end-2*span*fsfd);
    %sample to get symbols
    const = mf_signal_rz(1:fsfd:end);

    %ML decoding
    complexValues = closest(const);
    bit_vector = demapping(complexValues)';
    count = 0;
    audioAcc = zeroes(length(audioAcc,1)
end;
end;
figure(23)
scatterplot(const); grid on;
[numErrors, ber] = biterr(data_bin, bit_vector)

%PSD
F = fft(mf_signal_rz)
F=F(1:length(mf_signal_rz)/2+1);
psd=(1/(2*pi*length(mf_signal_rz)))*abs(F).^2;
psd(2:end-1) = 2*psd(2:end-1);
freqI=0:fsamp/length(mf_signal_rz):fsamp/2;
plot(freqI,10*log10(psd))
%disp('Complete the receiver') 
%pack = []; psd = [];  const=[]; eyed = [];


end