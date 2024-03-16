Pareto_RU_updated=ini_scheme_local_opt;%RUidx*STAidx
DR_per_packet_PO=zeros(1,Total_packet);
PER_per_packet_PO=zeros(1,Total_packet);
DR_PO=zeros(1,TotalSTA);
PER_PO=zeros(1,TotalSTA);
Pareto_RU_allocation_row=[];
Pareto_RU_allocation_col=[];
for m=1:TotalSTA
    nz_removed=nonzeros(Removed_RU(:,m));
    nz_recieved=nonzeros(Recieved_RU(:,m));
    len_Recieved_RU=length(nz_recieved);
    len_Removed_RU=length(nz_removed);
    Pareto_changed_idx=zeros(1,len_Removed_RU);
    for ii=1:len_Removed_RU
        if ~isempty(find(nz_removed(ii)==ini_scheme_local_opt(:,1,m), 1))
        Pareto_changed_idx(ii)=find(nz_removed(ii)==ini_scheme_local_opt(:,1,m));
        Pareto_RU_updated(Pareto_changed_idx(ii),1,m)=nz_recieved(ii);
        end
    end
    Pareto_RU_allocation_row=[Pareto_RU_allocation_row,nonzeros(Pareto_RU_updated(:,1,m))'];
    Pareto_RU_allocation_col=[Pareto_RU_allocation_col,nonzeros(Pareto_RU_updated(:,2,m))'];
end
for i=1:Total_packet
    DR_per_packet_PO(i)=DR_per_packet(Pareto_RU_allocation_row(i),Pareto_RU_allocation_col(i));
    PER_per_packet_PO(i)=PER_per_packet(Pareto_RU_allocation_row(i),Pareto_RU_allocation_col(i));
end
for m=1:TotalSTA
    if m==1
            DR_PO(m)=sum(DR_per_packet_PO(1:cutpoint(m)));
            PER_PO(m)=sum(PER_per_packet_PO(1:cutpoint(m)))/cutpoint(m);
    elseif m==TotalSTA
            DR_PO(m)=sum(DR_per_packet_PO(cutpoint(m-1)+1:Total_packet));
            PER_PO(m)=sum(PER_per_packet_PO(cutpoint(m-1)+1:Total_packet))/(Total_packet-cutpoint(m-1));
    else
            DR_PO(m)=sum(DR_per_packet_PO(cutpoint(m-1)+1:cutpoint(m)));
            PER_PO(m)=sum(PER_per_packet_PO(cutpoint(m-1)+1:cutpoint(m)))/(cutpoint(m)-cutpoint(m-1));
    end
end
index_DR_PO=1-exp(-DR_convergence_rate.*DR_PO./Th_request_list_STA); %DR_map(j,:)>=Th_request_list;
index_PER_PO=exp(-PER_convergence_rate.*PER_PO./PER_request_list);%PER_map(j,:)<=PER_request_list;
Utility_per_STA_PO=alpha.*index_DR_PO+beta.*index_PER_PO;
avg_PO_NL=mean(Utility_per_STA_PO);