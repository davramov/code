function [ g ] = katers_pendulum( l_1, l_2, T_1, T_2 )
l_1 = l_1/100; %cm to m
l_2 = l_2*0.0254 - l_1; %in to m

a = 8*pi^2;
la = l_1 + l_2;
lm = l_1 - l_2;
Ta = T_1^2 + T_2^2;
Tm = T_1^2 - T_2^2;

g = a*((Ta/la)+(Tm/lm))^(-1);
end

