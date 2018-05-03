function [ MO ] = MO2(PO2,Pressure,Hours)
%PO2 is the percent air saturation
%Temperature in °C
%Pressure in hPa
%Salinity in %
Temperature = 20;
Salinity = 0;
DOs=DO(Pressure,Temperature,Salinity);
MO=(PO2.*DOs)/100;

plot(Hours,MO)

end

