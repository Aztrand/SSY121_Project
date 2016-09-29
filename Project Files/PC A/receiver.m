function [pack, psd, const, eyed] = receiver(tout,fc)
% Complete the function and remove the following lines

%Constants
M=16;                                  %Number of symbols in the constellation
rb=440;                                % bit rate [bit/sec]
fsamp=44e3;                            %sample rate
Tsamp=1/fsamp;
m=log2(M);                            % Number of bits per symbol
fsymb =rb/m;                          % Symbol rate [symb/s]
fsfd = fsamp/fsymb;                  % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity) [samples/symb]


%Record Audio
audioArray = recordAudio(tout);
%

%PB to BB
bb_signal = pbTObb(audioArray, fc, Tsamp);

%n = (0:length(audioArray)-1)';
%pulse_train = audioArray%.*exp(-1i*2*pi*fc/fsamp*n);
%complexValues = closest(pulse_train);
%bitPackage = demapping(complexValues)
%

%Low-pass filter
lpf_signal = lpf(bb_signal);
%

%Macthed Filter
span = 6;                               %how many symbol times to we want of pulse 
a=0.3;                                  % Roll off factor
[pulse, t] =rtrcpuls(a,1/fsymb,fsamp,span);
mf_signal = mf(pulse, lpf_signal, fsfd);
%

%Downsampling

%remove zeros
mf_signal_rz = mf_signal(2*span*fsfd:end-2*span*fsfd);
%sample to get symbols
const = mf_signal_rz(1:fsfd:end);

%ML decoding
complexValues = closest(const);
bit_vector = demapping(complexValues)';

figure(23)
scatterplot(const); grid on;
[numErrors, ber] = biterr(data_bin, bit_vector)

%disp('Complete the receiver') 
%pack = []; psd = [];  const=[]; eyed = [];

end