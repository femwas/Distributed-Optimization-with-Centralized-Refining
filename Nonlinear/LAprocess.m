%passloss 87:3:102
%RU 9 allocation scheme = 0

% s = rng;
% r = rand(1,5)
% rng(s);
% r1 = rand(1,5); ±£´æËæ»ú×´Ì¬
%Readdata;

% load('PER_OFDMA.mat')
% load('Th_OFDMA.mat')

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
%SavetoExcleafterLA;
