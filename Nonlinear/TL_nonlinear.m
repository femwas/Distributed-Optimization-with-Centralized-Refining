MaxGenerations_base=[1e-5,1e-4,1e-3,1e-2,0.1,1,2,5,10,20,60,100,200];%];%suggest lower for testing [1e-5,1e-4,1e-3,1e-2,0.1,1]%[0.1,1,10,20,60,100];%10:10:100;
MaxTime=MaxGenerations_base.*6;
lenMG=length(MaxGenerations_base);
MaxGenerations_simple_mx=floor(MaxGenerations_base*3);
MaxGenerations_global_mx=floor(MaxGenerations_base);
avg_SCO_NL_mx=zeros(1,lenMG);
ga_process_time_SCO_mx=zeros(1,lenMG);
avg_con_NL_mx=zeros(1,lenMG);
ga_process_time_global_mx=zeros(1,lenMG);
avg_PO_NL_mx=zeros(1,lenMG);
avg_RA_NL_mx=zeros(1,lenMG);
for islot=1:lenMG
    find_cycles_islot;
    if temp_process_time>MaxTime(islot)
        avg_PO_NL_mx(islot)=avg_RA_NL;
    else
        Pareto_optimal_mx_NL;
        generate_RU_SCO;
        avg_PO_NL_mx(islot)=avg_PO_NL;
    end
    %Random_allocation_utility
    avg_RA_NL_mx(islot)=avg_RA_NL;
    if MaxGenerations_global_mx(islot)<=1
        avg_SCO_NL_mx(islot)=avg_PO_NL_mx(islot);
        avg_con_NL_mx(islot)=avg_RA_NL_mx(islot);
    else
        [~,avg_SCO_NL_mx(islot),ga_process_time_SCO_mx(islot)]=ga_solver_simple(TotalSTA, ...
            Total_packet,Th_request_list_STA,PER_request_list,alpha,DR_convergence_rate, ...
            PER_convergence_rate,DR_per_packet,PER_per_packet,cutpoint,RU_SCO, ...
            DR_per_packet_PO,PER_per_packet_PO,MaxGenerations_simple_mx(islot));
        [~,avg_con_NL_mx(islot),ga_process_time_global_mx(islot)]=ga_solver(TotalSTA,Total_packet,Th_request_list_STA, ...
            PER_request_list,alpha,DR_convergence_rate,PER_convergence_rate,DR_per_packet, ...
            PER_per_packet,cutpoint,MaxGenerations_global_mx(islot));
    end
end
%60:60:600s