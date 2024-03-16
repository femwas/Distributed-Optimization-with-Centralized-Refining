local_opt_time_vc=reshape(local_opt_time_mx,1,numel(local_opt_time_mx));
CTR_SCO_time=cyc_process_time_mx+sco_opt_time_mx;
figure(1)
cdfplot(local_opt_time_vc);
hold on
cdfplot(cyc_process_time_mx);
hold on
cdfplot(sco_opt_time_mx);
hold on
cdfplot(CTR_SCO_time);
hold on
cdfplot(con_opt_time_mx);
legend('Local HA Time','Find Cycles Time','Simplified HA Time','Trading + Simplified HA Time','Centralized HA Time','Location','best')
hold off

figure(2)
cdfplot(avg_mx_ini);
hold on
cdfplot(avg_mx_PO);
hold on
cdfplot(avg_mx_SCO);
hold on
cdfplot(avg_mx_max_ut);
legend('Random Allocation','Trading based Pareto Optimal','Trading + Simplified HA','Centralized HA','Location','best')
hold off
% avg_mx_max_utavg_max_ut;
% avg_mx_SCO;
% avg_mx_PO;
% avg_mx_ini;