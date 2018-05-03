function [ possibleE, multiplicity, probableE, hwhm ] = multiplicity(SA, SB, energy)
Q = energy;
multiplicity = zeros(1,Q);
possibleE = zeros(1,Q);
for i = 0:Q
    possibleE(i+1) = i;
    QA = possibleE(i+1);
    QB = Q - QA;
    multiplicity(i+1) = (factorial(SA+QA-1))/(factorial(QA)*factorial(SA-1))*(factorial(SB+QB-1))/(factorial(QB)*factorial(SB-1));
end
[M,I]=max(multiplicity)
probableE = I-1;
%probableE holds the value of the energy in object A
sigma = std(multiplicity);
sigma = std(
hwhm = sqrt(2*log(2))*sigma;

plot(possibleE,multiplicity)
end