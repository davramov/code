function aniwave(x,u0,v0,c,T,num)
[p,q]=size(x);              % Finds the size of the 'x' vector and assigns the width and height to p and q
a=zeros(p,q);               % Preallocates 'a' to the size of 'x'
b=zeros(p,q);               % Preallocates 'b' to the size of 'x'
L = max(x);                 % Assigns the max value of 'x' to 'L'
f = figure;                 % Create the figure for the animation
hold on                     % Reuse the same figure for multiple graphs
box on                      % Draw a box around the graph
grid on                     % Draws a grid


%[-L,L]
if abs(min(x))==max(x)     % If the absolute value of the smallest value of 'x' equals the largest ...; [-L,L]
    u=0;                   % Assigns u=0 since there is no A0 term
    for n=1:num            % Calculates the 'a' and 'b' coefficients for each 'n'
                           % Calculates u(x,0)
        a(n)=(2/L)*Integral(x,u0.*sin((n*pi*x)/L));
        b(n)=(2/(n*pi*c))*Integral(x,v0.*sin((n*pi*x)/L));
        u=u+(a(n).*sin((n*pi*x)/L));
    end
    axis([ -L L -1.5 1.5 ])          % Assigns the size of the axis
    ps = plot(x, u, 'linewidth', 2); % Plots 'x' versus u(x,0)
    for t = 0.05 : 0.05 : T          % Loop from t = 0 to t = T
        u = 0;                       % Reset u = 0 at the start of each iteration to avoid superposition
        for n=1:num                  % Loops to calculate u(x,t) for each 'n'
            u=u+(a(n).*cos((n*pi*c*t)/L)+b(n).*sin((n*pi*c*t)/L)).*sin((n*pi*x)/L);
        end
        set(ps, 'YData', u);         % Update the value of u(x,t) in graph
        pause(0.1);                  % Pause for 0.1 s between frames
    end
    
%[0,L]
elseif min(x)==0     % If the smallest value of 'x' equals 0...; [0,L]
    u=0;             % Assigns u=0 since there is no A0 term 
    
    for n=1:num      % Calculates the 'a' and 'b' coefficients for each 'n'
                     % Calculates u(x,0)      
        a(n)=(2/L)*Integral(x,u0.*sin((n*pi*x)/L));
        b(n)=(2/(n*pi*c))*Integral(x,v0.*sin((n*pi*x)/L));
        u=u+(a(n).*cos((n*pi*c*0)/L)+b(n).*sin((n*pi*c*0)/L)).*sin((n*pi*x)/L);
    end
    
    axis([0 L -1.5 1.5 ])              % Assigns the size of the axis
    ps = plot(x, u, 'linewidth', 2);   % Plots 'x' versus u(x,0)
    for t = 0.05 : 0.05 : T            % Loop from t = 0 to t = T
        u = 0;                         % Reset u = 0 at the start of each iteration to avoid superposition
        for n=1:num                    % Loops to calculate u(x,t) for each 'n'
            u=u+(a(n)*cos((n*pi*c*t)/L)+b(n)*sin((n*pi*c*t)/L))*sin((n*pi*x)/L);
        end
        set(ps, 'YData', u);           % Update the value of u(x,t) in graph
        pause(0.1);                    % Pause for 0.1 s between frames
    end
end
close(f);                              % Close the window

end

