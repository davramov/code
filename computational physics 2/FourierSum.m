function [ sum ] = FourierSum(x,f,n)
%Calculate the size of 'f' vector to preallocate arrays 'a' and 'b'
[u,v]=size(f);
a=zeros(u,v);
b=zeros(u,v);

%Calculates a0. Calls the Integral function to calculate the integral of
%'f' from -L to L, assuming the range of integration is given by 'x'
a0=1/(2*max(x))*Integral(x,f);

%Creates the variable 'sum' and gives it the value of 'a0'
sum=a0;

%This for loop calculates and stores 'ak' and 'bk' into arrays from 1:n and
%then plugs those values into 'sum'
for k=1:n
    a(k)=(1/max(x))*Integral(x,f.*cos((k*pi*x)/max(x)));
    b(k)=(1/max(x))*Integral(x,f.*sin((k*pi*x)/max(x)));
    sum=sum+a(k)*cos((k*pi*x)/max(x))+b(k)*sin((k*pi*x)/max(x));
end
sum
end