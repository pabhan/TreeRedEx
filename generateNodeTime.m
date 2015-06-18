function time=generateNodeTime(tree)
%this function generates a vector v s.t. v(i) is the time instant (from 1 to T) of node ni
	n=different_values(tree);
	T = length(tree(1,:));
	time = zeros(n,1);
	n_leaves=length(tree(:,1));

	cv = tree(1,1);
	time(1)=1;
	n_ind = 2;

	
	for t=1:T
		for ind=1:n_leaves
			if(tree(ind,t)~=cv)
				time(n_ind)=t;
				n_ind=n_ind+1;
				cv=tree(ind,t);
			end
		end			
	end
	
end
