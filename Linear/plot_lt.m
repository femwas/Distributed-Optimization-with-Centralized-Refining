figure(1)
x=1:slot;
X=0.0001+(x-1)*0.0005;
plot(X,tl_mx_max_ut,X,tl_mx_SCO)
hold on
plot(X,tl_mx_PO,X,tl_mx_ini)

legend('Centralized HA','Trading +Simplified HA','Trading based Pareto Optimality','Random Allocation')