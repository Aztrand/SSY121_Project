function [ audioArray ] = recordAudio( time )
%RECORDAUDIO Summary of this function goes here
%   Detailed explanation goes here
recObj = audiorecorder;
disp('Start')
recordblocking(recObj, time);
disp('end')
audioArray = getaudiodata(recObj);
end

