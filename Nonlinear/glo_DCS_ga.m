%MaxGenerations_global=100;
%1:2.627
[opt_allocation_x_re,avg_con_NL,ga_process_time_global]=ga_solver(TotalSTA,Total_packet,Th_request_list_STA, ...
    PER_request_list,alpha,DR_convergence_rate,PER_convergence_rate,DR_per_packet, ...
    PER_per_packet,cutpoint,MaxGenerations_global);
%save('ga_process_time_0606_3.mat','ga_process_time_global')
%612.91