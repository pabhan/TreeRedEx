function n=different_values(v)
% this function counts the number of different elements in v
    ms = numel(v);
    if ms==0
        n=0;
    else
        v=reshape(v,1,ms);
        n=1;
        l=length(v);
        v=sort(v);
        for i=2:l
            if v(i)>v(i-1)
                n=n+1;
            end
        end
    end    
end
