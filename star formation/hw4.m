
t=linspace(0,500000);
mass = 2e-6*(1-t/0.5e6);
hold on
title('dM/dt');
xlabel('t/tau');
ylabel('dM/dt');
plot(t/0.5e6,mass)