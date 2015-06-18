function A = load_matrix(filename,sep)
% this function loads a matrix from filename whose elements are separeted
% by delimiter
    fp=fopen(filename,'r');
    l=fgetl(fp);
    i=0;
    
    temp2=0;
    
    while (l~=-1)
        temp1=strread(l, '%f', 'delimiter', sep);
	i=i+1;
        if(temp2==0)
            temp2 = temp1';
        else
            temp2 = [temp2; temp1'];
        end
	l=fgetl(fp);
    end
    
    A=temp2;
    fclose(fp);
        
end
