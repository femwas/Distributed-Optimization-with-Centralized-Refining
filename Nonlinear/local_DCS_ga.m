ga_process_time_local=zeros(1,TotalSTA);
allocation_scheme_local_opt_NL=zeros(Total_packet,2,TotalSTA);
for STAidx=1:TotalSTA
    %opt_allocation_x_re_local=[];
    %STAidx=2;
    [opt_allocation_x_re_local,ga_process_time_local(STAidx),x,local_packet_num]=ga_solver_local(TotalSTA,STAidx, ...
        Total_packet,Th_request_list_STA,PER_request_list,alpha,DR_convergence_rate, ...
        PER_convergence_rate,DR_per_packet,PER_per_packet,cutpoint,STA_packet_size);

    [RU_idx_NL_local,packet_idx_NL_local]=find(opt_allocation_x_re_local==1);
    allocation_scheme_local_opt_NL(1:STA_packet_size(STAidx),1,STAidx)=RU_idx_NL_local;
    if STAidx~=1
        allocation_scheme_local_opt_NL(1:STA_packet_size(STAidx),2,STAidx)=packet_idx_NL_local+cutpoint(STAidx-1);
    else
        allocation_scheme_local_opt_NL(1:STA_packet_size(STAidx),2,STAidx)=packet_idx_NL_local;
    end
end
%save('ga_process_time_local_0606.mat','ga_process_time_local')