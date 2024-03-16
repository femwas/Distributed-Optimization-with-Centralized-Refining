MCSlen=11;
Passlosslen=12;
RUlen=9;

Data_PER=zeros(MCSlen,Passlosslen,RUlen);
Data_DR=zeros(MCSlen,Passlosslen,RUlen);
for i=1:11
    Data_PER(i,:,:)=readmatrix('PERdata1.xlsx','Sheet',i,'Range','A1:I12');
    Data_DR(i,:,:)=readmatrix('Throughputdata1.xlsx','Sheet',i,'Range','A1:I12');
end
