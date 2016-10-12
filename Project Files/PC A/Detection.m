detect=0;
sound_old =[];

while(detect~=1)
    sound_in = wavrecord(N,fs); %N should be number of samples for barker code + a small margin
    
    % Do crosscorr of sound_in with reference barker
    sound = [sound_old sound_in];
    bb_sound = pbTObb(sound,fc,Tsamp);
    lpf_sound = lpf(bb_sound);
    
    
    [r,lag] = xcorr(lpf_sound,ref_barker);
    crosscorrthreshold = ;
    if (r>crosscorrthreshold)
        detect = 1;
        signal = wavrecord(N2,fs); %N should be guard+signal
    end
    sound_old = sound_in;
end