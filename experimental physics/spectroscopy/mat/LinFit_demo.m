% LinFit_demo.m
% Linear curve fitting program
% Including weighting
% Also showing curve fit lines within parameter errors
% by Eric Landahl
% Revised 10/30/2008
% minor tweaks to show uncertainties graphically 10/18/10
%
clear all;
XX = input('Enter x-data values as a row vector: ');
YY = input('Enter y-data values as a row vector: ');
Y=YY';   % Convert y-data to a column vector
SS = input('Enter standard deviation of each data point as a row vector: ');  % Assume errors are uncorrelated
VV = SS.^2;  % standard deviation at each point
Var=sum(SS.^2);  %total variance
V = diag(VV);  % for uncorrelated errors, the variance matrix is a diagonal matrix
W=inv(V)*Var;   % data weights are 1/variance
[nu numpts]=size(XX);  %nu is not used, numpts is number of data points
% We have the function Y(X) = m1 + m2*X
numparams=2;  % two parameters m1 and m2 for linear problem
i=1:numpts;
j=1:numparams;
X(i,1)=1;  % derivitive of function wrt first fitting parameter
X(i,2)=XX(i);  % derivitive of function wrt second fitting parameter
P=inv(X' * W * X);  % Intermediate matrix calculated for least squares fit and errors
M=P* X' * W * Y;  % results of least square fit
Ycalc=X*M ;  % Use least square fit parameters to calculate the fit line
E=Ycalc-Y ;  % Difference between fit and data
S=(E' * W * E);  % Sum of squared residuals
sigmas_res=(( S *diag(P))/(numpts-numparams)).^(0.5); % Error in parameters due to residuals
sigmas_w  =((Var*diag(P))/(numpts-numparams)).^(0.5);  % Error in parameters due to error bars
sigmas_tot=sigmas_res + sigmas_w;  % total error in each fit parameter
fprintf('slope = %g +/- %g \n',M(2),sigmas_tot(2));
fprintf('intercept = %g +/- %g \n',M(1),sigmas_tot(1));
fprintf('slope error is %g from residuals and %g from error bars \n',sigmas_res(2),sigmas_w(2));
fprintf('intercept error is %g from residuals and %g from error bars \n',sigmas_res(1),sigmas_w(1));
figure(1); clf;
plot(XX,YY,'.');
hold on;
errorbar(XX,YY,SS,'.');
i=1:100;
xxx(i)=i*max(XX)/90;  % Calculate fitted curve from 0 to 10% past final point
y_best=M(2)*xxx+M(1);  % best curve fit
y_1 =(M(2)+sigmas_tot(2))*xxx+(M(1)-sigmas_tot(1));  % high slope, low intercept curve fit
y_2=(M(2)-sigmas_tot(2))*xxx+(M(1)+sigmas_tot(1));  % low slope, high intercept curve fit
y_3=(M(2)-sigmas_tot(2))*xxx+(M(1)-sigmas_tot(1));  % low slope, low intercept
y_4=(M(2)+sigmas_tot(2))*xxx+(M(1)+sigmas_tot(1));   % high slope, high intercept
plot(xxx,y_best);
plot(xxx,y_1,':');
plot(xxx,y_2,':');
plot(xxx,y_3,':');
plot(xxx,y_4,':');
xlabel('X');
ylabel('Y');
title('Linear Regression including uncertainty in fit parameters')
hold off;
figure(2);clf;hold on;
plot(XX,E);
xlabel('X');
ylabel('Residual');
title(['Chi-squared =' num2str(S) '  N-M =' num2str((length(XX)-2))]);
