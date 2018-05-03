function aniheat(x,u0,a,T,num)
[p,q]=size(x);
A=zeros(p,q);
B=zeros(p,q);
L = max(x);
f = figure;                 % Create the figure for the animation
hold on                     % Reuse the same figure for multiple graphs
box on                      % Draw a box around the graph
grid on 



u=(1/(2*L))*Integral(x,u0);

if abs(min(x))==max(x) % [-L,L]
    for n=1:num
        A(n)=(1/L)*Integral(x,u0.*cos((n*pi*x)/L));
        B(n)=(1/L)*Integral(x,u0.*sin((n*pi*x)/L));
        u=u+(A(n).*cos((n*pi*x)/L)+B(n).*sin((n*pi*x)/L)).*exp(((n^2)*(pi^2)*a*0)/(L^2));
    end
    
    axis([ -L L -1.5 1.5 ])  
    ps = plot(x, u, 'linewidth', 2);
    for t = 0.05 : 0.05 : T
        u = (1/(2*L))*Integral(x,u0);
        for n=1:num
            u=u+(A(n).*cos((n*pi*x)/L)+B(n).*sin((n*pi*x)/L)).*exp(((n^2)*(pi^2)*a*t)/(L^2));
        end
        set(ps, 'YData', u);            % Update the value of u(x,t) in graph
    
        pause(0.1);
    end
    

elseif min(x)==0 %[0,L]
    for n=1:num
       
    end
    
    axis([0 L -1.5 1.5 ])
    ps = plot(x, u, 'linewidth', 2);
    for t = 0.05 : 0.05 : T            % Loop from t = 0 to t = T
        u = 0;
        for n=1:num
           
        end
        set(ps, 'YData', u);            % Update the value of u(x,t) in graph
    
        pause(0.1);
    end
end

close(f);

end

