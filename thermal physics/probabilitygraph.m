function probabilitygraph(N,q)
%M=zeros(1,N);
%N=M;
%O=M;
probableE = N;
hwhm = N;
hold on
for i = 2:N
    SA = i-1;
    SB = N-SA;
    [A, B, C, D] = multiplicity2(SA,SB,q);
    possibleE = A;
    multi = B;
    probableE(i-1) = C;
    hwhm(i-1) = D;
    %M(i-1)=i-1;
    %N(i-1)=max(B);
    %O(i-1)=D;
    plot(SA,max(B), 'o')
    plot(SA,D,'o')
    hold on;  
end
%plot(M,N, 'o')
end

