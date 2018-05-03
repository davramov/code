function PlancksPlot(T1,T2,T3,vmin,vmax)
v = linspace(vmin,vmax,100);
B1=Plancks(T1,vmin,vmax);
B2=Plancks(T2,vmin,vmax);
B3=Plancks(T3,vmin,vmax);

loglog(B1);
hold on;
loglog(B2);
hold on;
loglog(B3);
hold on;
end

