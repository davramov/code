function [ evolution ] = C3( times, H, state )

%normalize
normal = 1/sqrt(state'*state);
normstate = normal*state;

%find eigenvectors and eigenvalues of the operator
energy_eigenvalues = eig(H);
[energy_eigenstates,~] = eig(H);
[a,~] = size(energy_eigenstates);
c = zeros(a,1);

for i = 1:a
    c(i) = energy_eigenstates(:,i)'*normstate;
end

[~,t]=size(times);
evolution = zeros(a,t);

for i = 1:t %moves to the next column - time
    for k = 1:a %moves to the next row
        for j = 1:a %moves down the columns for all of the states/value vectors 
            evolution(k,i)=evolution(k,i)+c(j)*exp(-(1i*energy_eigenvalues(j)*times(i)))*energy_eigenstates(k,j);
        end
    end
end
hold on
plot(times,real(evolution(1,:)))
plot(times,imag(evolution(1,:)))
end

