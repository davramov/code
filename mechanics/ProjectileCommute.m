function [ y_max ] = ProjectileCommute(v0, theta)

g = 9.80665;
d = 2247; %Distance from apartment to Byrne (meters)
t_tot = (v0*sin(theta) + sqrt((v0^2)*(sin(theta))^2-36*g))/g;
t_hmax = (v0*sin(theta) + sqrt((v0^2)*(sin(theta))^2))/(2*g)
t = linspace(0,t_tot,1000);

vx = d/t_tot;

x = vx.*t;
y = v0*sin(theta).*t - 0.5*g.*t.^2;

v0 = (0.5*g*t_tot^2 + 18)/(t_tot*sin(theta));

y_max = max(y);

plot(x,y);
xlabel('Horizontal Distance (m)');
ylabel('Vertical Distance (m)');
end