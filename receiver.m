function [pack, psd, const, eyed] = receiver(tout,fc)
% Complete the function and remove the following lines
%Constants
M=4;                                  %Number of symbols in the constellation
rb=440;                                % bit rate [bit/sec]
fsamp=44e3;                            %sample rate
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
pre_ref = [1, 1, 1, 1, 1, -1, -1, 1, 1, -1, 1, -1, 1]; %4QAM
xu = zeros(length(pre_ref)*floor(fsfd),1);
xu(1:fsfd:end) = pre_ref;
[pulse, t] = rrcpulse(a,1/fsymb,fsamp,span); %RRC
barker_ref = conv(pulse,xu);  

%Record Audio
tic;
while toc < tout

    detect=0;
    guard = 140*fsfd;
    sound_old =[];
    fs = 44000;
    while(detect~=1)
        if(toc > tout)
            break;
        end;
        sound_in = wavrecord((39)*fsfd,fsamp); %N should be number of samples for barker code + a small margin
    
        % Do crosscorr of sound_in with reference barker
        %sound = cat(1,sound_old,sound_in);
        sound = sound_in;
        sound=sound/max(sound);
        
        bb_sound = pbTObb(sound,fc,Tsamp);
        lpf_sound = lpf(bb_sound);
        
        figure(1)
        plot(real(lpf_sound))
        title('lpf_sound')
        %r = xcorr(real(barker_ref),real(lpf_sound));
        r= xcorr(barker_ref,lpf_sound);
        r=abs(r)
        figure(2)
        plot(r);
        %figure(15)
        %plot(bb_sound,'o') %added
        
        
        title('xcorr - lpf and barker')
        crosscorrthreshold = 1000; %80
        for i = 1:length(r)
            if (r(i)>crosscorrthreshold)
                detect = 1
                N2 = (13+1)*fsfd+432/2*fsfd+guard;
                % Phase synchronization
%                 known = pulse;
%                 lpf_sound(i
                wavrecord(50*fsfd,fs);
                signal = wavrecord(N2,fs); %N should be guard+signal
                break;
            end
        end
        sound_old = sound_in;
    end
if(toc > tout)
    break;
end;

%audioArray = recordAudio(1, fsamp);



%audioAcc = cat(1,audioAcc,audioArray);
audioAcc = signal;
%PB to BB
% figure(3)
% 
% plot(audioAcc)
% title('raw sound')

bb_signal = pbTObb(audioAcc, fc, Tsamp)/sqrt(2);


%Low-pass filter
lpf_signal = lpf(bb_signal);
lpf_signal_scaled = real(lpf_signal)/max(real(lpf_signal))+1i*imag(lpf_signal)/max(imag(lpf_signal));
figure(4)
title('lpf')
subplot(4,1,1)
plot(real(lpf_signal))
subplot(4,1,2)
plot(imag(lpf_signal))
subplot(4,1,3)
plot(real(lpf_signal_scaled))
subplot(4,1,4)
plot(imag(lpf_signal_scaled))

[r, lag] = xcorr(real(barker_ref),real(lpf_signal(1:12000)));


figure(6);
plot(r);
crossThresh = 50;
maxcorr = 0;
[val,pos] = max(abs(r));
delay = lag(pos);
delay



%Matched Filter
mf_signal = mf(pulse, lpf_signal, fsfd);
%remove zeros
mf_signal_rz = mf_signal(2*span*fsfd:end-2*span*fsfd);

%Matched Filter
mf_signal_scaled = mf(pulse, lpf_signal_scaled, fsfd);
%remove zeros
mf_signal_rz_scaled = mf_signal_scaled(2*span*fsfd:end-2*span*fsfd);

% figure(5)
% subplot(4,1,1)
% plot(real(mf_signal_rz))
% title('mf_signal_rz')
% subplot(4,1,2)
% plot(imag(mf_signal_rz))
% subplot(4,1,3)
% plot(real(mf_signal_rz_scaled))
% subplot(4,1,4)
% plot(imag(mf_signal_rz_scaled))


delay=abs(delay);
    mf_signal_reduced = mf_signal_rz(delay:delay+(barkerLength+symbolCount+29)*fsfd);
    mf_signal_reduced=mf_signal_reduced/max(abs(mf_signal_reduced));
    mf_signal_eyed = mf_signal_reduced(44*fsfd:end); 
%     figure(7)
%     subplot(3,1,1)
%     plot(real(mf_signal_rz))
%     subplot(3,1,2)
%     plot(real(mf_signal_reduced))
    const = mf_signal_reduced(1:fsfd:end);
%     figure(10)
%     plot(real(const))
    
    %Sample
    %phase shift - USE THIS BEFORE REMOVING BARKER SEQUENCE.
    Const=[1]; %First barker set (2 BITS FOR 4QAM AND 4 BITS FOR 16QAM)
    b=angle(Const)-angle(const(1)) %const(1) IS THE FIRST SYMBOL IN THE RECEIVED MESSAGE
    const1=exp(1i*b).*const; %const IS NOW PHASED SHIFTED TO ORIGINAL.
    mf_signal_eyed = mf_signal_eyed*exp(1i*b);

    %ML decoding
    const1 = const1(44:end);
%     figure(8)
%     scatterplot(const1)
%     figure(11)
%     plot(real(const1))
    complexValues = closest4(const1);
    bit_vector = demapping4(complexValues)';
    count = 0;
    detect = 0;
    audioAcc = [];
    tout = 0;
    pack = bit_vector'
%     size(bit_vector)

    value2 = mf_signal_eyed;
    eyediagram(mf_signal_eyed,fsfd);
    eyed = struct('fsfd',fsfd,'r',value2);
    const = real(const1)/max(real(const1))+1i*imag(const1)/max(imag(const1)); 


% Alternative 2 for psd
N = max(1024,length(mf_signal_reduced));
P1 = fftshift(fft(mf_signal_reduced,N));
%P1 = P1(end/2:end);
value4 = (fsamp/N)*(-floor(N/2):1:ceil(N/2)-1);
%value4 = fvec(end/2:end);
value3 = 20*log10(abs(P1/max(P1)));


    psd = struct('p',value3,'f',value4);
    break;
end



end