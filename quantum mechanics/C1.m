function [ results, probability, states, expectation, uncertainty ] = C1( operator, state )

results=eig(operator);
[s,~] = size(results);
[states,~] = eig(operator);
probability = zeros(s,1);
normal = 1/sqrt(state'*state);
%normstate=normal*state;
for i = 1:s
    probability(i,1) = abs((states(1:s, i)'*normal*state))^2;
end
probability;
expectation = normal^2*state'*operator*state;
A = normal^2*state'*operator*operator*state;
uncertainty = sqrt(A - expectation^2);

end

