function [opt_allocation_x_re,avg_con_NL,ga_process_time]=ga_solver(TotalSTA,Total_packet, ...
    Th_request_list_STA,PER_request_list,alpha,DR_convergence_rate,PER_convergence_rate, ...
    DR_per_packet,PER_per_packet,cutpoint,MaxGenerations_global)
allocation_len=Total_packet^2;
total_len=allocation_len;

intcon =1:allocation_len;
rng default % For reproducibility

objconstr = @(x) myobjfun(x,TotalSTA,Total_packet,Th_request_list_STA,PER_request_list, ...
    alpha,DR_convergence_rate,PER_convergence_rate,DR_per_packet,PER_per_packet,cutpoint) ; %x 1-81 x, 82-90 MCS, 91-171 p.
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
%DicentralizedSTA=0;
tic
 %optimoptions('ga','PlotFcn', @gaplotbestf,'PopulationSize', 50, 'Generations', 1000, 'MutationFcn', {@mutationuniform, 0.1}, 'CrossoverFcn', @crossoverheuristic);
options =optimoptions('ga','ConstraintTolerance',1e-3, ...
    'PopulationSize',75,'MigrationFraction',0.5,'MaxGenerations',MaxGenerations_global);%,400,'PlotFcn', @gaplotbestf
%[x,fval,exitflag,output,population,scores] 
[x,fval]= ga(objconstr,total_len,A,b,Aeq,beq,lb,ub,[],intcon,options);
avg_con_NL=-fval/TotalSTA;
ga_process_time=toc;
allocation_x=x(1:allocation_len);

opt_allocation_x_re=reshape(allocation_x,[Total_packet,Total_packet]);


end