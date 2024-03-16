clear all
Total_packet=74;
TotalSTA=20;
Total_RU=Total_packet;
repeattime=100;


local_opt_time_mx=zeros(TotalSTA,repeattime);
con_opt_time_mx=zeros(1,repeattime);
cyc_process_time_mx=zeros(1,repeattime);
sco_opt_time_mx=zeros(1,repeattime);
avg_mx_max_ut=zeros(1,repeattime);
avg_mx_SCO=zeros(1,repeattime);
avg_mx_PO=zeros(1,repeattime);
avg_mx_ini=zeros(1,repeattime);
avg_mx_delta_R=zeros(1,repeattime);

max_timelimit=0.008;
timestep=0.0005;%0.5ms
slot=max_timelimit/timestep;

tl_mx_max_ut=zeros(1,slot);
tl_mx_SCO=zeros(1,slot);
tl_mx_PO=zeros(1,slot);
tl_mx_ini=zeros(1,slot);
for tl=1:slot
    time_limitation=0.0001+(tl-1)*timestep;
    %Readdata;
    MCSlen=11;
    Passlosslen=12;
    RUlen=9;

    Data_PER=zeros(MCSlen,Passlosslen,RUlen);
    Data_DR=zeros(MCSlen,Passlosslen,RUlen);
    for i=1:11
        Data_PER(i,:,:)=readmatrix('PERdata1.xlsx','Sheet',i,'Range','A1:I12');
        Data_DR(i,:,:)=readmatrix('Throughputdata1.xlsx','Sheet',i,'Range','A1:I12');
    end

    %LAprocess;%rng
    PER_out_AMLA_2=zeros(Passlosslen,RUlen);
    DR_out_AMLA_2=zeros(Passlosslen,RUlen);
    for i=1:RUlen
        PER_set=Data_PER(:,:,i);
        DR_set=Data_DR(:,:,i);
        for k=1:Passlosslen
            MCSset=find(PER_set(:,k)<0.1);%10% PER in existing wifi
            maxPERset=zeros(length(MCSset));
            for ll=1:length(MCSset)
                maxPERset(ll)=PER_set(ll,k);
            end
            if isempty(MCSset)
                MCSmax=1;
            else
                MCSmax=max(MCSset);
            end
            %MCSmax_idx=find(PER_set(:,i)==MCSmax);
            PER_out_AMLA_2(k,i)=PER_set(MCSmax,k);
            DR_out_AMLA_2(k,i)=DR_set(MCSmax,k);
        end
    end




    parfor ddd=1:repeattime 
        %for ddd=1:repeattime
        %Generate_channel;
        Distance_based_passloss=randi([1,10],1,TotalSTA);
        AWGN_channel_rnd=randn(Total_RU,TotalSTA);
        AWGN_channel=zeros(Total_RU,TotalSTA);
        for i=1:3
            AWGN_channel(AWGN_channel_rnd>=i)=i;
            AWGN_channel(AWGN_channel_rnd<=-i)=-i;
        end
        Passloss_map=Distance_based_passloss+AWGN_channel;%random passloss index to mapping to 12 level in PER dataset
        Passloss_map(Passloss_map>12)=12;
        Passloss_map(Passloss_map<1)=1;

        %%linear
        %Random_packet_size_generation;%rng
        STA_packet_size=zeros(1,TotalSTA);
        cutpoint_rnd=randperm(Total_packet,TotalSTA-1);
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


        PER_map=zeros(Total_RU,TotalSTA);
        DR_map=zeros(Total_RU,TotalSTA);
        latency_map=zeros(Total_RU,TotalSTA);
        RU_index=zeros(1,Total_RU);
        for j=1:Total_RU
            RU_index(j)=mod(j,RUlen);
        end
        RU_index(RU_index==0)=9;
        for k=1:TotalSTA
            for j=1:Total_RU
                PER_map(j,k)=PER_out_AMLA_2(Passloss_map(j,k),RU_index(j));%12 passloss，9 RU.
                DR_map(j,k)=DR_out_AMLA_2(Passloss_map(j,k),RU_index(j));
            end
        end


        %Linear_Utility_generation;
        Th_request_list_RU=12*rand(1,TotalSTA);
        PER_request_list=10.^(-1*randi([1,4],1,TotalSTA));
        latency_request_list=10.^(-1*randi([2,5],1,TotalSTA));
        temp_alpha=rand(1,3);
        alpha=temp_alpha(1)/sum(temp_alpha);
        beta=temp_alpha(2)/sum(temp_alpha);
        gamma=temp_alpha(3)/sum(temp_alpha);
        % alpha=rand(1,TotalSTA);
        % beta=1-alpha;
        DR_convergence_rate=3;%randi([1,4],1,TotalSTA);
        PER_convergence_rate=3;%randi([1,4],1,TotalSTA);
        latency_convergence_rate=3;

        index_DR=zeros(Total_packet,TotalSTA);
        index_PER=zeros(Total_packet,TotalSTA);
        index_latency=zeros(Total_packet,TotalSTA);
        Linear_Uindex=zeros(Total_packet,TotalSTA);
        for j=1:Total_packet
            index_DR(j,:)=1-exp(-DR_convergence_rate.*DR_map(j,:)./Th_request_list_RU); %DR_map(j,:)>=Th_request_list;
            index_PER(j,:)=exp(-PER_convergence_rate.*PER_map(j,:)./PER_request_list);%PER_map(j,:)<=PER_request_list;
            for k=1:TotalSTA
                latency_map(j,k)=timestep./((1-PER_map(j,k)).*STA_packet_size(k));
                index_latency(j,k)=exp(-latency_convergence_rate.*latency_map(j,k)./latency_request_list(k));
            end
            Linear_Uindex(j,:)=alpha.*index_DR(j,:)+beta.*index_PER(j,:)+gamma.*index_latency(j,:);
        end

        %initial_local_assignment;
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

        %Utility_per_packet_generation;
        Utility_per_packet=zeros(Total_packet,Total_packet);
        DR_per_packet=zeros(Total_packet,Total_packet);
        PER_per_packet=zeros(Total_packet,Total_packet);
        for m=1:TotalSTA
            if m==1
                for j=1:cutpoint(m)
                    Utility_per_packet(:,j)=Linear_Uindex(:,m);
                    DR_per_packet(:,j)=DR_map(:,m);
                    PER_per_packet(:,j)=PER_map(:,m);
                end
            elseif m==TotalSTA
                for j=cutpoint(m-1)+1:Total_packet
                    Utility_per_packet(:,j)=Linear_Uindex(:,m);
                    DR_per_packet(:,j)=DR_map(:,m);
                    PER_per_packet(:,j)=PER_map(:,m);
                end
            else
                for j=cutpoint(m-1)+1:cutpoint(m)
                    Utility_per_packet(:,j)=Linear_Uindex(:,m);
                    DR_per_packet(:,j)=DR_map(:,m);
                    PER_per_packet(:,j)=PER_map(:,m);
                end
            end
        end
        Utility_per_packet_ini=zeros(1,Total_packet);
        for i=1:Total_packet
            Utility_per_packet_ini(i)=Utility_per_packet(i,i);
        end
        avg_ini=mean(Utility_per_packet_ini);

        %Linear_local_opt;
        local_opt_time=zeros(1,TotalSTA);
        allocation_scheme_local_opt=zeros(Total_packet,2,TotalSTA);
        for m=1:TotalSTA
            Local_Utility_per_matrix=[];
            if m==1
                Local_Utility_per_matrix=Utility_per_packet(:,1:cutpoint(m));
            elseif m==TotalSTA
                Local_Utility_per_matrix=Utility_per_packet(:,cutpoint(m-1)+1:Total_packet);
            else
                Local_Utility_per_matrix=Utility_per_packet(:,cutpoint(m-1)+1:cutpoint(m));
            end
            tic
            allocation_scheme_local_opt(1:STA_packet_size(m),:,m)=matchpairs(1-Local_Utility_per_matrix,1000);
            local_opt_time(m)=toc;
            if m~=1
                allocation_scheme_local_opt(1:STA_packet_size(m),2,m)=allocation_scheme_local_opt(1:STA_packet_size(m),2,m)+cutpoint(m-1);
            end
        end

        %graph and cycle
        %Target_Disuse;
        reserved_RU=zeros(Total_packet,TotalSTA);
        Target_RU=zeros(Total_packet,TotalSTA);
        Disused_RU=zeros(Total_packet,TotalSTA);

        for m=1:TotalSTA
            temp_r_RU=[];
            temp_t_RU=[];
            temp_d_RU=[];

            temp_r_RU=intersect(allocation_scheme_local_opt(1:STA_packet_size(m),1,m), ...
                ini_scheme_local_opt(1:STA_packet_size(m),1,m));
            temp_t_RU=setdiff(allocation_scheme_local_opt(1:STA_packet_size(m),1,m), ...
                ini_scheme_local_opt(1:STA_packet_size(m),1,m));
            temp_d_RU=setdiff(ini_scheme_local_opt(1:STA_packet_size(m),1,m), ...
                allocation_scheme_local_opt(1:STA_packet_size(m),1,m));

            reserved_RU(1:length(temp_r_RU),m)=temp_r_RU;
            Target_RU(1:length(temp_t_RU),m)=temp_t_RU;
            Disused_RU(1:length(temp_d_RU),m)=temp_d_RU;
        end

        %graph_generation;
        index_inDisused=zeros(Total_packet,2,TotalSTA);
        G=digraph;
        temp_Egde_num=0;
        Name=[];
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
                end
            end
            index_inDisused(1:length(row_inDisused_temp),1,m)=row_inDisused_temp;
            index_inDisused(1:length(row_inDisused_temp),2,m)=col_inDisused_temp;
            %Disused_RU_nz{m} = nonzeros(Disused_RU(:,m));
        end
        G.Edges.Name=Name';
        %find_cycles;
        Gtemp=G;

        Recieved_RU=zeros(Total_packet,TotalSTA);
        Removed_RU=zeros(Total_packet,TotalSTA);
        temp_cyc=0;

        [~,edgecycles_set_temp]=allcycles(Gtemp);
        cyc_process_time=0;
        while (~isempty(edgecycles_set_temp))&&cyc_process_time<time_limitation
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

        %
        %Pareto_optimal_mx;
        Pareto_RU_updated=ini_scheme_local_opt;%RUidx*STAidx
        Utility_per_packet_PO=zeros(1,Total_packet);
        Pareto_RU_allocation_row=[];
        Pareto_RU_allocation_col=[];
        for m=1:TotalSTA
            nz_removed=nonzeros(Removed_RU(:,m));
            nz_recieved=nonzeros(Recieved_RU(:,m));
            len_Recieved_RU=length(nz_recieved);
            len_Removed_RU=length(nz_removed);
            Pareto_changed_idx=zeros(1,len_Removed_RU);
            for ii=1:len_Removed_RU
                if ~isempty(find(nz_removed(ii)==ini_scheme_local_opt(:,1,m), 1))
                    Pareto_changed_idx(ii)=find(nz_removed(ii)==ini_scheme_local_opt(:,1,m));
                    Pareto_RU_updated(Pareto_changed_idx(ii),1,m)=nz_recieved(ii);
                end
            end
            Pareto_RU_allocation_row=[Pareto_RU_allocation_row,nonzeros(Pareto_RU_updated(:,1,m))'];
            Pareto_RU_allocation_col=[Pareto_RU_allocation_col,nonzeros(Pareto_RU_updated(:,2,m))'];
        end
        for i=1:Total_packet
            Utility_per_packet_PO(i)=Utility_per_packet(Pareto_RU_allocation_row(i),Pareto_RU_allocation_col(i));
        end
        avg_PO=mean(Utility_per_packet_PO);

        %simple_central_opt;
        RU_SCO=[];
        for m=1:TotalSTA
            nz_Disused_RU=nonzeros(Disused_RU(:,m));
            nz_Removed_RU=nonzeros(Removed_RU(:,m));
            RU_SCO_temp=setdiff(nz_Disused_RU,nz_Removed_RU);
            RU_SCO=[RU_SCO,RU_SCO_temp'];
        end
        %generate new cost mx
        rest_limited_time=time_limitation-cyc_process_time;
        if rest_limited_time>0
            Utility_per_packet_SCO=Utility_per_packet(RU_SCO,RU_SCO);%RUSCO are idx
            tic
            M_SCO=matchpairs(1-Utility_per_packet_SCO,1000);
            %[pktidx_sco,RUidx_sco,~]=TimeHungarian(Utility_per_packet_SCO,rest_limited_time)
            sco_opt_time=toc;
            if rest_limited_time>=sco_opt_time
                RU_SCO_update=zeros(length(RU_SCO),2);

                SCO_RU_allocation_row=Pareto_RU_allocation_row;
                SCO_RU_allocation_col=Pareto_RU_allocation_col;
                for tt=1:length(RU_SCO)
                    RU_SCO_update(tt,1)=RU_SCO(M_SCO(tt,1));%RUidx
                    RU_SCO_update(tt,2)=RU_SCO(M_SCO(tt,2));%packet idx
                    %RU_SCO_update(tt,1)=RU_SCO(RUidx_sco(tt));%RUidx
                    %RU_SCO_update(tt,2)=RU_SCO(pktidx_sco(tt));%packet idx
                    SCO_RU_allocation_row(RU_SCO_update(tt,2))=RU_SCO_update(tt,1);
                end
                Utility_per_packet_SCO=zeros(1,Total_packet);
                for i=1:Total_packet
                    Utility_per_packet_SCO(i)=Utility_per_packet(SCO_RU_allocation_row(i),SCO_RU_allocation_col(i));
                end
                avg_SCO=mean(Utility_per_packet_SCO);
            else
                avg_SCO=avg_PO;
            end
        else
            avg_SCO=avg_PO;
            sco_opt_time=0;
        end
        %con_opt;
        tic
        %M=matchpairs(1-Utility_per_packet,1000);
        [~,row4col_con,~]=TimeHungarian(Utility_per_packet,time_limitation);
        con_opt_time=toc;

        max_utility_mx=zeros(1,Total_packet);
        for l=1:Total_packet
            max_utility_mx(l)=Utility_per_packet(row4col_con(l),l);
        end
        avg_max_ut=mean(max_utility_mx);

        local_opt_time_mx(:,ddd)=local_opt_time;
        con_opt_time_mx(ddd)=con_opt_time;
        cyc_process_time_mx(ddd)=cyc_process_time;
        sco_opt_time_mx(ddd)=sco_opt_time;

        avg_mx_max_ut(ddd)=avg_max_ut;
        avg_mx_SCO(ddd)=avg_SCO;
        avg_mx_PO(ddd)=avg_PO;
        avg_mx_ini(ddd)=avg_ini;
        avg_mx_delta_R(ddd)=size(G.Edges,1);
        % clear G
    end
    tl_mx_max_ut(tl)=mean(avg_mx_max_ut);
    tl_mx_SCO(tl)=mean(avg_mx_SCO);
    tl_mx_PO(tl)=mean(avg_mx_PO);
    tl_mx_ini(tl)=mean(avg_mx_ini);
end