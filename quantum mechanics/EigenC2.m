function [resultA, resultB, probsAB, Bstates] = EigenC2(operA, operB, state)
[resultAo, probsA, Aeigen, ~, ~] = C1(operA, state);
[resultBo, ~, Beigen, ~, ~] = C1(operB, state);
resultAo = reshape(resultAo, length(resultAo), 1);
resultA = zeros(length(resultAo));
resultB = zeros(length(resultBo));
for i = 1:length(resultAo)
    resultA(i,:) = resultAo;
end
for j = 1:length(resultBo)
    resultB(:,j) = resultBo;
end
probsAB = zeros(length(resultAo));
for l = 1:length(resultAo);
    for k = 1:length(resultBo);
        probsAB(k, l) = probsA(l)*abs(Beigen(:,k)'*Aeigen(:,l))^2;
    end
end 
Normal = zeros(length(Beigen(1,:)),1);
for m = 1:length(Beigen(1,:));
    Normal(m) = 1/sqrt(Beigen(:,m)'*Beigen(:,m));
end
Bstates = zeros(length(Beigen));
for n = 1:length(Normal);
    for m = 1:length(Beigen(1,:));
        Bstates(:,m) = Normal(n)*Beigen(:,m);
    end
end
Bstates