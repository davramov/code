function [resultA, resultB, probsAB, NormalBees] = EigenC2(A, B, state)
[Aresult, probsA, Astates, ~, ~] = EigenC1(A, state);
[Bresult, ~, BStates, ~, ~] = C1(B, state);
Aresult = reshape(Aresult, length(Aresult), 1);
resultA = zeros(length(Aresult));
resultB = zeros(length(Bresult));
for i = 1:length(Aresult)
    resultA(i,:) = Aresult;
end
for j = 1:length(Bresult)
    resultB(:,j) = Bresult;
end
probsAB = zeros(length(Aresult));
for l = 1:length(Aresult);
    for k = 1:length(Bresult);
        probsAB(k, l) = probsA(l)*abs(BStates(:,k)'*Astates(:,l))^2;
    end
end 
Normal = zeros(length(BStates(1,:)),1);
for m = 1:length(BStates(1,:));
    Normal(m) = 1/sqrt(BStates(:,m)'*BStates(:,m));
end
NormalBees = zeros(length(BStates));
for n = 1:length(Normal);
    for m = 1:length(BStates(1,:));
        NormalBees(:,m) = Normal(n)*BStates(:,m);
    end
end