function ok=examineTreeForArbitrages(tree,rets)
% this function examines the returns rets associated to tree
% looking for arbitrages, using the algorithm from Klassen.
T= length(tree(1,:));

ok=1;
t=2;

while(ok==1 && t<=T)
	cv = tree(1,t-1); %set the reference value
	ip = different_values(tree(:,1:t-1)); %count the previous nodes
	sp = ip+1;  %set the starting point - i.e. the next node to consider
	n=different_values(tree(:,t-1));	%count the number of roots to examine
	m=different_values(tree(:,t));	  %count the number of nodes in the current time

	i=1;	%initialize the node index
	j=2;	%initialize the tree row index
	ij=1;   %initialize the check-point value for the tree row index
	
	while i<n && ok==1
		if tree(j,t-1)~=cv
			l=different_values(tree(ij:j-1,t)); %count the descendants of node i
			ok=ok*detectArbitrageOptim(rets(:,sp:sp+l-1)); %check the arbitrages in the subtree
			cv = tree(j,t-1);   %update the reference value
			sp=sp+l;			%update the starting point
			i=i+1;			  %update the examined node
			ij=j;			   %update the check-point index
		end
		j=j+1;
	end
	ok=ok*detectArbitrageOptim(rets(:,sp:ip+m));

	t=t+1;
end
