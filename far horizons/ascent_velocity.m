function [ velocity ] = ascent_velocity( m_tot, m_ballast )
%input mass in grams

Radius = 1; %meters
Temp = 25; %celcius
Altitude = 3000; %meters


velocity = ((13.7*1.054-3.27*m_tot)/(AirPressure(Altitude,Temp,Radius)));

end

