function f=myobjfun(x,TotalSTA,Total_packet,Th_request_list_STA,PER_request_list,alpha,DR_convergence_rate,PER_convergence_rate,DR_per_packet,PER_per_packet,cutpoint)%

%DicentralizedSTA=0;
allocation_len=Total_packet^2;


beta=1-alpha;

DR_per_packet_vc=reshape(DR_per_packet,1,allocation_len);
PER_per_packet_vc=reshape(PER_per_packet,1,allocation_len);
DR_pacekt=DR_per_packet_vc.*x(1,1:allocation_len);
PER_pacekt=PER_per_packet_vc.*x(1,1:allocation_len);

DR=zeros(1,TotalSTA);
PER=zeros(1,TotalSTA);

for m=1:TotalSTA
    if m==1
            DR(m)=sum(DR_pacekt(1:cutpoint(m)*Total_packet));
            PER(m)=sum(PER_pacekt(1:cutpoint(m)*Total_packet))/cutpoint(m);
    elseif m==TotalSTA
            DR(m)=sum(DR_pacekt(cutpoint(m-1)*Total_packet+1:Total_packet*Total_packet));
            PER(m)=sum(PER_pacekt(cutpoint(m-1)*Total_packet+1:Total_packet*Total_packet))/(Total_packet-cutpoint(m-1));
    else
            DR(m)=sum(DR_pacekt(cutpoint(m-1)*Total_packet+1:cutpoint(m)*Total_packet));
            PER(m)=sum(PER_pacekt(cutpoint(m-1)*Total_packet+1:cutpoint(m)*Total_packet))/(cutpoint(m)-cutpoint(m-1));
    end
end


index_DR=1-exp(-DR_convergence_rate.*DR./Th_request_list_STA); %DR_map(j,:)>=Th_request_list;
index_PER=exp(-PER_convergence_rate.*PER./PER_request_list);%PER_map(j,:)<=PER_request_list;
Uindex=alpha.*index_DR+beta.*index_PER;
f=-sum(Uindex);
end
