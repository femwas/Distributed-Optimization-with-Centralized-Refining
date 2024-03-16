
figure(11)
plot(MaxTime,avg_con_NL_mx,MaxTime,avg_SCO_NL_mx)
hold on;
plot(MaxTime,avg_PO_NL_mx,MaxTime,avg_RA_NL_mx)
legend('Conventional Optimization','Trading +Simplified Optimization','Trading based Pareto Optimality','Random Allocation')