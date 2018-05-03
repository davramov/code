function probabilitygraph2(N,q)
probableE = zeros(size(1:N-1));
hwhm = zeros(size(1:N-1));
for i = 1:N-1
    [~, ~, probableE(i), hwhm(i)] = multiplicity2(i,N-i,q);
end
hold on
plot(1:N-1,probableE, 'b')
plot(1:N-1,hwhm)
xlabel('Number of Oscillators in A');
ylabel('Most Probable Energy');
title('Most Probable Energy of Two Interacting Einstein Solids versus Number of Oscillators')
leg=legend('Probability', 'Half Width Half Max');
set(leg,'location','Northwest');
end