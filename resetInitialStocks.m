function resetInitialStocks(stock_file,x)
%resets the stock file to the initial value x
asset_n=length(x);
f=fopen(stock_file,'w');
for i=1:asset_n
	fprintf(f,strcat(num2str(x(i)),',')); 
end
fclose(f);
end
