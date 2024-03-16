% Total_packet=74;
% TotalSTA=20;
% Total_RU=Total_packet;
%Passloss_map=zeros(Total_RU,TotalSTA);%1-12levels
%s_channel=rng;
%load('s_channel.mat')
%rng(s_channel);
Distance_based_passloss=randi([1,10],1,TotalSTA);
AWGN_channel_rnd=randn(Total_RU,TotalSTA);
AWGN_channel=zeros(Total_RU,TotalSTA);
for i=1:3
    AWGN_channel(AWGN_channel_rnd>=i)=i;%整数化高斯
    AWGN_channel(AWGN_channel_rnd<=-i)=-i;
end
Passloss_map=Distance_based_passloss+AWGN_channel;%生成了随机的passloss index来对应PER中的12个衰减水平。
Passloss_map(Passloss_map>12)=12;
Passloss_map(Passloss_map<1)=1;

PER_map=zeros(Total_RU,TotalSTA);
DR_map=zeros(Total_RU,TotalSTA);
RU_index=zeros(1,Total_RU);%只生成了20MHz 9RU的数据，要拓展成160+160MHz, 74RU.
for j=1:Total_RU
    RU_index(j)=mod(j,RUlen);
end
 RU_index(RU_index==0)=9;%找到74RU在9RU中分别对应的RU
 for k=1:TotalSTA
     for j=1:Total_RU
        PER_map(j,k)=PER_out_AMLA_2(Passloss_map(j,k),RU_index(j));%PER_out_AMLA_2 列为12级别的passloss，行是9个RU.
        DR_map(j,k)=DR_out_AMLA_2(Passloss_map(j,k),RU_index(j));
     end
 end
%SavetoExcleaftermapping;