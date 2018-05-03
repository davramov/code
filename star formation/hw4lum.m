t=linspace(0,500000);
lum = (3*sqrt(2)*(1.33e20)^(3/2)*((2e-6)*t-(2e-12)*t.^2).^5/2)/(5*pi*(3*696300000)^(5/2));
hold on
title('Lumunosity(t)');
xlabel('t/tau');
ylabel('Accretion Luminosity (J/s)');
plot(t/0.5e6,lum) 