%initial local allocation
ini_scheme_local_opt=zeros(Total_packet,2,TotalSTA);
ini_assigned_RU=1:Total_packet;%randperm(Total_packet) random assignment
for m=1:TotalSTA
    if m==1
        ini_scheme_local_opt(1:STA_packet_size(m),1,m)=ini_assigned_RU(1:cutpoint(m));
        ini_scheme_local_opt(1:STA_packet_size(m),2,m)=ini_assigned_RU(1:cutpoint(m));
    elseif m==TotalSTA
        ini_scheme_local_opt(1:STA_packet_size(m),1,m)=ini_assigned_RU(cutpoint(m-1)+1:Total_packet);
        ini_scheme_local_opt(1:STA_packet_size(m),2,m)=ini_assigned_RU(cutpoint(m-1)+1:Total_packet);
    else
        ini_scheme_local_opt(1:STA_packet_size(m),1,m)=ini_assigned_RU(cutpoint(m-1)+1:cutpoint(m));
        ini_scheme_local_opt(1:STA_packet_size(m),2,m)=ini_assigned_RU(cutpoint(m-1)+1:cutpoint(m));
    end
end