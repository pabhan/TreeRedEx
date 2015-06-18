function t=compact_tree(it)
% this function compacts trees, i.e. it removes
% from a tree its redundant leaves

	vl=length(it(:,1));
	hl=length(it(1,:));

	
	t = it(1,:);
	cv = it(1,hl);

	for h=2:vl
		if it(h,hl)~=cv
			t = [t; it(h,:)];
			cv = it(h,hl); 
		end
	end

		
end
