function Animate

f = figure;                 % Create the figure for the animation
hold on                     % Reuse the same figure for multiple graphs
box on                      % Draw a box around the graph
grid on                     % Turn the grid on
set(gca, 'FontSize', 18)    % Increase the font size

L = 5;
x = linspace(0, L, 101);    % Define the x vector to run from 0 to L
u = sin(pi*x/L);            % The initial value of u(x,t) at t = 0

axis([ 0 L -1.2 1.2 ])      % Set the bounds of the x and y axes

xlabel('x')
ylabel('sin(\pi x/L) * cos(t)')

ps = plot(x, u, 'linewidth', 2);    % Plot u(x,0) versus x

for t = 0.05 : 0.05 : 10            % Loop from t = 0 to t = 10
    
    u = sin(pi*x/L) * cos(t);       % Recalculate u(x,t) at current t
    set(ps, 'YData', u);            % Update the value of u(x,t) in graph
    
    pause(0.1);                     % pause for 0.1 seconds
    
end

close(f);                   % Close the figure window