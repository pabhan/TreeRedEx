function addParamToFile(file,paramName,set1,set2,value)
%this function adds the parameter paramNam, with values value 
%related to set1 and set2 to file

l1=length(set1);
l2=length(set2);

% value=rand(l1,l2);

f=fopen(file,'a');

if(l1==1 && ~iscell(set1))
    set1 = {set1};
end

if(l2==1 && ~iscell(set2))
    set2 = {set2};
end

if(l1==0)
    fprintf(f,'param %s := %f;\n',paramName,value);
else
    if(l2==0) 
        fprintf(f,'param %s := \n',paramName);
        if iscell(value)
            for i=1:l1
           	fprintf(f,'%s %s',set1{i},value{i});
                if(i==l1)
                    fprintf(f,';\n');
                else
                    fprintf(f,'\n');
                end
            end
        else
            for i=1:l1
                fprintf(f,'%s %f',set1{i},value(i));
                if(i==l1)
                    fprintf(f,';\n');
                else
                    fprintf(f,'\n');
                end
            end
        end
    else
        fprintf(f,'param %s (tr):\n',paramName);
        for i=1:(l1-1)
            fprintf(f,'%s ',set1{i});
        end
        fprintf(f,'%s :=\n',set1{l1});
        for i=1:l2
            fprintf(f,'%s',set2{i});
            for j=1:l1
                fprintf(f,' %f',value(j,i));
            end
            if(i==l2)
                fprintf(f,';\n');
            else
                fprintf(f,'\n');
            end
        end
    end
end

fclose(f);

end

    
