allocation_len=Total_packet^2;
total_len=allocation_len;

intcon =1:allocation_len;
rng default % For reproducibility

objconstr = @(x) myobjfun(x,TotalSTA,Total_packet,Th_request_list_STA,PER_request_list,alpha,DR_convergence_rate, ...
    PER_convergence_rate,DR_per_packet,PER_per_packet,cutpoint) ; %x 1-81 x, 82-90 MCS, 91-171 p.
lb = zeros(1,total_len);
ub =  zeros(1,total_len);
A= zeros(1,total_len);
b= zeros(1,1);
Aeq= zeros(2*Total_packet,total_len);
beq=zeros(2*Total_packet,1);

ub(1:allocation_len)=1;%x

for i=1:Total_packet
    Aeq(i,(i-1)*Total_packet+1:i*Total_packet)=1;
    beq(i)=1;%每个STAx的和为一, 1-81
end%每一行，每个RU只能被分配一次



for i=1:Total_packet%lie
    for j=1:Total_packet%heng
        Aeq(i+Total_packet,i+(j-1)*Total_packet)=1;
        beq(i+Total_packet)=1;%每个STAx的和为一, 1-81
    end
end%每一列，每个packet只能被分配一次

tic
options = optimoptions('ga','PlotFcn', @gaplotbestf,'PopulationSize', 100, 'Generations', 200, 'MutationFcn', {@mutationuniform, 0.1}, 'CrossoverFcn', @crossoverheuristic);
x= ga(objconstr,total_len,A,b,Aeq,beq,lb,ub,[],intcon,options);
%optimoptions('ga','ConstraintTolerance',1e-3,'PlotFcn', @gaplotbestf,'PopulationSize',50,'MigrationFraction',0.5,'MaxGenerations',500);
%[x,fval,exitflag,output,population,scores] = ga(objconstr,total_len,A,b,Aeq,beq,lb,ub,[],intcon,options);
%x = surrogateopt(objconstr,lb,ub,intcon,A,b,Aeq,beq)

toc
allocation_x=x(1:allocation_len);

allocation_x_re=reshape(allocation_x,[Total_packet,Total_packet]);

%% STA_num
function f=myobjfun(x,TotalSTA,Total_packet,Th_request_list_STA,PER_request_list,alpha,DR_convergence_rate,PER_convergence_rate,DR_per_packet,PER_per_packet,cutpoint)%DicentralizedSTA
STA_num=TotalSTA;
DicentralizedSTA=0;
central_STA_num=STA_num-DicentralizedSTA;
allocation_len=Total_packet^2;


beta=1-alpha;

DR_per_packet_vc=reshape(DR_per_packet,1,allocation_len);
PER_per_packet_vc=reshape(PER_per_packet,1,allocation_len);
DR_pacekt=DR_per_packet_vc.*x(1,1:allocation_len);
PER_pacekt=PER_per_packet_vc.*x(1,1:allocation_len);

DR=zeros(1,TotalSTA);
PER=zeros(1,TotalSTA);

for m=1:TotalSTA
    if m==1
            DR(m)=sum(DR_pacekt(1:cutpoint(m)*Total_packet));
            PER(m)=sum(PER_pacekt(1:cutpoint(m)*Total_packet))/cutpoint(m);
    elseif m==TotalSTA
            DR(m)=sum(DR_pacekt(cutpoint(m-1)*Total_packet+1:Total_packet*Total_packet));
            PER(m)=sum(PER_pacekt(cutpoint(m-1)*Total_packet+1:Total_packet*Total_packet))/(Total_packet-cutpoint(m-1));
    else
            DR(m)=sum(DR_pacekt(cutpoint(m-1)*Total_packet+1:cutpoint(m)*Total_packet));
            PER(m)=sum(PER_pacekt(cutpoint(m-1)*Total_packet+1:cutpoint(m)*Total_packet))/(cutpoint(m)-cutpoint(m-1));
    end
end


index_DR=1-exp(-DR_convergence_rate.*DR./Th_request_list_STA); %DR_map(j,:)>=Th_request_list;
index_PER=exp(-PER_convergence_rate.*PER./PER_request_list);%PER_map(j,:)<=PER_request_list;
Uindex=alpha.*index_DR+beta.*index_PER;
f=-sum(Uindex)-DicentralizedSTA;
end
