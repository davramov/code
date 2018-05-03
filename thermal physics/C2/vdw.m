function [ pressure ] = vdw( N, T, Vx, a, b, V )

c = V*T^(5/2);
Temp = (c./Vx).^(2/5);
pressure = (((N*(1.38e-23)).*Temp)./(Vx-N*b))-((a*N^2)./(Vx.^2));

end

