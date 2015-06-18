function [p,asset_n,mu,rvar,pvar] = compute_stats(price_file,st_row,end_row,priceFreq)
% this function reads and returns prices from st_row to end_row for each asset,
%computes the (continuosly compounded) returns and returns their first two moments

	A= load_matrix(price_file,',');
	asset_n = length(A(1,:));
	
	rvar=0;
    
	if strcmp(priceFreq,'month')
		freq=12;
	else
		if strcmp(priceFreq,'week')
			freq=52;
		else
			freq=365;
		end
	end
	
	p = A(st_row:end_row,:);

	if(st_row==1) 
		A=A(1:end_row,:);
	else
		A=A(1:(st_row-1),:);	
	end

	rets=A(2:end,:);
	for h=1:asset_n
		for j=2:length(A(:,1))
			rets(j-1,h) = (log(A(j,h))-log(A(j-1,h)))*freq; 
		end
	end
	mu = zeros(asset_n,1);
	for i=1:asset_n
		mu(i)=mean(rets(:,i));
	end
	rvar = cov(rets);		
	pvar=cov(p);
	p=p';
end
