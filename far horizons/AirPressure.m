function [ m_air ] = AirPressure( Altitude, Temp, Radius )
%Altitude measured in meters above sea level
%Temp in C
%Radius measured in meters
%Mass of air in kg
%density = density_zero


%http://www.engineeringtoolbox.com/air-altitude-pressure-d_462.html
%molar mass - Mair	28.9645 g.mol?1
%(PV/RT) = n
%mair = n*28.9645 

P = 101325*(1-Altitude*2.25577e-5)^5.25588;
V = pi*Radius^2*(12000-Altitude);
T = Temp + 273.15;
R = 8.3144598; %m^3*Pa*K^?1*mol^?1

n = (P*V)/(R*T);
m_air = n*28.9645/1000;


end

