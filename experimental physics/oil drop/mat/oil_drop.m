function [ q ] = oil_drop(br,bf,V,P,n)

ro = 800; %density of oil in kg/m^3 (~0.8 g/cm^3)
g = 9.80665; %m/s^2
b = 8.2e-3; % constant in Pa*m
p = P*100; %barometric pressure in Pa
%omega = 2.15; % Mohm
n = n; %viscosity of air in poise Ns/m^2
vf = bf/1000; %velocity of fall in m/s
vr = br/1000; %velocity of rise in m/s
V = V; %potential difference across the plates in Volts
d = 0.0076; %width of plastic spacer
E = V/(300*d);

q = (4/3)*pi*ro*g*((sqrt((b/(2*p))^2+((9*n*vf)/(2*g*ro)))-(b/(2*p)))^3)*((vf+vr)/(E*vf));

end

