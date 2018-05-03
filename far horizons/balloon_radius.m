function [ radius ] = balloon_radius( m_tot, altitude, temp )
%m_tot in grams
%altitude in km
%temp in celcius

M_air = 28.9645; %g/mol
M_He = 4.0026; %g/mol
R = 8.3144598e-5; %m^3*bar / K*mol
T = temp + 273.15; %Kelvin

radius = ((3/(4.*pi)).*m_tot.*((M_air-M_He).*(1./(R.*T).*exp(-altitude./7))).^(-1)).^(1/3);

%radius2 = ((3*R*T*m_tot)/(4*exp(-altitude/7)*(M_air-M_He)*pi))^(1/3)

%plot(altitude,radius)
end

