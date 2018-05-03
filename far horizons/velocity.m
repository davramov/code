function [ v ] = velocity( m_tot, altitude, temp, delta_m )
%m_tot in grams
%altitude in km
%temp in celcius

M_air = 28.9645; %g/mol
M_He = 4.0026; %g/mol
R = 8.3144598e-5; %m^3*bar / K*mol
T = temp + 273.15; %Kelvin
g = 9.8; %m/s^2
delta_rho = (M_air-M_He)*(1/(R*T)*exp(-altitude/7));
rho_air = (M_air/(R*T)*exp(-altitude/7));
r = balloon_radius(m_tot,altitude,temp);
Vdisp = (4./3).*pi.*(r.^3);
Vdisp = Vdisp.*(5.9+4.2)/5.9;
A = pi.*(r.^2);

cd = 0.5;

v = sqrt(abs(-g.*(Vdisp.*delta_rho-(m_tot-delta_m))./(.5.*cd.*A.*rho_air)));

%v = sqrt(abs(-g*(Vdisp*delta_rho-(m_tot-delta_m))/(0.5*cd*pi*(r^2)*rho_air)));
%v = sqrt(abs(g*((4/3)*pi*(r^3)*delta_rho-m_tot)/(4*pi*(r^2)*rho_air)));

%a = (4/3)*pi*(r^3)*delta_rho

%v2 = sqrt(((8*r*g)/(3*cd))*(1-(3*(m_tot-delta_m))/(4*pi*rho_air*(r^3))))

plot(altitude, v)
hold on
end

