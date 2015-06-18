function red_rets=generateRedPbmRetsFile(tree,a1,a2,gen_rets_file,gen_rets_file_red)
% this function takes the returns in gen_rets_file that correspond to the portion of
% the tree delimited by the coordinates expressed in a1 and a2 and then saves them
% in gen_rets_file_red

	%two-step simplified version
	x1=a1(1);
	y1=a1(2);
	x2=a2(1);
	y2=a2(2);
	
	lv = length(tree(:,1));

	%initialization
	rets = dlmread(gen_rets_file);
	n=different_values(tree(x1:x2,y1:y2));

	red_rets = rets(:,1:n);

	%first set of values	
	n_in = different_values(tree(:,1:y1-1))+1;

	cv = tree(1,y1);
	rv = tree(x1,y1);
	counter=0;
	
	if(x1~=1)
		for i=2:lv
			if tree(i,y1)~=cv
				counter=counter+1;
				cv = tree(i,y1);
				if tree(i,y1)==rv
					n_in=n_in+counter;
					i=lv+2;
				end
			end
		end
	end
	red_rets(:,1) = rets(:,n_in);
	
	%second set of values
	n_in = different_values(tree(:,1:y2-1))+1;

	cv = tree(1,y2);
	rv = tree(x1,y2);
	counter=0;
	for i=2:x2
		if tree(i,y2)~=cv
			cv = tree(i,y2);
			counter=counter+1;
			if tree(i,y2)==rv
				n_in=n_in+counter;
				counter=0;
			end
		end
	end
	red_rets(:,2:end) = rets(:,n_in:n_in+counter);

	%save the rets in the prescribed file
	dlmwrite(gen_rets_file_red,red_rets);
			
end
