function FourierPlot(x,f,N)
plot(x,f)
hold on
plot(x,FourierSum(x,f,N),'m')
xlabel('x')
ylabel('f(x)')
title('num = N')
legend('f(x)','Fourier Series')
end