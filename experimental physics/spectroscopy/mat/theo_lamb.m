function [ theoretical_lamb ] = theo_lamb( ni, nf )

Rh=1.09677576e-7; %m^-1, rydberg constant
Z = 1; %atomic number for hydrogen

theoretical_lamb = (Rh*((1/(ni^2))-(1/(nf^2))))^(-1); %meters

end

