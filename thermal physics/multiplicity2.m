function [ possibleE, multiplicity, probableE, hwhm ] = multiplicity2(SA, SB, energy)
Q = energy;
multiplicity = zeros(1,Q);
possibleE = zeros(1,Q);
for i = 0:Q
    possibleE(i+1) = i;
    QA = possibleE(i+1);
    QB = Q - QA;   
    multiplicity(i+1) = nchoosek(QA+SA-1,QA)*nchoosek(QB+SB-1,QB);
    %multiplicity(i+1) = (factorial(SA+QA-1))/(factorial(QA)*factorial(SA-1))*(factorial(SB+QB-1))/(factorial(QB)*factorial(SB-1));
    %M1=SA+QA-1;
    %M2=SB+QB-1;
    %multiplicity(i+1)=exp(M1*log(M1)-M1+M2*log(M2)-M2-(QA*log(QA)-QA+QB*log(QB)-QB+(SA-1)*log(SA-1)-(SA-1)+(SB-1)*log(SB-1)-(SB-1)));
end
%multiplicity(1)=0;
%multiplicity(Q+1)=0;
[~,I]=max(multiplicity);
probableE = I-1;
%probableE holds the value of the energy in object A

halfmax = find(multiplicity>=(max(multiplicity)/2));
fullwidth = (max(halfmax) - min(halfmax));
hwhm = fullwidth/2;
%sigma = std(multiplicity);
%hwhm = sqrt(2*log(2))*sigma;

end