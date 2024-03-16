
%s_cut=rng;
%load('s_cut.mat')
%rng(s_cut);
STA_packet_size=zeros(1,TotalSTA);
cutpoint_rnd=randperm(Total_packet-1,TotalSTA-1);
cutpoint=sort(cutpoint_rnd);
for i=1:TotalSTA
    if i==1
        STA_packet_size(i)=cutpoint(i);
    elseif i==TotalSTA
        STA_packet_size(i)=Total_packet-cutpoint(i-1);
    else
        STA_packet_size(i)=cutpoint(i)-cutpoint(i-1);
    end
end