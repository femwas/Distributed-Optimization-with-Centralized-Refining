    
RU_SCO=[];
    for m=1:TotalSTA
        nz_Disused_RU=nonzeros(Disused_RU(:,m));
        nz_Removed_RU=nonzeros(Removed_RU(:,m));
        RU_SCO_temp=setdiff(nz_Disused_RU,nz_Removed_RU);
        RU_SCO=[RU_SCO,RU_SCO_temp'];
    end