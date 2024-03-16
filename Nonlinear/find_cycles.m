%Find cycles in the graph
%[cycles_set,edgecycles_set]=allcycles(G);
%plot(G)
Gtemp=G;

Recieved_RU=zeros(Total_packet,TotalSTA);
Removed_RU=zeros(Total_packet,TotalSTA);
temp_cyc=0;

[~,edgecycles_set_temp]=allcycles(Gtemp);
cyc_process_time=0;
while ~isempty(edgecycles_set_temp)
    temp_cyc=temp_cyc+1;

    lengthsG = cellfun(@length, edgecycles_set_temp);
    [~, idxG] = max(lengthsG);
    active_Target_RU_idx=edgecycles_set_temp{idxG};%should be edge idx
    for i=1:length(active_Target_RU_idx)
        Recieved_RU(temp_cyc,Gtemp.Edges.EndNodes(active_Target_RU_idx(i),1))=Gtemp.Edges.Name(active_Target_RU_idx(i));
        Removed_RU(temp_cyc,Gtemp.Edges.EndNodes(active_Target_RU_idx(i),2))=Gtemp.Edges.Name(active_Target_RU_idx(i));
    end
    remove_RU_name=Gtemp.Edges.Name(active_Target_RU_idx);
    remove_edge_idx=[];
    for j=1:length(remove_RU_name)
        temp_find_idx=find(Gtemp.Edges.Name==remove_RU_name(j));
        for k=1:length(temp_find_idx)
            remove_edge_idx(end+1)=temp_find_idx(k);
        end
    end
    %final_remove_edge_idx=intersect(active_Target_RU_idx,remove_edge_idx);
    Gtemp=rmedge(Gtemp,remove_edge_idx);
%     figure()
%     plot(Gtemp)
tic
    [~,edgecycles_set_temp]=allcycles(Gtemp);
temp_process_time=toc;
cyc_process_time=cyc_process_time+temp_process_time;

end
%cyc_process_time

% Recieved_RU_2=zeros(Total_packet,TotalSTA);
% Removed_RU_2=zeros(Total_packet,TotalSTA);
% for m=1:TotalSTA
%     Recieved_RU_nz=nonzeros(Recieved_RU(:,m));
%     if ~isempty(Recieved_RU_nz)
%         Recieved_RU_2(1:length(Recieved_RU_nz),m)=Recieved_RU_nz;
%     end
% end