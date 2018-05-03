l_1 = .375;
l_2 = 0.9475978-l_1;
T_1 = 1.958324696;
T_2 = 1.956786207;


a = 8*pi^2;
la = l_1 + l_2;
lm = l_1 - l_2;
Ta = T_1^2 + T_2^2;
Tm = T_1^2 - T_2^2;

g_experimental = a*((Ta/la)+(Tm/lm))^(-1);

g_accepted = 9.80665;

accuracy = (g_experimental/g_accepted)*100