function [opt_allocation_x_re,ga_process_time,x,local_packet_num]=ga_solver_local(TotalSTA,STAidx, ...
    Total_packet,Th_request_list_STA,PER_request_list,alpha,DR_convergence_rate, ...
    PER_convergence_rate,DR_per_packet,PER_per_packet,cutpoint,STA_packet_size)

local_packet_num=STA_packet_size(STAidx);
allocation_len=Total_packet*local_packet_num;
total_len=allocation_len;

intcon =1:allocation_len;
rng default % For reproducibility

objconstr = @(x) myobjfun_local(x,TotalSTA,STAidx,Total_packet,Th_request_list_STA,PER_request_list,alpha,DR_convergence_rate, ...
    PER_convergence_rate,DR_per_packet,PER_per_packet,cutpoint,local_packet_num); %x 1-81 x, 82-90 MCS, 91-171 p.
lb = zeros(1,total_len);
ub =  zeros(1,total_len);

A= zeros(Total_packet,total_len);%constrain num, variable num
b= 1*ones(Total_packet,1);
for i=1:Total_packet
    for j=1:local_packet_num
        A(i,i+(j-1)*Total_packet)=1;
    end
end



Aeq= zeros(local_packet_num,total_len);%constrain num, variable num
beq=zeros(local_packet_num,1);

ub(1:allocation_len)=1;%x

for j=1:local_packet_num
    Aeq(j,(j-1)*Total_packet+1:j*Total_packet)=1;
    beq(j)=1;%每个STAx的和为一, 1-81
end%每一行，每个RU只能被分配一次


%DicentralizedSTA=0;
tic
 %optimoptions('ga','PlotFcn', @gaplotbestf,'PopulationSize', 50, 'Generations', 1000, 'MutationFcn', {@mutationuniform, 0.1}, 'CrossoverFcn', @crossoverheuristic);
options =optimoptions('ga','ConstraintTolerance',1e-3,'PopulationSize',50,'MigrationFraction',0.5,'MaxGenerations',200);%'PlotFcn', @gaplotbestf,
%[x,fval,exitflag,output,population,scores] 
[x,~]= ga(objconstr,total_len,A,b,Aeq,beq,lb,ub,[],intcon,options);

ga_process_time=toc;
allocation_x=x;%(1:allocation_len);

opt_allocation_x_re=reshape(allocation_x,[Total_packet,local_packet_num]);

end