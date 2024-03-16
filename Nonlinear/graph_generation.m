%generate graph and find cycles
%graph generation
% Target_RU_nz={};
% Disused_RU_nz={};
index_inDisused=zeros(Total_packet,2,TotalSTA);
G=digraph;

temp_Egde_num=0;
Name=[];
%G.Edges.Name={};
% Node={};
% Edge={};
% Edge.Nave={};
%index_inDisused_simple=zeros(Total_packet,2,TotalSTA);%only care whos RU is targeted, to simplify graph generation.
for m=1:TotalSTA
    Target_RU_nz = nonzeros(Target_RU(:,m));
    row_inDisused_temp=zeros(1,length(Target_RU_nz));
    col_inDisused_temp=zeros(1,length(Target_RU_nz));
    for tt=1:length(Target_RU_nz)
        if ~isempty(find(Target_RU_nz(tt)==Disused_RU, 1))
            [row_inDisused_temp(tt),col_inDisused_temp(tt)]=find(Target_RU_nz(tt)==Disused_RU);
            G=addedge(G,m,col_inDisused_temp(tt));%Disused_RU(row_inDisused_temp(tt),col_inDisused_temp(tt))
            temp_Egde_num=temp_Egde_num+1;
            Name(temp_Egde_num)=Disused_RU(row_inDisused_temp(tt),col_inDisused_temp(tt));
            %G.Edges.Name{end+1}={Disused_RU(row_inDisused_temp(tt),col_inDisused_temp(tt))};
%             if isempty(find(cellfun(@(x) strcmp(x, m), Node)))
%                 Node{end+1}=m;%,col_inDisused_temp(tt)
%             elseif isempty(find(cellfun(@(x) strcmp(x, col_inDisused_temp(tt)), Node)))
%                 Node{end+1}=col_inDisused_temp(tt);
%             end
%             Edge(:,1){end+1}=m,col_inDisused_temp(tt);
%             Edge.Name{end+1}=Disused_RU(row_inDisused_temp(tt),col_inDisused_temp(tt));
        end
    end
    index_inDisused(1:length(row_inDisused_temp),1,m)=row_inDisused_temp;
    index_inDisused(1:length(row_inDisused_temp),2,m)=col_inDisused_temp;
    %Disused_RU_nz{m} = nonzeros(Disused_RU(:,m));
end

G.Edges.Name=Name';
%plot(G)
%find(Target_RU_nz{m}==Disused_RU_nz{n})