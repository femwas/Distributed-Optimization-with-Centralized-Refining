function f=myobjfun_simple(x,TotalSTA,Total_packet,Th_request_list_STA,PER_request_list, ...
    alpha,DR_convergence_rate,PER_convergence_rate,DR_per_packet_SCO_vc,PER_per_packet_SCO_vc, ...
    cutpoint,RU_SCO,DR_per_packet_PO,PER_per_packet_PO)%
%x 长度是
%STA_num=TotalSTA;
%DicentralizedSTA=0;
%central_STA_num=STA_num-DicentralizedSTA;
len_RU_SCO=length(RU_SCO);
allocation_len=len_RU_SCO^2;
beta=1-alpha;


DR_pacekt_SCO=DR_per_packet_SCO_vc.*x(1,1:allocation_len);
PER_pacekt_SCO=PER_per_packet_SCO_vc.*x(1,1:allocation_len);
SCO_DR_vc=DR_per_packet_PO;
SCO_PER_vc=PER_per_packet_PO;


for j=1:len_RU_SCO
    SCO_DR_vc(RU_SCO(j))=sum(DR_pacekt_SCO(len_RU_SCO*(j-1)+1:len_RU_SCO*j));
    SCO_PER_vc(RU_SCO(j))=sum(PER_pacekt_SCO(len_RU_SCO*(j-1)+1:len_RU_SCO*j));
end

DR_SCO=zeros(1,TotalSTA);
PER_SCO=zeros(1,TotalSTA);

for m=1:TotalSTA
    if m==1
            DR_SCO(m)=sum(SCO_DR_vc(1:cutpoint(m)));
            PER_SCO(m)=sum(SCO_PER_vc(1:cutpoint(m)))/cutpoint(m);
    elseif m==TotalSTA
            DR_SCO(m)=sum(SCO_DR_vc(cutpoint(m-1)+1:Total_packet));
            PER_SCO(m)=sum(SCO_PER_vc(cutpoint(m-1)+1:Total_packet))/(Total_packet-cutpoint(m-1));
    else
            DR_SCO(m)=sum(SCO_DR_vc(cutpoint(m-1)+1:cutpoint(m)));
            PER_SCO(m)=sum(SCO_PER_vc(cutpoint(m-1)+1:cutpoint(m)))/(cutpoint(m)-cutpoint(m-1));
    end
end


index_DR_SCO=1-exp(-DR_convergence_rate.*DR_SCO./Th_request_list_STA); %DR_map(j,:)>=Th_request_list;
index_PER_SCO=exp(-PER_convergence_rate.*PER_SCO./PER_request_list);%PER_map(j,:)<=PER_request_list;
Uindex=alpha.*index_DR_SCO+beta.*index_PER_SCO;
f=-sum(Uindex);
end
