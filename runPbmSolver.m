function [of fin_wealth]=runPbmSolver(run_file,model_file,data_file,wealth_file,of_file,fin_wealth_file)
% this function generates a run file (run_file) in which the operation the ampl solver has to perform are written
% Then, ampl is run and the result written in corresponding files 

	f=fopen(run_file,'w');
	
	fprintf(f,['model ' model_file ';\ndata ' data_file ';\nsolve;\n']);
	fprintf(f,['printf {a in ASSET, l in ROOT_NODE}: \"%%f,\", w[a,l] > ' wealth_file ';\n']);
	fprintf(f,['printf : \"%%f\", QU_LPM > ' of_file ';\n']);

	if nargin==6
		fprintf(f,['printf {l in LEAF_NODE}: \"%%f,\", sum{a in ASSET}w[a,l]  > ' fin_wealth_file ';\n']);
	%	fprintf(f,['printf {l in ROOT_NODE union MID_NODE union LEAF_NODE}: \"%%f,\", sum{a in ASSET}w[a,l]  > ' fin_wealth_file ';\n']);
        %	fprintf(f,['printf {l in MID_NODE}: \"%%f,\", sum{a in ASSET}w[a,l]  > ' 'PROVA.txt' ';\n']);
	end
	fclose(f);
		 
	dos(['ampl ' run_file]);
	
	fp=fopen(of_file,'r');
	of=fscanf(fp,'%f');
	fclose(fp);

	if nargout==2
		fin_wealth = load_results(fin_wealth_file,',');
	end
	
end
