function [ mf_output ] = mf( pulse, y2, fsfd )
%MF Summary of this function goes here
%   Detailed explanation goes here
matched_filter = fliplr(pulse); %%%pulse is the RRCpulse
mf_output = conv(y2, matched_filter)/fsfd; %using convolution to remove RRCpulse

end

