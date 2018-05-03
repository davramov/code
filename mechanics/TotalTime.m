function [ v0 ] = TotalTime(theta )

g = 9.80665; % m / s^2
t_tot = 10; %seconds
vy0 = (0.5*g*t_tot^2 + 18)/(t_tot*sin(theta));
vx0 = 2247/t_tot;
v0 = sqrt(vx0^2+vy0^2);
end

