function [tree_red diff]= removeNodeFromTree(tree,pos,gen_rets_file,temp_rets_file,v)
% this function generates tree_red by removing from tree a node (and thus its descendants) whose
% coordinates in the matrix are described by pos. Then, the return matrix rets_red is assembled
% by taking the rets in gen_rets_file corresponding the remaining nodes and saving them into
%temp_rets_file. This operation is eased by the knowledge of the branching factor v


x=pos(1);	%the last row related to the node that we want to remove
y=pos(2);	%this node column

vl = length(tree(:,1));
hl = length(tree(1,:));

j=x+1;
flag=0;
rv = tree(x,y);

V=cumprod([1; v(y:end)]);


%compute the indexes that need to be removed - the first row in which the node shows up
while j>0 && j<=vl && flag==0
	if(tree(j,y)==rv)
		j=j+1;
	else
		j=j-1;
		flag=1;
	end	
end

if (j>vl)
    j=vl;
end

diff = j-x+1;
tree_red = tree([1:x-1 j+1:vl],:);

rets = dlmread(gen_rets_file);
asset_n=length(rets(:,1));

in_n = different_values(tree(:,1:y-1));
tot_n = different_values(tree);

re_n = different_values(tree(x:j,y:end));

rets_red = zeros(asset_n,tot_n-re_n);
rets_red(:,1:in_n) = rets(:,1:in_n);

ip_r = in_n;
ip_o = in_n;

for t=y:hl
	nv = different_values(tree(1:x-1,t));
	rets_red(:,ip_r+1:ip_r+nv) = rets(:,ip_o+1:ip_o+nv);
	ip_r=ip_r+nv;
	ip_o = ip_o+nv+V(t-y+1);
	
	nv = different_values(tree(j+1:end,t));
	rets_red(:,ip_r+1:ip_r+nv) = rets(:,ip_o+1:ip_o+nv);
	ip_r=ip_r+nv;
	ip_o = ip_o+nv;

end

	dlmwrite(temp_rets_file,rets_red);


end
