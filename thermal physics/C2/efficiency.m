function [ work, eff ] = efficiency(Vl, Vs, Q, a, b)

a = 4E-49;
b = 6E-29;
Vl = 0.4;
Vs = 0.05;
Q = 1600;

R=0.0821; %Gas constant in (L*atm)/(mol*K)
k=1.38e-23; %J/K
P1=1; %in atm
n=(P1*Vl)/(R*300); %number of moles of gas in system
N=n*6.022e26; %number of atoms in system

T1=300;
T2=((Vl*T1^(5/2))/Vs)^(2/5);
T3=(Q/((5/2)*N*k))+T2;
T4=((Vs*T3^(5/2))/Vl)^(2/5);

eff = 1-T4/T3
Vx = linspace(Vs,Vl,1000);

Pb = vdw(N, T1, Vx, a, b, Vl);
Pt = vdw(N, T3, Vx, a, b, Vs);

Wb = Integral(Vx,Pb);
Wt = Integral(Vx,Pt);
work = Wt-Wb

work2=eff*Q;

end

