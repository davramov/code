function [ output_args ] = EinsteinSolid( N, epsilon, T )

E = zeros(1,N);
k = 8.6173e-5; %eV/K
a = exp(-epsilon/(k*T));

for j=1:1000
    for i=1:N
        r = randi(2); % 1 increases by epsilon, 2 decreases by epsilon
        r1 = rand;
        if r==1
           if r1<a
               E(i)=E(i)+epsilon;
           end
        end
        if r==2
          if E(i) > 0
              E(i)=E(i)-epsilon;
          end
       end
    end
end
h = abs(E)./epsilon
avgE = mean(E)
avgTE = (epsilon*exp(-epsilon/(k*T)))/(1-exp(-epsilon/(k*T)))

Elevels = max(h)

figure
histogram(h,30)
hold on

for i=0:200
    P(i+1)=exp((-i*epsilon)/(k*T))*(1-exp(-epsilon/(k*T)));
end
P = P.*N;
plot(P)

end

