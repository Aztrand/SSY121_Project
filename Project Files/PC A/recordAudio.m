function [ audioArray ] = recordAudio( time, fsamp )
%RECORDAUDIO Summary of this function goes here
%   Detailed explanation goes here
recObj = audiorecorder(fsamp);
disp('Start')
recordblocking(recObj, time+2); %adding extra time, which we later filter away.
disp('end')
audioArray = getaudiodata(recObj);
end

