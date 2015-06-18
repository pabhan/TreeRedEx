%% SCRIPT THAT SOLVES A SLIDING HORIZON QU WITH LPM
%% USING A TREE REDUCTION ALGORITHM

%% initialization
clear all;
clc;

%basic parameters
WorkingDirectory = fileparts(mfilename('fullpath'));
cd(WorkingDirectory);

noSet = [];
priceFreq = 'month';
					
data_file = 'model_data.dat';
model_file = 'max_qu_lpm.mod';
run_file = 'model.run';
%price_file = 'prices.dat';
price_file = 'prices_1.dat';

gen_rets_file = 'gen_rets.txt';
gen_rets_file_red = 'gen_rets_red.txt';
of_file = 'of_file.txt';
init_wealth_file='init_wealth.txt';
temp_rets_file = 'temp_rets_file.txt';
temp_rets_file_red = 'temp_rets_file_red.txt';
fin_wealth_file = 'fin_wealth_file.txt';
fin_wealth_file_red= 'fin_wealth_file_red.txt';
fin_gen_rets_file = 'fin_gen_rets_file.txt';

result_wealth_file = 'result_wealth_file.txt';
final_tree_file = 'final_tree_file.txt';
initial_tree_file = 'initial_tree_file.txt';


n_rows=12;
%generation parameters
[p,asset_n,mu,rvar,~] = compute_stats(price_file,1,n_rows,priceFreq);

setName1='ASSET';

asset_val = cell(asset_n,1);
for i=1:asset_n
	asset_val{i} = strcat('a',int2str(i));
end

%basic tree structure
v=2*(asset_n)*ones(3,1);
V=cumprod([1; v]');

thr = 3; %number of scenarios to remove at each iteration

%extended tree structure
amp_fact = 1.5;
v_e=amp_fact*v;
V_e=cumprod([1; v_e]');

%initial leaves number

%time parameters
t = 1;		  %length of the analyzed period
T = length(V);  %number of periods
timestep = t/T;		 %lenght of timesteps
if strcmp(priceFreq,'month')
	jump = floor(12*timestep);
else
	if strcmp(priceFreq,'week')
		jump = floor(52*timestep);
	else
		jump = floor(366*timestep);
	end
end
node_n = zeros(T,1);

repForScen = 4;
theta = @(t)1/t^0.5;

scen_n=sum(V);

%generate pbm parameters
W0 = 100000;
rf_ret = (1+0.04)^(T*t/n_rows)-1;
A=2;
alpha = ones(T,1);
TW = W0*(1+rf_ret).^((1:T)*n_rows/12);
%TW = W0*ones(T,1);

%% TREE GENERATION
tree=ones(V(end),T); %tree matrix allocation

for i=2:T		
	for j=1:V(i) %nodes are assigned according to their distance from the leaves - the further, the more times they are repeated
		tree(((j-1)*V(T)/V(i)+1):j*V(T)/V(i),i)=ones(1:length(((j-1)*V(T)/V(i)+1):j*V(T)/V(i)),1)*(j+sum(V(1:i-1)));
	end
end


% solution of the pbm using the basis tree
x = (W0/asset_n)./p(:,1);

fp=fopen(gen_rets_file,'w');
fclose(fp);

generateScenarioNoArb(v,mu,rvar,gen_rets_file,tree);

display('done')
%pause()
%simulation of the benchmark portfolio performance (needed in criterion 3)
n_it = 10^5;
sim_prices = pricesGeneration(p(:,1),mu,rvar,n_it,v);

bm = x'*sim_prices;
a = 0.05;
bm_quant = quantile(bm,a);
bm_diff = bm_quant; %mock value for the first computation of the quantiles distance (3rd crit)

init_tree = tree;
base_tree = tree;


treeRedEx(mu,rvar,T,init_tree,v,v_e,thr,initial_tree_file,final_tree_file,gen_rets_file,bm,bm_quant,p(:,1),a,A,alpha,TW,W0,model_file,run_file)

%% SLIDING-HORIZON SOLUTION OF THE QU_LPM OPTIMIZATION PBM
tree = dlmread(final_tree_file);
temp=tree;
W=W0;
rets=dlmread(gen_rets_file);

check_points = [1 n_rows/(T-1):n_rows/(T-1):n_rows];

for t=T:-1:2
	tree=compact_tree(temp(:,1:t));
	writePbmData(data_file,temp_rets_file,setName1,asset_val,A,alpha(1:t),TW(1:t),W,tree);
	runPbmSolver(run_file,model_file,data_file,init_wealth_file,of_file);
	init_wealth = load_results(init_wealth_file,',');
	W=sum(init_wealth./p(:,check_points(T-t+1)).*p(:,check_points(T-t+2)));
end

%benchmark solution
W_b=W0;
for t=1:T-1
	W_b=sum(W_b/asset_n./p(:,check_points(t)).*p(:,check_points(t+1)));
end

dlmwrite(result_wealth_file,[W_b; W]);
