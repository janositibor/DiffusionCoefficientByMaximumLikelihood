function output = Mobility_MSDFunction(x_withnulls,y_withnulls,framelength)
	num_of_fitted_points=3;
	dim=2;
	num_of_rows=size(x_withnulls,2);
	if(num_of_rows>4)
		num_of_steps=num_of_rows-1;
		for delta=1:num_of_steps
			delta=delta;
			Msd(delta)=0;
			for j=1:num_of_steps+1-delta
				j=j;
				Msd(delta)=Msd(delta)+((x_withnulls(j)-x_withnulls(j+delta))^2+(y_withnulls(j)-y_withnulls(j+delta))^2);
			end	
			Msd(delta)=(Msd(delta))/(num_of_steps+1-delta);
		end
		tempx=(1:num_of_fitted_points)*framelength;
		tempy=Msd(1:num_of_fitted_points);
		fit=polyfit(tempx,tempy,1);
		
		output=[fit(1)/(2*dim) fit(2)];	
	else
		output=[0 0];
	end
end