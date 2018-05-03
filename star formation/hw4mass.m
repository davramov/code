t=linspace(0,500000);
mass = (2e-6)*t-(2e-12)*t.^2;
hold on
title('Mass(t)');
xlabel('t/tau');
ylabel('M (Solar Masses)');
plot(t/0.5e6,mass)