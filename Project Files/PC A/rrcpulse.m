function [y,t] = rrcpulse(beta,Ts,fs)

% beta is roll-off factor
% Ts is symbol time
% fs is sampling frequency
% trunc_span is how much we should truncate the pulse

t_positive = eps:(1/fs):span*tau;  % Replace 0 with eps (smallest +ve number MATLAB can produce) to prevent NANs
t = [-fliplr(t_positive(2:end)) t_positive]; %Insert offset to prevent NANs

% Just some factors for the pulse equation
piTs = pi/Ts;
betaM = 1-beta;
betaP = 1+beta;
Ad = (4*beta/Ts)^2;
An = (4*beta/Ts);

% Generate the RRC pulse
y = (sin(piTs*t*betaM)+An*t.*cos(piTs*t*betaP))./(piTs*t.*(1-Ad*t.^2));

y = y/sqrt(Ts); %Unit energy
