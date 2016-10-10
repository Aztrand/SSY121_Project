function [ audioArray ] = recordAudio( time, fsamp )
%RECORDAUDIO Summary of this function goes here
%   Detailed explanation goes here
recObj = audiorecorder(fsamp,8,1);
disp('Start')
recordblocking(recObj, time); %adding extra time, which we later filter away.
disp('end')
audioArray = getaudiodata(recObj);
end

