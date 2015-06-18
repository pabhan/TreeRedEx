function p = pricesGeneration(s0,mu,rvar,time,bf)
% generate random prices - assuming they are distributed according to a
% log-normal distribution and they are path indepedent
% -s0 is the vector starting prices
% -mu is the vector of expected returns (i.e. sampled mean)
% -rvar is the vector of vars (i.e. sampled vars)
% -bf is the branching factor vector
% -time is the vector indicating the number of prices to be generated for
% each time step (basically the way the tree structure is accounted for)
%% parameters
	l=length(mu);
	t=length(time);	
	TT=sum(time);
	p=zeros(l,TT);
	timestep = 1/t;
	if t==1
		for h=1:TT
			p(:,h)=s0.*exp(mvnrnd(mu,rvar,1)*timestep)';
		end
	else
		vsum=cumsum(time);
		p(:,1)=s0;
		for k=2:vsum(2)
			p(:,k)=s0.*exp(mvnrnd(mu,rvar,1)*timestep)';
		end
		%% generate path-independent prices
		for j=3:t
		 	for k=1:bf(j-1)
				pt = s0.*exp(mvnrnd(mu,rvar,1)*timestep)';
				for h=0:(time(j-1)-1)
					p(:,vsum(j-1)+k+bf(j-2)*h) = pt;
				end
			end
		end
    end
end
