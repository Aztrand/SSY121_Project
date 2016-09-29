function [y,t] = rrcpulse(beta,t,Ts)

% beta is roll-off factor
% Ts is symbol time
% fs is sampling frequency
% trunc_span is how much we should truncate the pulse

t = t+.0000001; %Insert offset to prevent NANs

% Just some factors for the pulse equation
piTs = pi/Ts;
betaM = 1-beta;
betaP = 1+beta;
Ad = (4*beta/Ts)^2;
An = (4*beta/Ts);

% Generate the RRC pulse
y = (sin(piTs*t*betaM)+An*t.*cos(piTs*t*betaP))./(piTs*t.*(1-Ad*t.^2));

y = y/sqrt(Ts); %Unit energy
