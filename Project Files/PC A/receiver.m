function [pack, psd, const, eyed] = receiver(tout,fc)
% Complete the function and remove the following lines

%Constants
M=16;                                  %Number of symbols in the constellation
rb=440;                                % bit rate [bit/sec]
fsamp=44e3;                            %sample rate
Tsamp=1/fsamp;
m=log2(M);                            % Number of bits per symbol
fsymb =rb/m;                          % Symbol rate [symb/s]
fsfd = fsamp/fsymb;                    % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity) [samples/symb]

%Record Audio
audioArray = recordAudio(time);
%

%PB to BB
n = (0:length(audioArray)-1)';
pulse_train = audioArray.*exp(-1i*2*pi*fc/fsamp*n);
%

%Constellation
bitPackage = demapping(complex constants)

%disp('Complete the receiver') 
%pack = []; psd = [];  const=[]; eyed = [];

end