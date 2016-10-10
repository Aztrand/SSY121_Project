function filt_sig = lowpassfilter(size,cutoff,ord,signal)

% Cutoff is relative cutoff between 0 and 0.5
% Size is how long filter should be
% ord is order, determines how steep the cutoff is

% Standard values (200,0.2,20)



  y =([1:size]-(fix(size/2)+1))/size;

 f =1./(1.0+(y./cutoff).^(2*ord)); 

 filt_sig = conv(signal,f);
 

end

