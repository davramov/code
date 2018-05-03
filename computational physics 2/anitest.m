function anitest(x,u0,v0,c,T,num )
[p,q]=size(x);
a=zeros(p,q);
b=zeros(p,q);
L = max(x);
u=0;
for n=1:num
        a(n)=(2/L)*Integral(x,u0.*sin((n*pi*x)/L));
        b(n)=(2/(n*pi*c))*Integral(x,v0.*sin((n*pi*x)/L));
        u=u+(a(n).*sin((n*pi*x)/L));
end
plot(x,u)
end

