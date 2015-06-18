function flag=criterion_1(init_of,of,theta,t)
%this function computes the first criterion of Consigli (2013)
	if(abs(init_of-of)>=theta(t))
		flag=1;
	else
		flag=0;
	end
end
