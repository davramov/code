wc = [0, 1e-4];
Wt1=[3.8,5.1];
Wt2=[6,6];
Wt3=[3.2,4.6];
Wt4=[3.5,4.2];
Wt5=[4.9,5.5];

mc1=[0,10^-7,10^-6,10^-4];
M1=[0.8,0.9,1.1,3.1];
M2=[1.25,1.5,1.75,9];

plot(mc1,M1,'r-x',mc1,M2,'b-o',wc,Wt1,'g-.+',wc,Wt2,'m-.*','MarkerSize',12);
legend({'Week 4 Mutants','Week 5 Mutants', 'Week 4 Wild Type', 'Week 5 Wild Type'},'FontSize',12,'Location','southoutside','Orientation','horizontal');
title('Wisconsin Fast Plant Height versus Gibberellins Concentration','FontSize',18)
xlabel('Gibberellins Concentration (g/mL)','FontSize',15)
ylabel('Fast Plant Height (cm)','FontSize',15)