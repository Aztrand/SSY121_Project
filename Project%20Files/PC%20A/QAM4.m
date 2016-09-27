function [x_qam,s]=QAM4(x,M)
fsamp = 44e3; % sampling frequency [Hz]
Tsamp = 1/fsamp;    % Sampling time
rb = 440; % bit rate [bit/sec]
% Constellation or bit to symbol mapping
s = [(1 + 1i) (1 - 1i) (-1 -1i) (-1 + 1i)]/sqrt(2); % Constellation 1 - QPSK/4-QAM

M = length(s);                                      % Number of symbols in the constellation
m = log2(M);                                        % Number of bits per symbol
fsymb = rb/m;                                       % Symbol rate [symb/s]
fsfd = fsamp/fsymb;                                 % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity) [samples/symb]

x_buffer = buffer(x, m)';                           % Group bits into bits per symbol
sym_idx = bi2de(x_buffer, 'left-msb')'+1;           % Bits to symbol index
x_qam = s(sym_idx);                                     % Look up symbols using the indices
