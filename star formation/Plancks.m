function [ B ] = Plancks(T,vmin,vmax)
h=6.626e-34;
k=1.381e-23;
c=3e8;
v=logspace(4,22);
B = (((2*h.*v.^3))./(c^2)).*(1./(exp((h.*v)./(k.*T))-1));
end