
reserved_RU=zeros(Total_packet,TotalSTA);
Target_RU=zeros(Total_packet,TotalSTA);
Disused_RU=zeros(Total_packet,TotalSTA);

for m=1:TotalSTA
    temp_r_RU=[];
    temp_t_RU=[];
    temp_d_RU=[];

    temp_r_RU=intersect(allocation_scheme_local_opt_NL(1:STA_packet_size(m),1,m), ...
        ini_scheme_local_opt(1:STA_packet_size(m),1,m));
    temp_t_RU=setdiff(allocation_scheme_local_opt_NL(1:STA_packet_size(m),1,m), ...
        ini_scheme_local_opt(1:STA_packet_size(m),1,m));
    temp_d_RU=setdiff(ini_scheme_local_opt(1:STA_packet_size(m),1,m), ...
        allocation_scheme_local_opt_NL(1:STA_packet_size(m),1,m));

    reserved_RU(1:length(temp_r_RU),m)=temp_r_RU;
    Target_RU(1:length(temp_t_RU),m)=temp_t_RU;
    Disused_RU(1:length(temp_d_RU),m)=temp_d_RU;
end

