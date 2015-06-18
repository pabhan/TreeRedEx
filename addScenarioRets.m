function rets=addScenarioRets(tree,st_point,sc,gen_rets_file,gen_rets_file_test)
%this function inserts a new scenario path sc in a tree, connecting it to the node
%whose matrix coordinates are described in st_point.
%if gen_rets_file_test is inserted, the return matrix is then recorded there

	%loads the returns of the tree
	init_rets = loadScenarioRets(gen_rets_file); 

	%parameters setting
	asset_n=length(init_rets(:,1));
	x=st_point(1);
	y=st_point(2);
	leaves_n = length(tree(:,1));
		
	n=different_values(tree);
	l=different_values(tree(:,2));
	
	rets=zeros(asset_n,n);

	rets(:,1:(l+1))=init_rets(:,1:(l+1));
	vt=2;
	ht=3;
	p=l+2;
	ip = l+2;
	cv = tree(leaves_n,2);
	tot_sc = length(sc(1,:));
	sc_ins=0;

	%in this loop the pointers flow through the
	%tree and the returns at the same time
	%in order to insert the new scenario rets
	%in the appropriate position
	while p<=n && sc_ins<=tot_sc
		if(tree(vt,ht)~=cv)
			if(vt==x && ht>=y)
				rets(:,p)=sc(:,ht-y+1);
				sc_ins=sc_ins+1;
			else
				rets(:,p)=init_rets(:,ip);
				ip=ip+1;
			end
			cv=tree(vt,ht);
			p=p+1;
		end
		if(vt+1>leaves_n)
			vt=1;
			ht=ht+1;
		else
			vt=vt+1;
		end
	end
	rets(:,p:end)=init_rets(:,ip:end);
	
	dlmwrite(gen_rets_file_test,rets);
end	
	
	

