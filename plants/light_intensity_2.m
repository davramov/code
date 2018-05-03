d=[12,24,36,48];
no_h=[0.406666667,0.44,0.146666667,0.046666667];
h=[0.2,0.233333333,0.213333333,0.066666667];
du=12;
u=0.673333333;
db=12;
b=0;

plot(d,no_h,'r-x',d,h,'k:o',du,u,'m+',db,b,'b*','MarkerSize',12);
ax.XAxis.TickValues = [12 24 36 48];
legend({'Without Herbicide','With Herbicide','Uncoupler','Boiled Thylakoids'},'FontSize',12,'Location','southoutside','Orientation','horizontal');
title('Change in Absorbance per Minute for Each Treatment','FontSize',18)
xlabel('Distance (in)','FontSize',15)
ylabel('Change in Absorbance per Minute Measured at \lambda = 605 nm','FontSize',15)

