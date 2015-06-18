function addTreeGenProb(tree,filename,tot_nodes,cons)
%this function generates the probability of the nodes, either according
%to Consigli (2013) or attributing the same probability to nodes in the time layer

	if nargin==3
		cons = 1;
	end
	
	lt=length(tot_nodes);
	prob=ones(lt,1);
	den = length(tree(:,1));
	T = length(tree(1,:));

	i=2;
	if cons==1
		for t=2:T
			cv = tree(1,t);
			num = 1;
			for vi=2:den
				if tree(vi,t) == cv
					num=num+1;
				else
					prob(i)=num/den;
					i=i+1;
					cv = tree(vi,t);
					num = 1;
				end
			end
			prob(i)=num/den;
			i=i+1;
		end
	else
		for t=2:T
			n=different_values(tree(:,t));
			prob(i:i+n-1) = 1/n;
		end

	end
	addParamToFile(filename,'prob',tot_nodes,[],prob);
end
