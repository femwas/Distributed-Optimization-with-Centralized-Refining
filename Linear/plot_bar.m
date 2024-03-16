avglocal_opt_time_mx=mean(local_opt_time_vc);
avgcon_opt_time_mx=mean(con_opt_time_mx);
avgcyc_process_time_mx=mean(cyc_process_time_mx);
avgCTR_SCO_time=mean(CTR_SCO_time);
%bar([avgcyc_process_time_mx,avgCTR_SCO_time,avgcon_opt_time_mx])
savetime_SCO=(avgcon_opt_time_mx-avgCTR_SCO_time)./avgcon_opt_time_mx;
savetime_PO=(avgcon_opt_time_mx-avgcyc_process_time_mx)./avgcon_opt_time_mx;

avgavg_mx_max_ut=mean(avg_mx_max_ut);
avgavg_mx_SCO=mean(avg_mx_SCO);
avgavg_mx_PO=mean(avg_mx_PO);
avgavg_mx_ini=mean(avg_mx_ini);
utilitydecreasing_SCO=(avgavg_mx_max_ut-avgavg_mx_SCO)./avgavg_mx_max_ut;
utilitydecreasing_PO=(avgavg_mx_max_ut-avgavg_mx_PO)./avgavg_mx_max_ut;

figure(3)
bar([100,100;100,100])
hold on
bar([1-savetime_PO,1-utilitydecreasing_PO;1-savetime_SCO,1-utilitydecreasing_SCO].*100)
legend('','','Processing Time','Utility','Location','best')
hold off