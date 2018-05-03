function [Aresults,Bresults,probabilities, BStates  ] = C2( A, B, state )
%Find the size of A; Because A and B are both N X N matrices, assume the same
%size for both
[n,~]=size(A);

%Call C1 To find the result vectors of A and B
%The for loop produces 2 matrices:
%A: Possible values for the first measurement along each row
%B: Possible values for the second measurement along each column
[Aresult,AProbability,AStates,~,~,] = C1(A, state);
%BStates is also returned as the N X N matrix containing the normalized
%states of the system after the second mesurement
[Bresult,~,BStates,~,~] = C1(B, state);
Aresults=zeros(size(A));
Bresults=zeros(size(B));
for i = 1:n
   for j = 1:n
      Aresults(i,j)=Aresult(j,1);
      Bresults(j,i)=Bresult(j,1);
   end
end

%Probabilities: N X N matrix of probs for each pair of results
%There are N^2 possible outcomes
%All of the probabilities within the resulting matrix should add up to 1
probabilities = zeros(length(Aresult));
for l = 1:length(Aresult);
    for k = 1:length(Bresult);
        probabilities(k, l) = AProbability(l)*abs(BStates(:,k)'*AStates(:,l))^2;
    end
end 
end

