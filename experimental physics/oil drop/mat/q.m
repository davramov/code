load('data.mat');
a = size(bf);
charge = zeros(a);
for c = 1:a
    charge(c) = oil_drop(br(c),bf(c),V(c),P(c),n(c));
end

cc = charge/1.6e-19;
sc = sort(cc);
hold on
plot(cc, 'bo', 'MarkerSize', 11)
%plot(sc, 'o', 'MarkerSize', 12)
xlabel('Trial','FontSize',15);
ylabel('Charge (e)','FontSize',15);