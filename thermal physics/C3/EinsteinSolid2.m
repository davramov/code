function EinsteinSolid( N, epsilon, T )

E = zeros(1,N); % preallocate E = 0 for all oscillators
k = 8.6173e-5; % eV/K
a = exp(-epsilon/(k*T));

for j=1:10000
    for i=1:N
        r = randi(2); % 1 increases by epsilon, 2 decreases by epsilon
        r1 = rand; % random number between 0 and 1
        if r==1 
           if r1<a 
               E(i)=E(i)+1; % Increase by epsilon
           end
        end
        if r==2
          if E(i) > 0
              E(i)=E(i)-1; % Decrease by epsilon
          end
       end
    end
end

h = E*epsilon; % Multiply Energy vector by epsilon to get actual energy values

avgE = mean(h); % calculates the experimental average energy
avgTE = (epsilon*exp(-epsilon/(k*T)))/(1-exp(-epsilon/(k*T))); % Calculates the theoretical average energy


% Need to determine the size of bins for the histogram
Elevels = max(E); % Find the highest energy level

s = 1; % Initial step size
%This loops runs until the number of bins is less than 60
%Each iteration increases the step size by 1
%The number of energy levels in each bin is designated by s
while length(0:s:Elevels) > 60
    s = s + 1;
end

%Make bins an array from 0 to the maximum energy level with an increment of
%s
bins = 0:s:Elevels;

%Plot the histogram
figure
histogram(E,bins)
hold on

% Calculate the theoretical probabilities
P = zeros(1,Elevels+1);
for i=0:Elevels
    P(i+1)=exp((-i*epsilon)/(k*T))*(1-exp(-epsilon/(k*T)));
end
P = P.*N.*s;
plot(P)


xlabel(['Energy/' char(1013)])
ylabel('Number of oscillators')
title({[ num2str(N) ' oscillators, ' char(1013) ' = ' num2str(epsilon) 'eV, T = ' num2str(T) ' K']; ['Predicted average: ' num2str(avgTE) char(1013) ', Actual average: ' num2str(avgE) char(1013)]})


end

