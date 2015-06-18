function rets=generateScenarioNoArb(bf,mu,rvar,gen_rets_file,tree)
% this function generate a tree with branching factor bf, generating returns from
% a multivariate normal with mean mu and variance rvar and saves them in the file gen_rets_file.
% The tree is one subtree after the other, imposing a mean to the returns in order 
% not to introduce arbtirages

%parameters computation
time = cumprod([1; bf]);
l=length(mu);
t=length(time);
TT=sum(time);
rets=zeros(l,TT);

round_coeff = 10^5;

vsum=cumsum(time);

it=0;
nit=0;
while it==0
    rets(:,1:vsum(2))=round(round_coeff*mvnrnd(mu,rvar,vsum(2))'/t)/round_coeff; %returns generatrion

    %preparing data in order to satisfy the criteria

    coeff = mean(mean(rets(:,2:vsum(2))));

    den = sum(rets(:,2:vsum(2))');

    for k=1:l
        rets(k,2:vsum(2))=rets(k,2:vsum(2))/den(k)*coeff;
    end

    %% generate path-independent prices
    for j=3:t
        nb = round(mvnrnd(mu,rvar,bf(j-1))'/t*round_coeff)/round_coeff;

        %preparing data in order to satisfy the criteria

        den = sum(nb');
        for k=1:l
            nb(k,:)=nb(k,:)/den(k)*coeff;
        end

        for k=1:bf(j-1)			%returns are inserted in order to respect
            pt = nb(:,k);		%the path independency hypothesis
            for h=0:(time(j-1)-1)
                rets(:,vsum(j-1)+k+bf(j-2)*h) = pt;
            end
        end
    end
    
    if nargin==5
        it = examineTreeForArbitrages(tree,rets);
    else
        rets = rets(:,2:end);
        it = detectArbitrageOptim(rets);
    end
    
    nit=nit+1;
end

if nargin>=4
    dlmwrite(gen_rets_file,rets);
end
