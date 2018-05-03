function[resultsA,resultsB,probabilities,statesb]=c2 (A,B,psi)



resultsA=zeros(length(psi),length(psi));

for n=1:length(psi)

[res,~,states,~,~]=c1(A,psi);

resultsA(n,:)=res;

end

statesa=states;



resultsB=zeros(length(psi),length(psi));

for m=1:length(psi)

[res,~,states,~,~]=c1(B,psi);

resultsB(:,m)=res;

end 

statesb=states;



probabilities=zeros(length(psi));

probsba=zeros(length(psi),1);

for i=1:length(psi)

[~,probs,~,~,~]=c1(A,psi);

probsA=probs(i);

for j=1:length(psi)  

b=statesb(:,j)'* statesa(:,i);

probsba(j)=b'*b;

end

probabilities(:,i)=(probsA*probsba);

end

end