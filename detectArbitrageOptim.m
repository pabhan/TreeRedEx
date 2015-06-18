function [ok]=detectArbitrageOptim(rets)
%this function checks the presence of arbitrages of first and second type
%solving the linear system described in Ingersoll(1987) and Klaassen(2002)

M=(exp(rets)-1); %the CC returns are transformed in the growth factor matrix

round_f = 10^5;
M = floor(M*round_f)/round_f;
%M(abs(M)<10^(-5)) = 0;

%preparing the file for AMPL
file='arbit_optim.dat';
res_file = 'res_optim_file.txt';
res_file_of = 'res_optim_of_file.txt';
run_file = 'run_optim.run';

%reset data file
fp=fopen(file,'w');
fclose(fp);

%add data to data file
setName1='ASSET';
na = length(rets(:,1));
asset_val = cell(na);

for i=1:na
	asset_val{i} = ['a' int2str(i)];
end
addSetToFile(file,setName1,asset_val);

setName2 = 'NODE';
nn = length(rets(1,:));
node_val = cell(nn);

for i=1:nn
	node_val{i} = ['n' int2str(i)];
end
addSetToFile(file,setName2,node_val);

addParamToFile(file,'M',asset_val,node_val,M)

%generate the .run file
f=fopen(run_file,'w');
fprintf(f,['model arbitrage.mod;\ndata ' file ';\nsolve;\n']);

%in order to check if the problem has been solved, we look at the slack variable corresponding
%to the constraints of the problem.
fprintf(f,['printf {a in ASSET}: \"%%f\\n\", ExpRet_Cons_1[a].slack > ' res_file ';\n']);
fprintf(f,['printf {a in ASSET}: \"%%f\\n\", ExpRet_Cons_2[a].slack >> ' res_file ';\n']);
fprintf(f,['printf {n in NODE}: \"%%f\\n\", v_cons[n].slack > ' res_file_of ';\n']);
fprintf(f,['printf {n in NODE}: \"%%f\\n\", w_cons[n].slack >> ' res_file_of ';\n']);
fclose(f);

%run the optimizer
dos(['ampl ' run_file]);

%load the solution
cons_1 = dlmread (res_file);
cons_2 = dlmread (res_file_of);


if all(cons_1==0) && all(cons_2>=0)	%the first constraints are equality constraints,
					%therefore they are satisfied iff the slack is null.
					%the next ones are <=, therefore they are 
					% satisfied iff the slack are non negative
    ok=1; %no arbitrage is found in the current (sub-)tree
else
    ok=0; %arbitrages are present
end
end
