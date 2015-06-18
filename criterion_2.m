function flag=criterion_2(rif,temp)
%this function computes the second criterion described in Consigli (2013)
	if(var(rif)>=var(temp))
		flag=1;
	else
		flag=0;
	end
end
