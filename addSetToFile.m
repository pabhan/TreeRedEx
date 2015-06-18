function addSetToFile(file,setName,value)
%this file add a set setName with values value to a 
%AMPL data file file 

l=length(value);
f=fopen(file,'a');

fprintf(f,'set %s := ',setName);    

for i=1:l
    fprintf(f,' %s',value{i});
end
fprintf(f,';\n');

fclose(f);

%s=strcat(strcat(setName,' added to'),strcat(' ',file));
%display(s);
end
