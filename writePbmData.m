function writePbmData(filename,gen_rets_file,setName1,asset_val,A,alpha,TW,W0,tree,final_rets_file)
%this function creates filename file for the ampl solver. It loads returns from gen_rets_file
%and inserts it with the parameters A,alpha,TW,W0 in filename
%if final_rets_file is passed, the leaves nodes rets are written there
	noSet=[];
	k=-1;
	while(k==-1)
		k = fopen(filename,'w');
	end
	fclose(k);

	T = length(tree(1,:));
	lv = length(tree(:,1));

	nodes_names=different_values_vector(tree)-ones(1,different_values(tree));
		
	% generate asset set
	addSetToFile(filename,setName1,asset_val);
	 
	%generate scenarios set
	tot_nodes = cell(different_values(tree),1);

	setName2 = 'ROOT_NODE';
	node_val = cell(1);
	node_val{1}=['n' int2str(nodes_names(1))];
	tot_nodes{1}=node_val{1};
	addSetToFile(filename,setName2,node_val);

	setName3 = 'MID_NODE';
	node_val = cell(different_values(tree(:,1:(end-1)))-1,1);
	for i=1:(different_values(tree(:,1:(end-1)))-1)
		node_val{i}=strcat('n',int2str(nodes_names(1+i)));
		tot_nodes{i+1}=node_val{i};
	end
	addSetToFile(filename,setName3,node_val);

	setName4 = 'LEAF_NODE';
	node_val = cell(different_values(tree(:,end)),1);
	for i=1:(different_values(tree(:,end)))
		node_val{i}=strcat('n',int2str(nodes_names(i+(different_values(tree(:,1:(end-1)))))));
		tot_nodes{i+different_values(tree(:,1:(end-1)))}=node_val{i};
	end
	addSetToFile(filename,setName4,node_val);

	pred=cell(different_values(tree)-1,1);
	k=1;
	for t=2:T
	   cv=tree(1,t);
	   pred{k} = ['n' int2str(tree(1,t-1)-1)];
	   k=k+1;
	   for vi=2:lv
		if(tree(vi,t)~=cv)
			pred{k} = ['n' int2str(tree(vi,t-1)-1)];
			k=k+1;
			cv = tree(vi,t);
		end
	   end
	end
	addParamToFile(filename,'PRED',{tot_nodes{2:end}},noSet,pred);

	%generate probabilities
	addTreeGenProb(tree,filename,tot_nodes)
	
	%generate future expected rets
	ret = dlmread(gen_rets_file);
	addParamToFile(filename,'ret',asset_val,tot_nodes,ret);

	%generate time value associated with each node
	time = generateNodeTime(tree);
	addParamToFile(filename,'time',tot_nodes,noSet,time);

	%add constant T (time steps);
	T=length(tree(1,:));
	addParamToFile(filename,'T',noSet,noSet,T);

	%generate alpha
	time_vec=cell(t,1);
	for i=1:T
		time_vec{i}=int2str(i);
	end
	addParamToFile(filename,'alpha',time_vec,noSet,alpha);

	%generate TW
	addParamToFile(filename,'TW',time_vec,noSet,TW);

	%generate A
	addParamToFile(filename,'A',noSet,noSet,A);

	%generate risk aversion
	addParamToFile(filename,'W0',noSet,noSet,W0);

	if nargin==10
		l = length(node_val);
		fin_rets = ret(:,end-l+1:end);
		dlmwrite(final_rets_file,fin_rets);		
	end


end
