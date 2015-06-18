function rets = loadGenRets(time,bf,gen_rets_file,asset_n,flag)
% this file constructs a path independent matrix of returns, loading
% already generated scenarios and inserting them in such a way that
% nodes belonging to the same time layer have the same descendants
    if nargin<5
        flag=0;
    end
    t=length(time);
	TT=sum(time);
	rets=ones(asset_n,TT);
	v=cumsum(time);
    
    if(flag==0)
        fp=fopen([gen_rets_file '_' int2str(length(time)-1) '.txt'],'r');
    else
        fp=fopen(gen_rets_file,'r');
    end
    
	for j=2:t
		c=fgetl(fp);
		d=str2num(c);
		pt=d(1:asset_n*bf(j-1))';
		pt=reshape(pt,[asset_n bf(j-1)]);
		np=repmat(pt,1,time(j-1));
		rets(:,v(j-1)+1:v(j)) = np;
	end
        
	fclose(fp);
end
