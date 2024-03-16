%Copy right reserved 

Total_packet=74;
TotalSTA=20;
Total_RU=Total_packet;

Readdata;
LAprocess;
Generate_channel;

Random_packet_size_generation;
Th_request_list_RU=11.5*rand(1,TotalSTA);
Th_request_list_STA=Th_request_list_RU.*STA_packet_size;
PER_request_list=10.^(-1*randi([1,4],1,TotalSTA));
alpha=rand(1,TotalSTA);
beta=1-alpha;
DR_convergence_rate=3;%randi([1,4],1,TotalSTA);
PER_convergence_rate=3;%randi([1,4],1,TotalSTA);


DR_PER_per_packet;%DR PER map per packet
initial_local_assignment;

%% Initial division  
local_DCS_ga;
Target_Disuse;
graph_generation;
find_cycles;
Pareto_optimal_mx_NL
generate_RU_SCO;
Random_allocation_utility;
