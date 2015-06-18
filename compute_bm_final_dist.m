function bm_dist = compute_bm_final_dist(gen_rets_file,tree,x,p_0)
% this function computes the final distribution of wealth of the fixed mix benchmark
% using the rets saved in gen_rets_file. the initial assets prices p_0.
% The tree structure is needed to properly navigate the return matrix


rets = dlmread(gen_rets_file);
[ln, T]= size(tree);
asset_n = length(p_0);

prices = zeros(ln,T,asset_n);

for i=1:ln
	prices(i,1,:)=p_0;
end

rind = 1;
for j=2:T
	rind=rind+1;
	prices(1,j,:) = reshape(prices(1,j-1,:),asset_n,1).*exp(rets(:,rind));
	cv = tree(1,j);
	for i=2:ln
		if(tree(i,j) ~= cv)
			rind = rind+1;
			cv = tree(i,j);
		end
		prices(i,j,:) = reshape(prices(i,j-1,:),asset_n,1).*exp(rets(:,rind));
	end
end

bm_dist = zeros(ln,1);

% pause()
for k=1:ln
	bm_dist(k)=x'*p_0;
	for h=2:T
		%bm_dist(k)/asset_n./reshape(prices(k,h-1,:),asset_n,1)
		bm_dist(k) = (bm_dist(k)/asset_n./reshape(prices(k,h-1,:),asset_n,1))'*reshape(prices(k,h,:),asset_n,1);
	end
end



