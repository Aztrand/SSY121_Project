function [pack, psd, const, eyed] = receiver(tout,fc)
% Complete the function and remove the following lines
%Constants
M=4;                                  %Number of symbols in the constellation
rb=400;                                % bit rate [bit/sec]
fsamp=8e3;                            %sample rate
Tsamp=1/fsamp;
m=log2(M);                            % Number of bits per symbol
fsymb =rb/m;                          % Symbol rate [symb/s]
fsfd = fsamp/fsymb;                  % Number of samples per symbol (choose fs such that fsfd is an integer for simplicity) [samples/symb]
signalTime = Tsamp*47998; %tout
barkerLength = 13;
symbolCount = 432/m;
count = 0;
counter = 0;
audioAcc = [];
detect = 0;
span = 6;                               %how many symbol times to we want of pulse 
a=0.2;                                  % Roll off factor

%Create reference preamble
%pre_ref = [3 + 3i, 3 + 3i, 3 + 3i, 3 + 3i, 3 + 3i, -3 - 3i, -3 - 3i, 3 + 3i, 3 + 3i, -3 - 3i, 3 + 3i, -3 - 3i, 3 + 3i]; %16QAM
pre_ref = [1+1i, 1+1i, 1+1i, 1+1i, 1+1i, -1-1i, -1-1i, 1+1i, 1+1i, -1-1i, 1+1i, -1-1i, 1+1i]; %4QAM
xu = zeros(length(pre_ref)*floor(fsfd),1);
xu(1:fsfd:end) = pre_ref;
[pulse, t] = rrcpulse(a,1/fsymb,fsamp,span); %RRC
barker_ref = conv(pulse,xu);  

%Record Audio

tic;
while toc < tout

    detect=0;
    guard = 500*fsfd;
    sound_old =[];
    fs = 8000;
    while(detect~=1)
        sound_in = wavrecord((13+1)*fsfd,fs); %N should be number of samples for barker code + a small margin
    
        % Do crosscorr of sound_in with reference barker
        sound = cat(1,sound_old,sound_in);
       
        
        bb_sound = pbTObb(sound,fc,Tsamp);
        lpf_sound = lpf(bb_sound);
        
        figure(1)
        plot(real(lpf_sound))
        [r,lag] = xcorr(real(lpf_sound),real(barker_ref));
        figure(2)
        plot(lag,r);
        crosscorrthreshold = 60;
        for i = 1:length(r)
            if (r(i)>crosscorrthreshold)
                detect = 1
                N2 = (13+1)*fsfd+432/2*fsfd+guard;
                signal = wavrecord(N2,fs); %N should be guard+signal
                break;
            end
        end
        sound_old = sound_in;
    end
%audioArray = recordAudio(1, fsamp);



%audioAcc = cat(1,audioAcc,audioArray);
audioAcc = signal;
%PB to BB
figure(3)

plot(audioAcc)

bb_signal = pbTObb(audioAcc, fc, Tsamp)/sqrt(2);

%Low-pass filter
lpf_signal = lpf(bb_signal);
lpf_signal_scaled = real(lpf_signal)/max(real(lpf_signal))+1i*imag(lpf_signal)/max(imag(lpf_signal));
figure(4)
subplot(4,1,1)
plot(real(lpf_signal))
subplot(4,1,2)
plot(imag(lpf_signal))
subplot(4,1,3)
plot(real(lpf_signal_scaled))
subplot(4,1,4)
plot(imag(lpf_signal_scaled))

[r, lag] = xcorr(real(lpf_signal),real(barker_ref));
figure(6);
plot(lag,r);
crossThresh = 350;
r=fliplr(r);
for j = 1:length(r)
    if(r(j)>crossThresh)
        delay = lag(j)
        detect = 1;
        break;
    end
end

%Matched Filter
mf_signal = mf(pulse, lpf_signal, fsfd);
%remove zeros
mf_signal_rz = mf_signal(2*span*fsfd:end-2*span*fsfd);

%Matched Filter
mf_signal_scaled = mf(pulse, lpf_signal_scaled, fsfd);
%remove zeros
mf_signal_rz_scaled = mf_signal_scaled(2*span*fsfd:end-2*span*fsfd);


figure(5)
subplot(4,1,1)
plot(real(mf_signal_rz))
subplot(4,1,2)
plot(imag(mf_signal_rz))
subplot(4,1,3)
plot(real(mf_signal_rz_scaled))
subplot(4,1,4)
plot(imag(mf_signal_rz_scaled))

% 




%Matched Filter
mf_signal = mf(pulse, lpf_signal, fsfd);
%remove zeros
mf_signal_rz = mf_signal(2*span*fsfd:end-2*span*fsfd);





delay=abs(delay);
    mf_signal_reduced = mf_signal_rz(delay:delay+(barkerLength+symbolCount)*fsfd);
    figure(7)
    subplot(7,1,1)
    plot(real(mf_signal_rz))
    subplot(7,1,2)
    plot(real(mf_signal_reduced))
    const = mf_signal_reduced(1:fsfd:end)/sqrt(2);
    figure(10)
    plot(real(const))
    %Sample
    %phase shift - USE THIS BEFORE REMOVING BARKER SEQUENCE.
    Const=[1+1i]; %First barker set (2 BITS FOR 4QAM AND 4 BITS FOR 16QAM)
    b=angle(Const)-angle(const(1)) %const(1) IS THE FIRST SYMBOL IN THE RECEIVED MESSAGE
    const1=exp(1i*b).*const; %const IS NOW PHASED SHIFTED TO ORIGINAL.
    
    const = mf_signal_rz(delay+13*fsfd:fsfd:(13+216)*fsfd+delay);
    %ML decoding
    %const = const(21+delay: 216+(21+delay)-1);
    complexValues = closest4(const1);
    bit_vector = demapping4(complexValues)';
    count = 0;
    detect = 0;
    audioAcc = [];
    tout = 0;
    break;
end

figure(7)
scatterplot(const); grid on;

pack = bit_vector;

%PSD
figure(8)
F = fft(mf_signal_rz);
F=F(1:length(mf_signal_rz)/2+1);
psd=(1/(2*pi*length(mf_signal_rz)))*abs(F).^2;
psd(2:end-1) = 2*psd(2:end-1);
freqI=0:fsamp/length(mf_signal_rz):fsamp/2;
plot(freqI,10*log10(psd))
pack = bit_vector; psd = psd;  const=scatterplot(const); eyed = [];


end