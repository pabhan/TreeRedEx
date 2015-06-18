function updateScenariosRets(gen_rets_file,temp_rets_file)
%this function update the returns in gen_rets_file using those stored
%in temp_rets_file
    rets=dlmread(temp_rets_file);
    
    dlmwrite(gen_rets_file,rets);
end
