function [opt_allocation_x_re,avg_SCO_NL,ga_process_time]=ga_solver_simple(TotalSTA, ...
    Total_packet,Th_request_list_STA,PER_request_list,alpha,DR_convergence_rate, ...
    PER_convergence_rate,DR_per_packet,PER_per_packet,cutpoint,RU_SCO, ...
    DR_per_packet_PO,PER_per_packet_PO,MaxGenerations_simple)
len_RU_SCO=length(RU_SCO);
allocation_len=len_RU_SCO^2;
total_len=allocation_len;

DR_per_packet_SCO=DR_per_packet(RU_SCO,RU_SCO);%small mx for SCO
PER_per_packet_SCO=PER_per_packet(RU_SCO,RU_SCO);

DR_per_packet_SCO_vc=reshape(DR_per_packet_SCO,1,allocation_len);
PER_per_packet_SCO_vc=reshape(PER_per_packet_SCO,1,allocation_len);

intcon =1:allocation_len;
rng default % For reproducibility

objconstr = @(x) myobjfun_simple(x,TotalSTA,Total_packet,Th_request_list_STA,PER_request_list, ...
    alpha,DR_convergence_rate,PER_convergence_rate,DR_per_packet_SCO_vc,PER_per_packet_SCO_vc, ...
    cutpoint,RU_SCO,DR_per_packet_PO,PER_per_packet_PO);% %x 1-81 x, 82-90 MCS, 91-171 p.
lb = zeros(1,total_len);
ub =  zeros(1,total_len);
A= zeros(1,total_len);
b= zeros(1,1);
Aeq= zeros(2*len_RU_SCO,total_len);
beq=zeros(2*len_RU_SCO,1);

ub(1:allocation_len)=1;%x

for i=1:len_RU_SCO
    Aeq(i,(i-1)*len_RU_SCO+1:i*len_RU_SCO)=1;
    beq(i)=1;%每个STAx的和为一, 1-81
end%每一行，每个RU只能被分配一次



for i=1:len_RU_SCO%lie
    for j=1:len_RU_SCO%heng
        Aeq(i+len_RU_SCO,i+(j-1)*len_RU_SCO)=1;
        beq(i+len_RU_SCO)=1;%每个STAx的和为一, 1-81
    end
end%每一列，每个packet只能被分配一次
%DicentralizedSTA=0;
tic
 %optimoptions('ga','PlotFcn', @gaplotbestf,'PopulationSize', 50, 'Generations', 1000, 'MutationFcn', {@mutationuniform, 0.1}, 'CrossoverFcn', @crossoverheuristic);
options =optimoptions('ga','ConstraintTolerance',1e-3,'PopulationSize',75,'MigrationFraction',0.5,'MaxGenerations',MaxGenerations_simple);%,'PlotFcn', @gaplotbestf
%[x,fval,exitflag,output,population,scores] 
[x,fval]= ga(objconstr,total_len,A,b,Aeq,beq,lb,ub,[],intcon,options);
avg_SCO_NL=-fval/TotalSTA;
ga_process_time=toc;
allocation_x=x(1:allocation_len);

opt_allocation_x_re=reshape(allocation_x,[len_RU_SCO,len_RU_SCO]);


end