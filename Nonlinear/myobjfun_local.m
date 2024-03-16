function f=myobjfun_local(x,TotalSTA,STAidx,Total_packet,Th_request_list_STA,PER_request_list,alpha,DR_convergence_rate,PER_convergence_rate,DR_per_packet,PER_per_packet,cutpoint,local_packet_num)%
%local_packet_num=STA_packet_size(STAidx);
allocation_len_local=local_packet_num*Total_packet;
allocation_len=Total_packet^2;
Th_request_list_STA_local=Th_request_list_STA(STAidx);
PER_request_list_local=PER_request_list(STAidx);
alpha_local=alpha(STAidx);
beta_local=1-alpha_local;

DR_per_packet_vc=reshape(DR_per_packet,1,allocation_len);
PER_per_packet_vc=reshape(PER_per_packet,1,allocation_len);


% DR_packet=DR_per_packet_vc.*x(1,1:allocation_len_local);
% PER_packet=PER_per_packet_vc.*x(1,1:allocation_len_local);

% DR=0;
% PER=0;

if STAidx==1
        DR_packet=DR_per_packet_vc(1:allocation_len_local).*x(1,1:allocation_len_local);
        PER_packet=PER_per_packet_vc(1:allocation_len_local).*x(1,1:allocation_len_local);
elseif STAidx==TotalSTA
        DR_packet=DR_per_packet_vc(cutpoint(STAidx-1)*Total_packet+1:allocation_len).*x(1,1:allocation_len_local);
        PER_packet=PER_per_packet_vc(cutpoint(STAidx-1)*Total_packet+1:allocation_len).*x(1,1:allocation_len_local);
else
        DR_packet=DR_per_packet_vc(cutpoint(STAidx-1)*Total_packet+1:cutpoint(STAidx)*Total_packet).*x(1,1:allocation_len_local);
        PER_packet=PER_per_packet_vc(cutpoint(STAidx-1)*Total_packet+1:cutpoint(STAidx)*Total_packet).*x(1,1:allocation_len_local);
end
DR=sum(DR_packet);
PER=sum(PER_packet)/local_packet_num;

index_DR=1-exp(-DR_convergence_rate*DR/Th_request_list_STA_local); %DR_map(j,:)>=Th_request_list;
index_PER=exp(-PER_convergence_rate*PER/PER_request_list_local);%PER_map(j,:)<=PER_request_list;
Uindex=alpha_local*index_DR+beta_local*index_PER;
f=-sum(Uindex);
end