function treeRedEx(mu,rvar,T,init_tree,v,v_e,thr,initial_tree_file,final_tree_file,gen_rets_file,bm,bm_quant,p0,a,A,alpha,TW,W0,model_file,run_file)

init_wealth_file='init_wealth.txt';
data_file = 'model_data.dat';
gen_rets_file_red = 'gen_rets_red.txt';
of_file = 'of_file.txt';
init_wealth_file='init_wealth.txt';
temp_rets_file = 'temp_rets_file.txt';
fin_wealth_file = 'fin_wealth_file.txt';
fin_gen_rets_file = 'fin_gen_rets_file.txt';

asset_n = size(mu,1);
x = (W0/asset_n)./p0;


setName1='ASSET';

asset_val = cell(asset_n,1);
for i=1:asset_n
	asset_val{i} = strcat('a',int2str(i));
end

%% TREE RED-EXPANSION ALGORITHM
for t=1:T-1

	% GENERATING THE INITIAL TREE
	V_n = zeros(T,1);
	for h=1:T
		V_n(h) = different_values(init_tree(:,h));
	end
	v_n = V_n(2:end)./V_n(1:end-1); %the average branching factor of the current tree is computed
	
	%generating the tree structure
	tree=init_tree;			
	dv = different_values(init_tree);

	jump = prod(v_n(t+1:end));

	sp =1;
	spt = v_n(t)*jump+1;
	temp = tree;
	
	cmp_vec = [(v_e(t)-v_n(t)) v_n(t+1:end)'];	%differential branching factor vector:
							%it prescribed the number of nodes to add
							%at each node at time t+1 and their descendants
							%structure

		
	%generation of the matrix for the added subtree
	for ntc = 1:V_n(t)
	
		init_vec = temp(sp:sp+jump-1,1:t);

		ip = max(max(tree)); %selection of the initial point for the nodes name

		val_vec = ip+1:ip+sum(cumprod(cmp_vec));	%vector of nodes names
		
		val = zeros(prod(cmp_vec),T-t); 	%initialization of the vector that will contain
							%the new nodes
		spvv = 1;
		
		for h=1:T-t
			repv=prod(v_n(t+h:T-1));	%number of times the generated matrix will be repeated
			n_elem = size(val,1)/repv;	%number of values inserted
			val_tr=val_vec(spvv:spvv+n_elem-1)'; %extraction of the names I need
			rep_vec=zeros(repv*n_elem,1);
			for repind=1:n_elem
				rep_vec((repind-1)*repv+1:repind*repv)=val_tr(repind)*ones(repv,1);
			end
			val(:,h)=rep_vec;
			spvv = spvv+n_elem;
		end
		
		nv = [repmat(init_vec,(v_e(t)-v_n(t)),1) val];	%vector that will be added
		tree = [tree(1:spt-1,:); nv; tree(spt:end,:)];	%insertion of the nodes in the tree matrix

		if(t>1)
			sp=sp+jump*v(t-1);
		else
			sp=sp+jump;
		end
		
		spt = spt+(v_e(t)-v_n(t))*jump+v_n(t)*jump;
	end
	
	%RETURN MATRIX GENERATION
	init_rets = dlmread(gen_rets_file);

	rets = zeros(asset_n,sum(V_n)+sum(cumprod(cmp_vec))-1);

	CS = cumsum(V_n); %computation of the cumulative number of nodes

	%loading the initial values
	rets(:,1:CS(t)) = init_rets(:,1:CS(t));	

	%generating the added nodes' returns
	n = different_values(tree(:,t));
	toGen=(v_e(t)-v_n(t));

	retsToAdd = generateScenarioNoArb(toGen,mu,rvar); %generation of the new scenarios rets

	sp_nr = CS(t);	%initialization of vectors starting points
	sp_ir = CS(t);	%initialization of vectors starting points

	%inserting the new nodes in the level that is being expanded
	for h=1:n
		rets(:,sp_nr+1:sp_nr+v_n(t)) = init_rets(:,sp_ir+1:sp_ir+v_n(t)); %loading nodes
		sp_nr = sp_nr+v_n(t);
		sp_ir = sp_ir+v_n(t);

		rets(:,sp_nr+1:sp_nr+toGen) = retsToAdd; %inserting new nodes
		sp_nr = sp_nr+toGen;
	end

	%loading following nodes, considering the expanded topology of the tree
	for h=t+2:T
		ll = V_n(h);
		rets(:,sp_nr+1:sp_nr+ll) = init_rets(:,sp_ir+1:sp_ir+ll); %direct loading of the rets
		sp_nr = sp_nr+ll;

		toLoad = V_n(t)*(v_e(t)-v_n(t))*prod(v_n(t+1:h-1)); %generation of the needed returns
		rets(:,sp_nr+1:sp_nr+toLoad) = repmat(init_rets(:,sp_ir+1:sp_ir+v_n(h-1)),1,toLoad/v_n(h-1));
		sp_nr = sp_nr+toLoad;
		sp_ir = sp_ir+ll;
	end


	

	%saving returns and tree structure
	dlmwrite(gen_rets_file,rets);
	dlmwrite(initial_tree_file,tree);

	%compute the reference value for the first score
	writePbmData(data_file,gen_rets_file,setName1,asset_val,A,alpha,TW,W0,tree);
	[ref_of fw]=runPbmSolver(run_file,model_file,data_file,init_wealth_file,of_file,fin_wealth_file);


	red_wvs = zeros(n,1);

	%compute the reference value for the second score
	cv = tree(1,t);
	cn=1;
	sp=1;
	i=1;
	flag=0;
	while cn<n
		while(tree(i+1,t)==cv)
			i=i+1;
		end
		tree_red = compact_tree(tree(sp:i,t:t+1));
		generateRedPbmRetsFile(tree,[sp t],[i t+1],gen_rets_file,gen_rets_file_red);
		writePbmData(data_file,gen_rets_file_red,setName1,asset_val,A,alpha,TW,W0,compact_tree(tree(sp:i,t:t+1)));
		[~, vv]=runPbmSolver(run_file,model_file,data_file,init_wealth_file,of_file,fin_wealth_file);
		red_wvs(cn)=var(vv);
		
		cn=cn+1;
		sp=i+1;
		
		cv=tree(sp,t);
		flag=0;
	end
	
	generateRedPbmRetsFile(tree,[sp t],[length(tree(:,t)) t+1],gen_rets_file,gen_rets_file_red);
	writePbmData(data_file,gen_rets_file_red,setName1,asset_val,A,alpha,TW,W0,compact_tree(tree(sp:length(tree(:,t)),t:t+1)));
	[~, vv]=runPbmSolver(run_file,model_file,data_file,init_wealth_file,of_file,fin_wealth_file);
	red_wvs(end)=var(vv);


	%SCORE COMPUTATION
	
	n_f = different_values(tree(:,t+1));
	score = zeros(n_f,1); %the higher, the better
	predecessor = ones(n_f,1);
	position = ones(n_f,1);
	pr_pos = zeros(n_f,2);
	%get the predecessors of the nodes that will be examined
	
	cn=1;
	i=2;
	cv=tree(1,t+1);
	cp = tree(1,t);
	pr_pos(1,1)=1;
	temp_pos = 1;
	predecessor(1)=1;

	pr_ind=1;

	pr=2;

	while cn<n_f
		if cv~=tree(i,t+1)
			cn=cn+1;
			cv=tree(i,t+1);
			position(pr)=i;	

			if cp~=tree(i,t)
			
				pr_pos(pr,1)=i;
				pr_pos(pr-1,2)=i-1;
				temp_pos = i;
				cp=tree(i,t);

				pr_ind = pr_ind+1;
				predecessor(pr)=pr_ind;
				
			else
			
			 	predecessor(pr)=pr_ind;
				pr_pos(pr,1)=temp_pos;

			end
			pr=pr+1;

		end
		i=i+1;
	end
	pr_pos(end,2) = length(tree(:,1));
	%completing the vector of the predecessor initial and final position pr_pos
	temp = pr_pos(end,2);
	for tval=n_f-1:-1:1
		if pr_pos(tval,2)==0
			pr_pos(tval,2)=temp;
		else
			temp = pr_pos(tval,2);
		end
	end
	
	%start the scoring
	for ltc=1:n_f
		[tree_red diff]= removeNodeFromTree(tree,[position(ltc) t+1],gen_rets_file,temp_rets_file,v_n);
		
		%first criterion
		writePbmData(data_file,temp_rets_file,setName1,asset_val,A,alpha,TW,W0,tree_red,fin_gen_rets_file);
		[tof tfw]=runPbmSolver(run_file,model_file,data_file,init_wealth_file,of_file,fin_wealth_file);

		score(ltc) = score(ltc)+(ref_of-tof)/ref_of;

		%second criterion
		generateRedPbmRetsFile(tree_red,[pr_pos(ltc,1) t],[pr_pos(ltc,2)-diff t+1],temp_rets_file,gen_rets_file_red);
		writePbmData(data_file,temp_rets_file,setName1,asset_val,A,alpha,TW,W0,compact_tree(tree_red(pr_pos(ltc,1):pr_pos(ltc,2)-diff,t:t+1)));
		[~, tfw_red]=runPbmSolver(run_file,model_file,data_file,init_wealth_file,of_file,fin_wealth_file);
		
		score(ltc) = score(ltc) + (var(tfw_red)-red_wvs(predecessor(ltc)))/red_wvs(predecessor(ltc)); 


		%third criterion
		bm_dist = compute_bm_final_dist(temp_rets_file,tree_red,x,p0);
		[~, p_val]=kstest2(bm,bm_dist);
		score(ltc) = score(ltc)+(1-p_val);
		
	end

	%REMOVE NODES WITH THE LOWEST SCORE
	%select the nodes to be removed

	[~, ind] = sort(score,'ascend');

	
	seed_vec = ind>(thr)*V_n(t);

	%remove the nodes
	for ltc=1:n_f
		if(seed_vec(ltc)==0)
			[tree diff]= removeNodeFromTree(tree,[position(ltc) t+1],gen_rets_file,temp_rets_file,v_n);
			if ltc<n_f
				position(ltc+1:end) = position(ltc+1:end)-diff;
			end
			updateScenariosRets(gen_rets_file,temp_rets_file);
		end
	end
	init_tree = tree;
end

dlmwrite(final_tree_file,tree);

