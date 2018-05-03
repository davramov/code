function [int] = Integral(x,f)
[n,s]=size(f);
s=s-1;
A=zeros(n,s);
for i=1:s
    A(i)=(x(i+1)-x(i))*((f(i)+f(i+1))/2);
end
int = sum(A);
end