function [ DO ] = DO(Pressure,Temperature,Salinity) %Input temperature in °C, pressure in hPa, salinity in %
P=Pressure*0.000986923267;
Tc=Temperature;
Tk=Temperature+273.15;
S=Salinity;

%Following Benson and Krause Equations
DOo=exp(-139.34411+(1.575701e5/Tk)-(6.642308e7/(Tk^2))+(1.243800e10/(Tk^3))-(8.621949e11/(Tk^4)));
Fs=exp(-S*(0.017674-10.754/Tk+2140.7/(Tk^2)));
theta=0.000975-(1.426e-5)*Tc+(6.436e-8)*(Tc^2);
u=exp(11.8571-3840.70/Tk-216961/(Tk^2));
Fp=((P-u)*(1-theta*P))/((1-u)*(1-theta));
DO=DOo*Fs*Fp; %Units in mg/L
end