

RA_RU_allocation_row=randperm(Total_packet);%1:Total_packet;%
DR_per_packet_RA=zeros(1,Total_packet);
PER_per_packet_RA=zeros(1,Total_packet);
DR_RA=zeros(1,TotalSTA);
PER_RA=zeros(1,TotalSTA);
for i=1:Total_packet
    DR_per_packet_RA(i)=DR_per_packet(RA_RU_allocation_row(i),i);
    PER_per_packet_RA(i)=PER_per_packet(RA_RU_allocation_row(i),i);
end
for m=1:TotalSTA
    if m==1
            DR_RA(m)=sum(DR_per_packet_RA(1:cutpoint(m)));
            PER_RA(m)=sum(PER_per_packet_RA(1:cutpoint(m)))/cutpoint(m);
    elseif m==TotalSTA
            DR_RA(m)=sum(DR_per_packet_RA(cutpoint(m-1)+1:Total_packet));
            PER_RA(m)=sum(PER_per_packet_RA(cutpoint(m-1)+1:Total_packet))/(Total_packet-cutpoint(m-1));
    else
            DR_RA(m)=sum(DR_per_packet_RA(cutpoint(m-1)+1:cutpoint(m)));
            PER_RA(m)=sum(PER_per_packet_RA(cutpoint(m-1)+1:cutpoint(m)))/(cutpoint(m)-cutpoint(m-1));
    end
end
index_DR_RA=1-exp(-DR_convergence_rate.*DR_RA./Th_request_list_STA); %DR_map(j,:)>=Th_request_list;
index_PER_RA=exp(-PER_convergence_rate.*PER_RA./PER_request_list);%PER_map(j,:)<=PER_request_list;
Utility_per_STA_RA=alpha.*index_DR_RA+beta.*index_PER_RA;
avg_RA_NL=mean(Utility_per_STA_RA);