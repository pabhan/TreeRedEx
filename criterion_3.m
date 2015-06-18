function [flag pv] = criterion_3(fin_wealth,bm,a,pv)
%this function computes the third criterion described in Consigli (2013)
    if(length(bm)==1)
        diff=abs(quantile(fin_wealth,a)-bm);
    else
        diff=abs(quantile(fin_wealth,a)-quantile(bm,a));
    end
    if diff<=pv
        flag=1;
        pv=diff;
    else
        flag=0;
    end
end
