DR_per_packet=zeros(Total_packet,Total_packet);
PER_per_packet=zeros(Total_packet,Total_packet);
for m=1:TotalSTA
    if m==1
        for j=1:cutpoint(m)
            DR_per_packet(:,j)=DR_map(:,m);
            PER_per_packet(:,j)=PER_map(:,m);
        end
    elseif m==TotalSTA
        for j=cutpoint(m-1)+1:Total_packet
            DR_per_packet(:,j)=DR_map(:,m);
            PER_per_packet(:,j)=PER_map(:,m);
        end
    else
        for j=cutpoint(m-1)+1:cutpoint(m)
            DR_per_packet(:,j)=DR_map(:,m);
            PER_per_packet(:,j)=PER_map(:,m);
        end
    end
end