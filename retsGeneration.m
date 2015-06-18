function rets=retsGeneration(mu,rvar,time,bf)
% this function generates multivariate normal returns with mean
% mu and variance rvar for a tree with branching factor bf.
% the vector time describes the number of nodes in each time layer
	l=length(mu);
	t=length(time);
	TT=sum(time);
	rets=zeros(l,TT);
	if t==1
		rets=mvnrnd(mu,rvar,TT)/(length(bf)+1);
	else
		vsum=cumsum(time);
		rets(:,1:vsum(2))=mvnrnd(mu,rvar,vsum(2))'/4;
		%% generate path-independent prices
		for j=3:t
		 	for k=1:bf(j-1)
				pt = mvnrnd(mu,rvar,1)/4;
				for h=0:(time(j-1)-1)
					rets(:,vsum(j-1)+k+bf(j-2)*h) = pt;
				end
			end
		end
    end

end
