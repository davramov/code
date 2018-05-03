function [  ] = spec_gau( l, I, lmin, lmax  ) %wavelength, intensity, lmin, lmax
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here
%% Gaussian Curve Fitting Demonstration Program
% Gauss_Fit_Demo.m
% Written by Melissa Pastorius and Eric Landahl 
% First written October 2008
% Last revised by EL 10/26/2010 to correct bug in parameter uncertainty
% Requires sample data file IsoOph132co2fit.dat

%% Part I:  Input data and put it in the right format

hold off
%clear all;
%hold off;
%load IsoOph132co2fit.dat; %reads in the data
%[n,p]=size(IsoOph132co2fit);
%numpts=n;
xx = l;
yy = I;

XX=xx(lmin:lmax);
YY=yy(lmin:lmax);
plot(XX,YY);
Y=YY'; %Turn YY into a row vector
[n,p]=size(XX);
numpts=n;
%Sigma=IsoOph132co2fit(:,3); %3rd column downloaded (error)
%Sigma=IsoOph132co2fit(:,3)/10; %3rd column downloaded (error)
%VV=Sigma.^2; %variance is sqaure of the standard deviation
%Var=sum(VV); % total variance in all data
%V=diag(VV); % for uncorrelated errors, the variance is a diagonal matrix
%W=Var*inv(V); % Weight matrix 
%% Part II: Guess the first curve fit 

numparams=4; %M(1), M(2), M(3), M(4) for fit
%M(1)= amplitude
M_guess(1)=max(Y); 
%M_guess(1)=M_guess(1) + (rand(1)/5 - 0.1);  % for demonstration only, use poor guess
%M(2)=center
M_guess(2)=sum(XX.*YY)/sum(Y);
%M_guess(2)=M_guess(2) + (rand(1)/5 - 0.1);  % for demonstration only, use poor guess
%M(3)=Width
M_guess(3)=std(XX);
%M_guess(3)=M_guess(3) + (rand(1)/5 - 0.1); % for demonstration only, use poor guess
%M(4)=yoffset
M_guess(4)=min(Y);
%M_guess(4)=M_guess(4) + (rand(1)/5 - 0.1);  % for demonstration only, use poor guess
M=M_guess';

% Equation for the gaussian
Y_guess=(M(1))*exp(-((XX-M(2)).^2/(M(3)^2)))+M(4);
E_guess=Y'-Y_guess;    % Error between guessed curve fit and data
E=E_guess;
%S_guess=(E' * W * E);  % Weighted sum of squared residuals from guess (Chi Squared)
S_guess=(E' * E);  % Weighted sum of squared residuals from guess (Chi Squared)
S=S_guess;

%% Part III: Iterate to try and improve curve fit
X = size(XX);
f=.01; %Shift factor determines speed of nolinear regression (f <= 1)
maxtry=5;  % Maximum number of curve fitting iterations
for t=1:maxtry
    for i=1:numpts
        X(i,1)=exp(-((-XX(i)+M(2)).^2/(M(3)^2)));
        X(i,2)=(1/M(3)^2)*2*M(1)*(XX(i)-M(2))*exp(-((-XX(i)+M(2)).^2/(M(3)^2)));
        X(i,3)=(1/M(3)^3)*2*M(1)*((XX(i)-M(2)).^2)*exp(-((-XX(i)+M(2)).^2/(M(3)^2)));
        X(i,4)=1 ;
    end
   %P=inv(X'*W* X);  % Intermediate matrix calculated for least squares fit and error
   P=inv(X'* X);  % Intermediate matrix calculated for least squares fit and error
   %delta_M=P*X'*W*E;
   delta_M=P*X'*E;
   M_guess=M+delta_M*f; % Update guesses for fit parameters
   Y_next=(M_guess(1))*exp(-((XX-M_guess(2)).^2/(M_guess(3)^2)))+M_guess(4);
   E=Y'-Y_next; % Residuals from updated fit
   %S=(E'*W*E); % New Chi Squared
   
   if S > S_guess;  % If error has not improved, record old values and break
       S=S_guess;
       E=E_guess;
       P=P_guess;
       Y_next=Y_guess;
       break
   end

   figure(1); clf; hold on;
   plot(XX,Y,'.');   % Plot raw data
   %errorbar(XX,YY,Sigma,'.'); % Plot error bars
   plot(XX,Y_next,'-');  % Plot current curve fit
   title(strvcat (['Nonlinear Fitting Iteration ' num2str(t)]));
   xlabel('X');
   ylabel('Y');
   pause(0.1);
   
   S_guess=S; % Use new values for next parameter guesses
   E_guess=E;
   P_guess=P;
   M=M_guess;

end

%% Part IV:  Calculate and display error in fit parameters

%sigmas_res= (S*diag(P)/(numpts-numparams)).^(0.5); % Error in parameters due to residuals
%sigmas_w  = (Var*diag(P)/(numpts-numparams)).^(0.5);  % Error in parameters due to error bars
%sigmas_tot=sigmas_res + sigmas_w;  % total error in each fit parameter
fprintf('ran for %g iterations \n',t);
fprintf('number of points - number of parameters = %g \n',(numpts-numparams));
%fprintf('amplitude = %g +/- %g \n',M(1),sigmas_tot(1));
%fprintf('amplitude error is %g from residuals and %g from error bars \n',sigmas_res(1),sigmas_w(1));
%fprintf('center = %g +/- %g \n',M(2),sigmas_tot(2));
%fprintf('center error is %g from residuals and %g from error bars \n',sigmas_res(2),sigmas_w(2));
%fprintf('width = %g +/- %g \n',M(3),sigmas_tot(3));
%fprintf('width error is %g from residuals and %g from error bars \n',sigmas_res(3),sigmas_w(3));
%fprintf('baseline = %g +/- %g \n',M(4),sigmas_tot(4));
%fprintf('baseline error is %g from residuals and %g from error bars \n',sigmas_res(4),sigmas_w(4));
fprintf('center = %g \n',M(2));


%% Part V:  Plot final fit showing errors in fit parameters
figure(1); clf; hold on;
plot(XX,Y,'.');   % Plot raw data
%errorbar(XX,YY,Sigma,'.'); % Plot error bars
plot(XX,Y_next,'-');  % Plot current curve fit
title(strvcat (['Nonlinear Fitting Iteration ' num2str(t)],['Chi Squared =' num2str(S)]));
xlabel('X');
ylabel('Y');
%M_plus = M + sigmas_tot;
%M_minus = M - sigmas_tot;
%Y_plus=(M_plus(1))*exp(-((XX-M_plus(2)).^2/(M_plus(3)^2)))+M_plus(4);
%Y_minus=(M_minus(1))*exp(-((XX-M_minus(2)).^2/(M_minus(3)^2)))+M_minus(4);
%plot(XX,Y_minus,':');  
%plot(XX,Y_plus,':'); 

%% Part VI:  Plot residuals
figure(2);clf;hold on;
plot(XX,E,'.-')
title('Curve Fit Residuals');
xlabel('X');
ylabel('Data - Fit');

end

