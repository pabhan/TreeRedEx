function sc=generateScenario(v,mu,rvar,file)
% this function generates and save multivariate normal returns	
	sc=retsGeneration(mu,rvar,cumprod([1; v]),v);
	
	if nargin==4
		dlmwrite(file,sc);
	end
end
