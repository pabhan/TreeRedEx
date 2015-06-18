function w=load_results(filename,delimiter)
%this function load a vector of values separated by delimiter
    f = fopen(filename,'r');
    str = fscanf(f,'%s');

    w = strread(str,'%f','delimiter',delimiter);
    
    fclose(f);
end
