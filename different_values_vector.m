function v=different_values_vector(m)
%this function generates a vector containing
%each value that is presented at least once in m

	l=numel(m);
	dv=different_values(m);
	m=reshape(m,1,l);
	v=zeros(1,dv);
	v(1)=m(1);
	h=1;
	for i=2:l
		flag=0;
		for j=1:h
			if v(j)==m(i)
				flag=1;
			end
		end
		if flag==0
			h=h+1;
			v(h)=m(i);
		end
		if h==dv
			i=l+1;
		end
	end
end
