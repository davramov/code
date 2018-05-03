% NonLinFit_demo.m
% Nonlinear curve fitting program
% For the function Y(X)=M(1) + M(2) * X
% Including weighting
% This example shows that the linear curve fitting program converges within
%   one try, and that iterations (numtry) are not necessary for this simple
%   problem
% by Eric Landahl
% Last revised 11/6/2008
%
clear all;
hold off;
numpts=5;   % Number of data points 
XX = [1 2 3 4 5];   % This column corresponds to the x-axis data 
YY = [1.1 2 2.9 4.1 5];    % This column corresponds to the y-axis data 
Y=YY';   % Make  y-data to a column vector
SS = [0.2 0.2 0.2 0.2 0.2];  % standard deviation at each point is from measurement error
VV = SS.^2;  % variance is square of standard deviation
Var=sum(SS.^2);  %total variance
V = diag(VV);  % for uncorrelated errors, the variance matrix is a diagonal matrix
W=inv(V);   % data weights are 1/variance
% We have the function 
numparams=2;  % two parameters M(1),M(2) for linear fit :
              %     M(1) intercept
              %     M(2) slope
j=1:numparams;
% For nonlinear fitting, need guess values for parameters M
M_guess(1)=0.3;  % Guess intercept near zero
M_guess(2)=.8;   % Guess slope near 1
M = M_guess'  % M needs to be in a column matrix
for i = 1:numpts
    Y_guess(i)=M(1) + M(2) * XX(i);  % guess curve fit
end
figure(1); clf;
plot(XX,Y,'.');
hold on;
plot(XX,Y_guess);
E=Y-Y_guess';
S=(E' * W * E)
maxtry=4;    % Only need one iteration (maxtry=1) for linear problem.  Loop for demo purposes only.
for t=1:maxtry   % Iterate to refine parameters M
     for i = 1:numpts
        X(i,1)= 1;  % derivitive of function wrt first fitting parameter
        X(i,2)= XX(i);   % derivitive of function wrt second fitting parameter
     end
    P=inv(X' * W * X);  % Intermediate matrix calculated for least squares fit and error
    delta_M=P* X' * W * E;  % change fit parameters M by this amount
    M = M + delta_M
    for i = 1:numpts
        Y_next(i)=M(1) + M(2) * XX(i);  % guess curve fit
    end
    plot(XX,Y_next,':');
    E=Y-Y_next';
    S=(E' * W * E)
end
sigmas_res=(( S *diag(P))/(numpts-numparams)).^(0.5); % Error in parameters due to residuals
sigmas_w  =((Var*diag(P))/(numpts-numparams)).^(0.5);  % Error in parameters due to error bars
sigmas_tot=sigmas_res + sigmas_w;  % total error in each fit parameter
fprintf('slope = %g +/- %g \n',M(2),sigmas_tot(2));
fprintf('intercept = %g +/- %g \n',M(1),sigmas_tot(1));
fprintf('slope error is %g from residuals and %g from error bars \n',sigmas_res(2),sigmas_w(2));
fprintf('intercept error is %g from residuals and %g from error bars \n',sigmas_res(1),sigmas_w(1));



